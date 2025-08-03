import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/provider/countdown/forgotpassword_countdown/forgotPassword_countdown.dart';
import 'package:dinmajur_customer/respository/forgot_password_repositories/post_forgot_otpsend_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostForgotOtpSendViewModel with ChangeNotifier {
  final _myRepo = PostForgotOtpSendRepository();

  ///otp APi
  bool _otpAPiloading = false;
  bool get otpAPiloading => _otpAPiloading;
  setotpAPiLoading(bool value) {
    _otpAPiloading = value;
    notifyListeners();
  }

  Future<void> otpSendPostAPI(dynamic data, BuildContext context, {VoidCallback? onSuccess}) async {
    setotpAPiLoading(true);

    try {
      dynamic value = await _myRepo.otpSendPostAPI(data);
      setotpAPiLoading(false);

      if (kDebugMode) {
        print('🔁 Full OTP API Response:\n${jsonEncode(value)}');
      }

      // Check if response is successful
      if (value != null && value['success'] == true && value['data'] != null) {
        // Extract data from API response
        String? otpToken = value['data']['token'];
        int expiresInSeconds = value['data']['expiresInSeconds'] ?? 120;
        String successMessage = value['message'] ?? 'OTP has been sent successfully.';
        final responseData = value['data'];
        final user = responseData['user'];
        final token = responseData['token'];
        final phone = data['phone'];

        // Fix: Get role from user object, not from responseData directly
        final role = user['role']; // Changed from responseData['role'] to user['role']
        print(user);
        print(token);
        print(phone);
        print(role);
        // Null safety checks
        if (user['id'] == null || token == null || phone == null || role == null) {
          throw Exception('Missing required data in API response');
        }

        // Save to SharedPreferences
        await _saveToPreferences(
          userId: user['id'].toString(),
          token: token.toString(),
          phone: phone.toString(),
          role: role.toString(),
        );

        // Save OTP token separately if available
        if (otpToken != null && otpToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('otp_token', otpToken);

          if (kDebugMode) print('✅ OTP Token received and saved: $otpToken');
        } else {
          Utils.flushBarErrorMessage('Invalid token received from server', context);
          return;
        }

        Utils.flushBarSuccessMessage(successMessage, context);

        // Start countdown timer and execute success callback
        if (onSuccess != null) {
          final timerProvider = Provider.of<ForgotPasswordCountdown>(context, listen: false);
          timerProvider.startTimer(seconds: expiresInSeconds);

          // Execute success callback
          onSuccess();
        }

      } else {
        throw Exception(value['message'] ?? 'Invalid response from server');
      }

    } catch (error) {
      setotpAPiLoading(false);
      _handleError(error, context);

      if (kDebugMode) print('OTP API Error: $error');
    }
  }

  Future<void> _saveToPreferences({
    required String userId,
    required String token,
    required String phone,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('forgot_user_id', userId);
      await prefs.setString('forgot_token', token);
      await prefs.setString('forgot_phone', phone);
      await prefs.setString('forgot_role', role);

      if (kDebugMode) {
        print('📱 Saved to preferences:');
        print('User ID: $userId');
        print('Token: $token');
        print('Phone: $phone');
        print('Role: $role');
      }
    } catch (e) {
      if (kDebugMode) print('Error saving to preferences: $e');
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

  // Method to clear stored data when needed
  Future<void> clearForgotPasswordData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('forgot_user_id');
      await prefs.remove('forgot_token');
      await prefs.remove('forgot_phone');
      await prefs.remove('forgot_role');
      await prefs.remove('otp_token');
      await prefs.remove('forgot_new_password_token');

      if (kDebugMode) print('🗑️ Cleared all forgot password data');
    } catch (e) {
      if (kDebugMode) print('Error clearing forgot password data: $e');
    }
  }
}
