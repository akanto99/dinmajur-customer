import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/profile_model/profileview_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<ProfileViewModel> fetchProfileUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('id');
    print("usaser id $userID");
    ///6860e54d7ef33b5157635834
    try {
      dynamic response = await _apiServices.getGetApiResponse("${AppUrl.viewProfile}/$userID");
      // dynamic response = await _apiServices.getGetApiResponse("${AppUrl.viewProfile}/6860e54d7ef33b5157635834");
      return response =ProfileViewModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}