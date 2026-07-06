import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/featured_services_model/featured_services_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/featured_services_repository/featured_services_repository.dart';
import 'package:flutter/foundation.dart';

class FeaturedServicesViewModel with ChangeNotifier {
  final _repo = FeaturedServicesRepository();

  ApiResponse<FeaturedServicesModel> featuredServicesData = ApiResponse.loading();

  void _setData(ApiResponse<FeaturedServicesModel> response) {
    featuredServicesData = response;
    notifyListeners();
  }

  Future<void> fetchFeaturedServices() async {
    _setData(ApiResponse.loading());
    _repo
        .fetchFeaturedServices()
        .then((value) => _setData(ApiResponse.completed(value)))
        .onError((error, _) => _setData(ApiResponse.error(error.toString())));
  }
}
