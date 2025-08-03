import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PostForgotOtpSendRepository {
  BaseApiServices _apiServices = NetworkApiService(); // Fixed: underscore instead of asterisk

  Future<dynamic> otpSendPostAPI(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.forgotOtpSendPostAPI, data); // Fixed: underscore instead of asterisk
      print('📥 Raw response body: $response');

      if (response['success'] == false) {
        String errorMsg = response['message'] ?? 'Unknown error occurred';

        if (response['errorMessages'] != null &&
            response['errorMessages'] is List &&
            response['errorMessages'].isNotEmpty) {
          errorMsg = response['message'] ?? errorMsg;
          print("-------------");
        }

        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      throw e;
    }
  }
}