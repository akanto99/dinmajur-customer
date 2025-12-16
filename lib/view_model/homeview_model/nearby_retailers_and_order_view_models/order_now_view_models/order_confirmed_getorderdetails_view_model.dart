import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_and_order_repository/order_now_repository/order_confirmed_getorderdetails_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetOrderDetailsViewModel with ChangeNotifier {
  final _myRepo = OrderDetailsRepository();

  ApiResponse<GetOrderDetailsModel>orderDetailsData = ApiResponse.loading();

  setorderDetailsData(ApiResponse<GetOrderDetailsModel> response){
    orderDetailsData = response ;
    notifyListeners();
  }


  Future<void> fetchOrderDetailsData(String orderId) async{

    setorderDetailsData(ApiResponse.loading());

    _myRepo.fetchOrderDetailsData(orderId).then((value){
      print(value);
      setorderDetailsData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setorderDetailsData(ApiResponse.error(error.toString()));
    });
  }





}