import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/getall_premium_house_keeper_task_repository.dart';
import 'package:dinmajur_customer/respository/order_repositories/complete_order_repositoy.dart';
import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetallPremiumHouseKeeperTaskViewModel with ChangeNotifier {
  final _myRepo = GetallPremiumHouseKeeperTaskRepository();

  ApiResponse<GetAllPermiumHouseKeeperTaskModel> getAllPremiumHouseKeeperTaskData = ApiResponse.loading();

  setgetAllPremiumHouseKeeperTaskData(ApiResponse<GetAllPermiumHouseKeeperTaskModel> response){
    getAllPremiumHouseKeeperTaskData = response ;
    notifyListeners();
  }


  Future<void> fetchGetAllPermiumHouseKeeperTaskGetDataApi ()async{

    setgetAllPremiumHouseKeeperTaskData(ApiResponse.loading());

    _myRepo.fetchGetAllPremiumHouseKeeperTaskGetApi().then((value){
      print(value);
      setgetAllPremiumHouseKeeperTaskData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setgetAllPremiumHouseKeeperTaskData(ApiResponse.error(error.toString()));
    });
  }





}