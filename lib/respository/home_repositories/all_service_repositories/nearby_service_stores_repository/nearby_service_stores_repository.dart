import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/nearby_service_stores_model/getall_nearby_service_stores_model.dart';

class GetAllNearbyServiceStoresRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllNearbyServiceStoresModel> fetchGetAllServicesGetApi(String ServiceId) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
          "${AppUrl.getAllNearbyServiceStoresGetAPI}?serviceId=$ServiceId"
      );
      return GetAllNearbyServiceStoresModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}