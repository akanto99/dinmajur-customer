import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getdetails_family_event_booking_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/family_event_cooking_repository/getdetails_event_cooking_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetDetailsEventCookingViewModel with ChangeNotifier {
  final _myRepo = GetDetailsEventCookingRepository();

  ApiResponse<GetDetailesFamilyEventBookingModel> getDetailsEventCookingData = ApiResponse.loading();

  setDetailsEventCookingData(ApiResponse<GetDetailesFamilyEventBookingModel> response){
    getDetailsEventCookingData = response ;
    notifyListeners();
  }


  Future<void> fetchgetDetailsEventCookingDataApi (String byTrackId)async{

    setDetailsEventCookingData(ApiResponse.loading());

    _myRepo.fetchFemilyEventCookingGetApi(byTrackId).then((value){
      setDetailsEventCookingData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      setDetailsEventCookingData(ApiResponse.error(error.toString()));
    });
  }





}