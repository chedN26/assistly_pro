import 'package:flutter/material.dart';

/// The three device classes the UI/UX spec defines responsive behavior
/// for (Section 4 — Responsive Layout).
enum DeviceType { mobile, tablet, desktop }

/// Breakpoint logic shared by every page/widget that needs to adapt
/// its layout. Keeping the thresholds in one place avoids inconsistent
/// breakpoints appearing across different screens.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Below this width -> [DeviceType.mobile].
  static const double mobileBreakpoint = 700;

  /// Below this width (and >= [mobileBreakpoint]) -> [DeviceType.tablet].
  /// At or above this width -> [DeviceType.desktop].
  static const double desktopBreakpoint = 1100;

  static DeviceType deviceTypeOf(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return DeviceType.desktop;
    if (width >= mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) => deviceTypeOf(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) => deviceTypeOf(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) => deviceTypeOf(context) == DeviceType.desktop;
}
