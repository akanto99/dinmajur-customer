import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';

class GetallPremiumHouseKeeperTaskRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<GetAllPermiumHouseKeeperTaskModel> fetchGetAllPremiumHouseKeeperTaskGetApi(String categoryId) async {
    try {
      // Append categoryId as query parameter
      final url = '${AppUrl.getAllPremiumHouseKeeperGetAPI}?categoryId=$categoryId';

      dynamic response = await _apiServices.getGetApiResponse(url);
      return GetAllPermiumHouseKeeperTaskModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}