import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../common/chart_card.dart';
import '../common/error_state.dart';
import 'employee_productivity_chart.dart';
import 'kpi_cards_row.dart';
import 'revenue_profit_trend_chart.dart';

/// Tab 1 — Dashboard: KPI monitoring (Revenue, Net Profit, Active
/// Clients), financial trend monitoring (Revenue vs Net Profit), and
/// workforce analytics (Top 5 Employee Productivity).
class DashboardOverviewTab extends StatelessWidget {
  const DashboardOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (!provider.hasLoadedOnce && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadDashboard);
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KpiCardsRow(summary: provider.summary),
                const SizedBox(height: AppSpacing.lg),
                ChartCard(
                  title: 'Revenue vs Net Profit Trend',
                  height: 320,
                  child: RevenueProfitTrendChart(data: provider.monthlyTrend),
                ),
                const SizedBox(height: AppSpacing.lg),
                ChartCard(
                  title: 'Top 5 Employee Productivity',
                  height: 320,
                  child: EmployeeProductivityChart(data: provider.topEmployeeProductivity),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
