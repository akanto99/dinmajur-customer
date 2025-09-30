
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetLocationListViewModel with ChangeNotifier {
  final _myRepo = GetLocationListRepository();


  ApiResponse<GetLocationListDataModel> locationListData = ApiResponse.loading();

  setLocationListLoading(ApiResponse<GetLocationListDataModel> response) {
    locationListData = response;
    notifyListeners();
  }


  Future<void> fetchLocationListApi() async {
    setLocationListLoading(ApiResponse.loading());

    _myRepo.fetchLocationListAPI().then((value){
      print(value);
      setLocationListLoading(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setLocationListLoading(ApiResponse.error(error.toString()));
    });
  }






}