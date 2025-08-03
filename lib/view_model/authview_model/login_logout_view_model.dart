import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/login_logout_repository.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginLogoutViewModel with ChangeNotifier {
  final _myRepo = LoginLogoutRepository();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> loginApi(dynamic data, BuildContext context) async {
    setLoading(true);

    try {
      final response = await _myRepo.loginApi(data);

      // Parse the response
      final user = UserModel.fromJson(response);
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      await userPreference.saveUser(user);

      // Save tokens and user status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', user.data?.accessToken ?? '');
      await prefs.setBool('isPhoneVerified', user.data?.user?.isPhoneVerified ?? false);
      await prefs.setBool('isRegistered', user.data?.user?.isRegistered ?? false);

      setLoading(false);
      Utils.flushBarSuccessMessage('Login Successfully', context);

      final bool isPhoneVerified = user.data?.user?.isPhoneVerified ?? false;
      final bool isRegistered = user.data?.user?.isRegistered ?? false;

      print("Login Navigation - accessToken: ${user.data?.accessToken}");
      print("Login Navigation - isPhoneVerified: $isPhoneVerified");
      print("Login Navigation - isRegistered: $isRegistered");

      // Navigation logic
      if (isPhoneVerified && isRegistered) {
        print("🔥 Navigation: Going to navigationBar (Verified & Registered)");
        Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.navigationBar,
                (route) => false
        );
      }  else {
        print("🔥 Navigation: Error - Phone not verified");
        Utils.flushBarErrorMessage("এই নাম্বারটি রেজিস্টার করা হয়নি", context);
      }

      if (kDebugMode) print("Login Response: ${response.toString()}");

    } catch (error) {
      print("🔥 Login Error: $error");
      setLoading(false);
      _handleError(error, context);
    }
  }

  /// Handle Errors
  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Something went wrong';

    try {
      String errorBody = error.toString();

      // Look for JSON in the error string
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        String jsonString = errorBody.substring(jsonStartIndex);
        final decoded = jsonDecode(jsonString);

        // Extract error message from different possible structures
        if (decoded['message'] != null) {
          errorMessage = decoded['message'];
        } else if (decoded['errorMessages'] is List &&
            decoded['errorMessages'].isNotEmpty &&
            decoded['errorMessages'][0]['message'] != null) {
          errorMessage = decoded['errorMessages'][0]['message'];
        }
      } else {
        // If no JSON found, use the error as is (but clean it up)
        errorMessage = errorBody.replaceAll('Exception: ', '');
      }
    } catch (e) {
      print("Error parsing error message: $e");
      errorMessage = 'Unexpected error occurred';
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }
}