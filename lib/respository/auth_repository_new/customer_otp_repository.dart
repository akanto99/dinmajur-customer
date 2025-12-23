import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';


class AuthOtpVerifyRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> authOtpVerify(dynamic data, String token) async {
    try {
      return await _apiServices.getOTPPostApiResponse(
        AppUrl.customerAuthOtpVeryfyApi,
        data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
          'x-token-type':'auth-otp',
        },
      );
    } catch (e) {
      rethrow;
    }
  }



}
