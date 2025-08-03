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

  setimageUpdateLoading(bool value) {
    _imageUpdateLoading = value;
    notifyListeners();
  }

  Future<void> imageUpdatePatchApi(Uint8List imageBytes, BuildContext context, {VoidCallback? onComplete}) async {
    setimageUpdateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');

      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setimageUpdateLoading(false);
        if (onComplete != null) onComplete();
        return;
      }

      final value = await _myRepo.imageUpdatePatchApi(imageBytes, AToken);
      setimageUpdateLoading(false);

      if (kDebugMode) {
        print('Response from image upload: $value');
      }

      Utils.flushBarSuccessMessage('Image updated successfully', context);

      // Just call the completion callback - let UI handle navigation
      if (onComplete != null) onComplete();

    } catch (error) {
      setimageUpdateLoading(false);
      _handleError(error, context);
      if (onComplete != null) onComplete();
    }
  }
  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';
    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}