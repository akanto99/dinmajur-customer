import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class GroceryPaymentRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> groceryPaymentPatchApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPatchApiResponse(
        AppUrl.groceryPaymnetPatchAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}