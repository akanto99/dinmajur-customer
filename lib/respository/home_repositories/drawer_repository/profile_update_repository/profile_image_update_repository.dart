import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';

class PatchprofileImageUpdateRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future profileImageUpdatePatchApi(
      Uint8List imageBytes,
      String accessToken,
      String imageType,
      String fileName,
      ) async {
    try {
      return await _apiServices.getPatchApiImageCoverResponse(
        AppUrl.patchImageUpdateApi,
        fileName,
        imageBytes,
        imageType,
        headers: {'Authorization': accessToken},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> imageAndCoverUploadPatchApi(
      Uint8List imageBytes,
      String accessToken,
      String imageType,
      String fileName
      ) async {
    try {
      return await _apiServices.getPatchApiImageCoverResponse(
     "   AppUrl.image_CoverImage_patchApi,",
        fileName,
        imageBytes,
        imageType,
        headers: {'Authorization': accessToken},
      );
    } catch (e) {
      rethrow;
    }
  }
}