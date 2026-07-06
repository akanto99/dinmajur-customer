import 'dart:convert';
import 'dart:typed_data';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/patch_Image_update_repository/patch_Image_update_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUpdateViewModel with ChangeNotifier {
  final _myRepo = PatchImageUpdateRepository();

  bool _imageUpdateLoading = false;
  bool get imageUpdateLoading => _imageUpdateLoading;

  void setImageUpdateLoading(bool value) {
    _imageUpdateLoading = value;
    notifyListeners();
  }

  Future<void> imageUpdatePatchApi(
      Uint8List imageBytes,
      String fileName,
      String imageTypes,
      BuildContext context,
      {VoidCallback? onComplete}
      ) async {
    setImageUpdateLoading(true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setImageUpdateLoading(false);
        onComplete?.call();
        return;
      }

      // Fixed: Pass all required parameters
      await _myRepo.imageUpdatePatchApi(
          imageBytes,
          accessToken,
          fileName
      );

      setImageUpdateLoading(false);


      Utils.flushBarSuccessMessage('Image updated successfully', context);
      onComplete?.call();

    } catch (error) {
      setImageUpdateLoading(false);
      _handleError(error, context);
      onComplete?.call();
    }
  }

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = error.toString();

    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');

      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List &&
                decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }
}
