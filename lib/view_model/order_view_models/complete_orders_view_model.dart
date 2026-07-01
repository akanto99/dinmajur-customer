import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/respository/order_repositories/complete_order_repositoy.dart';
import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CompleteOrdersViewModel with ChangeNotifier {
  final _myRepo = GetCompleteOrderRepository();

  ApiResponse<GetAllOrderModel> completeOrdersData = ApiResponse.loading();

  setCompleteOrdersData(ApiResponse<GetAllOrderModel> response){
    completeOrdersData = response ;
    notifyListeners();
  }


  Future<void> fetchCompleteOrdersGetDataApi ()async{

    setCompleteOrdersData(ApiResponse.loading());

    _myRepo.fetchCompleteOrderGetApi().then((value){
      setCompleteOrdersData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      setCompleteOrdersData(ApiResponse.error(error.toString()));
    });
  }





}