import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class SslPaymentFailedRepository {
  BaseApiServices _apiServices = NetworkApiService();


  Future<dynamic> sslPaymentFailedAPI(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.sslPaymentFailed,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}

