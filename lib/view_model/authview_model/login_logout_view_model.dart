
import 'dart:convert';
import 'package:dinmajur_customer/configs/services/one_signal_push_notification/one_signal_pushnotification_service.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/login_logout_repository.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart'; // ✅ Add SSE import
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginLogoutViewModel with ChangeNotifier {
  final _myRepo = LoginLogoutRepository();

  bool _loading = false;
  bool get loading => _loading;

  bool _loggingOut = false;
  bool get loggingOut => _loggingOut;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  setLoggingOut(bool value) {
    _loggingOut = value;
    notifyListeners();
  }

  Future<void> logoutUser(BuildContext context) async {
    if (_loggingOut) return;

    setLoggingOut(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        print("❌ Logout: No accessToken found");
        setLoggingOut(false);
        Utils.flushBarErrorMessage("Invalid session. Please login again.", context);
        return;
      }

      // ✅ Get providers
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      final locationListViewModel = Provider.of<GetLocationListViewModel>(context, listen: false);
      final oneSignalService = Provider.of<OneSignalNotificationService>(context, listen: false);

      print("🔓 Logout: Starting logout process");

      // ✅ STEP 1: Logout from OneSignal
      try {
        await oneSignalService.logoutUser();
        print("🔔 ✅ OneSignal logout successful");
      } catch (e) {
        print("⚠️ OneSignal logout failed: $e");
      }

      // ✅ STEP 2: Disconnect Socket
      try {
        await socketProvider.disconnect().timeout(Duration(seconds: 3));
        print("🔌 ✅ Socket disconnected successfully");
      } catch (e) {
        print("⚠️ Socket disconnect failed: $e");
      }

      // ✅ STEP 3: Stop SSE Connection
      try {
        await sseService.stopListening();
        print("🔔 ✅ SSE connection stopped successfully");
      } catch (e) {
        print("⚠️ SSE disconnect failed: $e");
      }

      // ✅ STEP 4: Call logout API
      try {
        await _myRepo.logoutApi(token).timeout(Duration(seconds: 10));
        print("🔓 ✅ Logout API call successful");
      } catch (e) {
        print("⚠️ Logout API failed: $e");
        // Continue with local cleanup even if API fails
      }
      await userPreference.remove();
      profileViewModel.clearCache();
      locationListViewModel.clearCache();

      setLoggingOut(false);

      Utils.flushBarSuccessMessage("Logged out successfully", context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.authLoginWelcome,
            (route) => false,
      );

      print("🔓 ✅ Logout Completed Successfully");

    } catch (error) {
      print("❌ Logout Error: $error");
      setLoggingOut(false);
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