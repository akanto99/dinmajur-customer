import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteLocationRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> deleteAddressDeleteApi(String addressId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      dynamic response = await _apiServices.getDeleteApiResponse(
        "${AppUrl.deleteAddressDeleteAPI}/$addressId",
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