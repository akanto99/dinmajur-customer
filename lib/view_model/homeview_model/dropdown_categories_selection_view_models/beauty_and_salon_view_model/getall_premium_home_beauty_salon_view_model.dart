import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/beauty_and_salon_repository/getall_premium_home_beauty_salon_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetallPremiumHomeBeautySalonViewModel with ChangeNotifier {
  final _myRepo = GetallPremiumHomeBeautySalonRepository();

  ApiResponse<GetAllPermiumHomeBeautySalonModel> getAllPremiumHomeBeautySalonData = ApiResponse.loading();

  setgetAllPremiumHomeBeautySalonData(ApiResponse<GetAllPermiumHomeBeautySalonModel> response){
    getAllPremiumHomeBeautySalonData = response ;
    notifyListeners();
  }


  Future<void> fetchGetAllPermiumHomeBeautySalonGetDataApi ()async{

    setgetAllPremiumHomeBeautySalonData(ApiResponse.loading());

    try {
      final value = await _myRepo.fetchGetallPremiumHomeBeautySalonGetApi();
      setgetAllPremiumHomeBeautySalonData(ApiResponse.completed(value));
    } catch (error) {
      setgetAllPremiumHomeBeautySalonData(ApiResponse.error(error.toString()));
    }
  }





}