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
  static var otpVerify = baseUrl + '/auth/verify-registration-otp';
  static var imageApi= baseUrl + '/users/upload-profile-picture';


  static var logOutEndPoint = baseUrl + '/api/app/logout';



  ///Home
  static var viewProfile = baseUrl + '/users/get-user-data';
  ///=========>
  static var profileHeaderUpdatePatchAPI = baseUrl + '/users/update-me';
  static var patchImageUpdateApi= baseUrl + '/users/update-profile-picture';
  static var uploadThumnailPostApi= baseUrl + '/users/upload-profile-picture';
  static var changePasswordPostAPI = baseUrl + "/auth/change-password";

  ///Forgot Password
  static var forgotOtpSendPostAPI = baseUrl + '/auth/forgot-password';
  static var forgotOtpVerifyPostAPI = baseUrl + '/auth/verify-forgot-password-otp';
  static var forgotPasswordResetPostAPI = baseUrl + '/auth/reset-password';





}
