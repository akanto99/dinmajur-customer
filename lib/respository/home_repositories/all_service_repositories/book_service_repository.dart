import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class BookServiceRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> bookServicePostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.createServiceBookingPostAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}