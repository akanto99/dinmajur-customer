import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/check_coverage_model.dart';

class CheckCoverageRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<CheckCoverageModel> fetchCheckCoverageData() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse("${AppUrl.checkCoverageGetAPI}",);
      return CheckCoverageModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}