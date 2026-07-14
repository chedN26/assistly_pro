import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/dashboard_calculator.dart';
import '../common/monthly_bar_chart.dart';

/// Bar chart of total revenue per calendar month (UI/UX spec Section
/// 8 — "Revenue by Month, Bar Chart"). Delegates the actual chart
/// rendering to [MonthlyBarChart], shared with the Client Details
/// Revenue chart (Phase 6) — this widget's only job is converting
/// [MonthlyFinancials] into the month→value map that chart expects.
class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({super.key, required this.data});

  final List<MonthlyFinancials> data;

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, double> valuesByMonth = {
      for (final MonthlyFinancials monthly in data) monthly.month: monthly.revenue,
    };

    return MonthlyBarChart(
      valuesByMonth: valuesByMonth,
      barColor: AppColors.primary,
      emptyMessage: 'No revenue data available.',
    );
  }
}
