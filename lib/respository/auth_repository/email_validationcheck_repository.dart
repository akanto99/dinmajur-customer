import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';


class EmailValidationCheckRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> emailValidationCheck(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.emailCheckEndPoint, data);
      return response;
    } catch (e) {
      throw e;
    }
  }


}
