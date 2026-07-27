import 'package:app_links/app_links.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/referral_repository/referral_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';






/// Captures a referral code from an incoming referral link
/// (https://customer.dinmajur.com/ref/CODE). Referral codes are never
/// applied at registration time — only once there's a real, logged-in
/// account, matching the backend's post-registration-only apply rule:
///
/// - Link opened while already logged in → applied immediately (this can
///   happen any time after the app is installed).
/// - Link opened before the person has an account → code is stashed
///   locally, and [tryApplyPendingCodeAfterLogin] (called right after OTP
///   verification succeeds) applies it automatically the moment they're
///   logged in — no manual entry required.
/// - There is no manual "enter a code later" fallback: a referral code can
///   only ever be entered once, in NameEntryDialog, right after
///   registration. If this auto-apply path fails silently (link opened too
///   late, already applied, etc.), the person simply won't have a code —
///   they can still view and share their own via the Referral screen.
///
/// Domain/App Links verification (assetlinks.json, Play Console signing) is
/// intentionally not wired up yet — see the referral system plan notes.
/// This service only depends on the app receiving *some* URI, whichever
/// mechanism ends up delivering it once that infra is in place.
class ReferralDeepLinkService {
  static const _pendingCodeKey = 'pending_referral_code';

  static AppLinks? _appLinks;

  static Future<void> initialize() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) await _handleUri(initialUri);
    } catch (_) {
      // No initial link, or platform doesn't support it — non-fatal.
    }

    _appLinks!.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  static Future<void> _handleUri(Uri uri) async {
    final code = _extractReferralCode(uri);
    if (code == null || code.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      // Not logged in yet — stash it, applied automatically once they are.
      await prefs.setString(_pendingCodeKey, code);
      return;
    }

    await _applyCode(code);
  }

  /// Call once, right after OTP verification succeeds and the access token
  /// is persisted — applies any referral code captured before the person
  /// had an account. Safe to call unconditionally (no-op if nothing pending).
  static Future<void> tryApplyPendingCodeAfterLogin({BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_pendingCodeKey);
    if (code == null || code.isEmpty) return;

    await prefs.remove(_pendingCodeKey);
    await _applyCode(code, context: context);
  }

  static Future<void> _applyCode(String code, {BuildContext? context}) async {
    // Safe to attempt even if ineligible (already applied / already
    // ordered) — the backend rejects those cases without side effects, so
    // failures here are expected and silently ignored.
    try {
      final value = await ReferralRepository().applyReferralCodeApi(code, source: 'DEEP_LINK');
      final couponCode = value['data']?['coupon']?['code'];
      final ctx = context ?? NavigationService.navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Utils.flushBarSuccessMessage(
          couponCode != null ? 'Referral code applied — you got a coupon: $couponCode' : 'Referral code applied successfully',
          ctx,
        );
      }
    } catch (_) {
      // Expected for ineligible cases — no user-facing error.
    }
  }

  static String? _extractReferralCode(Uri uri) {
    // https://customer.dinmajur.com/ref/CODE
    final segments = uri.pathSegments;
    final refIndex = segments.indexOf('ref');
    if (refIndex != -1 && refIndex + 1 < segments.length) {
      return segments[refIndex + 1].trim().toUpperCase();
    }
    // Fallback: ?ref=CODE or ?referralCode=CODE
    final query = uri.queryParameters['ref'] ?? uri.queryParameters['referralCode'];
    return query?.trim().toUpperCase();
  }
}
