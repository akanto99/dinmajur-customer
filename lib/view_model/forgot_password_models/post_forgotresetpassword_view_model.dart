import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/forgot_password_repositories/post_forgot_resetpassword_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper_forgotpassword/helper_forpassword.dart';
class PostNewForgotPasswordViewModel with ChangeNotifier {
  final _myRepo = PostNewForgotPasswordRepository();

  bool _newPasswordLoading = false;

  bool get newPasswordLoading => _newPasswordLoading;

  setNewPasswordLoading(bool value) {
    _newPasswordLoading = value;
    notifyListeners();
  }

  Future<void> newPasswordPostApi(BuildContext context, dynamic data) async {
    setNewPasswordLoading(true);
    try {
      String? token = await ForgotPasswordHelper.getNewPasswordToken();

      if (token == null || token.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setNewPasswordLoading(false);
        return;
      }

      final value = await _myRepo.newPasswordPostAPI(data, token);
      setNewPasswordLoading(false);

      Utils.flushBarSuccessMessage('Password Changed Successfully', context); // Fixed message
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pushNamed(context, RoutesName.login);
      await _clearOldForgotPasswordData();
      if (kDebugMode) {
        print('Response from OTP verification: $value');
      }
    } catch (error) {
      setNewPasswordLoading(false);
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
    Utils.flushBarErrorMessage(errorMessage, context);
  }

  Future<void> _clearOldForgotPasswordData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove old data but keep new password token
      await Future.wait([
        prefs.remove('forgot_user_id'),
        prefs.remove('forgot_token'),
        prefs.remove('forgot_phone'),
        prefs.remove('forgot_role'),
        prefs.remove('f_phone'), // Also clear the phone from form data
      ]);

      if (kDebugMode) {
        print('🧹 Old forgot password data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing old forgot password data: $e');
      }
    }
  }
}