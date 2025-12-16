import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_beautysalon_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/beauty_and_salon_repository/get_beautysalon_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetBeautySalonViewModel with ChangeNotifier {
  final _myRepo = GetBeautysalonRepository();

  ApiResponse<GetHomeBeautySalonModel> getBeautySalonData = ApiResponse.loading();

  setgetBeautySalonData(ApiResponse<GetHomeBeautySalonModel> response){
    getBeautySalonData = response ;
    notifyListeners();
  }


  Future<void> fetchGetBeautySalonDataApi (String byTrackId)async{

    setgetBeautySalonData(ApiResponse.loading());

    _myRepo.fetchBeautysalonGetApi(byTrackId).then((value){
      print(value);
      setgetBeautySalonData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setgetBeautySalonData(ApiResponse.error(error.toString()));
    });
  }





}