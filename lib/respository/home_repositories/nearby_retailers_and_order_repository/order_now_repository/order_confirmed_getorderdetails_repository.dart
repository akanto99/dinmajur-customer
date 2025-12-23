import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetOrderDetailsModel> fetchOrderDetailsData(String orderId) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? accessToken = sp.getString('accessToken');

    // Check if token exists
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found. Please auth_login again.');
    }

    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        "${AppUrl.orderDetailsGetAPI}/$orderId",
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Authorization': '$accessToken',
        // },
      );
      return GetOrderDetailsModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}