import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class BookPremiumHomeBeautySalonRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> bookPremiumHomeBeautySalonPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.bookPremiumHomeBeautySalonPostAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}