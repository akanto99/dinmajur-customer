import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
class PatchProfileHeaderUpateRepository {
  BaseApiServices _apiServices = NetworkApiService();


  Future<dynamic> profileHeaderUpdatePatchAPI(String? accessToken, Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiServices.getPatchApiResponse(
        AppUrl.profileHeaderUpdatePatchAPI,
        data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}

