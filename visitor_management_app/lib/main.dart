import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di/components/service_locator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:visitor_management_app/screens/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPreferredOrientations();
  await GetStorage.init();
  await setupLocator();
  return runApp(MyApp());
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
