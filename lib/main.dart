
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/delete_location_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/checkout_order_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/notification_view_model/notification_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/complete_orders_view_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'configs/utils/routes/routes.dart';
import 'configs/utils/routes/routes_name.dart';
import 'l10n/app_localizations.dart';
import 'view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'view_model/auth_view_model_new/customer_otp_view_model.dart';
import 'view_model/auth_view_model_new/resend_otp_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/account_update_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/get_bkash_nagad_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/payment_method_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/support_view_model/support_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_beautysalon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/freelancer_rating_view_model.dart';
import 'view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  final languageProvider = LanguageChangeProvider();
  await languageProvider.getLanguage();


  ///SOCKET.IO
  final socketProvider = SocketProvider();
  ///SSE
  final sseService = SSENotificationService();
  final notificationCountViewModel = NotificationCountViewModel();
  final runningOrderCountViewModel = RunningOrderCountViewModel();

  // ✅ Auto-connect if user is already logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  if (userId != null && userId.isNotEmpty) {
    ///SOCKET.IO
    print("🔌 Main: Auto-connecting socket for logged-in user: $userId");
    await socketProvider.connectWithUser(userId: userId);

    ///SSE
    print("🔔 Main: Starting SSE connection for logged-in user");
    await sseService.startListening();

    // ✅ Wait for initial count and initialize listener
    await Future.delayed(Duration(milliseconds: 500));
    notificationCountViewModel.initializeCountListener(sseService.notificationCountStream);
    notificationCountViewModel.setInitialCount(sseService.currentCount);
    print("✅ Main: SSE listener initialized with count: ${sseService.currentCount}");

    runningOrderCountViewModel.initializeCountListener(sseService.runningOrderCountStream);
    runningOrderCountViewModel.setInitialCount(sseService.currentRunningOrderCount);
    print("✅ Main: SSE running order listener initialized with count: ${sseService.currentRunningOrderCount}");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageChangeProvider>.value(value: languageProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => CountdownTimerProvider()),

        ChangeNotifierProvider(create: (_) => LoginLogoutViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerAuthLoginViewModel()),
        ChangeNotifierProvider(create: (_) => AuthOtpVerifyViewModel()),
        ChangeNotifierProvider(create: (_) => ResendOtpViewModel()),

        ChangeNotifierProvider(create: (_) => ProfileViewViewModel()),
        ChangeNotifierProvider(create: (_) => AddLocationViewModel()),
        ChangeNotifierProvider(create: (_) => GetLocationListViewModel()),
        ChangeNotifierProvider(create: (_) => DeleteLocationViewModel()),

        Provider<SSENotificationService>.value(value: sseService),

        ChangeNotifierProvider<NotificationCountViewModel>.value(value: notificationCountViewModel,),
        ChangeNotifierProvider<RunningOrderCountViewModel>.value(value: runningOrderCountViewModel,),
        ChangeNotifierProvider(create: (_) => GetNotificationViewModel()),

        //==============>Order Now
        ChangeNotifierProvider(create: (_) => PostNearbyRetailersViewModel()),
        ChangeNotifierProvider(create: (_) => PostCheckOutOrderViewModel()),
        ChangeNotifierProvider(create: (_) => GetOrderDetailsViewModel()),
        ChangeNotifierProvider<OrderDetailsSocketProvider>(create: (context) => OrderDetailsSocketProvider()),
        ChangeNotifierProvider(create: (_) => PatchFreelancerRatingViewModel()),
        //==============>Premium House Keeper
        ChangeNotifierProvider(create: (_) => CheckCoverageViewModel()),
        ChangeNotifierProvider(create: (_) => GetallPremiumHouseKeeperTaskViewModel()),
        ChangeNotifierProvider(create: (_) => GetallShifttimeViewModel()),
        ChangeNotifierProvider(create: (_) => PostBookPremiumHouseKeeperViewModel()),
        ChangeNotifierProvider(create: (_) => GetConfirmedbookingViewModel()),
        //==============>Premium Home Beauty Salon
        ChangeNotifierProvider(create: (_) => GetallPremiumHomeBeautySalonViewModel()),
        ChangeNotifierProvider(create: (_) => PostBookPremiumHomeBeautySalonViewModel()),
        ChangeNotifierProvider(create: (_) => GetBeautySalonViewModel()),


        ChangeNotifierProvider(create: (_) => PatchprofileImageUpdateViewModel()),
        ChangeNotifierProvider(create: (_) => GetBkashNagadViewModel()),
        ChangeNotifierProvider(create: (_) => PostPaymentMethodViewModel()),
        ChangeNotifierProvider(create: (_) => PatchAccountUpdateViewModel()),
        ChangeNotifierProvider(create: (_) => PostSupportViewModel()),
        ChangeNotifierProvider(create: (_) => RunningOrdersViewModel()),
        ChangeNotifierProvider(create: (_) => CompleteOrdersViewModel()),
        ChangeNotifierProvider<SocketProvider>.value(value: socketProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  bool _isReconnecting = false;
  bool _isAlertSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNetworkMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // ✅ APP LIFECYCLE MANAGEMENT
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("🔌 MyApp: App lifecycle state changed to: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        print("🔌 MyApp: App resumed - checking connections");
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        print("🔌 MyApp: App paused");
        break;
      case AppLifecycleState.inactive:
        print("🔌 MyApp: App inactive");
        break;
      case AppLifecycleState.detached:
        print("🔌 MyApp: App detached");
        break;
      case AppLifecycleState.hidden:
        print("🔌 MyApp: App hidden");
        break;
    }
  }

  // ✅ HANDLE APP RESUME - Updated to include SSE
  Future<void> _handleAppResumed() async {
    if (_isReconnecting) {
      print("🔌 MyApp: Reconnection already in progress, skipping");
      return;
    }

    try {
      _isReconnecting = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        print("🔌 MyApp: No userId found, skipping reconnection");
        _isReconnecting = false;
        return;
      }

      // Wait for system to stabilize
      await Future.delayed(Duration(milliseconds: 500));

      // Check internet connection
      bool hasInternet = await InternetConnectionChecker().hasConnection;

      if (!hasInternet) {
        print("🔌 MyApp: No internet connection, cannot reconnect");
        _isReconnecting = false;
        return;
      }

      print("🔌 MyApp: Internet available, checking connections");

      // ✅ RECONNECT SOCKET.IO
      await _reconnectSocketIfNeeded(userId);

      // ✅ RECONNECT SSE
      await _reconnectSSEIfNeeded();

      _isReconnecting = false;
    } catch (e) {
      print("🔌 MyApp: Error handling app resume - $e");
      _isReconnecting = false;
    }
  }

  // ✅ NEW: Reconnect Socket.IO if disconnected
  Future<void> _reconnectSocketIfNeeded(String userId) async {
    try {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      print("🔌 MyApp: Checking socket status");

      if (!socketProvider.isConnected) {
        print("🔌 MyApp: Socket disconnected, reconnecting...");

        await socketProvider.disconnect();
        await Future.delayed(Duration(milliseconds: 300));
        await socketProvider.connectWithUser(userId: userId);

        // Verify connection
        await Future.delayed(Duration(milliseconds: 1000));

        if (socketProvider.isConnected) {
          print("🔌 MyApp: ✅ Socket reconnected successfully");
        } else {
          print("🔌 MyApp: ⚠️ Socket reconnection uncertain, trying auto-reconnect");
          await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 2));
        }
      } else {
        print("🔌 MyApp: Socket already connected");
      }
    } catch (e) {
      print("🔌 MyApp: Error reconnecting socket - $e");
    }
  }

  // ✅ NEW: Reconnect SSE if disconnected
  Future<void> _reconnectSSEIfNeeded() async {
    try {
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final notificationCountViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
      final runningOrderCountViewModel = Provider.of<RunningOrderCountViewModel>(context, listen: false); // ✅ Add this

      print("🔔 MyApp: Checking SSE status");

      if (!sseService.isListening) {
        print("🔔 MyApp: SSE disconnected, reconnecting...");

        await sseService.startListening();

        // Wait for initial count
        await Future.delayed(Duration(milliseconds: 500));

        // Re-initialize listener if needed
        if (!notificationCountViewModel.isInitialized) {
          notificationCountViewModel.initializeCountListener(sseService.notificationCountStream);
        }
        notificationCountViewModel.setInitialCount(sseService.currentCount);

        if (!runningOrderCountViewModel.isInitialized) {
          runningOrderCountViewModel.initializeCountListener(sseService.runningOrderCountStream);
        }
        runningOrderCountViewModel.setInitialCount(sseService.currentRunningOrderCount);

        print("🔔 MyApp: ✅ SSE reconnected successfully");
        print("🔔 Notification count: ${sseService.currentCount}");
        print("📦 Running order count: ${sseService.currentRunningOrderCount}");
      } else {
        print("🔔 MyApp: SSE already connected");
      }
    } catch (e) {
      print("🔔 MyApp: Error reconnecting SSE - $e");
    }
  }

  // ✅ INITIALIZE NETWORK MONITORING
  void _initializeNetworkMonitoring() {
    print("🔌 MyApp: Initializing network monitoring...");

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> result) async {
        print("🔌 MyApp: Connectivity listener triggered");
        print("🔌 MyApp: Current context available: ${NavigationService.navigatorKey.currentContext != null}");
        print("🔌 MyApp: Alert currently set: $_isAlertSet");

        await _handleConnectivityChange(result);
      },
      onError: (error) {
        print("🔌 MyApp: Connectivity listener error: $error");
      },
    );

    print("🔌 MyApp: ✅ Network monitoring initialized");
  }

  // ✅ HANDLE CONNECTIVITY CHANGES
  Future<void> _handleConnectivityChange(List<ConnectivityResult> result) async {
    if (_isReconnecting) {
      print("🔌 MyApp: Reconnection already in progress, skipping connectivity change");
      return;
    }

    print('🔌 MyApp: Connectivity changed: $result');

    bool hasConnectivity = !result.contains(ConnectivityResult.none) && result.isNotEmpty;

    // Wait a bit to check actual internet
    await Future.delayed(Duration(milliseconds: 500));
    bool hasInternet = await InternetConnectionChecker().hasConnection;

    bool hasConnection = hasConnectivity && hasInternet;

    if (!hasConnection && !_isAlertSet) {
      // ✅ CONNECTION LOST - Disconnect both Socket.IO and SSE
      print("🔌 MyApp: No connection detected, disconnecting services");

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId');

        if (userId != null && userId.isNotEmpty) {
          // Disconnect Socket.IO
          final socketProvider = Provider.of<SocketProvider>(context, listen: false);
          await socketProvider.unregisterAndDisconnect(userId: userId);
          print("🔌 MyApp: Socket disconnected due to network loss");

          // Disconnect SSE
          final sseService = Provider.of<SSENotificationService>(context, listen: false);
          await sseService.stopListening();
          print("🔔 MyApp: SSE disconnected due to network loss");
        }
      } catch (e) {
        print("🔌 MyApp: Error disconnecting services: $e");
      }

      // Show dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNoConnectionDialog();
        }
      });
      setState(() => _isAlertSet = true);

    } else if (hasConnection && _isAlertSet) {
      // ✅ CONNECTION RESTORED - Close dialog and reconnect both services
      print("🔌 MyApp: Connection restored, closing dialog and reconnecting services");

      // Use navigatorKey to dismiss dialog
      if (NavigationService.navigatorKey.currentContext != null) {
        Navigator.of(NavigationService.navigatorKey.currentContext!, rootNavigator: true).pop();
      }

      setState(() => _isAlertSet = false);

      // Reconnect both Socket.IO and SSE
      await _reconnectAllServices();
    }
  }

  // ✅ NEW METHOD - Reconnect both Socket.IO and SSE
  Future<void> _reconnectAllServices() async {
    if (_isReconnecting) {
      print("🔌 MyApp: Reconnection already in progress");
      return;
    }

    try {
      _isReconnecting = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        print("🔌 MyApp: No userId found for reconnection");
        _isReconnecting = false;
        return;
      }

      print("🔌 MyApp: Reconnecting all services for user: $userId");

      // ✅ Reconnect Socket.IO
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      await socketProvider.connectWithUser(userId: userId);
      print("🔌 MyApp: Socket reconnection initiated");

      // Wait and verify socket connection
      await Future.delayed(Duration(milliseconds: 1000));

      if (socketProvider.isConnected) {
        print("🔌 MyApp: ✅ Socket reconnected successfully");
      } else {
        print("🔌 MyApp: ⚠️ Socket reconnection uncertain, attempting auto-reconnect...");
        await socketProvider.autoReconnect(maxRetries: 3, delay: Duration(seconds: 2));
      }

      // ✅ Reconnect SSE
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final notificationCountViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);

      print("🔔 MyApp: Reconnecting SSE");
      await sseService.startListening();

      // Wait for initial count
      await Future.delayed(Duration(milliseconds: 500));

      // Re-initialize listener if needed
      if (!notificationCountViewModel.isInitialized) {
        notificationCountViewModel.initializeCountListener(sseService.notificationCountStream);
      }

      // Update with current count
      notificationCountViewModel.setInitialCount(sseService.currentCount);

      print("🔔 MyApp: ✅ SSE reconnected successfully, count: ${sseService.currentCount}");

      _isReconnecting = false;
    } catch (e) {
      print("🔌 MyApp: Service reconnection failed - $e");

      try {
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);
        await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 3));
      } catch (retryError) {
        print("🔌 MyApp: Final reconnection attempt failed - $retryError");
      }

      _isReconnecting = false;
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
            Icon(
              CupertinoIcons.wifi_exclamationmark,
              size: 40,
              color: CupertinoColors.systemRed,
            ),
            SizedBox(height: 10),
            Text(
              'Connection Lost',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'You seem to be offline. Check your connection to stay updated.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isAlertSet = false);

              // Check connection again
              List<ConnectivityResult> result = await _connectivity.checkConnectivity();
              bool hasInternet = await InternetConnectionChecker().hasConnection;
              bool hasConnection = !result.contains(ConnectivityResult.none) &&
                  result.isNotEmpty &&
                  hasInternet;

              if (hasConnection) {
                print("🔌 MyApp: Retry - Connection restored");
                await _reconnectAllServices();
              } else {
                print("🔌 MyApp: Retry - Still no connection");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _showNoConnectionDialog();
                    setState(() => _isAlertSet = true);
                  }
                });
              }
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageChangeProvider, SocketProvider>(
      builder: (context, themeProvider, languageProvider, socketProvider, child) {
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

        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);

        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          initialRoute: RoutesName.splash,
          onGenerateRoute: Routes.generateRoute,
          locale: languageProvider.appLocale ?? Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'), // English
            Locale('bn'), // Bengali
          ],
        );
      },
    );
  }
}