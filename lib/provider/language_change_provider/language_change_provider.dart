import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeProvider with ChangeNotifier {
  Locale? _appLocale;

  Locale? get appLocale => _appLocale;

  // Change this method to return Future<void>
  Future<void> changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (type == Locale('en')) {
      await sp.setString('language_code', 'en');
      _appLocale = Locale('en');
    } else {
      await sp.setString('language_code', 'bn');
      _appLocale = Locale('bn');
    }

    print('Language changed to: ${_appLocale?.languageCode}'); // Debug print
    notifyListeners();
  }

  // Make sure this returns Future<void> and is properly awaited
  Future<void> getLanguage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? languageCode = sp.getString('language_code');

    print('Retrieved language code: $languageCode'); // Debug print

    if (languageCode != null) {
      if (languageCode == 'en') {
        _appLocale = Locale('en');
      } else {
        _appLocale = Locale('bn');
      }
    } else {
      _appLocale = Locale('en'); // Default to English
      // Save default language to preferences
      await sp.setString('language_code', 'en');
    }

    print('Final app locale: ${_appLocale?.languageCode}'); // Debug print
    notifyListeners();
  }
}