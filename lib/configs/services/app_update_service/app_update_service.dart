import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Wraps Google Play's In-App Update API (Android only) so an available
/// update can be downloaded and installed with a single tap, instead of
/// sending the user to the Play Store to find and tap "Update" themselves.
///
/// - Immediate update: Play shows its own full-screen UI; one tap and Play
///   handles download + install + app restart automatically.
/// - Flexible update: downloads silently in the background, then a single
///   "Restart" completes the install.
class AppUpdateService {
  /// Returns true if this fully handled the update check (no update found,
  /// or an update flow was started) — callers should skip their own
  /// store-redirect dialog in that case. Returns false on iOS, or when the
  /// Play in-app update API is unavailable (sideloaded/debug build, Play
  /// services missing, etc.), so callers can fall back to `upgrader`.
  static Future<bool> checkAndUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return true;
      }

      if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }

      if (info.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: in-app update unavailable, falling back to store redirect — $e');
      }
      return false;
    }
  }
}
