import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/profile_model/profileview_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/profile_repository/profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ProfileViewViewModel with ChangeNotifier {
  final _myRepo = ProfileRepository();

  ApiResponse<ProfileViewModel> profileviewUserData = ApiResponse.loading();

  setProfileViewUserData(ApiResponse<ProfileViewModel> response){
    profileviewUserData = response ;
    notifyListeners();
  }


  Future<void> fetchProfileViewUserDataApi ()async{

    setProfileViewUserData(ApiResponse.loading());

    _myRepo.fetchProfileUserData().then((value){
      print(value);
      setProfileViewUserData(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setProfileViewUserData(ApiResponse.error(error.toString()));
    });
  }





}