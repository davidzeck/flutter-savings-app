/// Spacing and dimension constants for the application
///
/// Based on an 8-point grid system for consistent spacing throughout the app.
/// All dimensions are multiples of 8 for visual harmony.
class AppDimensions {
  AppDimensions._(); // Private constructor

  // ============================================================================
  // SPACING (8-point grid system)
  // ============================================================================

  /// Extra small spacing - 4dp
  static const double xs = 4.0;

  /// Small spacing - 8dp (base unit)
  static const double sm = 8.0;

  /// Medium spacing - 16dp
  static const double md = 16.0;

  /// Large spacing - 24dp
  static const double lg = 24.0;

  /// Extra large spacing - 32dp
  static const double xl = 32.0;

  /// 2X large spacing - 48dp
  static const double xxl = 48.0;

  /// 3X large spacing - 64dp
  static const double xxxl = 64.0;

  // ============================================================================
  // PADDING
  // ============================================================================

  /// Card padding
  static const double paddingCard = md; // 16.0

  /// Screen padding (horizontal)
  static const double paddingScreen = 20.0;

  /// Button padding (vertical)
  static const double paddingButtonVertical = 12.0;

  /// Button padding (horizontal)
  static const double paddingButtonHorizontal = md; // 16.0

  /// Input field padding
  static const double paddingInput = md; // 16.0

  /// List item padding
  static const double paddingListItem = md; // 16.0

  // ============================================================================
  // GAPS (Space between elements)
  // ============================================================================

  /// Gap between form elements
  static const double gapBetweenElements = 12.0;

  /// Gap between sections
  static const double gapBetweenSections = lg; // 24.0

  /// Gap in lists
  static const double gapInList = sm; // 8.0;

  /// Gap between icons and text
  static const double gapIconText = sm; // 8.0

  // ============================================================================
  // COMPONENT HEIGHTS
  // ============================================================================

  /// Standard button height
  static const double buttonHeight = 48.0;

  /// Small button height
  static const double buttonHeightSmall = 40.0;

  /// Large button height
  static const double buttonHeightLarge = 56.0;

  /// Text input field height
  static const double inputHeight = 56.0;

  /// App bar height (using kToolbarHeight from Flutter)
  static const double appBarHeight = 56.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 60.0;

  /// List tile height
  static const double listTileHeight = 72.0;

  // ============================================================================
  // COMPONENT WIDTHS
  // ============================================================================

  /// Maximum content width for tablets/desktop
  static const double maxContentWidth = 600.0;

  /// Dialog width
  static const double dialogWidth = 400.0;

  /// Sidebar width
  static const double sidebarWidth = 280.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Small border radius
  static const double radiusSmall = 4.0;

  /// Medium border radius
  static const double radiusMedium = 8.0;

  /// Large border radius
  static const double radiusLarge = 12.0;

  /// Extra large border radius
  static const double radiusXLarge = 16.0;

  /// Pill-shaped border radius (fully rounded)
  static const double radiusPill = 999.0;

  /// Button border radius
  static const double radiusButton = radiusMedium; // 8.0

  /// Card border radius
  static const double radiusCard = radiusLarge; // 12.0

  /// Input field border radius
  static const double radiusInput = radiusMedium; // 8.0

  /// Bottom sheet border radius (top corners only)
  static const double radiusBottomSheet = radiusXLarge; // 16.0

  /// Dialog border radius
  static const double radiusDialog = radiusLarge; // 12.0

  // ============================================================================
  // ELEVATION / SHADOW
  // ============================================================================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Subtle elevation (level 1)
  static const double elevationSubtle = 1.0;

  /// Card elevation (level 2)
  static const double elevationCard = 2.0;

  /// Raised element elevation (level 3)
  static const double elevationRaised = 4.0;

  /// Dialog elevation (level 4)
  static const double elevationDialog = 8.0;

  /// Modal elevation (level 5)
  static const double elevationModal = 16.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Small icon size
  static const double iconSmall = 16.0;

  /// Medium icon size (default)
  static const double iconMedium = 24.0;

  /// Large icon size
  static const double iconLarge = 32.0;

  /// Extra large icon size
  static const double iconXLarge = 48.0;

  // ============================================================================
  // AVATAR SIZES
  // ============================================================================

  /// Small avatar size
  static const double avatarSmall = 32.0;

  /// Medium avatar size
  static const double avatarMedium = 48.0;

  /// Large avatar size
  static const double avatarLarge = 64.0;

  /// Extra large avatar size (profile page)
  static const double avatarXLarge = 96.0;

  // ============================================================================
  // BORDER WIDTH
  // ============================================================================

  /// Thin border
  static const double borderThin = 1.0;

  /// Medium border
  static const double borderMedium = 2.0;

  /// Thick border
  static const double borderThick = 3.0;

  // ============================================================================
  // ANIMATION DURATIONS (in milliseconds)
  // ============================================================================

  /// Fast animation (micro-interactions)
  static const int animationFast = 150;

  /// Normal animation (standard transitions)
  static const int animationNormal = 250;

  /// Slow animation (complex animations)
  static const int animationSlow = 350;

  /// Very slow animation (page transitions)
  static const int animationVerySlow = 500;
}
