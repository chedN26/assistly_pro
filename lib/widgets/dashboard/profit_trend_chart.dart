import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/dashboard_calculator.dart';
import '../../utils/formatters.dart';

/// Line chart of Net Profit per calendar month. Not part of the
/// original UI/UX Wireframe Spec's two charts — added in Phase 4 at
/// explicit request, alongside Revenue by Month and Expense
/// Breakdown.
class ProfitTrendChart extends StatelessWidget {
  const ProfitTrendChart({super.key, required this.data});

  final List<MonthlyFinancials> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No profit data available.'));
    }

    final List<double> values = data.map((m) => m.netProfit).toList();
    final double minValue = values.reduce((a, b) => a < b ? a : b);
    final double maxValue = values.reduce((a, b) => a > b ? a : b);
    final double range = maxValue - minValue;
    // Guards against a degenerate (zero-height) chart when every
    // month has an identical net profit value.
    final double padding = range == 0 ? (maxValue.abs() * 0.1 + 100) : range * 0.2;

    return LineChart(
      LineChartData(
        minY: minValue - padding,
        maxY: maxValue + padding,
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
            spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].netProfit)],
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.success.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}
