import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// Generic Material [AlertDialog] used for any "are you sure?" flow
/// (UI/UX spec Section 15 — Dialog Specifications). Used for Logout in
/// this phase; the Employee/Client "Deactivate" confirmations in later
/// phases reuse this same widget instead of duplicating dialog code.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = AppStrings.cancelButton,
    this.isDanger = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  /// Shows the dialog and returns `true` if the user confirmed,
  /// `false` if they cancelled or dismissed it.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = AppStrings.cancelButton,
    bool isDanger = false,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: isDanger
              ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
