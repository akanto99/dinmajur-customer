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

      print("🔍 Splash Check:");
      print("   - accessToken: ${accessToken != null ? 'Present' : 'Missing'}");
      print("   - isPhoneVerified: $isPhoneVerified");
      print("   - role: $role");

      await Future.delayed(Duration(milliseconds: 1500));

      // Check if no token or empty token
      if (accessToken == null || accessToken.isEmpty) {
        print("🔓 Navigation: No token found - Going to auth_login");
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.welcomeLoginSignup,
              (route) => false,
        );
      }
      // Check if user is verified CUSTOMER
      else if (accessToken.isNotEmpty &&
          isPhoneVerified == true &&
          role == "CUSTOMER") {
        print("✅ Navigation: All conditions met - Going to home");
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.navigationBar,
              (route) => false,
        );
      }
      // User is not verified or not a CUSTOMER
      else {
        print("❌ Navigation: Conditions not met:");
        print("   - Has token: ${accessToken.isNotEmpty}");
        print("   - Phone verified: $isPhoneVerified");
        print("   - Is CUSTOMER: ${role == "CUSTOMER"}");
        print("   - Current role: $role");
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.welcomeLoginSignup,
              (route) => false,
        );
      }
    } else {
      print("👋 Navigation: First time user - Show onboarding");
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.onBoardUpdated,
            (route) => false,
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