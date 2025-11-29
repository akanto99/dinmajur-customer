import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/login_logout_repository.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> loginApi(dynamic data, BuildContext context) async {
    setLoading(true);

    try {
      final response = await _myRepo.loginApi(data);

      // Parse the response
      final user = UserModel.fromJson(response);

      final bool isPhoneVerified = user.data?.user?.isPhoneVerified ?? false;
      final bool isRegistered = user.data?.user?.isRegistered ?? false;
      final String userRole = user.data?.user?.role ?? '';
      final String userId = user.data?.user?.userId ?? '';

      print("🔍 Login Response Check:");
      print("   - accessToken: ${user.data?.accessToken != null ? 'Present' : 'Missing'}");
      print("   - isPhoneVerified: $isPhoneVerified");
      print("   - isRegistered: $isRegistered");
      print("   - userRole: $userRole");
      print("   - userId: $userId");

      // ✅ CHECK ROLE FIRST - Before saving anything
      if (userRole.toUpperCase() != 'CUSTOMER') {
        setLoading(false);
        print("❌ Login Failed: User role is '$userRole', not 'CUSTOMER'");
        Utils.flushBarErrorMessage("এই অ্যাকাউন্টটি কাস্টমার অ্যাকাউন্ট নয়", context);
        return; // Exit early - don't save user data or navigate
      }

      // ✅ CHECK PHONE VERIFICATION
      if (!isPhoneVerified) {
        setLoading(false);
        print("❌ Login Failed: Phone not verified");
        Utils.flushBarErrorMessage("এই নাম্বারটি রেজিস্টার করা হয়নি", context);
        return; // Exit early
      }

      // ✅ If we reach here, user is a verified CUSTOMER - proceed with login
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      await userPreference.saveUser(user);

      // Save additional preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', user.data?.accessToken ?? '');
      await prefs.setBool('isPhoneVerified', isPhoneVerified);
      await prefs.setBool('isRegistered', isRegistered);
      await prefs.setString('role', userRole);
      await prefs.setString('userId', userId);

      // ✅ CONNECT SOCKET AFTER SUCCESSFUL LOGIN
      if (userId.isNotEmpty) {
        try {
          final socketProvider = Provider.of<SocketProvider>(context, listen: false);

          print("🔌 Login: Connecting socket for user: $userId");

          // Connect socket with user credentials
          await socketProvider.connectWithUser(userId: userId);

          // Wait to ensure connection is established
          await Future.delayed(Duration(seconds: 1));

          if (socketProvider.isConnected) {
            print("🔌 Login: ✅ Socket connected successfully");
          } else {
            print("🔌 Login: ⚠️ Socket not connected, attempting retry");
            await socketProvider.autoReconnect(
              maxRetries: 3,
              delay: Duration(seconds: 2),
            );
          }
        } catch (socketError) {
          print("🔌 Login: Socket connection error - $socketError");
          // Don't fail login if socket connection fails
          // Socket will be reconnected by app lifecycle management
        }
      } else {
        print("⚠️ Login: userId is empty, skipping socket connection");
      }

      setLoading(false);

      // Show success message
      await Future.delayed(Duration(milliseconds: 300));
      Utils.flushBarSuccessMessage('Login Successfully', context);

      print("✅ Login Success: Customer verified - Navigating to home");

      // Navigate to home
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.navigationBar,
            (route) => false,
      );

      if (kDebugMode) print("Login Response: ${response.toString()}");
    } catch (error) {
      print("🔥 Login Error: $error");
      setLoading(false);
      _handleError(error, context);
    }
  }

  /// ✅ SIMPLIFIED: Logout - just disconnect socket and clear data
  Future<void> logoutUser(BuildContext context) async {
    setLoggingOut(true);

    try {
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      // ✅ Get userId BEFORE clearing data
      final currentUser = userPreference.currentUser;
      final userId = currentUser?.data?.user?.userId ?? '';

      print("🔓 Logout: Starting logout for user: $userId");

      // ✅ Disconnect socket and unregister user
      if (userId.isNotEmpty) {
        try {
          print("🔌 Logout: Disconnecting socket for user: $userId");

          await socketProvider.unregisterAndDisconnect(userId: userId);

          print("🔌 Logout: ✅ Socket disconnected and user unregistered");
        } catch (e) {
          print("🔌 Logout: ⚠️ Socket disconnect error - $e");
          // Continue logout even if socket fails
        }
      } else {
        print("⚠️ Logout: No userId found, skipping socket disconnect");
      }

      // ✅ Clear all user data
      try {
        await userPreference.remove();
        print("🔓 Logout: ✅ User data cleared");
      } catch (e) {
        print("🔓 Logout: ⚠️ Error clearing data - $e");
      }

      setLoggingOut(false);

      // ✅ Show success message
      Utils.flushBarSuccessMessage('Logged out successfully', context);

      // ✅ Navigate to login (this will dispose all screens)
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.welcomeLoginSignup,
            (route) => false,
      );

      print("🔓 Logout: ✅ Completed successfully");
    } catch (error) {
      print("🔥 Logout Error: $error");
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