import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../services/dashboard_calculator.dart';
import '../common/chart_card.dart';
import 'expense_pie_chart.dart';
import 'profit_trend_chart.dart';
import 'revenue_bar_chart.dart';

/// Arranges the three dashboard charts per UI/UX spec Section 4:
/// desktop gets a two-column layout (Revenue and Expense Breakdown
/// side by side, since they're both compact), tablet/mobile stack
/// everything in a single column. Monthly Profit Trend is always
/// full-width — a time-series line reads better with more horizontal
/// room than it would get squeezed into a two-column cell.
class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({
    super.key,
    required this.monthlyFinancials,
    required this.summary,
  });

  final List<MonthlyFinancials> monthlyFinancials;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final Widget revenueChart = ChartCard(
      title: AppStrings.dashboardChartRevenueByMonth,
      child: RevenueBarChart(data: monthlyFinancials),
    );
    final Widget expenseChart = ChartCard(
      title: AppStrings.dashboardChartExpenseBreakdown,
      child: ExpensePieChart(summary: summary),
    );
    final Widget profitChart = ChartCard(
      title: AppStrings.dashboardChartProfitTrend,
      child: ProfitTrendChart(data: monthlyFinancials),
    );

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: revenueChart),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: expenseChart),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          profitChart,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        revenueChart,
        const SizedBox(height: AppSpacing.md),
        expenseChart,
        const SizedBox(height: AppSpacing.md),
        profitChart,
      ],
    );
  }
}
