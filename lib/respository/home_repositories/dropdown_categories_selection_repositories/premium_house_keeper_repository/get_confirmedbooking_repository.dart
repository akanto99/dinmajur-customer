import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/get_confirmedbooking_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_shittime_model.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetConfirmedbookingRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetConfirmedBookingModel> fetchGetConfirmedBookingGetApi(String byTrackId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        "${AppUrl.getBookingByTrackingIdGetAPI}/$byTrackId",
      );
      return GetConfirmedBookingModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}