import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/client_payment.dart';
import '../common/monthly_bar_chart.dart';

/// Monthly Revenue chart for a single client (UI/UX spec Section 12
/// — "Revenue Chart, Monthly Revenue"). Groups this client's payments
/// by calendar month and delegates rendering to [MonthlyBarChart],
/// shared with the Dashboard's Revenue-by-Month chart (Phase 4).
class ClientRevenueChart extends StatelessWidget {
  const ClientRevenueChart({super.key, required this.payments});

  final List<ClientPayment> payments;

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, double> valuesByMonth = {};
    for (final ClientPayment payment in payments) {
      final DateTime key = DateTime(payment.date.year, payment.date.month);
      valuesByMonth[key] = (valuesByMonth[key] ?? 0) + payment.amount;
    }

    return MonthlyBarChart(
      valuesByMonth: valuesByMonth,
      barColor: AppColors.primary,
      emptyMessage: 'No payments available.',
    );
  }
}
