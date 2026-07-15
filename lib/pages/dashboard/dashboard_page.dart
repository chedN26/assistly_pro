import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/ai_assistant_tab.dart';
import '../../widgets/dashboard/dashboard_overview_tab.dart';
import '../../widgets/dashboard/forecast_tab.dart';
import '../../widgets/layout/app_shell.dart';

/// Business overview page — the landing page immediately after login
/// (unchanged from before). Now contains three tabs: Dashboard
/// (KPI/financial/workforce monitoring), Forecast (predictive
/// analytics), and AI Assistant (AI-assisted recommendations). All
/// data is sourced from [DashboardProvider], which now depends on the
/// dedicated [DashboardRepository] instead of the Employee/Client/
/// Settings repositories.
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
    return const AppShell(
      currentRoute: AppRoutes.dashboard,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Material(
              color: AppColors.surface,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.trending_up), text: 'Forecast'),
                  Tab(icon: Icon(Icons.auto_awesome_outlined), text: 'AI Assistant'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DashboardOverviewTab(),
                  ForecastTab(),
                  AiAssistantTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
