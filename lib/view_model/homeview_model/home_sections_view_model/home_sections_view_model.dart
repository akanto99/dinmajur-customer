import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/home_sections_model/home_sections_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/home_sections_repository/home_sections_repository.dart';
import 'package:flutter/foundation.dart';

class HomeSectionsViewModel with ChangeNotifier {
  final _myRepo = HomeSectionsRepository();

  ApiResponse<HomeSectionsModel> homeSectionsData = ApiResponse.loading();

  setHomeSectionsData(ApiResponse<HomeSectionsModel> response) {
    homeSectionsData = response;
    notifyListeners();
  }

  Future<void> fetchHomeSections() async {
    setHomeSectionsData(ApiResponse.loading());

    _myRepo
        .fetchHomeSections()
        .then((value) {
          setHomeSectionsData(ApiResponse.completed(value));
        })
        .onError((error, stackTrace) {
          setHomeSectionsData(ApiResponse.error(error.toString()));
        });
  }
}
