import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/book_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/checkout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_slot_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/getservice_confirmationdetails_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/banner_view_model/banner_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/approve_booking_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_bookedslot_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/book_family_event_cooking_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/grocery_order_view_model/grocery_ordernow_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_housekeeper_category_view_model.dart';
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
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'configs/services/one_signal_push_notification/one_signal_pushnotification_service.dart';
import 'configs/utils/routes/routes.dart';
import 'configs/utils/routes/routes_name.dart';
import 'data/network/service_reconnector.dart';
import 'l10n/app_localizations.dart';
import 'view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'view_model/auth_view_model_new/customer_otp_view_model.dart';
import 'view_model/auth_view_model_new/resend_otp_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/support_view_model/support_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_beautysalon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getall_family_event_cooking_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getdetails_event_cooking_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/freelancer_rating_view_model.dart';
import 'view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';
import 'view_model/order_view_models/assigned_freelance_view_model/freelancer_review_view_model.dart';
import 'view_model/homeview_model/featured_services_view_model/featured_services_view_model.dart';
import 'view_model/homeview_model/home_sections_view_model/home_sections_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  await dotenv.load(fileName: ".env");

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  final languageProvider = LanguageChangeProvider();
  await languageProvider.getLanguage();

  // OneSignal
  final oneSignalService = OneSignalNotificationService();
  await oneSignalService.initialize();
  await oneSignalService.autoLogin();
  await Future.delayed(const Duration(microseconds: 200));

  // App upgrade
  await Upgrader.clearSavedSettings();
  ///Facebook meta analytics
  // final facebookAppEvents = FacebookAppEvents();
  // await facebookAppEvents.setGraphApiVersion('v24.0');
  // await facebookAppEvents.activateApp();


  // ── SocketManager
  final socketManager = SocketManager();
  // ── SSE
  final sseService = SSENotificationService();
  final notificationCountViewModel = NotificationCountViewModel();
  final runningOrderCountViewModel = RunningOrderCountViewModel();

  ServiceReconnector().init(
    socketManager: socketManager,
    sseService: sseService,
    notifVM: notificationCountViewModel,
    orderVM: runningOrderCountViewModel,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<OneSignalNotificationService>.value(value: oneSignalService),

        ChangeNotifierProvider<LanguageChangeProvider>.value(value: languageProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => CountdownTimerProvider()),
        ChangeNotifierProvider(create: (_) => GlobalCartProvider()..hydrate()),

        // ── SocketManager replaces SocketProvider + SocketService ──────────
        ChangeNotifierProvider<SocketManager>.value(value: socketManager),

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
        ChangeNotifierProvider<NotificationCountViewModel>.value(value: notificationCountViewModel),
        ChangeNotifierProvider<RunningOrderCountViewModel>.value(value: runningOrderCountViewModel),
        ChangeNotifierProvider(create: (_) => GetNotificationViewModel()),

        // Order Now
        ChangeNotifierProvider(create: (_) => PostNearbyRetailersViewModel()),
        ChangeNotifierProvider(create: (_) => PostCheckOutOrderViewModel()),
        ChangeNotifierProvider(create: (_) => GetOrderDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => OrderDetailsSocketProvider()),
        ChangeNotifierProvider(create: (_) => PatchFreelancerRatingViewModel()),
        ChangeNotifierProvider(create: (_) => GroceryOrdernowViewModel()),

        // Premium House Keeper
        ChangeNotifierProvider(create: (_) => CheckCoverageViewModel()),
        ChangeNotifierProvider(create: (_) => GetallHousekeeperCategoryViewModel()),
        ChangeNotifierProvider(create: (_) => GetallPremiumHouseKeeperTaskViewModel()),
        ChangeNotifierProvider(create: (_) => GetallShifttimeViewModel()),
        ChangeNotifierProvider(create: (_) => PostBookPremiumHouseKeeperViewModel()),
        ChangeNotifierProvider(create: (_) => GetConfirmedbookingViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),

        // Family Event Cooking
        ChangeNotifierProvider(create: (_) => GetAllFamilyEventCookingViewModel()),
        ChangeNotifierProvider(create: (_) => PostBookFamilyEventCookingViewModel()),
        ChangeNotifierProvider(create: (_) => GetDetailsEventCookingViewModel()),
        ChangeNotifierProvider(create: (_) => CookingCheckoutViewModel()),

        // Premium Home Beauty Salon
        ChangeNotifierProvider(create: (_) => GetallPremiumHomeBeautySalonViewModel()),
        ChangeNotifierProvider(create: (_) => GetBookedSlotViewModel()),
        ChangeNotifierProvider(create: (_) => PostBookPremiumHomeBeautySalonViewModel()),
        ChangeNotifierProvider(create: (_) => GetBeautySalonViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutBeautySalonViewModel()),
        //Approve Booking
        ChangeNotifierProvider(create: (_) => ApproveBookingViewModel()),




        ///Home Screen Get All Service
        ChangeNotifierProvider(create: (_) => GetAllServiceViewModel()),
        ChangeNotifierProvider(create: (_) => ServicesViewGetAllCategoriesViewModel()),
        ChangeNotifierProvider(create: (_) => GetSlotViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutAllServicesViewModel()),
        ChangeNotifierProvider(create: (_) => BookServiceViewModel()),
        ChangeNotifierProvider(create: (_) => GetServiceConfirmationDetailsViewModel()),
        //Banner
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        //Featured Services
        ChangeNotifierProvider(create: (_) => FeaturedServicesViewModel()),
        //Home Page Layout (admin-controlled section order/visibility)
        ChangeNotifierProvider(create: (_) => HomeSectionsViewModel()),

        ChangeNotifierProvider(create: (_) => PatchprofileImageUpdateViewModel()),
        ChangeNotifierProvider(create: (_) => PostSupportViewModel()),
        ///Order
        ChangeNotifierProvider(create: (_) => RunningOrdersViewModel()),
        ChangeNotifierProvider(create: (_) => CompleteOrdersViewModel()),
        ChangeNotifierProvider(create: (_) => FreelancerReviewViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageChangeProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final bool isDarkMode = themeProvider.isDarkMode;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
          statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        ));

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
          locale: languageProvider.appLocale ?? const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('bn')],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          ),
        );
      },
    );
  }
}