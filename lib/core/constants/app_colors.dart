import 'package:flutter/material.dart';

/// Application color palette following enterprise design system
///
/// All colors are defined as constants for consistent usage throughout the app.
/// Based on Material Design color system with custom enterprise branding.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================

  /// Primary brand color - Blue 700
  static const Color primary = Color(0xFF1976D2);

  /// Light variant of primary color - Blue 400
  static const Color primaryLight = Color(0xFF42A5F5);

  /// Dark variant of primary color - Blue 900
  static const Color primaryDark = Color(0xFF0D47A1);

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================

  /// Accent color for highlights and CTAs - Orange 900
  static const Color accent = Color(0xFFFF6F00);

  /// Light variant of accent color - Orange 400
  static const Color accentLight = Color(0xFFFFA726);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success state color - Green 800
  static const Color success = Color(0xFF2E7D32);

  /// Light variant of success color - Green 400
  static const Color successLight = Color(0xFF66BB6A);

  /// Warning state color - Orange 700
  static const Color warning = Color(0xFFF57C00);

  /// Light variant of warning color - Orange 300
  static const Color warningLight = Color(0xFFFFB74D);

  /// Error state color - Red 800
  static const Color error = Color(0xFFC62828);

  /// Light variant of error color - Red 300
  static const Color errorLight = Color(0xFFE57373);

  /// Info state color - Light Blue 800
  static const Color info = Color(0xFF0277BD);

  /// Light variant of info color - Light Blue 300
  static const Color infoLight = Color(0xFF4FC3F7);

  // ============================================================================
  // NEUTRAL COLORS
  // ============================================================================

  /// Main background color - Grey 50
  static const Color background = Color(0xFFFAFAFA);

  /// Surface color for cards and sheets - White
  static const Color surface = Color(0xFFFFFFFF);

  /// Dark surface color for dark mode - Near Black
  static const Color surfaceDark = Color(0xFF121212);

  /// Primary text color - Grey 900 (87% opacity recommended)
  static const Color textPrimary = Color(0xFF212121);

  /// Secondary text color - Grey 600 (60% opacity recommended)
  static const Color textSecondary = Color(0xFF757575);

  /// Disabled text color - Grey 500 (38% opacity recommended)
  static const Color textDisabled = Color(0xFF9E9E9E);

  /// Text on primary color backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Border color - Grey 300
  static const Color border = Color(0xFFE0E0E0);

  /// Divider color - Grey 400
  static const Color divider = Color(0xFFBDBDBD);

  // ============================================================================
  // SPECIAL PURPOSE COLORS
  // ============================================================================

  /// Overlay color for modals and dialogs
  static const Color overlay = Color(0x80000000); // Black with 50% opacity

  /// Shimmer base color for loading states
  static const Color shimmerBase = Color(0xFFE0E0E0);

  /// Shimmer highlight color for loading states
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  /// Transparent color
  static const Color transparent = Color(0x00000000);

  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================

  /// Primary gradient for backgrounds and decorative elements
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Accent gradient for CTAs and highlights
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
}
