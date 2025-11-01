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
import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/order_screen/order_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/password/password_change.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/payment_method/payment_method.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/privacy_policy/privacy_policy_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/promo_codes/promo_code_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/review/review.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/save_address/save_address_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/support/support.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/terms_conditions/terms_conditions_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/view_edit_profile/view_profile.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/location/add_newlocation_screen.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/location/map_location_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/checkout_screen_new.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/deliverd_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_confirmed_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_now_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/track_order_viewdetails_socket_screen.dart';
import 'package:dinmajur_customer/view/screens/home/socket_get_all_order_screen/order_view_details_screen_socket.dart';
import 'package:dinmajur_customer/view/screens/order/complete_orders/complete_orders_details_screen.dart';
import 'package:dinmajur_customer/view/screens/order/order_details_old.dart';
import 'package:dinmajur_customer/view/screens/order/running_orders/running_orders_view_details_socketScreen.dart';
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
      case RoutesName.orderDetailsSocketScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => OrderDetailsSocketScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
      //-----------location
      case RoutesName.addlocation:
        return MaterialPageRoute(builder: (BuildContext context) => const AddNewlocationScreen());
      case RoutesName.mapLocationScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const MapLocationScreen());
      case RoutesName.orderNow:
        return MaterialPageRoute(builder: (BuildContext context) => const OrderNow(), settings: settings);
      // case RoutesName.checkoutScreen:
      //   return MaterialPageRoute(builder: (BuildContext context) => const CheckoutScreen(), settings: settings);
        case RoutesName.checkoutScreenNew:
        return MaterialPageRoute(builder: (BuildContext context) => const CheckoutScreenNew(), settings: settings);
      case RoutesName.orderConfirmScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => OrderConfirmedScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
        case RoutesName.trackOrderViewdetailsSocketScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => TrackOrderViewdetailsSocketScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
        case RoutesName.deliverdScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => DeliverdScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
        //drawer===========>
      case RoutesName.viewProfile:
        return MaterialPageRoute(builder: (BuildContext context) => const ViewProfile());
      case RoutesName.passwordChange:
        return MaterialPageRoute(builder: (BuildContext context) => const PasswordChange());
      case RoutesName.paymentMethod:
        return MaterialPageRoute(builder: (BuildContext context) => const PaymentMethod());
      case RoutesName.saveAddress:
        return MaterialPageRoute(builder: (BuildContext context) => const SaveAddressScreen());
      case RoutesName.ordersScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const OrderScreen());
      case RoutesName.promoCodes:
        return MaterialPageRoute(builder: (BuildContext context) => const PromoCodeScreen());
      case RoutesName.offers:
        return MaterialPageRoute(builder: (BuildContext context) => const OffersScreen());
      case RoutesName.review:
        return MaterialPageRoute(builder: (BuildContext context) => const Review());
      case RoutesName.support:
        return MaterialPageRoute(builder: (BuildContext context) => const Support());
      case RoutesName.termsAndCondition:
        return MaterialPageRoute(builder: (BuildContext context) => const TermsConditionsScreen());
      case RoutesName.privacyPolicy:
        return MaterialPageRoute(builder: (BuildContext context) => const PrivacyPolicyScreen());

      ///Task
      case RoutesName.orderScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const OrderScreen());
        //running Order Details SOCKET.IO Screen
      case RoutesName.runningOrdersViewDetailsSocketscreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => RunningOrdersViewDetailsSocketscreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
        //Complete Order Details API Get Data
      case RoutesName.completeOrdersDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => CompleteOrdersDetailsScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();


      // case RoutesName.orderDetailsScreen:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   if (args == null) {
      //     return _errorRoute();
      //   }
      //   return MaterialPageRoute(
      //     builder: (BuildContext context) => OrderDetailsScreen(orderData: args),
      //     settings: settings,
      //   );


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
