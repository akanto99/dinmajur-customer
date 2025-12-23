import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/respository/auth_repository_new/resend_otp_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResendOtpViewModel with ChangeNotifier {
  final _myRepo = ResendOtpRepository();

  bool _resendOTPloading = false;
  bool get resendOTPloading => _resendOTPloading;

  setResendOTPloading(bool value) {
    _resendOTPloading = value;
    notifyListeners();
  }

  Future<void> reSendOtp(dynamic data, BuildContext context, {VoidCallback? onSuccess}) async {
    setResendOTPloading(true);

    try {
      dynamic value = await _myRepo.resendOtp(data);
      setResendOTPloading(false);

      String? otpToken = value['data']['token'];
      int cooldownInSeconds = value['data']['cooldownInSeconds'] ?? 30;
      String successMessage = value['message'] ?? 'OTP সফলভাবে পাঠানো হয়েছে';

      if (otpToken != null && otpToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('otp_token', otpToken);

        if (kDebugMode) print('✅ OTP Token received and saved: $otpToken');
      } else {
        Utils.flushBarErrorMessage('Invalid token received from server', context);
        return;
      }

      Utils.flushBarSuccessMessage(successMessage, context);

      if (onSuccess != null) {
        onSuccess();

        // ✅ Start timer with cooldown duration
        final timerProvider = Provider.of<CountdownTimerProvider>(context, listen: false);
        timerProvider.startTimer(seconds: cooldownInSeconds);
      }

      if (kDebugMode) print(value.toString());
      debugPrint('🔁 Full OTP API Response:\n${jsonEncode(value)}', wrapWidth: 1024);
    } catch (error) {
      setResendOTPloading(false);
      String errorMessage = '$error';
      try {
        String errorBody = error.toString();
        int jsonStartIndex = errorBody.indexOf('{');
        if (jsonStartIndex != -1) {
          String jsonString = errorBody.substring(jsonStartIndex);
          final decodedError = jsonDecode(jsonString);

          errorMessage = decodedError['message'] ??
              (decodedError['errorMessages'] != null &&
                  decodedError['errorMessages'] is List &&
                  decodedError['errorMessages'].isNotEmpty
                  ? decodedError['errorMessages'][0]['message']
                  : errorMessage);
        }
      } catch (e) {
        errorMessage = 'Unexpected error';
      }
      Utils.flushBarErrorMessage(errorMessage, context);
      if (kDebugMode) print('OTP API Error: $error');
    }
  }
}