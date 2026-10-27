import 'package:sizer/sizer.dart';
import '../constants/strings.dart';
import '../utils/routes/routes.dart';
import '../constants/app_theme.dart';
import 'package:flutter/material.dart';
import '../stores/theme/theme_store.dart';
import '../utils/locale/app_localization.dart';
import '../di/components/service_locator.dart';
import '../stores/language/language_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:visitor_management_app/widgets/navigation_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Observer(
          name: 'global-observer',
          builder: (context) {
            return MaterialApp(
              navigatorKey: Strings.appNavigatorKey,
              debugShowCheckedModeBanner: false,
              title: Strings.appName,
              theme: _themeStore.darkMode
                  ? AppTheme.darkThemeData
                  : AppTheme.lightThemeData,
              routes: Routes.routes,
              locale: Locale(_languageStore.locale),
              supportedLocales: _languageStore.supportedLanguages
                  .map((language) => Locale(language.locale!, language.code))
                  .toList(),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: NavigationScreen(),
              builder: EasyLoading.init(),
            );
          },
        );
      },
    );
  }
}
