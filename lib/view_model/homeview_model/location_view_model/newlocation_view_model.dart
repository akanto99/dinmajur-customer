import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/newlocation_repository.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocationViewModel with ChangeNotifier {
  final _myRepo = AddLocationRepository();

  bool _createAddLocationLoading = false;
  bool get createAddLocationLoading => _createAddLocationLoading;

  setCreateAddLocationLoading(bool value) {
    _createAddLocationLoading = value;
    notifyListeners();
  }

  Future<void> addLocationPostApi(
      BuildContext context,
      dynamic fields,
      bool shouldNavigate, // ✅ New parameter
      ) async {
    setCreateAddLocationLoading(true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Authentication token not found', context);
        setCreateAddLocationLoading(false);
        return;
      }


      await _myRepo.addLocationPatchApi(fields);

      setCreateAddLocationLoading(false);
      Utils.flushBarSuccessMessage('Location saved successfully', context);

      ///Refetch and Clear cached
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.clearCache();
      final locationListViewModel = Provider.of<GetLocationListViewModel>(context, listen: false);
      locationListViewModel.clearCache();
      // ✅ Only navigate if shouldNavigate is true
      if (shouldNavigate) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationScreen(initialIndex: 0),
            ),
          );
        });
      }


    } catch (error) {
      setCreateAddLocationLoading(false);
      _handleError(error, context);
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
      await _myRepo.updateAddressPatchApi(fields, userId);

      setCreateAddLocationLoading(false);
      Utils.flushBarSuccessMessage('Location updated successfully', context);
      ///Refetch and Clear cached
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.clearCache();
      final locationListViewModel = Provider.of<GetLocationListViewModel>(context, listen: false);
      locationListViewModel.clearCache();

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen()));
        });

    } catch (error) {
      setCreateAddLocationLoading(false);
      _handleError(error, context);
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
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}
