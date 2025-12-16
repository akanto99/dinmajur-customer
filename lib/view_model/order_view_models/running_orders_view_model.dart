import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class RunningOrdersViewModel with ChangeNotifier {
  final _myRepo = GetRunningOrderRepository();

  ApiResponse<GetAllOrderModel> runningOrdersData = ApiResponse.loading();
  ApiResponse<GetAllOrderModel> pendingOrdersData = ApiResponse.loading();

  setPendingOrdersData(ApiResponse<GetAllOrderModel> response){
    pendingOrdersData = response ;
    notifyListeners();
  }

  setRunningOrdersData(ApiResponse<GetAllOrderModel> response){
    runningOrdersData = response ;
    notifyListeners();
  }


  Future<void> fetchRunningOrdersGetDataApi ()async{

    setRunningOrdersData(ApiResponse.loading());

    _myRepo.fetchRunningOrderGetApi().then((value){
      print(value);
      setRunningOrdersData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setRunningOrdersData(ApiResponse.error(error.toString()));
    });
  }

  Future<void> fetchPendingOrdersGetDataApi ()async{

    setPendingOrdersData(ApiResponse.loading());

    _myRepo.fetchPendingOrderGetApi().then((value){
      print(value);
      setPendingOrdersData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setPendingOrdersData(ApiResponse.error(error.toString()));
    });
  }




}