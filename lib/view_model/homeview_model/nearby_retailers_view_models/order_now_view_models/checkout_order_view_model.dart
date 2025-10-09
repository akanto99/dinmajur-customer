import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_repository/order_now_repository/checkout_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCheckOutOrderViewModel with ChangeNotifier {
  final _myRepo = PostCheckOutOrderRepository();
  bool _checkoutOrderLoading = false;
  bool get checkoutOrderLoading => _checkoutOrderLoading;

  setCheckoutOrderLoading(bool value) {
    _checkoutOrderLoading = value;
    notifyListeners();
  }

  Future<void> checkoutOrderPostApi(BuildContext context, dynamic fields) async {
    setCheckoutOrderLoading(true);

    // Print the request data
    if (kDebugMode) {
      print('========== CHECKOUT ORDER REQUEST ==========');
      print('Request Data: ${jsonEncode(fields)}');
      print('==========================================');
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');

      if (kDebugMode) {
        print('Access Token: ${AToken != null ? "Present" : "Missing"}');
      }

      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setCheckoutOrderLoading(false);
        return;
      }

      // Make API call
      dynamic value = await _myRepo.checkoutOrderPostApi(fields);

      setCheckoutOrderLoading(false);

      // Print the response
      if (kDebugMode) {
        print('========== CHECKOUT ORDER RESPONSE ==========');
        print('Response: ${jsonEncode(value)}');
        print('Response Type: ${value.runtimeType}');
        print('==========================================');
      }

      Utils.flushBarSuccessMessage('Order created successfully', context);

    } catch (error) {
      setCheckoutOrderLoading(false);

      if (kDebugMode) {
        print('========== CHECKOUT ORDER ERROR ==========');
        print('Error: $error');
        print('Error Type: ${error.runtimeType}');
        print('==========================================');
      }

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
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }

    if (kDebugMode) {
      print('Parsed Error Message: $errorMessage');
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }
}