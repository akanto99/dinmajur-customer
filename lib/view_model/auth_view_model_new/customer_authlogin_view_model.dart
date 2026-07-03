import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/respository/auth_repository_new/customer_authlogin_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAuthLoginViewModel with ChangeNotifier {
  final _myRepo = CustomerAuthLoginRepository();

  bool _authApiSendOtploading = false;
  bool get authApiSendOtploading => _authApiSendOtploading;

  setAuthApiSendOtpLoading(bool value) {
    _authApiSendOtploading = value;
    notifyListeners();
  }

  Future<void> authApiSendOtp(dynamic data, BuildContext context, {VoidCallback? onSuccess}) async {
    setAuthApiSendOtpLoading(true);

    try {
      dynamic value = await _myRepo.authApiSendOtp(data);
      setAuthApiSendOtpLoading(false);

      String? otpToken = value['data']['token'];
      int cooldownInSeconds = value['data']['cooldownInSeconds'] ?? 30;
      String successMessage = value['message'] ?? 'OTP সফলভাবে পাঠানো হয়েছে';

      if (otpToken != null && otpToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('otp_token', otpToken);

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

    } catch (error) {
      setAuthApiSendOtpLoading(false);
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
    }
  }
}