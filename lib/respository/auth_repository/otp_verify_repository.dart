import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';


class OtpVerifyRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> otpVerify(dynamic data, String token) async {
    try {
      return await _apiServices.getOTPPostApiResponse(
        AppUrl.otpVerify,
        data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
    } catch (e) {
      rethrow;
    }
  }



}
