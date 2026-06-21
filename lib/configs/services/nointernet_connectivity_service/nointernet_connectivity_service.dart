import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';

class NoConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.wifi_exclamationmark, size: 90, color: CupertinoColors.systemRed),
                const SizedBox(height: 24),
                 Text(
                  'Connection Lost',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textSize22(context,weight: FontWeight.w600)
                ),
                const SizedBox(height: 12),
                const Text(
                  'You seem to be offline. Check your connection to stay updated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
                  child: CupertinoButton(
                    color: AppColors.button(context),
                    borderRadius: BorderRadius.circular(100),
                    onPressed: onRetry,
                    child:  Text('Retry', style: AppTextStyles.textSize16(context, color: AppColors.whiteColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 2) SERVICE — watches connectivity, shows/hides the screen above
// ═══════════════════════════════════════════════════════════════════

class ConnectivityMonitorService {
  static final ConnectivityMonitorService _instance = ConnectivityMonitorService._internal();
  factory ConnectivityMonitorService() => _instance;
  ConnectivityMonitorService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounceTimer;

  bool _isNoConnectionScreenShown = false;
  bool _isMonitoring = false;

  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.createInstance(
    addresses: [
      AddressCheckOption(uri: Uri.parse('https://one.one.one.one')),
      AddressCheckOption(uri: Uri.parse('https://www.google.com')),
    ],
  );

  VoidCallback? onReconnected;
  VoidCallback? onDisconnected;

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
    if (_isNoConnectionScreenShown) return;

    final navCtx = NavigationService.navigatorKey.currentContext;
    if (navCtx == null) return;

    _isNoConnectionScreenShown = true;
    onDisconnected?.call();

    Navigator.of(navCtx, rootNavigator: true)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => NoConnectionScreen(
              onRetry: () async {
                await checkNow();
              },
            ),
          ),
        )
        .then((_) {
          _isNoConnectionScreenShown = false;
        });
  }

  void _handleReconnected() {
    if (!_isNoConnectionScreenShown) return;

    final navCtx = NavigationService.navigatorKey.currentContext;
    if (navCtx != null && Navigator.canPop(navCtx)) {
      Navigator.of(navCtx, rootNavigator: true).pop();
    }
    _isNoConnectionScreenShown = false;

    onReconnected?.call();
  }
}
