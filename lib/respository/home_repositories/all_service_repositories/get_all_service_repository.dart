import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';

class GetAllServiceRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllServicesModel> fetchGetAllServicesGetApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        AppUrl.getAllServiceGetAPI,
      );
      return GetAllServicesModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}