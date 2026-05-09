import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/banner_model/banner_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/banner_repository/banner_repository.dart';
import 'package:flutter/foundation.dart';

class BannerViewModel with ChangeNotifier {
  final _myRepo = BannerRepository();

  ApiResponse<BannerModel> bannerData = ApiResponse.loading();

  setBannerData(ApiResponse<BannerModel> response) {
    bannerData = response;
    notifyListeners();
  }

  Future<void> fetchBannerData() async {
    setBannerData(ApiResponse.loading());

    _myRepo
        .fetchBannerData()
        .then((value) {

          setBannerData(ApiResponse.completed(value));
        })
        .onError((error, stackTrace) {

          setBannerData(ApiResponse.error(error.toString()));
        });
  }
}
