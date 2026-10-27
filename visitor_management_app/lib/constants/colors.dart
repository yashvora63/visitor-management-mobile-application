import 'package:flutter/material.dart';

/// AppColors represents the luxury design palette for the Visitor Management Application,
/// inspired by the Sumadhura golden crest logo.
///
/// Palette Strategy:
/// - Light Theme: Warm White & Gold Cream (soft ivory surfaces with rich gold accents)
/// - Dark Theme: Obsidian & Champagne Gold (deep warm charcoal/obsidian with glowing champagne gold)
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────
  // BRAND GOLD PALETTE (Extracted from Logo)
  // ─────────────────────────────────────────────
  /// Primary warm regal gold from the logo crest
  static const Color primaryGold = Color(0xFFC59A3F);

  /// Luminous champagne gold for highlights, active tabs, and primary buttons in dark mode
  static const Color goldLight = Color(0xFFDFBA5D);

  /// Deep bronze/antique gold for pressed states and high-contrast light borders
  static const Color goldDark = Color(0xFFA17A24);

  /// Soft, radiant champagne gold glow for dark surfaces
  static const Color goldGlow = Color(0xFFE5C068);

  /// Ultra-subtle warm gold container fill for light mode badges & cards
  static const Color goldContainerLight = Color(0xFFF9F4E8);

  /// Deep amber-tinted obsidian container for dark mode chips & cards
  static const Color goldContainerDark = Color(0xFF282319);

  // ─────────────────────────────────────────────
  // LIGHT THEME (White & Gold Cream)
  // ─────────────────────────────────────────────
  /// Warm ivory/cream background
  static const Color lightScaffoldBg = Color(0xFFFAF8F5);

  /// Pure crisp white for elevated cards
  static const Color lightCardBg = Color(0xFFFFFFFF);

  /// Surface color for dialogs, bottom sheets, and app bars
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Soft warm cream fill for text fields
  static const Color lightInputBg = Color(0xFFF4F1E9);

  /// Delicate warm cream border for input fields and card outlines
  static const Color lightBorder = Color(0xFFE6DECE);

  /// Divider color with subtle cream undertone
  static const Color lightDivider = Color(0xFFEFE8DB);

  /// High-contrast espresso charcoal for primary text
  static const Color lightTextPrimary = Color(0xFF1C1A17);

  /// Elegant warm slate for secondary subtitles
  static const Color lightTextSecondary = Color(0xFF6B655A);

  /// Muted warm sand for placeholder hints & disabled states
  static const Color lightTextHint = Color(0xFFA39C8F);

  // ─────────────────────────────────────────────
  // DARK THEME (Obsidian & Champagne Gold)
  // ─────────────────────────────────────────────
  /// Deep warm obsidian night background (softer and more premium than pure black)
  static const Color darkScaffoldBg = Color(0xFF0F1014);

  /// Deep midnight charcoal for cards and elevated components
  static const Color darkCardBg = Color(0xFF171920);

  /// Subtly warm gold-tinted border for dark cards
  static const Color darkCardBorder = Color(0xFF2B2822);

  /// Midnight surface color for modals and bottom sheets
  static const Color darkSurface = Color(0xFF171920);

  /// Elevated dark charcoal fill for inputs in dark mode
  static const Color darkInputBg = Color(0xFF1E2028);

  /// Subtle dark border for inputs and dividers
  static const Color darkBorder = Color(0xFF2E2C26);

  /// Charcoal divider with warm undertone for dark mode
  static const Color darkDivider = Color(0xFF23252E);

  /// Deepest obsidian for bottom navigation bar and app bars
  static const Color darkNavBg = Color(0xFF0C0D11);

  /// Warm pearl off-white for primary text in dark mode
  static const Color darkTextPrimary = Color(0xFFF7F5F0);

  /// Muted cashmere silver-gold for secondary labels
  static const Color darkTextSecondary = Color(0xFFBBB5A8);

  /// Ash gold for subtle hints and muted text
  static const Color darkTextMuted = Color(0xFF78746B);

  // ─────────────────────────────────────────────
  // SEMANTIC & STATUS COLORS
  // ─────────────────────────────────────────────
  /// Emerald green for "Checked In" status and success feedback
  static const Color successGreen = Color(0xFF10B981);
  static const Color successContainerLight = Color(0xFFECFDF5);
  static const Color successContainerDark = Color(0xFF064E3B);

  /// Golden amber for "Registered" / pending status
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningContainerLight = Color(0xFFFFFBEB);
  static const Color warningContainerDark = Color(0xFF78350F);

  /// Velvet crimson for "Checked Out" / delete / errors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorContainerLight = Color(0xFFFEF2F2);
  static const Color errorContainerDark = Color(0xFF7F1D1D);

  /// Royal sapphire for information
  static const Color infoBlue = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────
  // BACKWARD-COMPATIBILITY TOKENS
  // ─────────────────────────────────────────────
  static const Color primaryBlue = primaryGold;
  static const Color primaryBlueLight = goldLight;
  static const Color blueGlow = goldGlow;
  static const Color redPrimary = errorRed;
  static const Color alertColor = errorRed;
  static const Color successColor = successGreen;

  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color secondWhiteColor = Color(0xFFF7F5F0);

  // Dark theme aliases
  static const Color appBackground = darkScaffoldBg;
  static const Color secondaryBackground = darkCardBg;
  static const Color cardBackground = darkCardBg;
  static const Color searchBarBackground = darkInputBg;
  static const Color deviceCardBackground = darkCardBg;
  static const Color deviceCardBorder = darkCardBorder;
  static const Color deviceCardShadow = Color(0x33000000);
  static const Color navBackground = darkNavBg;
  static const Color navInactiveIcon = darkTextMuted;
  static const Color dividerDark = darkDivider;
  static const Color inputBorderDark = darkBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;

  // Light theme aliases
  static const Color lightInputBackground = lightInputBg;
  static const Color lightInputBorder = lightBorder;
  static const Color textFieldBackGroundColor = lightInputBg;
  static const Color textDefaultColor = lightTextPrimary;
  static const Color textSubduedColor = lightTextSecondary;
  static const Color textSubTitleColor = lightTextSecondary;

  // Cyan / Accent aliases
  static const Color cyanAccent = goldGlow;
  static const Color lightCyanAccent = primaryGold;

  // Splash
  static const Color splashBgDark = darkScaffoldBg;
  static const Color splashBgLight = lightScaffoldBg;
}
