import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/getservice_confirmationdetails_model.dart';


class GetServicesConfirmationRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<ServiceConfirmationDetailsModel> fetchServiceViewGetApi(String byTrackId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.getServiceTrackingIdGetAPI}/$byTrackId",
      );
      return ServiceConfirmationDetailsModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}