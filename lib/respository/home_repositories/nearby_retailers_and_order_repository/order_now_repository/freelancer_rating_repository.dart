import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PatchFreelancerRatingRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> freelancerRatingPatchApi( dynamic data) async {
    try {
      dynamic response = await _apiServices.getPatchApiResponse(
        "${AppUrl.freelancerRatingPatchAPI}",
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}