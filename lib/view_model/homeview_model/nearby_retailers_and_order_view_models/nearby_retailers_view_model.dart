import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_and_order_repository/nearby_retailers_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostNearbyRetailersViewModel with ChangeNotifier {
  final _myRepo = PostNearbyRetailersRepository();
  bool _nearbyRetailersLoading = false;
  List<dynamic> _nearbyStores = [];

  bool get nearbyRetailersLoading => _nearbyRetailersLoading;
  List<dynamic> get nearbyStores => _nearbyStores;

  setnearbyRetailersLoading(bool value) {
    _nearbyRetailersLoading = value;
    notifyListeners();
  }

  setNearbyStores(List<dynamic> stores) {
    _nearbyStores = stores;
    notifyListeners();
  }

  Future<List<dynamic>?> nearbyRetailersPostApi(BuildContext context, dynamic fields) async {
    setnearbyRetailersLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');
      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setnearbyRetailersLoading(false);
        return null;
      }

      dynamic value = await _myRepo.nearbyRetailersPostApi(fields);
      setnearbyRetailersLoading(false);

      if (kDebugMode) {
        print('Parsed response JSON: $value');
        print(value.toString());
      }

      // Parse the response and extract the stores data
      if (value != null) {
        // Handle both Map and already parsed response
        Map<String, dynamic> responseMap;
        if (value is String) {
          responseMap = jsonDecode(value);
        } else if (value is Map<String, dynamic>) {
          responseMap = value;
        } else {
          if (kDebugMode) print('Unexpected response type: ${value.runtimeType}');
          setNearbyStores([]);
          return [];
        }

        if (responseMap['success'] == true && responseMap['data'] != null) {
          List<dynamic> stores = responseMap['data'];
          if (kDebugMode) print('Extracted stores: $stores, Count: ${stores.length}');
          setNearbyStores(stores);
          return stores;
        } else {
          if (kDebugMode) print('API returned success=false or no data');
          setNearbyStores([]);
          Utils.flushBarErrorMessage(responseMap['message'] ?? 'No stores found', context);
          return [];
        }
      } else {
        if (kDebugMode) print('Response is null');
        setNearbyStores([]);
        Utils.flushBarErrorMessage('No response from server', context);
        return [];
      }
    } catch (error) {
      setnearbyRetailersLoading(false);
      setNearbyStores([]);
      _handleError(error, context);
      if (kDebugMode) print('Error in nearbyRetailersPostApi: $error');
      return null;
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