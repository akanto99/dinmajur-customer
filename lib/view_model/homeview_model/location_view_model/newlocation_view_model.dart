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

  Future<void> addLocationPatchApi(BuildContext context, dynamic fields) async {
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

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Failed to save location';

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
      errorMessage = 'Unexpected error occurred while saving location';
    }

    if (kDebugMode) {
      print('AddLocation Error: $errorMessage');
    }

    // For automatic location posting, you might want to use a less intrusive error handling
    // Utils.flushBarErrorMessage(errorMessage, context);
  }

  // Method to check if location should be auto-posted
  Future<bool> shouldAutoPostLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // You can add logic here to check if location was already posted recently
      // For example, check last post timestamp
      String? lastLocationPost = prefs.getString('lastLocationPostTime');

      if (lastLocationPost == null) {
        return true; // First time, should post
      }

      DateTime lastPost = DateTime.parse(lastLocationPost);
      DateTime now = DateTime.now();

      // Only auto-post if last post was more than 1 hour ago
      if (now.difference(lastPost).inHours > 1) {
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) print('Error checking auto-post condition: $e');
      return true; // Default to posting if check fails
    }
  }

  // Method to update last location post time
  Future<void> updateLastLocationPostTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastLocationPostTime', DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) print('Error updating last location post time: $e');
    }
  }

  // Enhanced method for automatic location posting with conditions
  Future<void> autoPostLocationIfNeeded(BuildContext context, dynamic locationData) async {
    try {
      bool shouldPost = await shouldAutoPostLocation();

      if (shouldPost) {
        if (kDebugMode) print('Auto-posting location data...');
        await addLocationPatchApi(context, locationData);
        await updateLastLocationPostTime();
      } else {
        if (kDebugMode) print('Skipping auto-post - location posted recently');
      }
    } catch (e) {
      if (kDebugMode) print('Error in auto-post location: $e');
    }
  }
}