import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookPremiumHouseKeeperRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> bookPremiumHouseKeeperPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        AppUrl.bookPremiumHouseKeeperPostAPI,
        data,
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Authorization': '$accessToken',
        // },
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

}
