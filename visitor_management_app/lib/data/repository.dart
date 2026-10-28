import 'dart:async';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/data/network/apis/visitors/visitors_api.dart';
import 'package:visitor_management_app/data/sharedpref/shared_preference_helper.dart';
import 'package:visitor_management_app/models/visitor_detail/visitor_detail_model.dart';
import 'package:visitor_management_app/data/network/apis/visitors_registration/visitors_registration_api.dart';

class Repository {
  final VisitorListApi _visitorListApi;
  final SharedPreferenceHelper _sharedPrefsHelper;
  final VisitorRegistrationApi _visitorRegistrationApi;

  Repository(
    this._sharedPrefsHelper,
    this._visitorListApi,
    this._visitorRegistrationApi,
  );

  //visitor apis

  Future<List<VisitorListModel>> getVisitorList() async {
    return await _visitorListApi.getVisitorList();
  }

  Future<VisitorDetailModel> getVisitordetail(String id) async {
    return await _visitorListApi.getVisitordetail(id);
  }

  Future<bool> deleteVisitor(String id) async {
    return await _visitorListApi.deleteVisitor(id);
  }

  Future<VisitorListModel> registerVisitor(Map<String, dynamic> data) async {
    return await _visitorRegistrationApi.registerVisitor(data);
  }

  Future<VisitorListModel> updateVisitor(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _visitorRegistrationApi.updateVisitor(id, data);
  }

  Future<VisitorListModel> patchVisitor(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _visitorRegistrationApi.patchVisitor(id, data);
  }

  Future<bool> addVisitorRegistration() async {
    return await _visitorRegistrationApi.addVisitorRegistration();
  }


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
