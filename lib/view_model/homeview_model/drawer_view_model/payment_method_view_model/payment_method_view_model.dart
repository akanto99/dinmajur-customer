import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/drawer_repository/payment_method_repository/payment_method_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPaymentMethodViewModel with ChangeNotifier {
  final _myRepo = PayemntMethodRepository();
  bool _createPayementMetheodLoading = false;
  bool get createPayementMetheodLoading => _createPayementMetheodLoading;

  setCreatePayementMetheodLoading(bool value) {
    _createPayementMetheodLoading = value;
    notifyListeners();
  }

  Future<void> PayementMetheodPostApi(BuildContext context, dynamic fields,) async {
    setCreatePayementMetheodLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');
      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setCreatePayementMetheodLoading(false);
        return;
      }
      dynamic value = await _myRepo.payemntMethodPostApi(fields);
      setCreatePayementMetheodLoading(false);
      Utils.flushBarSuccessMessage('Payement Method added successfully', context);
      if (kDebugMode) print(value.toString());
    } catch (error) {
      setCreatePayementMetheodLoading(false);
      _handleError(error, context);
      if (kDebugMode) print('Error: $error');
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