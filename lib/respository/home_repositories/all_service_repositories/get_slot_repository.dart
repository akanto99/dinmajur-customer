import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_bookedslot_model.dart';

class GetSlotRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetBookedTimeSlotModel> fetchSlotGetApi(String bookedDate, String serviceId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.getSlotGetAPI}$bookedDate&serviceId=$serviceId",
      );
      return GetBookedTimeSlotModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}