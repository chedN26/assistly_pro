import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/dashboard_calculator.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/dashboard/dashboard_charts_section.dart';
import '../../widgets/dashboard/dashboard_summary_grid.dart';
import '../../widgets/layout/app_shell.dart';

/// Business overview page (UI/UX spec Section 8): 8 summary cards
/// plus Revenue-by-Month, Expense-Breakdown, and Monthly-Profit-Trend
/// charts, all sourced from [DashboardProvider].
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Deferred to a microtask so this runs after the first frame,
    // avoiding a notifyListeners() call during this widget's own
    // build phase.
    Future.microtask(() {
      if (!mounted) return;
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.dashboard,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (!provider.hasLoadedOnce && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onRetry: () => provider.loadDashboard(),
            );
          }

          final DashboardSummary summary = provider.summary;
          final bool isEmpty = summary.revenue == 0 &&
              summary.salaryExpense == 0 &&
              summary.activeEmployees == 0 &&
              summary.activeClients == 0;

          if (isEmpty) {
            return const PlaceholderPageContent(
              icon: Icons.bar_chart_outlined,
              title: AppStrings.pageTitleDashboard,
              message: AppStrings.dashboardEmptyMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardSummaryGrid(summary: summary),
                  const SizedBox(height: AppSpacing.lg),
                  DashboardChartsSection(
                    monthlyFinancials: provider.monthlyFinancials,
                    summary: summary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

