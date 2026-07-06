import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_housekeeper_category_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/getall_housekeeper_category_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetallHousekeeperCategoryViewModel with ChangeNotifier {
  final _myRepo = GetallHousekeeperCategoryRepository();

  ApiResponse<GetAllHouseKeeperCategoryModel> getAllHouseKeeperCategoryData = ApiResponse.loading();

  setgetAllHouseKeeperCategoryData(ApiResponse<GetAllHouseKeeperCategoryModel> response){
    getAllHouseKeeperCategoryData = response ;
    notifyListeners();
  }


  Future<void> fetchGetAllHouseKeeperCategoryGetApi ()async{

    setgetAllHouseKeeperCategoryData(ApiResponse.loading());

    _myRepo.fetchGetAllHouseKeeperCategoryGetApi().then((value){
      setgetAllHouseKeeperCategoryData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      setgetAllHouseKeeperCategoryData(ApiResponse.error(error.toString()));
    });
  }
}