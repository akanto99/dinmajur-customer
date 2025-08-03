import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashService {

  Future<void> navigateAfterDelay(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));

    bool seen = await getShowHome();

    if (seen) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      bool? isPhoneVerified = prefs.getBool('isPhoneVerified');
      String? role = prefs.getString('role');

      print("accessToken: $accessToken");
      print("isPhoneVerified: $isPhoneVerified");
      print("role: $role");

      await Future.delayed(Duration(milliseconds: 1500));

      if (accessToken == null || accessToken.isEmpty) {
        print("🔓 A: No token found");
        Navigator.pushNamed(context, RoutesName.welcomeLoginSignup);
      }
      // ✅ Most specific condition first (F)
      else if (accessToken.isNotEmpty &&
          isPhoneVerified == true &&
          role == "CUSTOMER") {
        print("✅ Navigation: Going to home - All conditions met");
        Navigator.pushNamed(context, RoutesName.navigationBar);
      }
      else {
        print("   - role == CUSTOMER: ${role == "CUSTOMER"}");
        print("   - Current role: $role");
        Navigator.pushNamed(context, RoutesName.welcomeLoginSignup);
      }
    } else {
      print("👋 : First time, show onboarding");
      // Navigator.pushNamed(context, RoutesName.onBoard);
      Navigator.pushNamed(context, RoutesName.onBoardUpdated);
    }
  }
}

Future<void> setShowHome() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('showHome', true);
}

Future<bool> getShowHome() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('showHome') ?? false;
}