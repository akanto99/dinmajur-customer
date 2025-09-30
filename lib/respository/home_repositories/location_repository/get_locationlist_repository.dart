

import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';

class GetLocationListRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetLocationListDataModel> fetchLocationListAPI() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(AppUrl.locationListGetAPI);
      return GetLocationListDataModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}
