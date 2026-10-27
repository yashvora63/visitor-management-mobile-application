import 'package:flutter/material.dart';

/// Helper class for device related operations, screen metrics, and responsive values.
class DeviceUtils {
  /// Hides the soft keyboard if it's currently open.
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Returns true if the screen is classified as a tablet (width >= 600 or shortestSide >= 600).
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width >= 600 || mediaQuery.size.shortestSide >= 600;
  }

  /// Returns true if the screen is classified as mobile.
  static bool isMobile(BuildContext context) => !isTablet(context);

  /// Returns a responsive value based on device type.
  /// If device is a tablet and [tablet] is provided, returns [tablet].
  /// Otherwise returns [mobile].
  static T responsive<T>(BuildContext context, {required T mobile, T? tablet}) {
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Returns true if the device orientation is portrait.
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Returns true if the device orientation is landscape.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Returns total screen width.
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Returns total screen height.
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns the shortest side of the screen.
  static double getShortestSide(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide;

  /// Accepts a double [scale] and returns scaled size based on screen orientation.
  static double getScaledSize(BuildContext context, double scale) =>
      scale *
      (MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.height);

  /// Accepts a double [scale] and returns scaled size based on screen width.
  static double getScaledWidth(BuildContext context, double scale) =>
      scale * MediaQuery.of(context).size.width;

  /// Accepts a double [scale] and returns scaled size based on screen height.
  static double getScaledHeight(BuildContext context, double scale) =>
      scale * MediaQuery.of(context).size.height;
}
