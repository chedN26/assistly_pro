import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../common/chart_card.dart';
import '../common/error_state.dart';
import 'net_profit_forecast_chart.dart';

/// Tab 2 — Forecast: historical Net Profit (sourced from
/// [DashboardProvider], which gets it from [DashboardRepository] —
/// never manually encoded here) plus a "Generate Forecast" button
/// that runs a simple linear regression to predict the next 3
/// months, displayed as a dashed continuation of the same chart.
class ForecastTab extends StatelessWidget {
  const ForecastTab({super.key});

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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChartCard(
                title: 'Historical Net Profit',
                height: 320,
                child: NetProfitForecastChart(points: provider.forecastPoints),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isGeneratingForecast ? null : provider.generateForecast,
                  icon: provider.isGeneratingForecast
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_graph),
                  label: const Text('Generate Forecast'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
