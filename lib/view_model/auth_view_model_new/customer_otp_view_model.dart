import 'dart:convert';
import 'package:dinmajur_customer/configs/services/one_signal_push_notification/one_signal_pushnotification_service.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository_new/customer_otp_repository.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthOtpVerifyViewModel with ChangeNotifier {
  final _myRepo = AuthOtpVerifyRepository();

  bool _authOTPVerifyloading = false;
  bool get authOTPVerifyloading => _authOTPVerifyloading;

  setAuthOTPVerifyloading(bool value) {
    _authOTPVerifyloading = value;
    notifyListeners();
  }

  Future<void> authOtpVerify(dynamic data, BuildContext context) async {
    setAuthOTPVerifyloading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('otp_token');
      final value = await _myRepo.authOtpVerify(data, token ?? '');

      setAuthOTPVerifyloading(false);

      if (value['success'] != true) {
        final errorMessage = value['message'] ?? 'OTP verification failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        return;
      }

      Utils.flushBarSuccessMessage('OTP has been successfully verified.', context);

      // ✅ Save user data
      final user = UserModel.fromJson(value);
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      await userPreference.saveUser(user);

      // ✅ Extract tokens and userId
      String? accessToken = value['data']?['accessToken'];
      String? userId = value['data']?['user']?['id'] ?? value['data']?['user']?['_id'];

      if (accessToken == null || accessToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token received from server', context);
        return;
      }

      await prefs.setString('accessToken', accessToken);
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString('userId', userId);
      }

      print("✅ OTP Verify: Token saved - accessToken: ${accessToken.isNotEmpty}");

      // ✅ STEP 1: Login to OneSignal
      if (userId != null && userId.isNotEmpty) {
        try {
          final oneSignalService = Provider.of<OneSignalNotificationService>(context, listen: false);
          await oneSignalService.loginUser(userId);
          print("🔔 OTP Verify: ✅ OneSignal login successful");
        } catch (e) {
          print("⚠️ OTP Verify: OneSignal login error - $e");
        }
      }

      // ✅ STEP 2: Connect Socket with access token
      try {
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);
        print("🔌 OTP Verify: Connecting socket with access token ------------$accessToken");
        await socketProvider.connectWithToken(accessToken: accessToken);

        await Future.delayed(Duration(seconds: 2));

        // if (socketProvider.isConnected) {
        //   print("🔌 OTP Verify: ✅ Socket connected successfully");
        // } else {
        //   print("🔌 OTP Verify: ⚠️ Attempting auto-reconnect");
        //   await socketProvider.autoReconnect();
        // }
      } catch (e) {
        print("⚠️ OTP Verify: Socket connection error - $e");
      }

      // ✅ STEP 3: Start SSE connection
      try {
        final sseService = Provider.of<SSENotificationService>(context, listen: false);
        final notificationCountViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
        final runningOrderCountViewModel = Provider.of<RunningOrderCountViewModel>(context, listen: false);

        print("🔔 OTP Verify: Starting SSE connection");
        await sseService.startListening();
        await Future.delayed(Duration(milliseconds: 500));

        // Initialize notification count listener
        notificationCountViewModel.initializeCountListener(sseService.notificationCountStream, sseService.notificationIncrementStream);
        notificationCountViewModel.setInitialCount(sseService.currentCount);

        // Initialize running order count listener
        runningOrderCountViewModel.initializeCountListener(sseService.runningOrderCountStream);
        runningOrderCountViewModel.setInitialCount(sseService.currentRunningOrderCount);

        print("🔔 OTP Verify: ✅ SSE connected successfully");
      } catch (e) {
        print("⚠️ OTP Verify: SSE connection error - $e");
      }

      // ✅ STEP 4: Navigate to home
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, RoutesName.navigationBar);

      print("✅ OTP Verification Complete: All services connected");
    } catch (error) {
      setAuthOTPVerifyloading(false);
      print("🔥 OTP Verify Error: $error");
      _handleError(error, context);
    }
  }

  /// Handle Errors
  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Something went wrong';

    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');

      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ?? (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty ? decoded['errorMessages'][0]['message'] : errorMessage);
      } else {
        errorMessage = errorBody.replaceAll('Exception: ', '');
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }
}
