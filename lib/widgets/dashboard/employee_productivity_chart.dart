import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee_productivity.dart';

/// "Top 5 Employee Productivity" ranking (Dashboard tab): a
/// horizontal, proportional bar per employee, ranked by total hours.
///
/// Implemented as a plain Flutter widget rather than fl_chart's
/// `BarChart` — fl_chart doesn't have a reliably version-stable
/// first-class horizontal orientation, and this is fully responsive
/// and correct without depending on that. [data] is expected to
/// already be sorted/limited to the top 5 by the caller
/// ([DashboardProvider.topEmployeeProductivity]).
class EmployeeProductivityChart extends StatelessWidget {
  const EmployeeProductivityChart({super.key, required this.data});

  final List<EmployeeProductivity> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No productivity data available.'));
    }

    final double maxHours = data.map((e) => e.totalHours).reduce((a, b) => a > b ? a : b);

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final EmployeeProductivity item = data[index];
        final double fraction = maxHours == 0 ? 0 : item.totalHours / maxHours;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.employeeName,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${item.totalHours.toStringAsFixed(0)} hrs',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 10, width: constraints.maxWidth, color: AppColors.border),
                      Container(
                        height: 10,
                        width: constraints.maxWidth * fraction,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
