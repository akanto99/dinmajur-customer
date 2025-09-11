import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class AccountUpdateRepository {
  BaseApiServices _apiServices = NetworkApiService();


  Future<dynamic> accountPatchAPI(String? accessToken,String? id, Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiServices.getPatchApiResponse(
        "${AppUrl.accountUpdatePatchAPI}/$id",
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

