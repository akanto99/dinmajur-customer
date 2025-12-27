//
// import 'package:dinmajur_customer/data/response/api_response.dart';
// import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
// import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// class GetLocationListViewModel with ChangeNotifier {
//   final _myRepo = GetLocationListRepository();
//
//
//   ApiResponse<GetLocationListDataModel> locationListData = ApiResponse.loading();
//
//   setLocationListLoading(ApiResponse<GetLocationListDataModel> response) {
//     locationListData = response;
//     notifyListeners();
//   }
//
//
//   Future<void> fetchLocationListApi() async {
//     setLocationListLoading(ApiResponse.loading());
//
//     _myRepo.fetchLocationListAPI().then((value){
//       print(value);
//       setLocationListLoading(ApiResponse.completed(value));
//
//
//     }).onError((error, stackTrace){
//       if (kDebugMode) {
//         print(error);
//         print(stackTrace);
//       }
//       setLocationListLoading(ApiResponse.error(error.toString()));
//     });
//   }
//
//
//
//
//
//
// }
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetLocationListViewModel with ChangeNotifier {
  final _myRepo = GetLocationListRepository();

  ApiResponse<GetLocationListDataModel> locationListData = ApiResponse.loading();

  // ✅ Cache control variables
  bool _isCached = false;
  bool get isCached => _isCached;

  setLocationListLoading(ApiResponse<GetLocationListDataModel> response) {
    locationListData = response;
    notifyListeners();
  }

  // ✅ Clear cache method (call this when adding new location or logout)
  void clearCache() {
    _isCached = false;
    locationListData = ApiResponse.loading();
    if (kDebugMode) {
      print('📍 GetLocationListViewModel: Cache cleared');
    }
    notifyListeners();
  }

  // ✅ Updated fetch method with caching logic
  Future<void> fetchLocationListApi({bool forceRefresh = false}) async {
    // If data is already cached and not forcing refresh, skip API call
    if (_isCached && !forceRefresh) {
      if (kDebugMode) {
        print('📍 GetLocationListViewModel: Using cached data');
      }
      return;
    }

    if (kDebugMode) {
      print('📍 GetLocationListViewModel: Fetching from API');
    }

    setLocationListLoading(ApiResponse.loading());

    _myRepo.fetchLocationListAPI().then((value) {
      if (kDebugMode) {
        print('📍 GetLocationListViewModel: Data fetched successfully');
        print(value);
      }
      setLocationListLoading(ApiResponse.completed(value));
      _isCached = true; // ✅ Mark as cached after successful fetch
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print('📍 GetLocationListViewModel: Error fetching data');
        print(error);
        print(stackTrace);
      }
      setLocationListLoading(ApiResponse.error(error.toString()));
      _isCached = false; // ✅ Don't cache on error
    });
  }

  // ✅ Optional: Method to refresh data (useful for pull-to-refresh)
  Future<void> refreshLocationList() async {
    await fetchLocationListApi(forceRefresh: true);
  }
}