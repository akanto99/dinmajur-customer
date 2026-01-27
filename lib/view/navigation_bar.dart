import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/screens/draft/draft_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/order/order_screen_new.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  // ✅ Network monitoring
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  bool _isReconnecting = false;
  bool _isAlertSet = false;

  final List<String> icons = [
    "assets/images/navBar/navbar_new/home.svg",
    "assets/images/navBar/navbar_new/offers.svg",
    "assets/images/navBar/navbar_new/order.svg",
    "assets/images/navBar/navbar_new/support.svg",
  ];

  late List<String> labels;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pages = [HomeScreen(scaffoldKey: _key), OffersScreen(), OrderScreen(), DraftScreen()];
    _currentIndex = widget.initialIndex;

    _initializeNetworkMonitoring();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIColors();

    labels = [
      AppLocalizations.of(context)!.home,
      AppLocalizations.of(context)!.offers,
      AppLocalizations.of(context)!.order,
      AppLocalizations.of(context)!.callus,
    ];
  }

  // ✅ APP LIFECYCLE MANAGEMENT
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("🔌 NavigationScreen: App resumed - checking connections");
      _handleAppResumed();
      WakelockPlus.enable();
    } else if (state == AppLifecycleState.paused) {
      WakelockPlus.disable();
      print("🔌 NavigationScreen: App paused");
    }
  }

  // ✅ HANDLE APP RESUME
  Future<void> _handleAppResumed() async {
    if (_isReconnecting) return;

    try {
      _isReconnecting = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        print("🔌 NavigationScreen: No access token found, skipping reconnection");
        _isReconnecting = false;
        return;
      }

      await Future.delayed(Duration(milliseconds: 500));

      bool hasInternet = await InternetConnectionChecker().hasConnection;
      if (!hasInternet) {
        print("🔌 NavigationScreen: No internet connection, cannot reconnect");
        _isReconnecting = false;
        return;
      }

      print("🔌 NavigationScreen: Internet available, checking connections");

      await _reconnectSocketIfNeeded(accessToken);
      await _reconnectSSEIfNeeded();

      _isReconnecting = false;
    } catch (e) {
      print("🔌 NavigationScreen: Error handling app resume - $e");
      _isReconnecting = false;
    }
  }

  // ✅ Reconnect Socket.IO if disconnected
  Future<void> _reconnectSocketIfNeeded(String accessToken) async {
    try {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      if (!socketProvider.isConnected) {
        print("🔌 NavigationScreen: Socket disconnected, reconnecting...");

        await socketProvider.disconnect();
        await Future.delayed(Duration(milliseconds: 300));
        await socketProvider.connectWithToken(accessToken: accessToken);

        await Future.delayed(Duration(milliseconds: 1000));

        if (socketProvider.isConnected) {
          print("🔌 NavigationScreen: ✅ Socket reconnected successfully");
        } else {
          print("🔌 NavigationScreen: ⚠️ Attempting auto-reconnect");
          await socketProvider.autoReconnect();
        }
      } else {
        print("🔌 NavigationScreen: Socket already connected");
      }
    } catch (e) {
      print("🔌 NavigationScreen: Error reconnecting socket - $e");
    }
  }

  // ✅ Reconnect SSE if disconnected
  Future<void> _reconnectSSEIfNeeded() async {
    try {
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final notificationCountViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
      final runningOrderCountViewModel = Provider.of<RunningOrderCountViewModel>(context, listen: false);

      if (!sseService.isListening) {
        print("🔔 NavigationScreen: SSE disconnected, reconnecting...");

        await sseService.startListening();
        await Future.delayed(Duration(milliseconds: 500));

        if (!notificationCountViewModel.isInitialized) {
          notificationCountViewModel.initializeCountListener(
            sseService.notificationCountStream,
            sseService.notificationIncrementStream,
          );
        }
        notificationCountViewModel.setInitialCount(sseService.currentCount);

        if (!runningOrderCountViewModel.isInitialized) {
          runningOrderCountViewModel.initializeCountListener(sseService.runningOrderCountStream);
        }
        runningOrderCountViewModel.setInitialCount(sseService.currentRunningOrderCount);

        print("🔔 NavigationScreen: ✅ SSE reconnected successfully");
      } else {
        print("🔔 NavigationScreen: SSE already connected");
      }
    } catch (e) {
      print("🔔 NavigationScreen: Error reconnecting SSE - $e");
    }
  }

  // ✅ INITIALIZE NETWORK MONITORING
  void _initializeNetworkMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> result) async {
        await _handleConnectivityChange(result);
      },
      onError: (error) {
        print("🔌 NavigationScreen: Connectivity listener error: $error");
      },
    );
  }

  // ✅ HANDLE CONNECTIVITY CHANGES
  Future<void> _handleConnectivityChange(List<ConnectivityResult> result) async {
    if (_isReconnecting) return;

    bool hasConnectivity = !result.contains(ConnectivityResult.none) && result.isNotEmpty;

    await Future.delayed(Duration(milliseconds: 500));
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    bool hasConnection = hasConnectivity && hasInternet;

    if (!hasConnection && !_isAlertSet) {
      // ✅ CONNECTION LOST
      print("🔌 NavigationScreen: No connection detected, disconnecting services");

      try {
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);
        await socketProvider.disconnect();
        print("🔌 NavigationScreen: Socket disconnected due to network loss");

        final sseService = Provider.of<SSENotificationService>(context, listen: false);
        await sseService.stopListening();
        print("🔔 NavigationScreen: SSE disconnected due to network loss");
      } catch (e) {
        print("🔌 NavigationScreen: Error disconnecting services: $e");
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showNoConnectionDialog();
      });
      setState(() => _isAlertSet = true);

    } else if (hasConnection && _isAlertSet) {
      // ✅ CONNECTION RESTORED
      print("🔌 NavigationScreen: Connection restored, closing dialog and reconnecting services");

      if (NavigationService.navigatorKey.currentContext != null) {
        Navigator.of(NavigationService.navigatorKey.currentContext!, rootNavigator: true).pop();
      }

      setState(() => _isAlertSet = false);
      await _reconnectAllServices();
    }
  }

  // ✅ SHOW NO CONNECTION DIALOG
  void _showNoConnectionDialog() {
    if (!mounted) return;

    showCupertinoDialog<String>(
      context: NavigationService.navigatorKey.currentContext ?? context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: Column(
          children: [
            Icon(CupertinoIcons.wifi_exclamationmark, size: 40, color: CupertinoColors.systemRed),
            SizedBox(height: 10),
            Text('Connection Lost', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'You seem to be offline. Check your connection to stay updated.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isAlertSet = false);

              List<ConnectivityResult> result = await _connectivity.checkConnectivity();
              bool hasInternet = await InternetConnectionChecker().hasConnection;
              bool hasConnection = !result.contains(ConnectivityResult.none) && result.isNotEmpty && hasInternet;

              if (hasConnection) {
                print("🔌 NavigationScreen: Retry - Connection restored");
                await _reconnectAllServices();
              } else {
                print("🔌 NavigationScreen: Retry - Still no connection");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _showNoConnectionDialog();
                    setState(() => _isAlertSet = true);
                  }
                });
              }
            },
            child: Text('Retry', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✅ Reconnect both Socket.IO and SSE
  Future<void> _reconnectAllServices() async {
    if (_isReconnecting) return;

    try {
      _isReconnecting = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        print("🔌 NavigationScreen: No access token found for reconnection");
        _isReconnecting = false;
        return;
      }

      print("🔌 NavigationScreen: Reconnecting all services");

      // ✅ Reconnect Socket.IO
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      await socketProvider.connectWithToken(accessToken: accessToken);

      await Future.delayed(Duration(milliseconds: 1000));

      if (!socketProvider.isConnected) {
        print("🔌 NavigationScreen: ⚠️ Attempting auto-reconnect...");
        await socketProvider.autoReconnect();
      }

      // ✅ Reconnect SSE
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final notificationCountViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
      final runningOrderCountViewModel = Provider.of<RunningOrderCountViewModel>(context, listen: false);

      await sseService.startListening();
      await Future.delayed(Duration(milliseconds: 500));

      if (!notificationCountViewModel.isInitialized) {
        notificationCountViewModel.initializeCountListener(
          sseService.notificationCountStream,
          sseService.notificationIncrementStream,
        );
      }
      notificationCountViewModel.setInitialCount(sseService.currentCount);

      if (!runningOrderCountViewModel.isInitialized) {
        runningOrderCountViewModel.initializeCountListener(sseService.runningOrderCountStream);
      }
      runningOrderCountViewModel.setInitialCount(sseService.currentRunningOrderCount);

      print("🔔 NavigationScreen: ✅ Services reconnected successfully");

      _isReconnecting = false;
    } catch (e) {
      print("🔌 NavigationScreen: Service reconnection failed - $e");

      try {
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);
        await socketProvider.autoReconnect();
      } catch (retryError) {
        print("🔌 NavigationScreen: Final reconnection attempt failed - $retryError");
      }

      _isReconnecting = false;
    }
  }

  void _setSystemUIColors() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpgrade(context));

          return WillPopScope(
            onWillPop: () async {
              // Handle drawer close if open
              if (_currentIndex == 0 && _key.currentState?.isDrawerOpen == true) {
                _key.currentState!.closeDrawer();
                return false;
              }

              // Show exit confirmation dialog
              final value = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.containerBackground(context),
                    contentPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
                    insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.1, vertical: screenHeight * 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    content: Text("Are you sure you want to exit?", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              width: screenWidth * 0.2,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                              decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(5)),
                              child: Center(child: Text('No', style: AppTextStyles.textSize12(context, weight: FontWeight.w600))),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          GestureDetector(
                            onTap: () => SystemNavigator.pop(),
                            child: Container(
                              width: screenWidth * 0.2,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                              decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text('Yes', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.whiteColor)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
              return value ?? false;
            },
            child: Scaffold(
              backgroundColor: AppColors.containerBackground(context),
              body: _pages[_currentIndex],
              bottomNavigationBar: SafeArea(
                child: Container(
                  height: 60,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.globalBlackWhite(context),
                    boxShadow: [
                      Theme.of(context).brightness == Brightness.dark
                          ? BoxShadow(color: Colors.white12.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -2))
                          : BoxShadow(color: Colors.white10, blurRadius: 10, offset: const Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Divider(color: AppColors.border(context), height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(icons.length, (index) {
                          bool isSelected = _currentIndex == index;
                          bool isOrderTab = index == 2;

                          return GestureDetector(
                            onTap: () async {
                              if (index == 0 && _currentIndex == 0 && _key.currentState?.isDrawerOpen == true) {
                                _key.currentState!.closeDrawer();
                              } else if (index == 3) {
                                // Support tab - Open WhatsApp (don't change current index)
                                await _openWhatsAppSupport();
                              } else {
                                setState(() => _currentIndex = index);
                              }
                            },
                            child: Container(
                              width: screenWidth * 0.2,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isOrderTab
                                      ? Consumer<RunningOrderCountViewModel>(
                                    builder: (context, orderCountViewModel, _) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          SvgPicture.asset(
                                            icons[index],
                                            width: 18,
                                            height: 18,
                                            color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                            semanticsLabel: labels[index],
                                          ),
                                          if (orderCountViewModel.hasRunningOrders)
                                            Positioned(
                                              right: -6,
                                              top: -4,
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.globalBlackWhite(context), width: 1),
                                                ),
                                                constraints: BoxConstraints(minWidth: 14, minHeight: 14),
                                                child: Text(
                                                  '${orderCountViewModel.runningOrderCount > 9 ? '9+' : orderCountViewModel.runningOrderCount}',
                                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  )
                                      : SvgPicture.asset(
                                    icons[index],
                                    width: 18,
                                    height: 18,
                                    color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                    semanticsLabel: labels[index],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    labels[index],
                                    style: AppTextStyles.textSize12(
                                      context,
                                      weight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                      color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                    ),
                                  ),
                                ],
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _openWhatsAppSupport() async {
    const String companyPhone = '8801929600600';
    const String message = 'Hello! I need assistance with Dinmajur platform services.';
    final String whatsappUrl = 'https://wa.me/$companyPhone?text=${Uri.encodeComponent(message)}';
    final Uri whatsappUri = Uri.parse(whatsappUrl);

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        print('✅ WhatsApp opened successfully');
      } else {
        print('⚠️ WhatsApp is not available');
        _showWhatsAppNotInstalledDialog();
      }
    } catch (e) {
      print('❌ Error opening WhatsApp: $e');
      Utils.flushBarErrorMessage("WhatsApp not available. Opening phone dialer...", context);
      await Future.delayed(Duration(milliseconds: 500));
      await _callSupport();
    }
  }

  void _showWhatsAppNotInstalledDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.containerBackground(context),
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.phone_android, color: AppColors.button(context), size: 28),
              SizedBox(width: 10),
              Expanded(child: Text('WhatsApp Not Found', style: AppTextStyles.textSize16(context, weight: FontWeight.w600))),
            ],
          ),
          content: Text('WhatsApp is not installed. Would you like to call our support team instead?', style: AppTextStyles.textSize14(context)),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _callSupport();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.014),
                    decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 18, color: AppColors.whiteColor),
                        SizedBox(width: 8),
                        Text('Call Support (01929-600600)', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: AppColors.border(context)),
                    ),
                    child: Center(child: Text('Cancel', style: AppTextStyles.textSize14(context, weight: FontWeight.w500))),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _callSupport() async {
    const String phoneNumber = 'tel:+8801929600600';
    final Uri phoneUri = Uri.parse(phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        print('✅ Phone dialer opened for support call');
      } else {
        Utils.flushBarErrorMessage("Unable to open phone dialer", context);
      }
    } catch (e) {
      print('❌ Error opening phone dialer: $e');
      Utils.flushBarErrorMessage("Unable to make phone call", context);
    }
  }

  void _checkForUpgrade(BuildContext context) async {
    final upgrader = Upgrader(countryCode: 'BD', languageCode: 'en');
    await upgrader.initialize();

    if (upgrader.shouldDisplayUpgrade()) {
      _showCustomUpgradeDialog(context, upgrader);
    }
  }

  void _showCustomUpgradeDialog(BuildContext context, Upgrader upgrader) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.containerBackground(context),
          insetPadding: EdgeInsets.all(screenHeight * 0.02),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Icon(FontAwesomeIcons.cloudArrowDown, color: AppColors.button(context), size: 50),
                SizedBox(height: 10),
                Text('Update Available', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                SizedBox(height: 20),
                Text('A new version is available!', textAlign: TextAlign.center, style: AppTextStyles.textSize14(context)),
                SizedBox(height: 5),
                Text(
                  'Version ${upgrader.currentAppStoreVersion ?? 'Unknown'} is now available. You are using version ${upgrader.currentInstalledVersion ?? 'Unknown'}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await upgrader.sendUserToAppStore();
                  },
                  child: Container(
                    width: screenWidth * 0.5,
                    height: 45,
                    decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Text('Update Now', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}