import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/otp_verify_repository.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerifyViewModel with ChangeNotifier {
  final _myRepo = OtpVerifyRepository();

  bool _otpVerifyloading = false;
  bool get otpVerifyloading => _otpVerifyloading;
  setotpVerifyloading(bool value) {
    _otpVerifyloading = value;
    notifyListeners();
  }

  Future<void> otpVerify(dynamic data, BuildContext context) async {
    setotpVerifyloading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('otp_token');
      print("get token successfully $token");
      final value = await _myRepo.otpVerify(data, token ?? '');
      // print("---------$token");
      setotpVerifyloading(false);
      if (value['success'] == true) {
        Utils.flushBarSuccessMessage('OTP has been successfully verified.', context);
        debugPrint('🔁 Full OTP API Response:\n${jsonEncode(value)}');

        final user = UserModel.fromJson(value);
        final userPreference = Provider.of<UserViewModel>(context, listen: false);
        userPreference.saveUser(user);
        print(user);
        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushReplacementNamed(context, RoutesName.navigationBar);
        String ? _accessToken = value['data']['accessToken'];
        if (_accessToken != null && _accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', _accessToken);
          prefs.setBool('isPhoneVerified', true);
        } else {
          Utils.flushBarErrorMessage('Invalid token received from server', context);
          return;
        }

      } else {
        final errorMessage = value['message'] ?? 'OTP verification failed';
        Utils.flushBarErrorMessage(errorMessage, context);
      }
    } catch (error) {
      setotpVerifyloading(false);
      _handleError(error, context);
    }
  }



  ///Handle Errors
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

  String? _accessToken;
  String? get accessToken => _accessToken;


}
