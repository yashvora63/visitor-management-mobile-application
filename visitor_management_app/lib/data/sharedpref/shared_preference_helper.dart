import 'dart:async';
import 'constants/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  final SharedPreferences _sharedPreference;

  SharedPreferenceHelper(this._sharedPreference);

  // Authentication & Session: -------------------------------------------------
  String? get authToken {
    return _sharedPreference.getString(Preferences.auth_token);
  }

  Future<bool> saveAuthToken(String authToken) async {
    return _sharedPreference.setString(Preferences.auth_token, authToken);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.auth_token);
  }

  Future<bool> get isLoggedIn async {
    return _sharedPreference.getBool(Preferences.is_logged_in) ?? false;
  }

  Future<bool> saveIsLoggedIn(bool value) async {
    return _sharedPreference.setBool(Preferences.is_logged_in, value);
  }

  // Screen Navigation & Onboarding: -------------------------------------------
  Future<bool> saveScreenNavigation(String value) async {
    return _sharedPreference.setString(Preferences.screen_navigation, value);
  }

  String? get getScreenNavigation {
    return _sharedPreference.getString(Preferences.screen_navigation);
  }

  // Theme: --------------------------------------------------------------------
  bool get isDarkMode {
    return _sharedPreference.getBool(Preferences.is_dark_mode) ?? false;
  }

  Future<bool> changeBrightnessToDark(bool value) async {
    return _sharedPreference.setBool(Preferences.is_dark_mode, value);
  }

  // Language & Locale: --------------------------------------------------------
  String? get currentLanguage {
    return _sharedPreference.getString(Preferences.current_language);
  }

  Future<bool> changeLanguage(String language) async {
    return _sharedPreference.setString(Preferences.current_language, language);
  }

  // Clear Session / Reset Preferences: ----------------------------------------
  Future<bool> clearAll() async {
    return await _sharedPreference.clear();
  }
}
