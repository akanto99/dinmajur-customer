import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/failedorder_screen_widget.dart';
import 'package:dinmajur_customer/view/auth_login/auth_login_welcome.dart';
import 'package:dinmajur_customer/view/auth_login/customer_otplogin_screen.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/onboarding/onboarding_update.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/checkout_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/confirmed_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/homebeauty_salon_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/cooking_checkout_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/cooking_confirmed_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/family_event_cooking_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/book_now_housekeeper_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/checkout_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/confirmed_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/order_screen/order_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/payment_method/payment_method.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/policies/cooking_policy.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/policies/delivery_policy.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/policies/refund_policy.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/privacy_policy/privacy_policy_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/promo_codes/promo_code_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/review/review.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/save_address/save_address_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/support/support.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/terms_conditions/terms_conditions_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/view_edit_profile/view_profile.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view/screens/home/location_screens/add_newlocation_screen.dart';
import 'package:dinmajur_customer/view/screens/home/location_screens/map_location_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/checkout_screen_new.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/deliverd_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_confirmed_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_now_screen.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/track_order_viewdetails_socket_screen.dart';
import 'package:dinmajur_customer/view/screens/home/socket_get_all_order_screen/order_view_details_screen_socket.dart';
import 'package:dinmajur_customer/view/screens/home/sse_notification_screen/notification_screen.dart';
import 'package:dinmajur_customer/view/screens/home/unified_seeall_screen/unified_seeall_screen.dart';
// import 'package:dinmajur_customer/view/screens/home/sse_notification_screen/sse_notification_screen.dart';
import 'package:dinmajur_customer/view/screens/order/complete_orders/complete_orders_details_screen.dart';
import 'package:dinmajur_customer/view/screens/order/pending_orders/pending_orders_view_details_socketScreen.dart';
import 'package:dinmajur_customer/view/screens/order/running_orders/running_orders_view_details_socketScreen.dart';
import 'package:dinmajur_customer/view/splash_screen/splash_view.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(builder: (BuildContext context) => const SplashScreen());
      case RoutesName.onBoardUpdated:
        return MaterialPageRoute(builder: (BuildContext context) => const OnboardingScreenUpdated());


        ///New
         case RoutesName.authLoginWelcome:
         return MaterialPageRoute(builder: (BuildContext context) => const WelcomeLoginScreen());
        case RoutesName.authOtp:
        return MaterialPageRoute(builder: (BuildContext context) => const CustomerAuthOtpScreen(), settings: settings);
    // case RoutesName.verificationSuccessScreen:
    //     return MaterialPageRoute(builder: (BuildContext context) => const ());




      case RoutesName.navigationBar:
        return MaterialPageRoute(builder: (BuildContext context) => const NavigationScreen());


      ///Home
      case RoutesName.home:
        return MaterialPageRoute(builder: (BuildContext context) => const HomeScreen());
        case RoutesName.addLocationScreenWidget:
        return MaterialPageRoute(builder: (BuildContext context) => const AddLocationScreenWidget());
        case RoutesName.notificationsListScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const NotificationsListScreen());//Notifications ListScreen SSE Just
        //  case RoutesName.notificationsListScreen:
        // return MaterialPageRoute(builder: (BuildContext context) => const NotificationsListScreen());//Notifications ListScreen SSE Just//
      case RoutesName.unifiedSeeAllScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => UnifiedSeeAllScreen(
              storeType: args['storeType'],
              stores: args['stores'],
              storeTypes: args['storeTypes'],
              currentPosition: args['currentPosition'],
              currentAddress: args['currentAddress'],
              isCheckingCoverage: args['isCheckingCoverage'],
              isInsideServiceArea: args['isInsideServiceArea'],
              customerName: args['customerName'],
              customerPhone: args['customerPhone'],
              customerAddress: args['customerAddress'],
            ),
            settings: settings,
          );
        }
        return _errorRoute();
      case RoutesName.orderDetailsSocketScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => OrderDetailsSocketScreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();
      //-----------location_screens
      case RoutesName.addlocation:
        return MaterialPageRoute(builder: (BuildContext context) => const AddNewlocationScreen());
      case RoutesName.mapLocationScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const MapLocationScreen());

      case RoutesName.failedOrderScreenWidget:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => FailedOrderScreenWidget(
              trackingId: args['trackingId'] ?? 'N/A',
              valId: args['valId'] ?? 'N/A',
              reason: args['reason'],
              errorMessage: args['errorMessage'],
            ),
            settings: settings,
          );
        }
        return _errorRoute();

        ///order Now Screen For Retail after clicking Grocerry in HOME SCreen- DropDown 1
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

    ///In HOME SCreen- DropDown 2 Premium House Keeper
      case RoutesName.bookNowPremiumHouseKeeper:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => BookNowHousekeeperScreen(
                customerName: args['customerName'],
                customerPhone: args['customerPhone'],
                customerAddress: args['customerAddress'],
              isFromHome: args['isFromHome'] ?? false,
            ),
            settings: settings,
          );
        }
        return _errorRoute();
      case RoutesName.confirmedScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => ConfirmedScreen(
              //   trackingId: args['trackingId'],
              // valId: args['valId'],
              trackingId: args['trackingId'] as String? ?? '',
              valId: args['valId'] as String? ?? '',
            ),
            settings: settings,
          );
        }
        return _errorRoute();

        case RoutesName.checkoutHouseKeeperScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => CheckoutHouseKeeperScreen(
              serviceQuantities: args['serviceQuantities'] ,
              selectedTaskItems: args['selectedTaskItems'] ,
              selectedFrequency: args['selectedFrequency'] ,
              selectedDate: args['selectedDate'],
              selectedTime: args['selectedTime'] ,
              customerName: args['customerName'] ,
              customerPhone: args['customerPhone'] ,
              customerAddress: args['customerAddress'] ,
              onAddressUpdate: args['onAddressUpdate'],
              transportFee: args['transportFee'],
              onSuccess: () {
                // This callback will be called from checkout screen
              },
            ),
            settings: settings,
          );
        }
        return _errorRoute();
    ///In HOME Screen- DropDown 3 Premium Home Beauty Salon
      case RoutesName.bookNowHomeBeautySalonScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => BookNowHomeBeautySalonScreen(
              customerName: args['customerName'],
              customerPhone: args['customerPhone'],
              customerAddress: args['customerAddress'],
              isFromHome: args['isFromHome'] ?? false,
            ),
            settings: settings,
          );
        }
        return _errorRoute();
      case RoutesName.beautyConfirmedScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => BeautyConfirmedScreen(
              //   trackingId: args['trackingId'],
              // valId: args['valId'],
              trackingId: args['trackingId'] as String? ?? '',
              valId: args['valId'] as String? ?? '',
            ),
            settings: settings,
          );
        }
        return _errorRoute();
      case RoutesName.beautyCheckoutScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => CheckoutScreen(
              customerName: args['customerName'],
              customerPhone: args['customerPhone'],
              customerAddress: args['customerAddress'],
              userId: args['userId'],
              categories: args['categories'],
              serviceQuantities: args['serviceQuantities'],
              totalPrice: args['totalPrice'],
              transportFee: args['transportFee'],
              onAddressUpdate: args['onAddressUpdate'],
            ),
            settings: settings,
          );
        }
        return _errorRoute();


    ///In HOME Screen- DropDown 4 Family Event Cooking
      case RoutesName.familyEventCookingScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => FamilyEventCookingScreen(
              customerName: args['customerName'],
              customerPhone: args['customerPhone'],
              customerAddress: args['customerAddress'],
              isFromHome: args['isFromHome'] ?? false,
            ),
            settings: settings,
          );
        }
        return _errorRoute();
      case RoutesName.cookingCheckoutScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => CookingCheckoutScreen(
              customerName: args['customerName'],
              customerPhone: args['customerPhone'],
              customerAddress: args['customerAddress'],
              userId: args['userId'],
              categories: args['categories'],
              selectedPackages: args['selectedPackages'],
              selectedManualItems: args['selectedManualItems'],
              activeCategoryId: args['activeCategoryId'],
              selectedGuestRangeIndex: args['selectedGuestRangeIndex'],
              totalPrice: args['totalPrice'],
              savedAmount: args['savedAmount'],
              transportFee: args['transportFee'],
              selectedDate: args['selectedDate'],
              selectedServiceTime: args['selectedServiceTime'],
              onAddressUpdate: args['onAddressUpdate'],
            ),
            settings: settings,
          );
        }
        return _errorRoute();

      case RoutesName.cookingConfirmedScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => CookingConfirmedScreen(
              //   trackingId: args['trackingId'],
              // valId: args['valId'],
              trackingId: args['trackingId'] as String? ?? '',
              valId: args['valId'] as String? ?? '',
            ),
            settings: settings,
          );
        }
        return _errorRoute();


    //drawer===========>
        case RoutesName.viewProfile:
        return MaterialPageRoute(builder: (BuildContext context) => const ViewProfile());
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
        case RoutesName.cookiesPolicyScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const CookiesPolicyScreen());
        case RoutesName.deliveryPolicyScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const DeliveryPolicyScreen());
        case RoutesName.refundPolicyScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const RefundPolicyScreen());

      ///Task
      case RoutesName.orderScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const OrderScreen());
        //pending Order Details SOCKET.IO Screen
      case RoutesName.pendingOrdersViewDetailsSocketscreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (BuildContext context) => PendingOrdersViewDetailsSocketscreen(orderId: args['orderId']),
            settings: settings,
          );
        }
        return _errorRoute();

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
