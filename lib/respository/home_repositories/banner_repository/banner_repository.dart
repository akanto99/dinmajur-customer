import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/banner_model/banner_model.dart';

class BannerRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<BannerModel> fetchBannerData() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse("${AppUrl.bannerSliderGetAPI}");
      return response =BannerModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  /// Fetch one specific banner CMS document by id — used to render a
  /// banner in the exact position the admin's Home Page Layout order
  /// puts it in, rather than whichever doc the home_page placement query
  /// happens to pick.
  Future<BannerModel> fetchBannerById(String id) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse("${AppUrl.cmsByIdGetAPI}$id");
      return BannerModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}