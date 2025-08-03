import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/view_model/authview_model/authview_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/otp_verify_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgot_otpsend_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotresetpassword_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotverifyotp_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'configs/utils/routes/routes.dart';
import 'configs/utils/routes/routes_name.dart';
import 'provider/countdown/forgotpassword_countdown/forgotPassword_countdown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();
  await Upgrader.clearSavedSettings();
  runApp(
    MultiProvider(
      providers: [
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


        ///Home=====>
        ChangeNotifierProvider(create: (_) => ProfileViewViewModel()),



        // ChangeNotifierProvider(create: (_) => ImageUpdateViewModel()),
        // ChangeNotifierProvider(create: (_) => PostPortfolioUploadThumnailviewModel()),
        // ChangeNotifierProvider(create: (_) => ProfileViewViewModel()),
        // ChangeNotifierProvider(create: (_) => PostForgotOtpSendViewModel()),
        // ChangeNotifierProvider(create: (_) => PostForgotOtpVerifyViewModel()),
        // ChangeNotifierProvider(create: (_) => PostNewForgotPasswordViewModel()),
        // ChangeNotifierProvider(create: (_) => PostChangePasswordViewModel()),

      ],
      child: MyApp(),
      // child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isDarkMode = themeProvider.isDarkMode;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
            statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
            statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
            // Add these for better control
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
          // initialRoute: RoutesName.testScreen,
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}
