import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// Generic "something went wrong" view with a Retry button, used
/// whenever a provider's load call fails (UI/UX spec Section 21 —
/// Error States). Shared across Dashboard, Employee, and Client pages
/// instead of each page defining its own copy.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text(AppStrings.retryButton)),
          ],
        ),
      ),
    );
  }
}
