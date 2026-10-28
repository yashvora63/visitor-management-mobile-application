import 'package:flutter/material.dart';
import '../di/components/service_locator.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/navigation/navigation_store.dart';
import 'package:visitor_management_app/screens/preview/preview.dart';
import 'package:visitor_management_app/screens/bottom_navigation/bottom_navigation.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late final NavigationStore _navigationStore = getIt<NavigationStore>();

  @override
  void didChangeDependencies() {
    _navigationStore.getScreenNavigationText();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final screenName = _navigationStore.screenName;
        final hasCompletedOnboarding =
            screenName == "bottom_navigation" || screenName == "home";

        if (!hasCompletedOnboarding) {
          return const PreviewScreen();
        } else {
          return const BottomNavigation();
        }
      },
    );
  }
}
