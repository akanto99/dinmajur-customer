import 'dart:convert';
import 'dart:typed_data';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/drawer_repository/profile_update_repository/profile_image_update_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatchprofileImageUpdateViewModel with ChangeNotifier {
  final _myRepo = PatchprofileImageUpdateRepository();

  bool _profileImageUpdateLoading = false;
  bool get profileImageUpdateLoading => _profileImageUpdateLoading;

  void setprofileImageUpdateLoading(bool value) {
    _profileImageUpdateLoading = value;
    notifyListeners();
  }

  Future<void> profileImageUpdatePatchApi(Uint8List imageBytes, String fileName, String imageTypes, int routeCount, BuildContext context) async {
    setprofileImageUpdateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setprofileImageUpdateLoading(false);
        return;
      }

      final value = await _myRepo.profileImageUpdatePatchApi(imageBytes, accessToken, imageTypes, fileName);
      setprofileImageUpdateLoading(false);

      if (kDebugMode) {
        print('Profile Image Upload Response: $value');
      }

      if (value['success'] == true) {
        Utils.flushBarSuccessMessage('Profile picture uploaded successfully', context);

        if (routeCount == 1) {
          await Future.delayed(Duration(milliseconds: 1000));
          Navigator.pushNamedAndRemoveUntil(context, RoutesName.navigationBar, (route) => false);
        }
      } else {
        Utils.flushBarErrorMessage('Failed to upload Profile Image', context);
      }
    } catch (error) {
      setprofileImageUpdateLoading(false);
      _handleError(error, context);
    }
  }

  bool _imageAndCoverUpdateLoading = false;
  bool get imageAndCoverUpdateLoading => _imageAndCoverUpdateLoading;

  void setImageAndCoverUpdateLoading(bool value) {
    _imageAndCoverUpdateLoading = value;
    notifyListeners();
  }

  Future<void> uploadImageCoverPatch(Uint8List imageBytes, String fileName, String imageTypes, int routesCount, BuildContext context) async {
    setImageAndCoverUpdateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setImageAndCoverUpdateLoading(false);
        return;
      }

      final value = await _myRepo.imageAndCoverUploadPatchApi(imageBytes, accessToken, imageTypes, fileName);
      setImageAndCoverUpdateLoading(false);

      if (kDebugMode) {
        print('Image Cover Upload Response: $value');
      }

      if (value['success'] == true) {
        Utils.flushBarSuccessMessage(value['message'] ?? 'Image uploaded successfully', context);

        if (routesCount == 1) {
          await Future.delayed(Duration(milliseconds: 1000));
          Navigator.pushNamedAndRemoveUntil(context, RoutesName.navigationBar, (route) => false);
        } else if (routesCount == 2) {
          // Handle route 2
        } else if (routesCount == 3) {
          // Handle route 3
        }
      } else {
        String errorMessage = value['message'] ?? 'Failed to upload Image';
        Utils.flushBarErrorMessage(errorMessage, context);
      }
    } catch (error) {
      setImageAndCoverUpdateLoading(false);
      _handleError(error, context);
    }
  }

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';
    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ?? (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty ? decoded['errorMessages'][0]['message'] : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}
