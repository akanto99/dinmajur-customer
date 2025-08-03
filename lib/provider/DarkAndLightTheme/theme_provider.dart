import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    updateSystemTheme();
  }

  Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isDarkMode')) {
      final isDark = prefs.getBool('isDarkMode') ?? false;
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      // Default to system theme
      updateSystemTheme();
    }
    notifyListeners();
  }

  void updateSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}



class MyThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black, // Ensures dark mode support
    ),
  );
}
