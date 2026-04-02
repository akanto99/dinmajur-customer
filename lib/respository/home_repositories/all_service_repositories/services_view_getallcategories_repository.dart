import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';

class ServicesViewGetAllCategoriesRepository{
  BaseApiServices _apiServices = NetworkApiService();

  Future<ServicesViewGetAllCategoryModel> fetchServicesViewGetAllCategoriesGetApi(String serviceId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.servicesViewGetAllCategoryGetAPI}/$serviceId",
      );
      return ServicesViewGetAllCategoryModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}