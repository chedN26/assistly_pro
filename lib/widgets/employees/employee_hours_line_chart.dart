import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/employee_hour.dart';
import '../../utils/formatters.dart';

/// Hours Worked Per Day line chart (UI/UX spec Section 10). Y-axis is
/// fixed to 0–24 since that's the valid range for a single day's
/// hours (DDD Section 12 validation rule), making the chart easy to
/// compare across employees at a glance.
class EmployeeHoursLineChart extends StatelessWidget {
  const EmployeeHoursLineChart({super.key, required this.hours});

  final List<EmployeeHour> hours;

  @override
  Widget build(BuildContext context) {
    final List<EmployeeHour> sorted = [...hours]..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) {
      return const Center(child: Text('No work hours recorded.'));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 24,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 4),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= sorted.length) return const SizedBox.shrink();
                // Thin out labels when there are many points, to avoid
                // them overlapping and becoming unreadable.
                if (sorted.length > 8 && index.isOdd) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppFormatters.shortDate(sorted[index].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < sorted.length; i++) FlSpot(i.toDouble(), sorted[i].hoursWorked)],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
