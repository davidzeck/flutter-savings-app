import 'package:flutter/material.dart';

/// Typography system for the application
///
/// Defines font families, sizes, weights, and text styles.
/// Based on a 1.25 scale ratio (Major Third) for harmonious sizing.
class AppTypography {
  AppTypography._(); // Private constructor

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  /// Primary font family for general text
  /// Uses 'Inter' via Google Fonts, falls back to system font
  static const String primaryFontFamily = 'Inter';

  /// Monospace font family for code and technical text
  static const String monospaceFontFamily = 'JetBrains Mono';

  // ============================================================================
  // FONT SIZES
  // ============================================================================

  /// Heading 1 - Largest heading
  static const double h1 = 32.0;

  /// Heading 2 - Large heading
  static const double h2 = 28.0;

  /// Heading 3 - Medium heading
  static const double h3 = 24.0;

  /// Heading 4 - Small heading
  static const double h4 = 20.0;

  /// Heading 5 - Extra small heading
  static const double h5 = 18.0;

  /// Heading 6 - Smallest heading
  static const double h6 = 16.0;

  /// Body text - Large
  static const double bodyLarge = 16.0;

  /// Body text - Medium (default)
  static const double bodyMedium = 14.0;

  /// Body text - Small
  static const double bodySmall = 12.0;

  /// Label text - Large
  static const double labelLarge = 14.0;

  /// Label text - Medium
  static const double labelMedium = 12.0;

  /// Label text - Small
  static const double labelSmall = 11.0;

  // ============================================================================
  // FONT WEIGHTS
  // ============================================================================

  /// Regular weight (400)
  static const FontWeight regular = FontWeight.w400;

  /// Medium weight (500)
  static const FontWeight medium = FontWeight.w500;

  /// Semi-bold weight (600)
  static const FontWeight semiBold = FontWeight.w600;

  /// Bold weight (700)
  static const FontWeight bold = FontWeight.w700;

  // ============================================================================
  // LINE HEIGHTS
  // ============================================================================

  /// Line height for headings (h1-h3)
  static const double lineHeightHeading = 1.2;

  /// Line height for sub-headings (h4-h6)
  static const double lineHeightSubheading = 1.3;

  /// Line height for body text
  static const double lineHeightBody = 1.5;

  /// Line height for labels
  static const double lineHeightLabel = 1.4;

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  /// Heading 1 text style
  static const TextStyle heading1 = TextStyle(
    fontSize: h1,
    fontWeight: bold,
    height: lineHeightHeading,
    letterSpacing: -0.5,
  );

  /// Heading 2 text style
  static const TextStyle heading2 = TextStyle(
    fontSize: h2,
    fontWeight: bold,
    height: lineHeightHeading,
    letterSpacing: -0.5,
  );

  /// Heading 3 text style
  static const TextStyle heading3 = TextStyle(
    fontSize: h3,
    fontWeight: semiBold,
    height: lineHeightHeading,
    letterSpacing: 0,
  );

  /// Heading 4 text style
  static const TextStyle heading4 = TextStyle(
    fontSize: h4,
    fontWeight: semiBold,
    height: lineHeightSubheading,
    letterSpacing: 0,
  );

  /// Heading 5 text style
  static const TextStyle heading5 = TextStyle(
    fontSize: h5,
    fontWeight: medium,
    height: lineHeightSubheading,
    letterSpacing: 0,
  );

  /// Heading 6 text style
  static const TextStyle heading6 = TextStyle(
    fontSize: h6,
    fontWeight: medium,
    height: lineHeightSubheading,
    letterSpacing: 0,
  );

  /// Body large text style
  static const TextStyle bodyTextLarge = TextStyle(
    fontSize: bodyLarge,
    fontWeight: regular,
    height: lineHeightBody,
    letterSpacing: 0.5,
  );

  /// Body medium text style (default)
  static const TextStyle bodyTextMedium = TextStyle(
    fontSize: bodyMedium,
    fontWeight: regular,
    height: lineHeightBody,
    letterSpacing: 0.25,
  );

  /// Body small text style
  static const TextStyle bodyTextSmall = TextStyle(
    fontSize: bodySmall,
    fontWeight: regular,
    height: lineHeightBody,
    letterSpacing: 0.4,
  );

  /// Label large text style
  static const TextStyle labelTextLarge = TextStyle(
    fontSize: labelLarge,
    fontWeight: medium,
    height: lineHeightLabel,
    letterSpacing: 0.1,
  );

  /// Label medium text style
  static const TextStyle labelTextMedium = TextStyle(
    fontSize: labelMedium,
    fontWeight: medium,
    height: lineHeightLabel,
    letterSpacing: 0.5,
  );

  /// Label small text style
  static const TextStyle labelTextSmall = TextStyle(
    fontSize: labelSmall,
    fontWeight: medium,
    height: lineHeightLabel,
    letterSpacing: 0.5,
  );

  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: labelLarge,
    fontWeight: semiBold,
    letterSpacing: 1.25,
  );

  /// Caption text style
  static const TextStyle caption = TextStyle(
    fontSize: bodySmall,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Overline text style (all caps, for labels)
  static const TextStyle overline = TextStyle(
    fontSize: labelSmall,
    fontWeight: medium,
    height: 1.0,
    letterSpacing: 1.5,
  );
}
