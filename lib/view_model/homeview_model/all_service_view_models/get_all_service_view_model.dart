import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/get_all_service_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetAllServiceViewModel with ChangeNotifier {
  final _myRepo = GetAllServiceRepository();

  ApiResponse<GetAllServicesModel> getAllServicesData = ApiResponse.loading();

  setgetAllServicesData(ApiResponse<GetAllServicesModel> response) {
    getAllServicesData = response;
    notifyListeners();
  }

  Future<void> fetchGetAllServices() async {
    setgetAllServicesData(ApiResponse.loading());

    _myRepo
        .fetchGetAllServicesGetApi()
        .then((value) {
          setgetAllServicesData(ApiResponse.completed(value));
        })
        .onError((error, stackTrace) {
          setgetAllServicesData(ApiResponse.error(error.toString()));
        });
  }
}
