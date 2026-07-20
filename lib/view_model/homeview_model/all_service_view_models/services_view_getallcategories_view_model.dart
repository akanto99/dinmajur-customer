import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/services_view_getallcategories_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ServicesViewGetAllCategoriesViewModel with ChangeNotifier {
  final _myRepo = ServicesViewGetAllCategoriesRepository();

  ApiResponse<ServicesViewGetAllCategoryModel> servicesViewGetAllCategoryData = ApiResponse.loading();

  setServicesViewGetAllCategoryData(ApiResponse<ServicesViewGetAllCategoryModel> response) {
    servicesViewGetAllCategoryData = response;
    notifyListeners();
  }

  Future<void> fetchServicesViewGetAllCategoriesGetApi(String serviceId, String ?userId) async {
    setServicesViewGetAllCategoryData(ApiResponse.loading());

    try {
      final value = await _myRepo.fetchServicesViewGetAllCategoriesGetApi(serviceId, userId);
      setServicesViewGetAllCategoryData(ApiResponse.completed(value));
    } catch (error) {
      setServicesViewGetAllCategoryData(ApiResponse.error(error.toString()));
    }
  }
}
