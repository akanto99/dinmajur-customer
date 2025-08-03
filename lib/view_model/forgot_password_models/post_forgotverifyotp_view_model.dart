import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/forgot_password_repositories/post_forgotverifyotp_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper_forgotpassword/helper_forpassword.dart';

class PostForgotOtpVerifyViewModel with ChangeNotifier {
  final _myRepo = PostForgotOtpVerifyRepository();

  bool _verifyOTPLoading = false;

  bool get verifyOTPLoading => _verifyOTPLoading;

  setVerifyOTPLoading(bool value) {
    _verifyOTPLoading = value;
    notifyListeners();
  }

  Future<void> verifyOtpPostApi(BuildContext context, dynamic data,{VoidCallback? onSuccess}) async {
    setVerifyOTPLoading(true);
    try {
      String? token = await ForgotPasswordHelper.getForgotToken();

      if (token == null || token.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setVerifyOTPLoading(false);
        return;
      }

      // Call the API first
      final value = await _myRepo.otpVerifyPostAPI(data, token);
      setVerifyOTPLoading(false);

      // Extract data from response
      if (value != null && value['success'] == true && value['data'] != null) {
        final responseData = value['data'];
        final newPasswordToken = responseData['token'];

        // Save the new token for password reset
        if (newPasswordToken != null) {
          await _saveNewPasswordToken(newPasswordToken);

          Utils.flushBarSuccessMessage('OTP verified successfully', context);
          await Future.delayed(Duration(milliseconds: 1000));
          onSuccess?.call();
          Navigator.pushNamed(context, RoutesName.newPassword);




        } else {
          throw Exception('No token received from server');
        }
      } else {
        throw Exception('Invalid response format');
      }

      if (kDebugMode) {
        print('Response from OTP verification: $value');
      }
    } catch (error) {
      setVerifyOTPLoading(false);
      _handleError(error, context);
    }
  }

  // Method to save new password token
  Future<void> _saveNewPasswordToken(String newPasswordToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('forgot_new_password_token', newPasswordToken);

      if (kDebugMode) {
        print('🔐 New password token saved: $newPasswordToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving new password token: $e');
      }
    }
  }

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Unexpected error occurred';

    try {
      String errorBody = error.toString();

      // Check if it's a JSON error response
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      } else {
        // Handle Exception objects - remove "Exception: " prefix
        if (error is Exception) {
          String exceptionMessage = error.toString();
          if (exceptionMessage.startsWith('Exception: ')) {
            errorMessage = exceptionMessage.substring('Exception: '.length);
          } else {
            errorMessage = exceptionMessage;
          }
        } else {
          errorMessage = error.toString();
        }
      }
    } catch (_) {
      // If all parsing fails, try to clean up Exception prefix as last resort
      String fallbackMessage = error.toString();
      if (fallbackMessage.startsWith('Exception: ')) {
        errorMessage = fallbackMessage.substring('Exception: '.length);
      } else {
        errorMessage = fallbackMessage;
      }
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }
}