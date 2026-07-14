import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A single tappable navigation entry used inside [AppSidebar].
/// Supports a collapsed icon-only mode (tablet rail) and a "danger"
/// styling variant used for the Logout item.
class NavItemTile extends StatelessWidget {
  const NavItemTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showLabel = true,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final bool isDanger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isDanger
        ? AppColors.danger
        : (selected ? AppColors.primary : AppColors.textSecondary);
    final Color background = selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent;

    final Widget tile = Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: showLabel ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 22),
              if (showLabel) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return showLabel ? tile : Tooltip(message: label, child: tile);
  }
}
