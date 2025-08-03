import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PatchImageUpdateRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> imageUpdatePatchApi(Uint8List imageBytes, String accesstoken) async {
    try {
      return await _apiServices.getPatchApiImageResponse(
        AppUrl.patchImageUpdateApi,
        imageBytes,
        headers: {
          'Authorization': '$accesstoken',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

