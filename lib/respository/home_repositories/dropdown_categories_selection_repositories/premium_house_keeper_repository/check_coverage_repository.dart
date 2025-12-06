import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/check_coverage_model.dart';
import 'package:dinmajur_customer/model/home_models/profile_model/profileview_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckCoverageRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<CheckCoverageModel> fetchCheckCoverageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(
        "${AppUrl.checkCoverageGetAPI}",
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );
      return response =CheckCoverageModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}