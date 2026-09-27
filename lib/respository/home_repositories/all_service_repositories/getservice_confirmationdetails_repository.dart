import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/getservice_confirmationdetails_model.dart';


class GetServicesConfirmationRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<ServiceConfirmationDetailsModel> fetchServiceViewGetApi(String byTrackId) async {
    try {
      // Authenticated read, so a signed-in customer gets their own booking in
      // full. The backend serves this route to guests as well, with the contact
      // details removed, so nothing breaks when nobody is logged in:
      // `_getAuthHeaders` simply omits Authorization and the response comes back
      // sanitised. Using the unauthenticated helper here meant even the owner
      // only ever received the sanitised payload once the backend stopped
      // handing customer contact details to anonymous callers.
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        "${AppUrl.getServiceTrackingIdGetAPI}/$byTrackId",
      );
      return ServiceConfirmationDetailsModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}