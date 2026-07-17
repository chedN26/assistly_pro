import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee.dart';
import '../../utils/formatters.dart';
import '../common/status_badge.dart';

/// Employee Information card (UI/UX spec Section 10): name, email,
/// phone, position, hourly rate, status, department, supervisor, and
/// assigned client.
class EmployeeInfoCard extends StatelessWidget {
  const EmployeeInfoCard({super.key, required this.employee, this.assignedClientName});

  final Employee employee;

  /// Resolved display name for [Employee.assignedClientId], or null
  /// if unassigned. Resolved by the page (which has access to
  /// [ClientProvider]) rather than here, keeping this widget purely
  /// presentational.
  final String? assignedClientName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    _initials(employee.name),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        employee.position,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: employee.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1),
            ),
            _InfoRow(label: 'Email', value: employee.email),
            _InfoRow(label: 'Phone', value: employee.phone),
            _InfoRow(label: 'Hourly Rate', value: AppFormatters.currency(employee.hourlyRate)),
            _InfoRow(label: AppStrings.employeeDepartmentLabel, value: employee.department),
            _InfoRow(label: AppStrings.employeeSupervisorLabel, value: employee.supervisor),
            _InfoRow(
              label: AppStrings.employeeAssignedClientLabel,
              value: assignedClientName ?? AppStrings.employeeAssignedClientNone,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
