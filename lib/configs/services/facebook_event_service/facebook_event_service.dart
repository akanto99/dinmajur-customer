// import 'package:facebook_app_events/facebook_app_events.dart';
//
// class FacebookEventService {
//   static final FacebookAppEvents _facebookAppEvents =
//   FacebookAppEvents();
//
//   static Future<void> purchase(double amount) async {
//     await _facebookAppEvents.logPurchase(
//       amount: amount,
//       currency: "BDT",
//     );
//   }
//
//   static Future<void> registration() async {
//     await _facebookAppEvents.logCompletedRegistration(
//       registrationMethod: "phone",
//     );
//   }
//
//   static Future<void> checkout(double amount) async {
//     await _facebookAppEvents.logInitiatedCheckout(
//       totalPrice: amount,
//       currency: "BDT",
//     );
//   }
// }