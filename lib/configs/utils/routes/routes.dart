import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/view/autentication/authentication_screen.dart';
import 'package:dinmajur_customer/view/autentication/otp_screen.dart';
import 'package:dinmajur_customer/view/autentication/verification_success_dialouge.dart';
import 'package:dinmajur_customer/view/forgot_password/forgot_password.dart';
import 'package:dinmajur_customer/view/forgot_password/new_password.dart';
import 'package:dinmajur_customer/view/forgot_password/otp_verify.dart';
import 'package:dinmajur_customer/view/login/login_screen.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/onboarding/onboarding_update.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_now.dart';
import 'package:dinmajur_customer/view/splash_screen/splash_view.dart';
import 'package:dinmajur_customer/view/welcome_loginsignup/welcome_loginsignup.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(builder: (BuildContext context) => const SplashScreen());
      case RoutesName.welcomeLoginSignup:
        return MaterialPageRoute(builder: (BuildContext context) => const WelcomeLoginSignup());
      case RoutesName.login:
        return MaterialPageRoute(builder: (BuildContext context) => const LoginScreen());
      // case RoutesName.onBoard:
      // return MaterialPageRoute(builder: (BuildContext context) => const OnboardingScreen());
      case RoutesName.onBoardUpdated:
        return MaterialPageRoute(builder: (BuildContext context) => const OnboardingScreenUpdated());
      case RoutesName.navigationBar:
        return MaterialPageRoute(builder: (BuildContext context) => const NavigationScreen());
      case RoutesName.register:
        return MaterialPageRoute(builder: (BuildContext context) => const AuthenticationScreen());
      case RoutesName.otp:
        return MaterialPageRoute(builder: (BuildContext context) => const OtpScreen(), settings: settings);
      case RoutesName.verificationSuccessScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const VerificationSuccessScreen());

      ///Forgot Password
      case RoutesName.forgotPassword:
        return MaterialPageRoute(builder: (BuildContext context) => const ForgotPassword());
      case RoutesName.forgot_otpVerify:
        return MaterialPageRoute(builder: (BuildContext context) => const OtpVerify(), settings: settings);
      case RoutesName.newPassword:
        return MaterialPageRoute(builder: (BuildContext context) => const NewPassword(), settings: settings);

      ///Home

      case RoutesName.home:
        return MaterialPageRoute(builder: (BuildContext context) => const HomeScreen());
      case RoutesName.orderNow:
        return MaterialPageRoute(
          builder: (BuildContext context) => const OrderNow(),
          settings: settings,
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return const Scaffold(body: Center(child: Text('No route defined')));
      },
    );
  }
}
