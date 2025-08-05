import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PatchImageUpdateRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> imageUpdatePatchApi(
      Uint8List imageBytes,
      String accessToken,
      // String imageType,
      String fileName,) async {
    try {
      return await _apiServices.getPatchApiImageResponse(
        AppUrl.patchImageUpdateApi,
        fileName,
        imageBytes,
        // imageType,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
