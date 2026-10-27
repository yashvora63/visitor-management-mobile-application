import 'dart:async';
import 'package:visitor_management_app/data/sharedpref/shared_preference_helper.dart';

class Repository {
  final SharedPreferenceHelper _sharedPrefsHelper;

  Repository(this._sharedPrefsHelper);

  // Authentication & Session
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;

  void saveAuthToken(String authToken) {
    _sharedPrefsHelper.saveAuthToken(authToken);
  }

  String? get authToken => _sharedPrefsHelper.authToken;

  Future<void> clearSession() async {
    await _sharedPrefsHelper.clearAll();
  }

  // Screen Navigation & Onboarding
  void saveScreenNavigation(String value) {
    _sharedPrefsHelper.saveScreenNavigation(value);
  }

  String? get getScreenNavigation => _sharedPrefsHelper.getScreenNavigation;

  // Theme
  Future<void> changeBrightnessToDark(bool value) =>
      _sharedPrefsHelper.changeBrightnessToDark(value);

  bool get isDarkMode => _sharedPrefsHelper.isDarkMode;

  // Language & Localization
  Future<void> changeLanguage(String value) =>
      _sharedPrefsHelper.changeLanguage(value);

  String? get currentLanguage => _sharedPrefsHelper.currentLanguage;
}
