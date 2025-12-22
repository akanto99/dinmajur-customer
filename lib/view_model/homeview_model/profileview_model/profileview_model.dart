import 'dart:convert';

import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/profile_model/profileview_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/profile_repository/profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ProfileViewViewModel with ChangeNotifier {
  final _myRepo = ProfileRepository();

  ApiResponse<ProfileViewModel> profileviewUserData = ApiResponse.loading();

  // Add a flag to track if data has been fetched
  bool _isInitialized = false;

  // Add timestamp for cache expiry (optional - set to 5 minutes)
  DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(minutes: 5);

  bool get isInitialized => _isInitialized;

  setProfileViewUserData(ApiResponse<ProfileViewModel> response) {
    profileviewUserData = response;
    if (response.status == Status.COMPLETED) {
      _isInitialized = true;
      _lastFetchTime = DateTime.now();
    }
    notifyListeners();
  }

  // Check if cache is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
  }

  // Main fetch method with smart caching
  Future<void> fetchProfileViewUserDataApi({bool forceRefresh = false}) async {
    // Skip if already initialized and not forcing refresh and cache is valid
    if (_isInitialized && !forceRefresh && isCacheValid) {
      if (kDebugMode) {
        print('Profile data already loaded and cache is valid, skipping API call');
      }
      return;
    }

    if (kDebugMode) {
      print('Fetching profile data from API...');
    }

    setProfileViewUserData(ApiResponse.loading());

    _myRepo.fetchProfileUserData().then((value) {
      if (kDebugMode) {
        print('Profile data fetched successfully');
        print(value);
      }
      setProfileViewUserData(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setProfileViewUserData(ApiResponse.error(error.toString()));
    });
  }



  // Method to force refresh (for pull-to-refresh or manual updates)
  Future<void> refreshProfileData() async {
    return fetchProfileViewUserDataApi(forceRefresh: true);
  }

  // Method to clear cache (call this when user logs out or updates profile)
  void clearCache() {
    _isInitialized = false;
    _lastFetchTime = null;
    profileviewUserData = ApiResponse.loading();
    notifyListeners();
  }

  // Optional: Method to invalidate cache without clearing data
  void invalidateCache() {
    _lastFetchTime = null;
  }


  ///Update Profile Name
  bool _profileHeaderUpdateLoading = false;
  bool get profileHeaderUpdateLoading => _profileHeaderUpdateLoading;

  setprofileHeaderUpdateLoading(bool value) {
    _profileHeaderUpdateLoading = value;
    notifyListeners();
  }

  Future<void> profileUpdatePatchApi(
      BuildContext context,
      dynamic data, {
        bool showSuccessMessage = true, // Add this parameter
      }) async {
    setprofileHeaderUpdateLoading(true);
    try {
      final value = await _myRepo.profileUpdatePatchAPI(data);
      setprofileHeaderUpdateLoading(false);

      if (kDebugMode) {
        print('Response from image upload: $value');
      }

      // Only show success message if requested
      if (showSuccessMessage) {
        Utils.flushBarSuccessMessage('Profile Name Updated Successfully', context);
      }

    } catch (error) {
      setprofileHeaderUpdateLoading(false);
      _handleError(error, context);
      rethrow; // Re-throw so the dialog knows it failed
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