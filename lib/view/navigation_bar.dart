import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:dinmajur_customer/configs/services/nointernet_connectivity_service/nointernet_connectivity_service.dart';
import 'package:dinmajur_customer/configs/services/one_signal_push_notification/one_signal_pushnotification_service.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';
import 'package:dinmajur_customer/view/screens/cart/cart_screen.dart';
import 'package:dinmajur_customer/view/screens/draft/draft_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/order/order_screen_new.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  final int orderTabIndex;
  const NavigationScreen({super.key, this.initialIndex = 0, this.orderTabIndex = 0});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with WidgetsBindingObserver {
  // ─── Navigation ──────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  bool _cartBarDismissed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;

  // ─── Upgrade check guard ── Prevents the upgrade dialog from showing more than once per session.
  bool _upgradeChecked = false;
  final List<String> _icons = [
    "assets/images/navBar/navbar_new/home.svg",
    "", // cart — rendered with Material icon
    "assets/images/navBar/navbar_new/order.svg",
    "assets/images/navBar/navbar_new/support.svg",
  ];
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pages = [
      HomeScreen(scaffoldKey: _scaffoldKey),
      CartScreen(onBack: () => setState(() => _currentIndex = 0)),
      OrderScreen(initialTabIndex: widget.orderTabIndex),
      DraftScreen(),
    ];
    _currentIndex = widget.initialIndex;

    WakelockPlus.enable();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initServices();
      ConnectivityMonitorService().start(
        onReconnected: () {
          // Optional: nudge socket/SSE back in sync when internet returns.
          if (!mounted) return;
          context.read<SocketManager>().handleAppResume();
          _ensureSSERunning();
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();

    // Stop watching connectivity when NavigationScreen is torn down
    // (e.g. user logs out and goes back to splash/login).
    ConnectivityMonitorService().stop();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSystemUIColors();
    _labels = [AppLocalizations.of(context)!.home, 'Cart', AppLocalizations.of(context)!.order, 'Need Help?'];
  }

  // ══════════════════════════════ APP LIFECYCLE — pause / resume═════════════════════════════════════════════
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      default:
        break;
    }
  }

  void _onAppPaused() {
    WakelockPlus.disable();
  }

  Future<void> _onAppResumed() async {
    if (!mounted) return;
    WakelockPlus.enable();

    // Let socket handle its own reconnect logic.
    context.read<SocketManager>().handleAppResume();

    // Ensure SSE is running.
    await _ensureSSERunning();
  }

  // ═══════════════════════════════════ INIT SERVICES — called once after first mount════════════════════════════════════════
  Future<void> _initServices() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken') ?? '';
    final String userId = prefs.getString('userId') ?? '';
    if (accessToken.isEmpty) return;

    // ── OneSignal ─────────────────────────────────────────────────────
    if (userId.isNotEmpty) {
      try {
        await context.read<OneSignalNotificationService>().loginUser(userId);
      } catch (e) {
      }
    }

    // ── Socket ────────────────────────────────────────────────────────
    final socket = context.read<SocketManager>();
    socket.onConnected = _onSocketConnected;

    if (socket.isConnected) {
      _onSocketConnected();
    } else {
      await socket.connect(accessToken);
    }

    // ── SSE ───────────────────────────────────────────────────────────
    await _ensureSSERunning();
  }

  // ═══════════════════════════════SOCKET — callback only, no dialog logic here════════════════════════════════════════════
  void _onSocketConnected() {
    if (!mounted) return;
  }

  // ══════════════════════════════════SSE═════════════════════════════════════════
  Future<void> _ensureSSERunning() async {
    if (!mounted) return;
    try {
      final sseService = context.read<SSENotificationService>();
      final notificationVM = context.read<NotificationCountViewModel>();
      final runningOrderVM = context.read<RunningOrderCountViewModel>();

      if (!sseService.isListening) {
        await sseService.startListening();
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (!notificationVM.isInitialized) {
        notificationVM.initializeCountListener(sseService.notificationCountStream, sseService.notificationIncrementStream);
      }
      notificationVM.setInitialCount(sseService.currentCount);

      if (!runningOrderVM.isInitialized) {
        runningOrderVM.initializeCountListener(sseService.runningOrderCountStream);
      }
      runningOrderVM.setInitialCount(sseService.currentRunningOrderCount);

      // Fetch running orders from API so badge shows even when SSE count is 0
      final ordersVM = context.read<RunningOrdersViewModel>();
      await ordersVM.fetchRunningOrdersGetDataApi();
      if (mounted) {
        final count = ordersVM.runningAllOrders.length;
        if (count > runningOrderVM.runningOrderCount) {
          runningOrderVM.setInitialCount(count);
        }
      }
    } catch (e) {
    }
  }

  // ══════════════════════════════════════HELPERS═════════════════════════════════════
  void _syncSystemUIColors() {
    final bool isDark = context.read<ThemeProvider>().isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
        statusBarColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
      ),
    );
  }

  // ═════════════════════════════════════UPGRADE CHECK — runs ONCE per session══════════════════════════════════════
  Future<void> _checkForUpgrade() async {
    if (_upgradeChecked) return;
    _upgradeChecked = true;

    final upgrader = Upgrader(countryCode: 'BD', languageCode: 'en');
    await upgrader.initialize();
    if (!mounted) return;

    if (upgrader.shouldDisplayUpgrade()) {
      _showUpgradeDialog(upgrader);
    }
  }

  void _showUpgradeDialog(Upgrader upgrader) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.containerBackground(context),
        insetPadding: EdgeInsets.all(h * 0.02),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Icon(FontAwesomeIcons.cloudArrowDown, color: AppColors.button(context), size: 50),
              const SizedBox(height: 10),
              Text('Update Available', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
              const SizedBox(height: 20),
              Text('A new version is available!', textAlign: TextAlign.center, style: AppTextStyles.textSize14(context)),
              const SizedBox(height: 5),
              Text(
                'Version ${upgrader.currentAppStoreVersion ?? 'Unknown'} is now available. '
                'You are using version ${upgrader.currentInstalledVersion ?? 'Unknown'}.',
                textAlign: TextAlign.center,
                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await upgrader.sendUserToAppStore();
                },
                child: Container(
                  width: w * 0.5,
                  height: 45,
                  decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                  child: Center(
                    child: Text(
                      'Update Now',
                      style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════SUPPORT / WHATSAPP═════════════════════════════════════════
  void _showContactDropup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(2)),
              ),
              Text('Need Help?', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              const SizedBox(height: 16),
              _contactOption(
                ctx: ctx,
                icon: Icons.chat,
                label: 'WhatsApp',
                subtitle: 'Chat with us on WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _openWhatsApp();
                },
              ),
              const SizedBox(height: 10),
              _contactOption(
                ctx: ctx,
                icon: Icons.phone,
                label: 'Call Us',
                subtitle: '01929-600600',
                color: AppColors.button(context),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _callSupport();
                },
              ),
              const SizedBox(height: 10),
              _contactOption(
                ctx: ctx,
                icon: Icons.message_outlined,
                label: 'Leave a Text',
                subtitle: 'Send us a message',
                color: AppColors.subtitle(context),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, RoutesName.support);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _contactOption({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: AppColors.subtitle(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    const String phone = '8801929600600';
    const String message = 'Hello! I need assistance with Dinmajur platform services.';
    final Uri uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showWhatsAppNotInstalledDialog();
      }
    } catch (_) {
      Utils.flushBarErrorMessage('WhatsApp not available', context);
      await _callSupport();
    }
  }

  void _showWhatsAppNotInstalledDialog() {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.containerBackground(context),
        contentPadding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
        insetPadding: EdgeInsets.symmetric(horizontal: w * 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.phone_android, color: AppColors.button(context), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text('WhatsApp Not Found', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text('WhatsApp is not installed. Would you like to call our support team instead?', style: AppTextStyles.textSize14(context)),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _callSupport();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: h * 0.014),
                  decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 18, color: AppColors.whiteColor),
                      const SizedBox(width: 8),
                      Text(
                        'Call Support (01929-600600)',
                        style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: h * 0.012),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: Center(
                    child: Text('Cancel', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callSupport() async {
    final Uri uri = Uri.parse('tel:+8801929600600');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Utils.flushBarErrorMessage('Unable to open phone dialer', context);
      }
    } catch (_) {
      Utils.flushBarErrorMessage('Unable to make phone call', context);
    }
  }

  Widget _buildCartBar(BuildContext context, GlobalCartProvider cart) {
    final int items = cart.itemCount;
    final int categories = cart.serviceCarts.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cart icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.appBackground(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Icon(Icons.shopping_cart_outlined, size: 20, color: AppColors.textPrimary(context)),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$items ${items == 1 ? 'item' : 'items'} in cart',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w700),
                ),
                Text(
                  'From $categories ${categories == 1 ? 'category' : 'categories'}',
                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                ),
              ],
            ),
          ),
          // View button
          GestureDetector(
            onTap: () => setState(() {
              _currentIndex = 1;
              _cartBarDismissed = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.button(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('View', style: AppTextStyles.textSize13(context, weight: FontWeight.w700, color: AppColors.whiteColor)),
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          GestureDetector(
            onTap: () => setState(() => _cartBarDismissed = true),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
                color: AppColors.appBackground(context),
              ),
              child: Icon(Icons.close, size: 16, color: AppColors.subtitle(context)),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _lastBackPressed;
  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeProvider>().isDarkMode;
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpgrade());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (_currentIndex == 0 && _scaffoldKey.currentState?.isDrawerOpen == true) {
            _scaffoldKey.currentState!.closeDrawer();
            return;
          }

          final now = DateTime.now();
          final isDoubleBack = _lastBackPressed != null && now.difference(_lastBackPressed!) < const Duration(seconds: 2);

          if (isDoubleBack) {
            SystemNavigator.pop();
          } else {
            _lastBackPressed = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text('Double tap to exit', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.appBackground(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.containerBackground(context),
          body: _pages[_currentIndex],
          bottomNavigationBar: Consumer<GlobalCartProvider>(
            builder: (context, cart, _) {
              final showCartBar = cart.hasItems && !_cartBarDismissed && _currentIndex != 1;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCartBar) _buildCartBar(context, cart),
                  SafeArea(
                    child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.globalBlackWhite(context),
                  boxShadow: [
                    isDark
                        ? BoxShadow(color: Colors.white12.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -2))
                        : const BoxShadow(color: Colors.white10, blurRadius: 10, offset: Offset(0, -2)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Divider(color: AppColors.border(context), height: 1),
                    Row(
                      children: List.generate(_icons.length, (index) {
                        final bool isSelected = _currentIndex == index;
                        final bool isCartTab = index == 1;
                        final bool isOrderTab = index == 2;
                        final bool isCallUsTab = index == 3;

                        Widget iconWidget;
                        if (isCartTab) {
                          iconWidget = Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                                size: 20,
                                color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                              ),
                              if (cart.hasItems)
                                Positioned(
                                  right: -6,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.globalBlackWhite(context), width: 1),
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else if (isOrderTab) {
                          iconWidget = Consumer2<RunningOrderCountViewModel, RunningOrdersViewModel>(
                            builder: (context, sseVm, ordersVm, _) {
                              final count = sseVm.runningOrderCount > ordersVm.runningAllOrders.length
                                  ? sseVm.runningOrderCount
                                  : ordersVm.runningAllOrders.length;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SvgPicture.asset(
                                    _icons[index],
                                    width: 18,
                                    height: 18,
                                    color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                    semanticsLabel: _labels[index],
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: -6,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.globalBlackWhite(context), width: 1),
                                        ),
                                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                        child: Text(
                                          count > 9 ? '9+' : '$count',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        } else {
                          iconWidget = SvgPicture.asset(
                            _icons[index],
                            width: 18,
                            height: 18,
                            color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                            semanticsLabel: _labels[index],
                          );
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (index == 0 && _currentIndex == 0 && _scaffoldKey.currentState?.isDrawerOpen == true) {
                                _scaffoldKey.currentState!.closeDrawer();
                              } else if (isCallUsTab) {
                                _showContactDropup();
                              } else {
                                setState(() => _currentIndex = index);
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  iconWidget,
                                  const SizedBox(height: 6),
                                  Text(
                                    _labels[index],
                                    style: AppTextStyles.textSize11(
                                      context,
                                      weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Container(height: 1),
                  ],
                ),
              ),
            ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
