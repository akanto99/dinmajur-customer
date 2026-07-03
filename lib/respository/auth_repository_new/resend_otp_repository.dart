import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';


class ResendOtpRepository {
  BaseApiServices _apiServices = NetworkApiService();


  Future<dynamic> resendOtp(dynamic data) async {
    try {
      dynamic response = await _apiServices.getsamePostApiResponse(AppUrl.resendOtpApi, data,
        headers: {
          'x-token-type':'auth-otp',
        },
      );

      if (response['success'] == false) {
        String errorMsg = response['message'] ?? 'Unknown error occurred';

        if (response['errorMessages'] != null &&
            response['errorMessages'] is List &&
            response['errorMessages'].isNotEmpty) {
          errorMsg = response['errorMessages'][0]['message'] ?? errorMsg;
        }

        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      throw e;
    }
  }


}
