import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/featured_services_model/featured_services_model.dart';

class FeaturedServicesRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<FeaturedServicesModel> fetchFeaturedServices() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(AppUrl.featuredServicesGetAPI);
      return FeaturedServicesModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}
