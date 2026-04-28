import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/pending_navigator_service.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashService {
  Future<void> navigateAfterDelay(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    bool seen = await getShowHome();

    if (seen) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      String? role = prefs.getString('role');

      await Future.delayed(const Duration(milliseconds: 1500));

      if (accessToken == null || accessToken.isEmpty) {
        PendingNavigationService().clear();
        Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.authLoginWelcome, (route) => false,
        );
      } else if (accessToken.isNotEmpty && role == "CUSTOMER") {
        Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.navigationBar, (route) => false,
        );

        /// ⚡ After home is pushed, check for a pending notification route
        final pending = PendingNavigationService();
        if (pending.hasPending) {
          await Future.delayed(const Duration(milliseconds: 500));
          final navigator = NavigationService.navigatorKey.currentState;
          if (navigator != null) {
            pending.consumePending(navigator);
          }
        }
      } else {
        PendingNavigationService().clear();
        Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.authLoginWelcome, (route) => false,
        );
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, RoutesName.onBoardUpdated, (route) => false,
      );
    }
  }
}
Future<void> setShowHome() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool('showHome', true);
}

Future<bool> getShowHome() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('showHome') ?? false;
}