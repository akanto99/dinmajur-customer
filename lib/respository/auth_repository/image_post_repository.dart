
import 'dart:typed_data';

import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';


class ImagePostRepository {
  BaseApiServices _apiServices = NetworkApiService();
///P
  Future<dynamic> imagePostApi(
      Uint8List imageBytes,
      String accessToken,
      String fileName,
      String imageType,
      ) async {
    try {
      return await _apiServices.imageMultipartPostApiResponse(
        AppUrl.imageApi,
        fileName,
        imageType,
        imageBytes,
        headers: {
          'Authorization': '$accessToken',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}


