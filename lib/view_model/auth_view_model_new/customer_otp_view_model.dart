import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository_new/customer_otp_repository.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthOtpVerifyViewModel with ChangeNotifier {
  final _myRepo = AuthOtpVerifyRepository();

  bool _authOTPVerifyloading = false;
  bool get authOTPVerifyloading => _authOTPVerifyloading;

  void setAuthOTPVerifyloading(bool value) {
    _authOTPVerifyloading = value;
    notifyListeners();
  }

  Future<void> authOtpVerify(dynamic data, BuildContext context) async {
    setAuthOTPVerifyloading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final otpToken = prefs.getString('otp_token');
      final value = await _myRepo.authOtpVerify(data, otpToken ?? '');

      setAuthOTPVerifyloading(false);

      // ── Handle server error ───────────────────────────────────────────
      if (value['success'] != true) {
        Utils.flushBarErrorMessage(
            value['message'] ?? 'OTP verification failed', context);
        return;
      }

      Utils.flushBarSuccessMessage(
          'OTP has been successfully verified.', context);

      // ── Save user model ───────────────────────────────────────────────
      final user = UserModel.fromJson(value);
      await Provider.of<UserViewModel>(context, listen: false).saveUser(user);

      // ── Extract and persist credentials ──────────────────────────────
      final String? accessToken = value['data']?['accessToken'];
      final String? userId =
          value['data']?['user']?['id'] ?? value['data']?['user']?['_id'];

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage(
            'Invalid token received from server', context);
        return;
      }

      await prefs.setString('accessToken', accessToken);
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString('userId', userId);
      }

      if (kDebugMode) print('✅ OTP Verify: credentials saved, navigating…');

      // ── Navigate — NavigationScreen._initServices() takes over ────────
      // It reads accessToken + userId from SharedPreferences and boots:
      //   • OneSignal login
      //   • SocketManager.connect()
      //   • SSENotificationService.startListening()
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, RoutesName.navigationBar);
    } catch (error) {
      setAuthOTPVerifyloading(false);
      _handleError(error, context);
    }
  }

  // ── Error Handler ─────────────────────────────────────────────────────────

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Something went wrong';
    try {
      final String errorBody = error.toString();
      final int jsonStart = errorBody.indexOf('{');
      if (jsonStart != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStart));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List &&
                (decoded['errorMessages'] as List).isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      } else {
        errorMessage = errorBody.replaceAll('Exception: ', '');
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}