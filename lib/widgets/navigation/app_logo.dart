import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// The "Assistly Pro" wordmark shown at the top of the sidebar/drawer
/// and on the login card. Collapses to just the icon when [showLabel]
/// is false (used by the collapsed tablet sidebar rail).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.showLabel = true, this.iconSize = 28});

  final bool showLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Icon icon = Icon(
      Icons.workspaces_rounded,
      color: AppColors.primary,
      size: iconSize,
    );

    if (!showLabel) return icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
