import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_timeslot_model.dart';

class GetSlotRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetTimeSlotModel> fetchSlotGetApi(String bookedDate, String serviceId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.getSlotGetAPI}$bookedDate&serviceId=$serviceId",
      );
      return GetTimeSlotModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}