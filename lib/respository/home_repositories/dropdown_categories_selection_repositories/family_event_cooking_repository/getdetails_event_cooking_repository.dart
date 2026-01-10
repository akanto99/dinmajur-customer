import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getdetails_family_event_booking_model.dart';


class GetDetailsEventCookingRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetDetailesFamilyEventBookingModel> fetchFemilyEventCookingGetApi(String byTrackId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.getFamilyEventCookingGetAPI}/$byTrackId",
      );
      return GetDetailesFamilyEventBookingModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}