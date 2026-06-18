import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class ApproveBookingRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> approveBookingApi({
    required String bookingId,
    required dynamic data,
  }) async {
    try {
      dynamic response = await _apiServices.getPatchApiResponse(
        "${AppUrl.approveBookingPostAPI}/$bookingId",
        data,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}