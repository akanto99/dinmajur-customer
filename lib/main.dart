import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view_model/authview_model/authview_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/otp_verify_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgot_otpsend_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotresetpassword_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotverifyotp_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/checkout_order_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/post_change_passwordview_model/post_change_passwordview_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'configs/utils/routes/routes.dart';
import 'configs/utils/routes/routes_name.dart';
import 'l10n/app_localizations.dart';
import 'provider/countdown/forgotpassword_countdown/forgotPassword_countdown.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/account_update_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/get_bkash_nagad_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/payment_method_view_model/payment_method_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'view_model/homeview_model/drawer_view_model/support_view_model/support_view_model.dart';
import 'view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  // Initialize language provider
  final languageProvider = LanguageChangeProvider();
  // THIS IS CRUCIAL - Make sure to await the language loading
  await languageProvider.getLanguage();

  await Upgrader.clearSavedSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageChangeProvider>.value(value: languageProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => CountdownTimerProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordCountdown()),
        ChangeNotifierProvider(create: (_) => LoginLogoutViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AuthenticationViewModel()),
        ChangeNotifierProvider(create: (_) => OtpVerifyViewModel()),

        ///Forgot Password
        ChangeNotifierProvider(create: (_) => PostForgotOtpSendViewModel()),
        ChangeNotifierProvider(create: (_) => PostForgotOtpVerifyViewModel()),
        ChangeNotifierProvider(create: (_) => PostNewForgotPasswordViewModel()),

        ///Home=====>"
        ChangeNotifierProvider(create: (_) => ProfileViewViewModel()),
        ChangeNotifierProvider(create: (_) => AddLocationViewModel()),
        ChangeNotifierProvider(create: (_) => GetLocationListViewModel()),
        ChangeNotifierProvider(create: (_) => PostNearbyRetailersViewModel()),
        ChangeNotifierProvider(create: (_) => PostCheckOutOrderViewModel()),
        //order Under Nearby Retailers and Order
        ChangeNotifierProvider(create: (_) => GetOrderDetailsViewModel()),//view Details in Nearby order directory Order Confirmed Screen Get Order Details
        //====drawer
        ChangeNotifierProvider(create: (_) => PatchprofileImageUpdateViewModel()),//profile image update
        ChangeNotifierProvider(create: (_) => PostChangePasswordViewModel()),
        //----------payment method screen
        ChangeNotifierProvider(create: (_) => GetBkashNagadViewModel()),
        ChangeNotifierProvider(create: (_) => PostPaymentMethodViewModel()),
        ChangeNotifierProvider(create: (_) => PatchAccountUpdateViewModel()),
        //-------------Support
        ChangeNotifierProvider(create: (_) => PostSupportViewModel()),



        // Add Socket Provider here
        ChangeNotifierProvider(create: (_) => SocketProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageChangeProvider, SocketProvider>(
      builder: (context, themeProvider, languageProvider, socketProvider, child) {
        bool isDarkMode = themeProvider.isDarkMode;

        // Debug print to check language in MaterialApp
        print('MaterialApp locale: ${languageProvider.appLocale?.languageCode}');

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
          // Use dynamic locale from LanguageChangeProvider
          locale: languageProvider.appLocale ?? Locale('en'),
          // locale: Locale('en'),
          // locale: Locale('bn'),
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