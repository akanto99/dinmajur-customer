import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/get_confirmedbooking_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/get_confirmedbooking_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetConfirmedbookingViewModel with ChangeNotifier {
  final _myRepo = GetConfirmedbookingRepository();

  ApiResponse<GetConfirmedBookingModel> getConfirmBookingData = ApiResponse.loading();

  setgetConfirmBookingData(ApiResponse<GetConfirmedBookingModel> response){
    getConfirmBookingData = response ;
    notifyListeners();
  }


  Future<void> fetchGetConfirmBookingDataApi (String byTrackId)async{

    setgetConfirmBookingData(ApiResponse.loading());

    _myRepo.fetchGetConfirmedBookingGetApi(byTrackId).then((value){
      print(value);
      setgetConfirmBookingData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setgetConfirmBookingData(ApiResponse.error(error.toString()));
    });
  }





}