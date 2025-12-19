import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class RefreshTokenRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  /// Refresh access token using refresh token
  Future<dynamic> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _apiServices.gePostApiWithHeaderesponse(
        '${AppUrl.baseUrl}${AppUrl.refreshTokenEndpoint}',
        {'refreshToken': refreshToken},
        headers: {
          'Content-Type': 'application/json',
          'Authorization': refreshToken,
        },
      );
      return response;
    } catch (e) {
      throw e;
    }
  }
}