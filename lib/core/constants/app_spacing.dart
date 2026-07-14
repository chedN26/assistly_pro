/// Consistent spacing scale used across all pages and widgets.
/// Widgets should reference these constants instead of hardcoded
/// numeric padding/margin values.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Layout dimensions
  static const double sidebarWidthExpanded = 260;
  static const double sidebarWidthCollapsed = 76;
  static const double topBarHeight = 64;
  static const double maxContentWidth = 1400;
}
