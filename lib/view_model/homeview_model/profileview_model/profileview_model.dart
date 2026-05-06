import 'dart:convert';

import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/profile_model/profileview_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/profile_repository/profile_repository.dart';
import 'package:flutter/cupertino.dart';

class ProfileViewViewModel with ChangeNotifier {
  final _myRepo = ProfileRepository();

  ApiResponse<ProfileViewModel> profileviewUserData = ApiResponse.loading();

  bool _isInitialized = false;
  DateTime? _lastFetchTime;

  static const _cacheValidityDuration = Duration(minutes: 5);

  bool get isInitialized => _isInitialized;

  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
  }

  void _setProfileViewUserData(ApiResponse<ProfileViewModel> response) {
    profileviewUserData = response;
    if (response.status == Status.COMPLETED) {
      _isInitialized = true;
      _lastFetchTime = DateTime.now();
    }
    notifyListeners();
  }

  Future<void> fetchProfileViewUserDataApi({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh && isCacheValid) return;

    _setProfileViewUserData(ApiResponse.loading());

    _myRepo.fetchProfileUserData().then((value) {
      _setProfileViewUserData(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      _setProfileViewUserData(ApiResponse.error(error.toString()));
    });
  }

  Future<void> refreshProfileData() async {
    return fetchProfileViewUserDataApi(forceRefresh: true);
  }

  void clearCache() {
    _isInitialized = false;
    _lastFetchTime = null;
    profileviewUserData = ApiResponse.loading();
    notifyListeners();
  }

  // ── Update Profile Name ──────────────────────────────────────────

  bool _profileHeaderUpdateLoading = false;
  bool get profileHeaderUpdateLoading => _profileHeaderUpdateLoading;

  void _setProfileHeaderUpdateLoading(bool value) {
    _profileHeaderUpdateLoading = value;
    notifyListeners();
  }

  Future<void> profileUpdatePatchApi(
      BuildContext context,
      dynamic data, {
        bool showSuccessMessage = true,
      }) async {
    _setProfileHeaderUpdateLoading(true);
    try {
      await _myRepo.profileUpdatePatchAPI(data);
      _setProfileHeaderUpdateLoading(false);
      if (showSuccessMessage) {
        Utils.flushBarSuccessMessage('Profile Name Updated Successfully', context);
      }
    } catch (error) {
      _setProfileHeaderUpdateLoading(false);
      _handleError(error, context);
      rethrow;
    }
  }

  // ── Delete Account ───────────────────────────────────────────────

  bool _deleteAccountLoading = false;
  bool get deleteAccountLoading => _deleteAccountLoading;

  void _setDeleteAccountLoading(bool value) {
    _deleteAccountLoading = value;
    notifyListeners();
  }

  Future<bool> deleteAccountApi(BuildContext context) async {
    _setDeleteAccountLoading(true);
    try {
      await _myRepo.deleteAccount(null);
      _setDeleteAccountLoading(false);
      return true;
    } catch (error) {
      _setDeleteAccountLoading(false);
      _handleError(error, context);
      return false;
    }
  }

  // ── Error Handler ────────────────────────────────────────────────

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';
    try {
      final errorBody = error.toString();
      final jsonStartIndex = errorBody.indexOf('{');
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