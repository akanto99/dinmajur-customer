import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostNearbyRetailersRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> nearbyRetailersPostApi(dynamic data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.nearbyRetailersPostAPI,
        data,
        ///Added AuthHeader in Network Service without it response 401 not worked
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
