import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/home_sections_model/home_sections_model.dart';

class HomeSectionsRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<HomeSectionsModel> fetchHomeSections() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        AppUrl.homeSectionsGetAPI,
      );
      return HomeSectionsModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}
