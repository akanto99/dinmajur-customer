// import 'dart:convert';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/model/user/user_model.dart';
// import 'package:dinmajur_customer/respository/auth_repository/login_logout_repository.dart';
// import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
// import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LoginLogoutViewModel with ChangeNotifier {
//   final _myRepo = LoginLogoutRepository();
//
//   bool _loading = false;
//   bool get loading => _loading;
//
//   bool _loggingOut = false;
//   bool get loggingOut => _loggingOut;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   setLoggingOut(bool value) {
//     _loggingOut = value;
//     notifyListeners();
//   }
//
//   Future<void> loginApi(dynamic data, BuildContext context) async {
//     setLoading(true);
//
//     try {
//       final response = await _myRepo.loginApi(data);
//
//       // Parse the response
//       final user = UserModel.fromJson(response);
//
//       final bool isPhoneVerified = user.data?.user?.isPhoneVerified ?? false;
//       final bool isRegistered = user.data?.user?.isRegistered ?? false;
//       final String userRole = user.data?.user?.role ?? '';
//       final String userId = user.data?.user?.userId ?? '';
//
//       print("🔍 Login Response Check:");
//       print("   - accessToken: ${user.data?.accessToken != null ? 'Present' : 'Missing'}");
//       print("   - isPhoneVerified: $isPhoneVerified");
//       print("   - isRegistered: $isRegistered");
//       print("   - userRole: $userRole");
//       print("   - userId: $userId");
//
//       // ✅ CHECK ROLE FIRST - Before saving anything
//       if (userRole.toUpperCase() != 'CUSTOMER') {
//         setLoading(false);
//         print("❌ Login Failed: User role is '$userRole', not 'CUSTOMER'");
//         Utils.flushBarErrorMessage("এই অ্যাকাউন্টটি কাস্টমার অ্যাকাউন্ট নয়", context);
//         return; // Exit early - don't save user data or navigate
//       }
//
//       // ✅ CHECK PHONE VERIFICATION
//       if (!isPhoneVerified) {
//         setLoading(false);
//         print("❌ Login Failed: Phone not verified");
//         Utils.flushBarErrorMessage("এই নাম্বারটি রেজিস্টার করা হয়নি", context);
//         return; // Exit early
//       }
//
//       // ✅ If we reach here, user is a verified CUSTOMER - proceed with login
//       final userPreference = Provider.of<UserViewModel>(context, listen: false);
//       await userPreference.saveUser(user);
//
//       // Save additional preferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('accessToken', user.data?.accessToken ?? '');
//       await prefs.setBool('isPhoneVerified', isPhoneVerified);
//       await prefs.setBool('isRegistered', isRegistered);
//       await prefs.setString('role', userRole);
//       await prefs.setString('userId', userId);
//
//       // ✅ CONNECT SOCKET AFTER SUCCESSFUL LOGIN
//       if (userId.isNotEmpty) {
//         try {
//           final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//
//           print("🔌 Login: Connecting socket for user: $userId");
//
//           // Connect socket with user credentials
//           await socketProvider.connectWithUser(userId: userId);
//
//           // Wait to ensure connection is established
//           await Future.delayed(Duration(seconds: 1));
//
//           if (socketProvider.isConnected) {
//             print("🔌 Login: ✅ Socket connected successfully");
//           } else {
//             print("🔌 Login: ⚠️ Socket not connected, attempting retry");
//             await socketProvider.autoReconnect(
//               maxRetries: 3,
//               delay: Duration(seconds: 2),
//             );
//           }
//         } catch (socketError) {
//           print("🔌 Login: Socket connection error - $socketError");
//           // Don't fail login if socket connection fails
//           // Socket will be reconnected by app lifecycle management
//         }
//       } else {
//         print("⚠️ Login: userId is empty, skipping socket connection");
//       }
//
//       setLoading(false);
//
//       // Show success message
//       await Future.delayed(Duration(milliseconds: 300));
//       Utils.flushBarSuccessMessage('Login Successfully', context);
//
//       print("✅ Login Success: Customer verified - Navigating to home");
//
//       // Navigate to home
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         RoutesName.navigationBar,
//             (route) => false,
//       );
//
//       if (kDebugMode) print("Login Response: ${response.toString()}");
//     } catch (error) {
//       print("🔥 Login Error: $error");
//       setLoading(false);
//       _handleError(error, context);
//     }
//   }
//
//   /// ✅ SIMPLIFIED: Logout - just disconnect socket and clear data
//   Future<void> logoutUser(BuildContext context) async {
//     if (_loggingOut) {
//       print("⚠️ Logout already in progress");
//       return;
//     }
//
//     setLoggingOut(true);
//
//     try {
//       final userPreference = Provider.of<UserViewModel>(context, listen: false);
//       final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//       final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false); // Add this
//
//       // Get accessToken from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken') ?? '';
//
//       // ✅ FIX: Get userId from SharedPreferences FIRST (more reliable)
//       String userId = prefs.getString('userId') ?? '';
//
//       // Fallback: try to get from userPreference if not in SharedPreferences
//       if (userId.isEmpty) {
//         final currentUser = userPreference.currentUser;
//         userId = currentUser?.data?.user?.userId ?? '';
//       }
//
//       print("🔓 Logout: userId = '$userId', token exists = ${token.isNotEmpty}");
//
//       if (token.isEmpty) {
//         print("❌ Logout: No accessToken found");
//         setLoggingOut(false);
//         Utils.flushBarErrorMessage("Invalid session. Please login again.", context);
//         return;
//       }
//
//       // ✅ STEP 1: Disconnect socket FIRST (with better error handling)
//       bool socketDisconnected = false;
//
//       // Always attempt to disconnect socket, even if userId is empty
//       try {
//         print("🔌 Attempting to disconnect socket (userId: '$userId')");
//
//         if (userId.isNotEmpty) {
//           // If we have userId, do proper unregister
//           await socketProvider.unregisterAndDisconnect(userId: userId)
//               .timeout(Duration(seconds: 5));
//         } else {
//           // If no userId, just force disconnect
//           print("⚠️ No userId found, forcing socket disconnect");
//           await socketProvider.disconnect().timeout(Duration(seconds: 2));
//         }
//
//         socketDisconnected = true;
//         print("🔌 ✅ Socket disconnected successfully");
//
//       } catch (e) {
//         print("⚠️ Socket disconnect failed: $e");
//
//         // Try force disconnect as fallback
//         try {
//           print("🔌 Attempting force disconnect...");
//           await socketProvider.disconnect().timeout(Duration(seconds: 2));
//           socketDisconnected = true;
//           print("🔌 ✅ Force disconnect successful");
//         } catch (forceError) {
//           print("⚠️ Force disconnect also failed: $forceError");
//           // Continue anyway - don't block logout
//         }
//       }
//
//       // ✅ STEP 2: Call logout API
//       try {
//         print("🔓 Calling logout API...");
//         await _myRepo.logoutApi(token).timeout(Duration(seconds: 10));
//         print("🔓 ✅ Logout API call successful");
//       } catch (apiError) {
//         print("⚠️ Logout API failed: $apiError");
//         // Continue with local cleanup even if API fails
//       }
//
//       // ✅ STEP 3: Clear local data
//       print("🗑️ Clearing local data...");
//       await userPreference.remove();
//       profileViewModel.clearCache();
//
//       setLoggingOut(false);
//
//       // ✅ STEP 4: Show success message
//       if (!socketDisconnected) {
//         Utils.flushBarErrorMessage("Logged out (socket may still be connected)", context);
//       } else {
//         Utils.flushBarSuccessMessage("Logged out successfully", context);
//       }
//
//       // ✅ STEP 5: Navigate to login (this will close the dialog automatically)
//       Navigator.pushNamedAndRemoveUntil(
//           context, RoutesName.welcomeLoginSignup, (route) => false);
//
//       print("🔓 ✅ Logout Completed Successfully");
//
//     } catch (error) {
//       print("❌ Logout Error: $error");
//       setLoggingOut(false);
//       _handleError(error, context);
//     }
//   }
//
//   /// Handle Errors
//   void _handleError(dynamic error, BuildContext context) {
//     String errorMessage = 'Something went wrong';
//
//     try {
//       String errorBody = error.toString();
//
//       // Look for JSON in the error string
//       int jsonStartIndex = errorBody.indexOf('{');
//       if (jsonStartIndex != -1) {
//         String jsonString = errorBody.substring(jsonStartIndex);
//         final decoded = jsonDecode(jsonString);
//
//         // Extract error message from different possible structures
//         if (decoded['message'] != null) {
//           errorMessage = decoded['message'];
//         } else if (decoded['errorMessages'] is List &&
//             decoded['errorMessages'].isNotEmpty &&
//             decoded['errorMessages'][0]['message'] != null) {
//           errorMessage = decoded['errorMessages'][0]['message'];
//         }
//       } else {
//         // If no JSON found, use the error as is (but clean it up)
//         errorMessage = errorBody.replaceAll('Exception: ', '');
//       }
//     } catch (e) {
//       print("Error parsing error message: $e");
//       errorMessage = 'Unexpected error occurred';
//     }
//
//     Utils.flushBarErrorMessage(errorMessage, context);
//   }
// }

import 'dart:convert';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_count/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/login_logout_repository.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart'; // ✅ Add SSE import
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
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
      final String accessToken = user.data?.accessToken ?? ''; // ✅ Get access token

      print("🔍 Login Response Check:");
      print("   - accessToken: ${accessToken.isNotEmpty ? 'Present' : 'Missing'}");
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
      await prefs.setString('accessToken', accessToken);
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

      // ✅ START SSE CONNECTION AFTER SUCCESSFUL LOGIN
      if (accessToken.isNotEmpty) {
        try {
          final sseService = Provider.of<SSENotificationService>(context, listen: false);
          final notificationCountViewModel = NotificationCountViewModel();

          print("🔔 Login: Starting SSE connection with access token");

          // Start SSE listening with the access token
          await sseService.startListening();
          await Future.delayed(Duration(milliseconds: 500)); // Wait for initial count
          notificationCountViewModel.initializeCountListener(sseService.notificationCountStream);
          notificationCountViewModel.setInitialCount(sseService.currentCount);
        } catch (sseError) {
          print("🔔 Login: SSE connection error - $sseError");
          // Don't fail login if SSE connection fails
          // SSE can be reconnected later
        }
      } else {
        print("⚠️ Login: accessToken is empty, skipping SSE connection");
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

  /// ✅ UPDATED LOGOUT: Disconnect both Socket and SSE
  Future<void> logoutUser(BuildContext context) async {
    if (_loggingOut) {
      print("⚠️ Logout already in progress");
      return;
    }

    setLoggingOut(true);

    try {
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      final sseService = Provider.of<SSENotificationService>(context, listen: false); // ✅ Get SSE service

      // Get accessToken from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      // ✅ Get userId from SharedPreferences
      String userId = prefs.getString('userId') ?? '';

      // Fallback: try to get from userPreference if not in SharedPreferences
      if (userId.isEmpty) {
        final currentUser = userPreference.currentUser;
        userId = currentUser?.data?.user?.userId ?? '';
      }

      print("🔓 Logout: userId = '$userId', token exists = ${token.isNotEmpty}");

      if (token.isEmpty) {
        print("❌ Logout: No accessToken found");
        setLoggingOut(false);
        Utils.flushBarErrorMessage("Invalid session. Please login again.", context);
        return;
      }

      // ✅ STEP 1: Disconnect Socket
      bool socketDisconnected = false;

      try {
        print("🔌 Attempting to disconnect socket (userId: '$userId')");

        if (userId.isNotEmpty) {
          await socketProvider.unregisterAndDisconnect(userId: userId)
              .timeout(Duration(seconds: 5));
        } else {
          print("⚠️ No userId found, forcing socket disconnect");
          await socketProvider.disconnect().timeout(Duration(seconds: 2));
        }

        socketDisconnected = true;
        print("🔌 ✅ Socket disconnected successfully");

      } catch (e) {
        print("⚠️ Socket disconnect failed: $e");

        try {
          print("🔌 Attempting force disconnect...");
          await socketProvider.disconnect().timeout(Duration(seconds: 2));
          socketDisconnected = true;
          print("🔌 ✅ Force disconnect successful");
        } catch (forceError) {
          print("⚠️ Force disconnect also failed: $forceError");
        }
      }

      // ✅ STEP 1.5: Stop SSE Connection
      bool sseDisconnected = false;

      try {
        print("🔔 Attempting to stop SSE connection");
        await sseService.stopListening();
        sseDisconnected = true;
        print("🔔 ✅ SSE connection stopped successfully");
      } catch (e) {
        print("⚠️ SSE disconnect failed: $e");
        // Continue anyway - don't block logout
      }

      // ✅ STEP 2: Call logout API
      try {
        print("🔓 Calling logout API...");
        await _myRepo.logoutApi(token).timeout(Duration(seconds: 10));
        print("🔓 ✅ Logout API call successful");
      } catch (apiError) {
        print("⚠️ Logout API failed: $apiError");
        // Continue with local cleanup even if API fails
      }

      // ✅ STEP 3: Clear local data
      print("🗑️ Clearing local data...");
      await userPreference.remove();
      profileViewModel.clearCache();

      setLoggingOut(false);

      // ✅ STEP 4: Show success message
      if (!socketDisconnected || !sseDisconnected) {
        Utils.flushBarErrorMessage("Logged out (connections may still be active)", context);
      } else {
        Utils.flushBarSuccessMessage("Logged out successfully", context);
      }

      // ✅ STEP 5: Navigate to login
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.welcomeLoginSignup, (route) => false);

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