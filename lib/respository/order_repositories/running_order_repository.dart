import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';

class GetRunningOrderRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllOrderModel> fetchRunningOrderGetApi({
    required int page,
    required int limit,
  }) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        '${AppUrl.runningOrderGetAPI}&page=$page&limit=$limit',
      );

      return GetAllOrderModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  Future<GetAllOrderModel> fetchPendingOrderGetApi({
    required int page,
    required int limit,
  }) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        '${AppUrl.pendingOrderGetAPI}&page=$page&limit=$limit',
      );

      return GetAllOrderModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  Future<GetAllOrderModel> fetchCompleteOrderGetApi({
    required int page,
    required int limit,
  }) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        '${AppUrl.completedOrderGetAPI}&page=$page&limit=$limit',
      );

      return GetAllOrderModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}