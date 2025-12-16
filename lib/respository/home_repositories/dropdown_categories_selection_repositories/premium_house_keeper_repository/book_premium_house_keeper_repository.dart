// import 'package:dinmajur_customer/configs/res/app_url.dart';
// import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
// import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BookPremiumHouseKeeperRepository {
//   BaseApiServices _apiServices = NetworkApiService();
//
//   Future<dynamic> bookPremiumHouseKeeperPostApi(dynamic data) async {
//     try {
//       dynamic response = await _apiServices.getPostApiResponse(
//         AppUrl.bookPremiumHouseKeeperPostAPI,
//         data
//       );
//       return response;
//     } catch (e) {
//       throw e;
//     }
//   }
//
// }
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class BookPremiumHouseKeeperRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> bookPremiumHouseKeeperPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.bookPremiumHouseKeeperPostAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}