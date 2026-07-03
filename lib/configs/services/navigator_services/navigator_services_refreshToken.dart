import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  // Navigation methods
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateAndClearStack(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  // Session expired handling
  Future<void> handleSessionExpired() async {
    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

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
                      try {
                        Navigator.of(dialogContext).pop();
                        final loginLogoutViewModel = Provider.of<LoginLogoutViewModel>(
                          context,
                          listen: false,
                        );

                        await loginLogoutViewModel.logoutUser(context);

                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutesName.authLoginWelcome,
                                (Route<dynamic> route) => false,
                          );
                        }
                      } catch (e) {
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
}