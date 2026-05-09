import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/getservice_confirmationdetails_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/getservice_confirmationdetails_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetServiceConfirmationDetailsViewModel with ChangeNotifier {
  final _myRepo = GetServicesConfirmationRepository();

  ApiResponse<ServiceConfirmationDetailsModel> getServiceData = ApiResponse.loading();

  setGetServiceData(ApiResponse<ServiceConfirmationDetailsModel> response){
    getServiceData = response ;
    notifyListeners();
  }


  Future<void> fetchGetServiceDataApi (String byTrackId)async{

    setGetServiceData(ApiResponse.loading());

    _myRepo.fetchServiceViewGetApi(byTrackId).then((value){
      print(value);
      setGetServiceData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      setGetServiceData(ApiResponse.error(error.toString()));
    });
  }





}