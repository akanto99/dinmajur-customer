import 'package:flutter/material.dart';
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  BuildContext? get context => navigatorKey.currentContext;

  // Method to handle automatic logout
  Future<void> handleSessionExpired() async {
    if (navigatorKey.currentContext != null) {
      // Show a dialog to inform user about session expiry
      await showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please login again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login and clear all previous routes
                navigateAndClearStack('/login');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // If no context available, just navigate to login
      navigateAndClearStack('/login');
    }
  }
}