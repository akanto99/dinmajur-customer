import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetallPremiumHomeBeautySalonRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllPermiumHomeBeautySalonModel> fetchGetallPremiumHomeBeautySalonGetApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      dynamic response = await _apiServices.getGetApiResponse(
        AppUrl.getAllPremiumHomeBeautySalonGetAPI,
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Authorization': '$accessToken',
        // },
      );
      return GetAllPermiumHomeBeautySalonModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}