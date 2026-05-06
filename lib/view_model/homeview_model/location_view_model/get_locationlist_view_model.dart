import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
import 'package:flutter/cupertino.dart';

class GetLocationListViewModel with ChangeNotifier {
  final _myRepo = GetLocationListRepository();

  ApiResponse<GetLocationListDataModel> locationListData = ApiResponse.loading();

  bool _isCached = false;
  bool get isCached => _isCached;

  void _setLocationListData(ApiResponse<GetLocationListDataModel> response) {
    locationListData = response;
    notifyListeners();
  }

  void clearCache() {
    _isCached = false;
    locationListData = ApiResponse.loading();
    notifyListeners();
  }

  Future<void> fetchLocationListApi({bool forceRefresh = false}) async {
    if (_isCached && !forceRefresh) return;

    _setLocationListData(ApiResponse.loading());

    _myRepo.fetchLocationListAPI().then((value) {
      _setLocationListData(ApiResponse.completed(value));
      _isCached = true;
    }).onError((error, stackTrace) {
      _setLocationListData(ApiResponse.error(error.toString()));
      _isCached = false;
    });
  }

  Future<void> refreshLocationList() async {
    await fetchLocationListApi(forceRefresh: true);
  }
}