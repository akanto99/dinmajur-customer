import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class SupportRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> supportPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        AppUrl.suppportAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

}
