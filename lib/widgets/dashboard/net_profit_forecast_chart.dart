import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/forecast_point.dart';
import '../../utils/formatters.dart';
import 'chart_legend_item.dart';

/// Historical + forecast Net Profit chart (Forecast tab). Historical
/// points render as a solid line; predicted points (once generated)
/// render as a dashed line via fl_chart's `dashArray`, sharing the
/// last historical point as its own starting point so the two
/// segments visually connect with no gap.
class NetProfitForecastChart extends StatelessWidget {
  const NetProfitForecastChart({super.key, required this.points});

  final List<ForecastPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No historical data available.'));
    }

    final List<ForecastPoint> historical = points.where((p) => !p.isForecast).toList();
    final List<ForecastPoint> forecast = points.where((p) => p.isForecast).toList();

    final List<double> allValues = points.map((p) => p.netProfit).toList();
    final double highest = allValues.reduce((a, b) => a > b ? a : b);
    final double lowest = allValues.reduce((a, b) => a < b ? a : b);
    final double padding = (highest - lowest).abs() * 0.15;

    final List<FlSpot> historicalSpots = [
      for (int i = 0; i < historical.length; i++) FlSpot(i.toDouble(), historical[i].netProfit),
    ];

    // The forecast series starts at the last historical index/value
    // so the dashed segment picks up exactly where the solid line
    // ends, instead of leaving a visual gap.
    final List<FlSpot> forecastSpots = [
      if (historical.isNotEmpty) FlSpot((historical.length - 1).toDouble(), historical.last.netProfit),
      for (int i = 0; i < forecast.length; i++) FlSpot((historical.length + i).toDouble(), forecast[i].netProfit),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ChartLegendItem(color: AppColors.primary, label: 'Historical'),
            if (forecast.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              const ChartLegendItem(color: AppColors.warning, label: 'Forecast'),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: lowest - padding,
              maxY: highest + padding,
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) => Text(
                      AppFormatters.compactCurrency(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= points.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppFormatters.monthLabel(points[index].month),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: historicalSpots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
                if (forecastSpots.length > 1)
                  LineChartBarData(
                    spots: forecastSpots,
                    isCurved: true,
                    color: AppColors.warning,
                    barWidth: 3,
                    dashArray: const [6, 6],
                    dotData: const FlDotData(show: true),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
