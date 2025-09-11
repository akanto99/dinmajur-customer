import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/drawer_repository/payment_method_repository/account_update_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatchAccountUpdateViewModel with ChangeNotifier {
  final _myRepo = AccountUpdateRepository();

  bool _accountUpdateLoading = false;
  bool get accountUpdateLoading => _accountUpdateLoading;

  setAccountUpdateLoading(bool value) {
    _accountUpdateLoading = value;
    notifyListeners();
  }

  Future<void> accountUpdatePatchApi(BuildContext context, String id, dynamic data) async {
    setAccountUpdateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');

      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setAccountUpdateLoading(false);
        return;
      }

      final value = await _myRepo.accountPatchAPI(AToken,id, data, );
      setAccountUpdateLoading(false);

      if (kDebugMode) {
        print('Response from profile update: $value');
      }

      Utils.flushBarSuccessMessage('Account updated successfully', context);


    } catch (error) {
      setAccountUpdateLoading(false);
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
