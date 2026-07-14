import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

/// Generic month-labeled bar chart: given values keyed by the first
/// day of each month, renders one bar per month with currency-style
/// axis labels. Used by both the Dashboard's Revenue-by-Month chart
/// (Phase 4) and the Client Details Revenue chart (Phase 6) so the
/// bar-chart rendering logic isn't duplicated between them — only the
/// data-grouping differs (all payments vs. one client's payments).
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.valuesByMonth,
    required this.barColor,
    this.emptyMessage = 'No data available.',
  });

  final Map<DateTime, double> valuesByMonth;
  final Color barColor;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (valuesByMonth.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    final List<DateTime> months = valuesByMonth.keys.toList()..sort();
    final double highest = valuesByMonth.values.reduce((a, b) => a > b ? a : b);
    final double maxY = highest == 0 ? 10 : highest * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
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
                if (index < 0 || index >= months.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(AppFormatters.monthLabel(months[index]), style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < months.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: valuesByMonth[months[i]]!,
                  color: barColor,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
