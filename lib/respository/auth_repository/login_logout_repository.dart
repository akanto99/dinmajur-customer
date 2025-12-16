import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:http/http.dart' as https;

class LoginLogoutRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.loginEndPint, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logoutApi(String token) async {
    try {
      dynamic response = await _apiServices.getPostApiWithOutBodyresponse(AppUrl.logOutEndPoint,
          headers: {'Authorization': '$token'});
      return response;
    } catch (e) {
      throw e;
    }
  }

}
