import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
class PostNewForgotPasswordRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> newPasswordPostAPI(dynamic data, String token) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.forgotPasswordResetPostAPI,
        data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
          'x-token-type':'reset-password',
        },
      );

      print('📥 Raw response body: $response');

      if (response['success'] == false) {
        String errorMsg = response['message'] ?? 'Unknown error occurred';

        if (response['errorMessages'] != null &&
            response['errorMessages'] is List &&
            response['errorMessages'].isNotEmpty) {
          errorMsg = response['errorMessages'][0]['message'] ?? response['message'] ?? errorMsg; // Fixed logic
        }

        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      throw e;
    }
  }
}