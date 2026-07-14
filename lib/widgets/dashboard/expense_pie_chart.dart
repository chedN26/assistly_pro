import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../services/dashboard_calculator.dart';

/// Pie chart breaking the current expense figures down into Salary,
/// Tools, Miscellaneous, and Owner Share (UI/UX spec Section 8 —
/// "Expense Breakdown, Pie Chart"). Uses the flat [DashboardSummary]
/// totals rather than a specific month, since it represents the
/// business's current overall composition.
class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key, required this.summary});

  final DashboardSummary summary;

  static const List<Color> _sliceColors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.secondary,
    AppColors.info,
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, double>> entries = [
      MapEntry('Salary', summary.salaryExpense),
      MapEntry('Tools', summary.toolsExpense),
      MapEntry('Miscellaneous', summary.miscellaneousExpense),
      MapEntry('Owner Share', summary.ownerShare),
    ].where((entry) => entry.value > 0).toList();

    if (entries.isEmpty) {
      return const Center(child: Text('No expense data available.'));
    }

    final double total = entries.fold(0.0, (sum, entry) => sum + entry.value);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: _sliceColors[i % _sliceColors.length],
                    radius: 60,
                    title: '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _sliceColors[i % _sliceColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
