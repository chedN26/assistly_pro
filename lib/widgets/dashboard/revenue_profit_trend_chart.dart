import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/monthly_financial_data.dart';
import '../../utils/formatters.dart';
import 'chart_legend_item.dart';

/// "Revenue vs Net Profit Trend" chart (Dashboard tab). Two lines —
/// Revenue and Net Profit — plotted together month-by-month.
class RevenueProfitTrendChart extends StatelessWidget {
  const RevenueProfitTrendChart({super.key, required this.data});

  final List<MonthlyFinancialData> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No trend data available.'));
    }

    final double highest = [
      ...data.map((d) => d.revenue),
      ...data.map((d) => d.netProfit),
    ].reduce((a, b) => a > b ? a : b);
    final double maxY = highest == 0 ? 10 : highest * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            ChartLegendItem(color: AppColors.primary, label: 'Revenue'),
            SizedBox(width: AppSpacing.md),
            ChartLegendItem(color: AppColors.success, label: 'Net Profit'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
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
                      if (index < 0 || index >= data.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppFormatters.monthLabel(data[index].month),
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].revenue)],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].netProfit)],
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
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
