import 'package:flutter/material.dart';

/// Centralized color palette matching the UI/UX Wireframe Specification
/// (Section 2 — Color Theme). Widgets should reference these constants
/// instead of raw [Colors.*] values so the palette stays consistent and
/// easy to update in one place.
class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF1565C0); // Blue
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF607D8B); // Gray

  // Surfaces
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE3E6EA);

  // Status colors (Section 2 — Status Colors)
  static const Color success = Color(0xFF2E7D32); // Active
  static const Color danger = Color(0xFFC62828); // Inactive
  static const Color warning = Color(0xFFF9A825); // Warnings
  static const Color info = Color(0xFF1976D2); // Information

  // Text
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF667085);
}
