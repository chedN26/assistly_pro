import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/department_summary.dart';

/// A single department card (Departments page): department name,
/// supervisor/department head, and employee count. Tapping it opens
/// the Department Details page via [onTap].
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({super.key, required this.department, required this.onTap});

  final DepartmentSummary department;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.apartment_outlined, color: AppColors.primary, size: 20),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                department.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Supervisor: ${department.departmentHead}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Employees: ${department.employeeCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
