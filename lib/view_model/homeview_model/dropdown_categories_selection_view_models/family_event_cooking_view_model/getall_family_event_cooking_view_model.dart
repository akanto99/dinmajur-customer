import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/family_event_cooking_repository/getall_family_event_cooking_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetAllFamilyEventCookingViewModel with ChangeNotifier {
  final _myRepo = GetAllFamilyEventCookingRepository();

  ApiResponse<GetAllFamilyEventCookingModel> getAllFamilyEventCookingData = ApiResponse.loading();

  setgetAllFamilyEventCookingData(ApiResponse<GetAllFamilyEventCookingModel> response){
    getAllFamilyEventCookingData = response ;
    notifyListeners();
  }


  Future<void> fetchGetAllFamilyEventCookingGetDataApi ()async{

    setgetAllFamilyEventCookingData(ApiResponse.loading());

    _myRepo.fetchGetAllFamilyEventCookingGetApi().then((value){
      setgetAllFamilyEventCookingData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      setgetAllFamilyEventCookingData(ApiResponse.error(error.toString()));
    });
  }





}