import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(context).size.width * 1;
        final screenHeight = MediaQuery.of(context).size.height * 1;

        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
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
                    "Your session has expired. Don't worry, we kept all of your filters and breakdowns in place.\nPlease auth_login again to continue.",
                    style: AppTextStyles.textSize14(
                      dialogContext,
                      weight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height02(dialogContext),
                  GestureDetector(
                    onTap: () async {
                      try {
                        // ✅ 1. Close the dialog first
                        Navigator.of(dialogContext).pop();

                        print('🔄 User clicked Login Again, logging out...');

                        // ✅ 2. Perform logout
                        final loginLogoutViewModel = Provider.of<LoginLogoutViewModel>(
                            context,
                            listen: false
                        );

                        await loginLogoutViewModel.logoutUser(context);

                        print('✅ Logout successful');

                        // ✅ 3. Navigate to welcome screen
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutesName.authLoginWelcome,
                                (Route<dynamic> route) => false,
                          );
                          print('✅ Navigated to welcome screen');
                        }
                      } catch (e) {
                        print('❌ Error during logout/navigation: $e');
                      }
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

  /// Handle session expired - clear all user data and show dialog
  Future<void> handleSessionExpired() async {
    try {
      await showSessionExpiredDialog();

    } catch (e) {
      print('❌ Error in handleSessionExpired: $e');

      // Fallback: If dialog fails, navigate directly
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesName.authLoginWelcome,
              (Route<dynamic> route) => false,
        );
      }
    }
  }
}