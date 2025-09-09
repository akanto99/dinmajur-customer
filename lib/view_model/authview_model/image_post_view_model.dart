import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/auth_repository/image_post_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImagePostViewModel with ChangeNotifier {
  final _myRepo = ImagePostRepository();

  bool _profileImageLoading = false;
  bool get profileImageLoading => _profileImageLoading;

  setprofileImageLoading(bool value) {
    _profileImageLoading = value;
    notifyListeners();
  }

  // ✅ CORRECTED: Added fileName parameter
  Future<void> imagePostApi(
      Uint8List imageBytes,
      BuildContext context,
      String fileName,      // ✅ Added fileName parameter
      String imageType,      // ✅ Added fileName parameter
      ) async {
    setprofileImageLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setprofileImageLoading(false);
        return;
      }

      // ✅ FIXED: Now passing all required parameters including fileName
      final value = await _myRepo.imagePostApi(imageBytes, accessToken, fileName, imageType);
      setprofileImageLoading(false);

      if (kDebugMode) {
        print('Business Logo Upload Response: $value');
      }

      // Check and store URL and altText
      if (value['success'] == true && value['data'] != null) {
        final url = value['data']['url'] ?? '';
        final altText = value['data']['altText'] ?? '';

        // Save to SharedPreferences
        await prefs.setString('businessLogoURL', url);
        await prefs.setString('businessLogoAltText', altText);

        if (kDebugMode) {
          print('businessLogo URL stored: $url');
          print('businessLogo altText stored: $altText');
        }

        Utils.flushBarSuccessMessage('Shop Logo uploaded successfully', context);
      } else {
        Utils.flushBarErrorMessage('Failed to upload Shop Logo', context);
      }
    } catch (error) {
      setprofileImageLoading(false);
      _handleError(error, context);
    }
  }

  ///Handle Errors
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