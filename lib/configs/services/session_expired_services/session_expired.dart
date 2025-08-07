
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';

class SessionExpiredService {
  static final SessionExpiredService _instance = SessionExpiredService._internal();
  factory SessionExpiredService() => _instance;
  SessionExpiredService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  // Navigate to a route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Navigate and remove all previous routes
  Future<dynamic> navigateAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  // Navigate and replace current route
  Future<dynamic> navigateAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Go back
  void goBack([dynamic result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  // 🔧 NEW METHOD: Direct navigation to login without dialog
  Future<void> navigateToLoginDirectly() async {
    navigateAndRemoveUntil(RoutesName.welcomeLoginSignup);
  }

  // Keep the old method for manual session expired (when user manually logs out)
  Future<void> handleSessionExpired() async {
    if (currentContext != null) {
      // Only show dialog if not already showing one
      if (!_isDialogShowing) {
        _isDialogShowing = true;

        await showDialog(
          context: currentContext!,
          barrierDismissible: false,
          // barrierColor: AppColors.whiteColor.withOpacity(0.1),
          builder: (BuildContext context) {
            final screenWidth = MediaQuery.of(context).size.width * 1;
            final screenHeight = MediaQuery.of(context).size.height * 1;
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                backgroundColor: AppColors.appBackground(context),
                insetPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    // color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.flushbarColor(context),
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
                          child: Text('Session Expired',style: AppTextStyles.textSize20(context,weight: FontWeight.w500,color: AppColors.darkRedColor),)),
                      SizedboxSpaccing.height02(context),
                      Text("Your session has expired.Don't worry, we kept all of your filters and breakdowns in place.\nPlease login again to continue.",style: AppTextStyles.textSize14(context,weight:
                      FontWeight.w400),textAlign: TextAlign.center,),
                      SizedboxSpaccing.height02(context),



                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _isDialogShowing = false;
                          navigateAndRemoveUntil(RoutesName.welcomeLoginSignup);
                        },
                        child: Container(
                          width: screenWidth * 0.3,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.button(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                                'Login Again',
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500,color: AppColors.whiteColor)
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

        _isDialogShowing = false;
      }
    } else {
      // If no context, directly navigate to login
      navigateAndRemoveUntil(RoutesName.welcomeLoginSignup);
    }
  }

  static bool _isDialogShowing = false;

}