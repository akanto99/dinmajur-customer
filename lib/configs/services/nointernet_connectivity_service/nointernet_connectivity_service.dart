import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';

class NoConnectionDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionDialog({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.containerBackground(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon in a soft circle background
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textFieldFill(context),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.wifi_exclamationmark,
                        size: 48,
                        color: AppColors.subtitle(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Connection Lost',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'You seem to be offline. Check your connection to stay updated.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border(context)),
            // Flat text-only action — no colored button, matches reference UI
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                onTap: onRetry,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'TRY AGAIN',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


///SERVICE —

class ConnectivityMonitorService {
  static final ConnectivityMonitorService _instance = ConnectivityMonitorService._internal();
  factory ConnectivityMonitorService() => _instance;
  ConnectivityMonitorService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounceTimer;

  bool _isNoConnectionDialogShown = false;
  bool _isMonitoring = false;

  /// Tracks the last known REAL internet state, so we only react on an
  /// actual transition (disconnected -> connected), not on every single
  /// connectivity_plus event (which can fire even with no real change).
  /// Starts as `true` — assumes the app is online when monitoring starts
  /// (it just loaded past splash/login), so the very first event doesn't
  /// spuriously trigger reconnect listeners that screens already handle
  /// themselves in initState().
  bool? _lastKnownHasInternet = true;

  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.createInstance(
    addresses: [
      AddressCheckOption(uri: Uri.parse('https://one.one.one.one')),
      AddressCheckOption(uri: Uri.parse('https://www.google.com')),
    ],
  );

  VoidCallback? onReconnected;
  VoidCallback? onDisconnected;

  // ── Multiple reconnect subscribers ──────────────────────────────
  // Any screen (Home, TrackOrder, etc.) can register a refresh callback
  // while it's mounted. When internet comes back, ALL currently
  // registered callbacks fire — so whichever screen the user happens
  // to be on at that moment reloads its own data automatically.
  final List<VoidCallback> _reconnectListeners = [];

  /// Call in a screen's initState(). Safe to call multiple times with
  /// the same callback — deduplicated.
  void addReconnectListener(VoidCallback cb) {
    if (!_reconnectListeners.contains(cb)) {
      _reconnectListeners.add(cb);
    }
  }

  /// Call in a screen's dispose() — IMPORTANT, otherwise you'll leak
  /// callbacks referencing disposed widgets.
  void removeReconnectListener(VoidCallback cb) {
    _reconnectListeners.remove(cb);
  }

  void start({VoidCallback? onReconnected, VoidCallback? onDisconnected}) {
    this.onReconnected = onReconnected ?? this.onReconnected;
    this.onDisconnected = onDisconnected ?? this.onDisconnected;

    if (_isMonitoring) return;
    _isMonitoring = true;

    _connectivitySub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
        _verifyAndReact(results);
      });
    });
  }

  void stop() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _isMonitoring = false;
    _lastKnownHasInternet = true;
  }

  void dispose() {
    stop();
    _internetChecker.dispose();
  }

  Future<void> _verifyAndReact(List<ConnectivityResult> results) async {
    final bool hasRadio = !results.contains(ConnectivityResult.none) && results.isNotEmpty;

    bool hasRealInternet = false;
    if (hasRadio) {
      try {
        hasRealInternet = await _internetChecker.hasConnection;
      } catch (_) {
        hasRealInternet = false;
      }
    }

    // Only act if the real state actually changed since last time.
    if (_lastKnownHasInternet == hasRealInternet) return;
    _lastKnownHasInternet = hasRealInternet;

    if (!hasRealInternet) {
      _handleDisconnected();
    } else {
      _handleReconnected();
    }
  }

  Future<void> checkNow() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      await _verifyAndReact(results);
    } catch (_) {
      _handleDisconnected();
    }
  }

  void _handleDisconnected() {
    if (_isNoConnectionDialogShown) return;

    final navCtx = NavigationService.navigatorKey.currentContext;
    if (navCtx == null) return;

    _isNoConnectionDialogShown = true;
    onDisconnected?.call();

    showDialog<void>(
      context: navCtx,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(navCtx),
      useRootNavigator: true,
      builder: (_) => NoConnectionDialog(
        onRetry: () async {
          await checkNow();
        },
      ),
    ).then((_) {
      _isNoConnectionDialogShown = false;
    });
  }

  void _handleReconnected() {
    final bool wasShowingNoConnectionDialog = _isNoConnectionDialogShown;

    if (wasShowingNoConnectionDialog) {
      final navCtx = NavigationService.navigatorKey.currentContext;
      if (navCtx != null && Navigator.canPop(navCtx)) {
        Navigator.of(navCtx, rootNavigator: true).pop();
      }
      _isNoConnectionDialogShown = false;
    }

    onReconnected?.call();

    // Fire every currently-registered screen's refresh callback —
    // whichever screen the user is on right now reloads its own data.
    for (final cb in List<VoidCallback>.from(_reconnectListeners)) {
      cb();
    }
  }
}
