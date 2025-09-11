class AppUrl {

  static var baseUrl = 'https://api-staging.dinmajur.com/api/v1' ;// Staging Server

  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static var loginEndPint = baseUrl + '/auth/login';
  static var emailCheckEndPoint = baseUrl + '/auth/check-email';

  ///Multisteps
  static var multiSignUpEndPint = baseUrl + '/users/update-profile-and-create-skills';
  static var createServicesEndPoint = baseUrl + '/user-services';
  static var updateMe = baseUrl + '/users/update-me';
  static var createaddress = baseUrl + '/user-address';

  static var otpApi = baseUrl + '/users/create';
  static var otpVerify = baseUrl + '/auth/verify-otp';
  // static var imageApi= baseUrl + '/users/upload-profile-picture';
  static var imageApi= baseUrl + '/files/images/upload-image';



  static var logOutEndPoint = baseUrl + '/api/app/logout';



  ///Home
  static var viewProfile = baseUrl + '/users/get-user-data';
  ///=========>
  static var profileHeaderUpdatePatchAPI = baseUrl + '/users/update-me';
  // static var patchImageUpdateApi= baseUrl + '/users/update-profile-picture';
  static var patchImageUpdateApi= baseUrl + '/files/images/update-image';
  // static var uploadThumnailPostApi= baseUrl + '/users/upload-profile-picture';
  static var uploadThumnailPostApi= baseUrl + '/files/images/upload-image';
  static var changePasswordPostAPI = baseUrl + "/auth/change-password";//Change Password
  //=====>----------------------------Payment method
  static var paymentMethodBkashNagadGetAPI = baseUrl + '/payment-methods?provider=';
  static var bkashNagadGetAPI = baseUrl + '/payment-methods';
  static var accountUpdatePatchAPI = baseUrl + '/payment-methods';
  static var paymentMethodPostAPI = baseUrl + '/payment-methods';


  //order Now
  static var nearbyRetailersPostAPI = baseUrl + "/retailers/nearby-retailers";
  static var CheckoutOrderPostAPI = baseUrl + "/orders/create";

  ///Forgot Password
  static var forgotOtpSendPostAPI = baseUrl + '/auth/forgot-password';
  static var forgotOtpVerifyPostAPI = baseUrl + '/auth/verify-otp';
  static var forgotPasswordResetPostAPI = baseUrl + '/auth/reset-password';




  static var suppportAPI = baseUrl + '/contact';//support
}
