class AppUrl {

  static var baseUrl = 'https://api-staging.dinmajur.com/api/v1' ;// Staging Server

  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static var loginEndPint = baseUrl + '/auth/login';
  static var emailCheckEndPoint = baseUrl + '/auth/check-email';

  ///Multisteps
  static var otpApi = baseUrl + '/users/create';
  static var otpVerify = baseUrl + '/auth/verify-otp';
  // static var imageApi= baseUrl + '/users/upload-profile-picture';
  static var imageApi= baseUrl + '/files/images/upload-image';



  static var logOutEndPoint = baseUrl + '/api/app/logout';



  ///Home
  static var viewProfile = baseUrl + '/users/get-user-data';
  static var addlocationPostAPI = baseUrl + '/customers/create-address';

  ///=========>
  static var profileHeaderUpdatePatchAPI = baseUrl + '/users/update-me';
  static var patchImageUpdateApi= baseUrl + '/files/images/update-image';
  static var uploadThumnailPostApi= baseUrl + '/files/images/upload-image';
  static var changePasswordPostAPI = baseUrl + "/auth/change-password";//Change Password
  //=====>----------------------------Payment method
  static var paymentMethodBkashNagadGetAPI = baseUrl + '/payment-methods?provider=';
  static var bkashNagadGetAPI = baseUrl + '/payment-methods';
  static var accountUpdatePatchAPI = baseUrl + '/payment-methods';
  static var paymentMethodPostAPI = baseUrl + '/payment-methods';


  //order Now
  static var nearbyRetailersPostAPI = baseUrl + "/customers/nearby-stores";
  static var CheckoutOrderPostAPI = baseUrl + "/customers/create-order";

  ///Forgot Password
  static var forgotOtpSendPostAPI = baseUrl + '/auth/forgot-password';
  static var forgotOtpVerifyPostAPI = baseUrl + '/auth/verify-otp';
  static var forgotPasswordResetPostAPI = baseUrl + '/auth/reset-password';




  static var suppportAPI = baseUrl + '/contact';//support
}
