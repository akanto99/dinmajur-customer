import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PostNearbyRetailersRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> nearbyRetailersPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.nearbyRetailersPostAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

}
