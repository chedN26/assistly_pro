import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// Temporary content shown for pages whose real UI and business logic
/// are built in a later development phase (per Phase 1 scope: "Pages
/// may contain simple placeholders, but the navigation structure must
/// be final"). Each page's `body` is fully replaced when its module
/// phase is implemented — this widget itself is not extended or built
/// upon.
class PlaceholderPageContent extends StatelessWidget {
  const PlaceholderPageContent({
    super.key,
    required this.icon,
    required this.title,
    this.message = AppStrings.comingSoonMessage,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
