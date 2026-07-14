import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// Displays the hardcoded demo credentials on the Login page so
/// graders/reviewers can sign in without needing separate
/// documentation. Values are read from [AppConstants] — the same
/// source [MockAuthRepository] validates against — so this can never
/// drift out of sync with the actual accepted credentials.
class DemoCredentialsBanner extends StatelessWidget {
  const DemoCredentialsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.info),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.authDemoCredentialsTitle, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${AppStrings.authUsernameLabel}: ${AppConstants.demoUsername}\n'
                  '${AppStrings.authPasswordLabel}: ${AppConstants.demoPassword}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
