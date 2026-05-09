import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/delete_location_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/newlocation_repository.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteLocationViewModel with ChangeNotifier {
  final _myRepo = DeleteLocationRepository();

  bool _createDeleteLocationLoading = false;
  bool get createDeleteLocationLoading => _createDeleteLocationLoading;

  setCreateDeleteLocationLoading(bool value) {
    _createDeleteLocationLoading = value;
    notifyListeners();
  }

  Future<void> deleteLocationDeleteApi(BuildContext context, String addressId) async {
    setCreateDeleteLocationLoading(true);

    try {
      dynamic response = await _myRepo.deleteAddressDeleteApi(addressId);

      setCreateDeleteLocationLoading(false);
      Utils.flushBarSuccessMessage('Location Deleted successfully', context);

      final locationListViewModel = Provider.of<GetLocationListViewModel>(context, listen: false);
      locationListViewModel.clearCache(); // Clear the cached data
      await locationListViewModel.fetchLocationListApi();
      if (kDebugMode) {
        // print('Location API Response: ${jsonEncode(response)}');
        print('========================================');
      }

    } catch (error) {
      setCreateDeleteLocationLoading(false);
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
