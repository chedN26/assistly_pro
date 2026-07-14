/// Miscellaneous app-wide constants that don't belong under
/// [AppStrings] (display text), [AppSpacing] (layout), or
/// [AppColors]/[AppTheme] (styling).
class AppConstants {
  AppConstants._();

  // Hardcoded demo credentials for mock authentication (Phase 2).
  // Referenced by both MockAuthRepository and DemoCredentialsBanner so
  // the two never drift out of sync.
  static const String demoUsername = 'admin';
  static const String demoPassword = 'admin123';
}
