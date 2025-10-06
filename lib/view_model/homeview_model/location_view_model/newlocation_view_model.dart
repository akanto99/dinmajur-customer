import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/newlocation_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocationViewModel with ChangeNotifier {
  final _myRepo = AddLocationRepository();

  bool _createAddLocationLoading = false;
  bool get createAddLocationLoading => _createAddLocationLoading;

  setCreateAddLocationLoading(bool value) {
    _createAddLocationLoading = value;
    notifyListeners();
  }

  Future<void> addLocationPostApi(BuildContext context, dynamic fields) async {
    setCreateAddLocationLoading(true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Authentication token not found', context);
        setCreateAddLocationLoading(false);
        return;
      }

      if (kDebugMode) {
        print('========== POSTING LOCATION DATA ==========');
        print('Request data: ${jsonEncode(fields)}');
        print('Access token: ${accessToken.substring(0, 20)}...');
      }

      dynamic response = await _myRepo.addLocationPatchApi(fields);

      setCreateAddLocationLoading(false);

      if (kDebugMode) {
        print('Location API Response: ${jsonEncode(response)}');
        print('========================================');
      }

      // Optional: Show success message (you might want to remove this for automatic posting)
      // Utils.flushBarSuccessMessage('Location saved successfully', context);
    } catch (error) {
      setCreateAddLocationLoading(false);
      _handleError(error, context);

      if (kDebugMode) {
        print('Error in AddLocationViewModel: $error');
      }
    }
  }

  Future updateAddressPatchApi(BuildContext context, dynamic fields, String userId) async {
    setCreateAddLocationLoading(true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Authentication token not found', context);
        setCreateAddLocationLoading(false);
        return;
      }
      dynamic response = await _myRepo.updateAddressPatchApi(fields, userId);

      setCreateAddLocationLoading(false);

      if (kDebugMode) {
        print('Location API Response: ${jsonEncode(response)}');
      }
    } catch (error) {
      setCreateAddLocationLoading(false);
      _handleError(error, context);

      if (kDebugMode) {
        print('Error in AddLocationViewModel: $error');
      }
    }
  }

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Failed to save location';

    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');

      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ?? (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty ? decoded['errorMessages'][0]['message'] : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred while saving location';
    }

    if (kDebugMode) {
      print('AddLocation Error: $errorMessage');
    }
  }
}
