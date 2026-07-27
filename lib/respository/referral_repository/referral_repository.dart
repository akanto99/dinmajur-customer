import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class ReferralRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> getMyReferralCodeApi() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(AppUrl.referralMyCodeGetAPI);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> getReferralOverviewApi() async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(AppUrl.referralOverviewGetAPI);
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// [source] is omitted for manual entry from the Referral screen (defaults
  /// server-side to POST_REGISTRATION) and set to 'DEEP_LINK' when applied
  /// automatically from a captured referral link.
  Future<dynamic> applyReferralCodeApi(String referralCode, {String? source}) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(AppUrl.referralApplyPostAPI, {
        'referralCode': referralCode,
        if (source != null) 'source': source,
      });
      return response;
    } catch (e) {
      throw e;
    }
  }
}
