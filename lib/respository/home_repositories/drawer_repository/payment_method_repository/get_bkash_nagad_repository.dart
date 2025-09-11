import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/drawer_models/payment_method_model/get_bkash_nagad_model.dart';

class GetBkashNagadRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetBkashNagadModel> getBkashNagadGETAPI(String paymentType) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
          "${AppUrl.paymentMethodBkashNagadGetAPI}$paymentType"
      );
      return GetBkashNagadModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }



  Future<GetBkashNagadModel> getAllBkashNagadGETAPI(String paymentType) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
          AppUrl.bkashNagadGetAPI
      );
      return GetBkashNagadModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}