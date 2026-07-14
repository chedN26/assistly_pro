import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/status.dart';

/// Small colored pill showing an entity's [Status] (Active/Inactive).
/// Used by both the Employee and Client tables and detail pages so
/// the visual language for status stays identical across modules.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final Status status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == Status.active;
    final Color color = isActive ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
