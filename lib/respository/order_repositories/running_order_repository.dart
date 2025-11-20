import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetRunningOrderRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllOrderModel> fetchRunningOrderGetApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        AppUrl.runningOrderGetAPI,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );

      // Parse the Map response to GetAllOrderModel
      return GetAllOrderModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
  Future<GetAllOrderModel> fetchPendingOrderGetApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        AppUrl.pendingOrderGetAPI,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );

      // Parse the Map response to GetAllOrderModel
      return GetAllOrderModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}