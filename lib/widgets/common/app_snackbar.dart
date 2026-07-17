import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Centralized SnackBar presentation (UI/UX spec Sections 21 & 22 —
/// Error/Success States). Every page previously built its own
/// `SnackBar(content: Text(...), backgroundColor: ...)` inline; this
/// consolidates that into one consistently-styled helper (icon +
/// color + duration) so success/error messaging looks identical
/// everywhere, and clears any currently-showing snackbar first so
/// messages never stack up on rapid actions.
///
/// This changes presentation only — every call site still shows the
/// exact same message text at the exact same trigger point as before.
class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.check_circle_outline, color: AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      color: AppColors.danger,
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.info_outline, color: AppColors.info);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
  }
}
