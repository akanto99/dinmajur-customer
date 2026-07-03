import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/nearby_service_stores_model/getall_nearby_service_stores_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/nearby_service_stores_repository/nearby_service_stores_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetAllNearbyServicStoresViewModel with ChangeNotifier {
  final _myRepo = GetAllNearbyServiceStoresRepository();

  ApiResponse<GetAllNearbyServiceStoresModel> getAllNearbyServiceStoresData = ApiResponse.loading();

  setgetAllServicesData(ApiResponse<GetAllNearbyServiceStoresModel> response) {
    getAllNearbyServiceStoresData = response;
    notifyListeners();
  }

  Future<void> fetchGetAllNearbyServiceStores(String serviceId) async {
    setgetAllServicesData(ApiResponse.loading());

    _myRepo
        .fetchGetAllServicesGetApi(serviceId)
        .then((value) {
          setgetAllServicesData(ApiResponse.completed(value));
        })
        .onError((error, stackTrace) {
          setgetAllServicesData(ApiResponse.error(error.toString()));
        });
  }
}
