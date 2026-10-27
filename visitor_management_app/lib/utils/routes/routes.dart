import 'package:flutter/material.dart';
import 'package:visitor_management_app/screens/bottom_navigation/bottom_navigation.dart';

class Routes {
  Routes._();

  //static variables
  static const String bottomNavigation = '/bottom_navigation';
  static const String visitorDetail = '/visitor_detail';

  static final routes = <String, WidgetBuilder>{
    bottomNavigation: (BuildContext context) => const BottomNavigation(),
  };
}
