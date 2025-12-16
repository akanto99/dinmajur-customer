// import 'dart:convert';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/model/user/user_model.dart';
// import 'package:dinmajur_customer/respository/auth_repository/otp_verify_repository.dart';
// import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
// import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class OtpVerifyViewModel with ChangeNotifier {
//   final _myRepo = OtpVerifyRepository();
//
//   bool _otpVerifyloading = false;
//   bool get otpVerifyloading => _otpVerifyloading;
//   setotpVerifyloading(bool value) {
//     _otpVerifyloading = value;
//     notifyListeners();
//   }
//
//   Future<void> otpVerify(dynamic data, BuildContext context) async {
//     setotpVerifyloading(true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('otp_token');
//       print("get token successfully $token");
//       final value = await _myRepo.otpVerify(data, token ?? '');
//
//       setotpVerifyloading(false);
//
//       if (value['success'] == true) {
//         Utils.flushBarSuccessMessage('OTP has been successfully verified.', context);
//         debugPrint('🔁 Full OTP API Response:\n${jsonEncode(value)}');
//
//         // Extract user data
//         final user = UserModel.fromJson(value);
//         final userPreference = Provider.of<UserViewModel>(context, listen: false);
//         userPreference.saveUser(user);
//         print(user);
//
//         // Extract accessToken
//         String? _accessToken = value['data']['accessToken'];
//         if (_accessToken != null && _accessToken.isNotEmpty) {
//           await prefs.setString('accessToken', _accessToken);
//           await prefs.setBool('isPhoneVerified', true);
//         } else {
//           Utils.flushBarErrorMessage('Invalid token received from server', context);
//           return;
//         }
//
//         // ✅ CONNECT TO SOCKET WITH USER ID
//         try {
//           // Extract user ID from response
//           final userId = value['data']['user']['id'] ?? value['data']['user']['_id'];
//
//           if (userId != null && userId.isNotEmpty) {
//             // Get socket provider and connect
//             final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//             await socketProvider.connectWithUser(userId: userId);
//             debugPrint('🔌 Socket connected with userId: $userId');
//           } else {
//             debugPrint('⚠️ User ID not found in response');
//           }
//         } catch (socketError) {
//           debugPrint('❌ Socket connection error: $socketError');
//           // Don't stop the flow, just log the error
//         }
//
//         // Navigate to success screen
//         await Future.delayed(const Duration(seconds: 1));
//         Navigator.pushReplacementNamed(context, RoutesName.verificationSuccessScreen);
//
//       } else {
//         final errorMessage = value['message'] ?? 'OTP verification failed';
//         Utils.flushBarErrorMessage(errorMessage, context);
//       }
//     } catch (error) {
//       setotpVerifyloading(false);
//       _handleError(error, context);
//     }
//   }
//
//   ///Handle Errors
//   void _handleError(dynamic error, BuildContext context) {
//     String errorMessage = '$error';
//     try {
//       String errorBody = error.toString();
//       int jsonStartIndex = errorBody.indexOf('{');
//       if (jsonStartIndex != -1) {
//         final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
//         errorMessage = decoded['message'] ?? (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty ? decoded['errorMessages'][0]['message'] : errorMessage);
//       }
//     } catch (_) {
//       errorMessage = 'Unexpected error occurred';
//     }
//     Utils.flushBarErrorMessage(errorMessage, context);
//   }
//
//   String? _accessToken;
//   String? get accessToken => _accessToken;
// }
import 'dart:convert';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_count/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/auth_repository/otp_verify_repository.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart'; // ✅ Add SSE import
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
      final value = await _myRepo.otpVerify(data, token ?? '');

      setotpVerifyloading(false);

      if (value['success'] == true) {
        Utils.flushBarSuccessMessage('OTP has been successfully verified.', context);
        final user = UserModel.fromJson(value);
        final userPreference = Provider.of<UserViewModel>(context, listen: false);
        await userPreference.saveUser(user);
        print("👤 User saved: $user");
        String? accessToken = value['data']['accessToken'];
        String? userId = value['data']['user']['id'] ?? value['data']['user']['_id'];

        if (accessToken == null || accessToken.isEmpty) {
          Utils.flushBarErrorMessage('Invalid token received from server', context);
          return;
        }
        await prefs.setString('accessToken', accessToken);
        await prefs.setBool('isPhoneVerified', true);
        if (userId != null && userId.isNotEmpty) {
          await prefs.setString('userId', userId);}
        ///SOCKET
        if (userId != null && userId.isNotEmpty) {
          try {
            final socketProvider = Provider.of<SocketProvider>(context, listen: false);

            print("🔌 OTP Verify: Connecting socket with userId: $userId");
            await socketProvider.connectWithUser(userId: userId);

            // Wait to ensure connection
            await Future.delayed(Duration(milliseconds: 1000));

            if (socketProvider.isConnected) {
              print("🔌 OTP Verify: ✅ Socket connected successfully");
            } else {
              print("🔌 OTP Verify: ⚠️ Socket connection uncertain, attempting retry");
              await socketProvider.autoReconnect(
                maxRetries: 3,
                delay: Duration(seconds: 2),
              );
            }
          } catch (socketError) {
            print("❌ OTP Verify: Socket connection error - $socketError");
            // Don't stop the flow, just log the error
          }
        } else {
          print("⚠️ OTP Verify: User ID not found in response");
        }

        ///SSE
        if (accessToken.isNotEmpty) {
          try {
            final sseService = Provider.of<SSENotificationService>(context, listen: false);
            final notificationCountViewModel = NotificationCountViewModel();
            print("🔔 OTP Verify: Starting SSE connection with access token");
            await sseService.startListening();
            await Future.delayed(Duration(milliseconds: 500)); // Wait for initial count
            notificationCountViewModel.initializeCountListener(sseService.notificationCountStream);
            notificationCountViewModel.setInitialCount(sseService.currentCount);
            print("🔔 OTP Verify: ✅ SSE connection initiated successfully");
          } catch (sseError) {
            print("❌ OTP Verify: SSE connection error - $sseError");
          }
        } else {
          print("⚠️ OTP Verify: Access token is empty, skipping SSE connection");
        }

        //Navigate to success screen
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, RoutesName.verificationSuccessScreen);

        print("✅ OTP Verification Complete: Socket & SSE connected, navigating to success screen");

      } else {
        final errorMessage = value['message'] ?? 'OTP verification failed';
        Utils.flushBarErrorMessage(errorMessage, context);
      }
    } catch (error) {
      setotpVerifyloading(false);
      print("🔥 OTP Verify Error: $error");
      _handleError(error, context);
    }
  }

  /// Handle Errors
  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';

    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');

      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }

    Utils.flushBarErrorMessage(errorMessage, context);
  }

  String? _accessToken;
  String? get accessToken => _accessToken;
}