import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visitor_management_app/constants/colors.dart';
import 'package:visitor_management_app/constants/font_family.dart';

/// AppTheme manages the application's Material 3 theme configurations.
///
/// Designed around the regal Sumadhura gold crest logo:
/// - Light Theme: Warm White & Gold Cream (soft ivory scaffold, crisp white cards, rich gold accents)
/// - Dark Theme: Obsidian & Champagne Gold (deep warm obsidian, midnight charcoal surfaces, glowing champagne gold)
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  //  LIGHT THEME (Warm White & Gold Cream)
  // ─────────────────────────────────────────────
  static ThemeData get lightThemeData {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      primaryColor: AppColors.primaryGold,
      fontFamily: FontFamily.plusJakartaSans,

      // ─────────────────────────────────────────────
      // COLOR SCHEME
      // ─────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGold,
        onPrimary: Colors.white,
        primaryContainer: AppColors.goldContainerLight,
        onPrimaryContainer: AppColors.goldDark,
        secondary: AppColors.goldDark,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),

      // ─────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightScaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.lightTextPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // CARD THEME
      // ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      // ─────────────────────────────────────────────
      // INPUT DECORATION
      // ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.lightTextHint,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelStyle: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),

      // ─────────────────────────────────────────────
      // ELEVATED BUTTON
      // ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // OUTLINED BUTTON
      // ─────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // TEXT BUTTON
      // ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // TEXT THEME
      // ─────────────────────────────────────────────
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleSmall: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodySmall: TextStyle(
          color: AppColors.lightTextHint,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelLarge: TextStyle(
          color: AppColors.primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelSmall: TextStyle(
          color: AppColors.lightTextHint,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // CHIP THEME
      // ─────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightInputBg,
        selectedColor: AppColors.goldContainerLight,
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // DIVIDER
      // ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCardBg,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.lightTextHint,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // SNACK BAR
      // ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─────────────────────────────────────────────
      // DIALOG
      // ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DARK THEME (Obsidian & Champagne Gold)
  // ─────────────────────────────────────────────
  static ThemeData get darkThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkScaffoldBg,
      primaryColor: AppColors.goldLight,
      fontFamily: FontFamily.plusJakartaSans,

      // ─────────────────────────────────────────────
      // COLOR SCHEME
      // ─────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldLight,
        onPrimary: AppColors.darkScaffoldBg,
        primaryContainer: AppColors.goldContainerDark,
        onPrimaryContainer: AppColors.goldGlow,
        secondary: AppColors.goldGlow,
        onSecondary: AppColors.darkScaffoldBg,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),

      // ─────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkScaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // CARD THEME
      // ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
      ),

      // ─────────────────────────────────────────────
      // INPUT DECORATION
      // ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.goldLight, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),

      // ─────────────────────────────────────────────
      // ELEVATED BUTTON
      // ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldLight,
          foregroundColor: AppColors.darkScaffoldBg,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // OUTLINED BUTTON
      // ─────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldLight,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.goldLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // TEXT BUTTON
      // ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldLight,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.plusJakartaSans,
          ),
        ),
      ),

      // ─────────────────────────────────────────────
      // TEXT THEME
      // ─────────────────────────────────────────────
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        bodySmall: TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelLarge: TextStyle(
          color: AppColors.goldLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        labelSmall: TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // CHIP THEME
      // ─────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkInputBg,
        selectedColor: AppColors.goldContainerDark,
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // DIVIDER
      // ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavBg,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: AppColors.darkTextMuted,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),

      // ─────────────────────────────────────────────
      // SNACK BAR
      // ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardBg,
        contentTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─────────────────────────────────────────────
      // DIALOG
      // ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.plusJakartaSans,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontFamily: FontFamily.plusJakartaSans,
        ),
      ),
    );
  }
}
