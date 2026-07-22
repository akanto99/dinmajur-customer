import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class CouponRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> validateCouponPostApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.gePostApiWithHeaderesponse(
        AppUrl.couponValidateAPI,
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> getAvailableCouponsApi({String? serviceId, String? serviceKey}) async {
    try {
      final query = <String, String>{
        if (serviceId != null) 'serviceId': serviceId,
        if (serviceKey != null) 'serviceKey': serviceKey,
      };
      final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
      final url = queryString.isEmpty ? AppUrl.couponAvailableAPI : '${AppUrl.couponAvailableAPI}?$queryString';
      dynamic response = await _apiServices.getGetApiWithHeaderResponse(url);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
