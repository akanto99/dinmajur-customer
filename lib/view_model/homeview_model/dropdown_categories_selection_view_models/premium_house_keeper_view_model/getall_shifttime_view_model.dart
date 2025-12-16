import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_shittime_model.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/getall_premium_house_keeper_task_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/getall_shifttime_repository.dart';
import 'package:dinmajur_customer/respository/order_repositories/complete_order_repositoy.dart';
import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetallShifttimeViewModel with ChangeNotifier {
  final _myRepo = GetallShifttimeRepository();

  ApiResponse<GetAllShiftTimeModel> getAllShiftTimeData = ApiResponse.loading();

  setgetAllShiftTimeData(ApiResponse<GetAllShiftTimeModel> response){
    getAllShiftTimeData = response ;
    notifyListeners();
  }


  Future<void> fetchGetAllsetgetAllShiftTimeGetDataApi (String byDate)async{

    setgetAllShiftTimeData(ApiResponse.loading());

    _myRepo.fetchGetAllShiftTimeGetApi(byDate).then((value){
      print(value);
      setgetAllShiftTimeData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setgetAllShiftTimeData(ApiResponse.error(error.toString()));
    });
  }





}