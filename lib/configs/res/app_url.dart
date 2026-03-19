class AppUrl {
  // static var baseUrl = 'https://6fb1-103-153-170-227.ngrok-free.app/api/v1' ;// Staging Server
  // static var socketUrl = 'https://6fb1-103-153-170-227.ngrok-free.app' ;// Staging

  // static var baseUrl = 'https://api-staging.dinmajur.com/api/v1' ;// Staging Server
  // static var socketUrl = 'https://api-staging.dinmajur.com' ;// Staging


  static var baseUrl = 'https://api.dinmajur.com/api/v1' ;// Dev
  static var socketUrl = 'https://api.dinmajur.com' ;// Dev


  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static var loginEndPint = baseUrl + '/auth/auth_login';
  static var emailCheckEndPoint = baseUrl + '/auth/check-email';


  ///New
  static var customerAuthSendOtpApi = baseUrl + '/auth/login-customer';
  static var customerAuthOtpVeryfyApi = baseUrl + '/auth/verify-customer-otp';
  static var resendOtpApi = baseUrl + '/auth/resend-otp';




  ///Multisteps

  // static var imageApi= baseUrl + '/users/upload-profile-picture';
  static var imageApi= baseUrl + '/files/images/upload-image';



  static var logOutEndPoint = baseUrl + '/auth/logout';


  ///Home
  static var viewProfile = baseUrl + '/customers/get-all-data';
  static var addlocationPostAPI = baseUrl + '/customers/create-address';
  static var updateAddressPatchAPI = baseUrl + '/customers/update-address-by-id';
  static var locationListGetAPI = baseUrl + '/customers/get-delivery-address';
  static var deleteAddressDeleteAPI = baseUrl + '/customers/delete-address';
  //Notification
  static var notificationGetAPI = baseUrl +'/notifications/get-all';

  ///=========>
  static var profileUpdateFullNamePatchAPI = baseUrl + '/customers';
  static var profileHeaderUpdatePatchAPI = baseUrl + '/users/update-me';
  static var patchImageUpdateApi= baseUrl + '/files/images/update-image';
  static var uploadThumnailPostApi= baseUrl + '/files/images/upload-image';
  //=====>----------------------------Payment method
  static var paymentMethodBkashNagadGetAPI = baseUrl + '/payment-methods?provider=';
  static var bkashNagadGetAPI = baseUrl + '/payment-methods';
  static var accountUpdatePatchAPI = baseUrl + '/payment-methods';
  static var paymentMethodPostAPI = baseUrl + '/payment-methods';

  ///Home Screen DropDown
  static var sslPaymentFailed = baseUrl + "/api/v1/payments/ipn";
  //========>order Now
  static var nearbyRetailersPostAPI = baseUrl + "/customers/nearby-stores";
  static var CheckoutOrderPostAPI = baseUrl + "/customers/create-order";
  static var orderDetailsGetAPI = baseUrl + '/orders';
  static var groceryPaymnetPatchAPI = baseUrl + '/customers/payments/type';
  //Freelancer Rating
  static var freelancerRatingPatchAPI = baseUrl + '/customers/reviews';
  //========>Premium house Keeper
  static var checkCoverageGetAPI = baseUrl + '/customers/check-coverage';
  static var getAllPremiumHouseKeeperCategoryGetAPI = baseUrl + '/house-keeper-categories/get-all';
  static var getAllPremiumHouseKeeperGetAPI = baseUrl + '/house-keeper-tasks';
  static var getAllShiftTimeGetAPI = baseUrl + '/shifts/get-all';
  static var getAllShiftTimeByDateGetAPI = baseUrl + '/shifts';
  static var bookPremiumHouseKeeperPostAPI = baseUrl + '/house-keeper-bookings/create';
  static var getBookingByTrackingIdGetAPI = baseUrl + '/house-keeper-bookings/tracking';
  //========>Premium Home Beauty and Salon
  static var getAllPremiumHomeBeautySalonGetAPI = baseUrl + '/beauty-salon-tasks';
  static var getBookedSlotGetAPI = baseUrl + '/time-slots/booked';
  static var bookPremiumHomeBeautySalonPostAPI = baseUrl + '/beauty-salon-bookings/create';
  static var getBeautySalonByTrackingIdGetAPI = baseUrl + '/beauty-salon-bookings/tracking';
  //========>Family Event Cooking
  static var getAllFamilyEventCookingGetAPI = baseUrl + '/event-cooking-categories/get-all';
  static var bookFamilyEventCookingPostAPI = baseUrl + '/event-cooking-bookings';
  static var getFamilyEventCookingGetAPI = baseUrl + '/event-cooking-bookings';
  //Home Screen ALL SERVICE
  static var getAllServiceGetAPI = baseUrl + '/services/get-all';
  static var servicesViewGetAllCategoryGetAPI = baseUrl + '/categories/by-service';





  ///Forgot Password
  static var forgotOtpSendPostAPI = baseUrl + '/auth/forgot-password';
  static var forgotOtpVerifyPostAPI = baseUrl + '/auth/verify-otp';
  static var forgotPasswordResetPostAPI = baseUrl + '/auth/reset-password';




  static var suppportAPI = baseUrl + '/contact';//support


///Order Tab
 static var runningOrderGetAPI = baseUrl + '/customers/orders?status=RUNNING';
 static var pendingOrderGetAPI = baseUrl + '/customers/orders?status=PENDING';
 static var completedOrderGetAPI = baseUrl + '/customers/orders?status=COMPLETED';

}
