import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_housekeeper_category_model.dart';

class GetallHousekeeperCategoryRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllHouseKeeperCategoryModel> fetchGetAllHouseKeeperCategoryGetApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        AppUrl.getAllPremiumHouseKeeperCategoryGetAPI,
      );
      return GetAllHouseKeeperCategoryModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}