// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
//
// class SessionExpiredService {
//   // ✅ Use the existing NavigationService navigatorKey
//   static GlobalKey<NavigatorState> get navigatorKey => NavigationService.navigatorKey;
//
//   /// Handle session expired - clear all user data and navigate to welcome screen
//   Future<void> handleSessionExpired() async {
//     try {
//       print('🔒 Handling session expired...');
//
//       // Clear all stored data
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.clear();
//
//       print('✅ All user data cleared');
//
//       // Navigate to welcome screen using NavigationService
//       final context = navigatorKey.currentContext;
//       if (context != null && context.mounted) {
//
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           RoutesName.welcomeLoginSignup,
//               (Route<dynamic> route) => false,
//         );
//         print('✅ Navigated to welcome screen');
//       } else {
//         print('❌ Context not available for navigation');
//       }
//     } catch (e) {
//       print('❌ Error in handleSessionExpired: $e');
//     }
//   }
// }

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';

class SessionExpiredService {
  // ✅ Use the existing NavigationService navigatorKey
  static GlobalKey<NavigatorState> get navigatorKey => NavigationService.navigatorKey;

  /// Show session expired dialog
  Future<void> showSessionExpiredDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      print('❌ Context not available for dialog');
      await handleSessionExpired(); // Fallback: direct logout
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: AppColors.appBackground(dialogContext),
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.flushbarColor(dialogContext),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Session Expired',
                      style: AppTextStyles.textSize20(
                        dialogContext,
                        weight: FontWeight.w500,
                        color: AppColors.darkRedColor,
                      ),
                    ),
                  ),
                  SizedboxSpaccing.height02(dialogContext),
                  Text(
                    "Your session has expired. Don't worry, we kept all of your filters and breakdowns in place.\nPlease login again to continue.",
                    style: AppTextStyles.textSize14(
                      dialogContext,
                      weight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height02(dialogContext),
                  GestureDetector(
                    onTap: () async {
                      // Close dialog first
                      Navigator.of(dialogContext).pop();

                      // Handle logout and navigation
                      await handleSessionExpired();
                    },
                    child: Container(
                      width: screenWidth * 0.3,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.button(dialogContext),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Login Again',
                          style: AppTextStyles.textSize14(
                            dialogContext,
                            weight: FontWeight.w500,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle session expired - clear all user data and navigate to welcome screen
  Future<void> handleSessionExpired() async {
    try {
      print('🔒 Handling session expired...');

      // Clear UserViewModel data
      final userViewModel = UserViewModel();
      await userViewModel.remove();
      print('✅ UserModel data cleared');

      // Clear all SharedPreferences data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ All SharedPreferences data cleared');

      // Navigate to welcome screen
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesName.welcomeLoginSignup,
              (Route<dynamic> route) => false,
        );
        print('✅ Navigated to welcome screen');
      } else {
        print('❌ Context not available for navigation');
      }
    } catch (e) {
      print('❌ Error in handleSessionExpired: $e');
    }
  }
}