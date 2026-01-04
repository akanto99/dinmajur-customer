import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';

class GetAllFamilyEventCookingRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllFamilyEventCookingModel> fetchGetAllFamilyEventCookingGetApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        AppUrl.getAllPremiumHomeBeautySalonGetAPI,
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Authorization': '$accessToken',
        // },
      );
      return GetAllFamilyEventCookingModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}