import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dashboard_summary.dart';
import '../../utils/formatters.dart';
import 'stat_card.dart';

/// The three KPI cards at the top of the Dashboard tab: Revenue, Net
/// Profit, Active Clients. Reuses the existing [StatCard] widget
/// (unchanged) — only the card count/content is new. Wraps gracefully
/// on smaller screens: 3 columns desktop/tablet, 1 column mobile.
class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final DeviceType deviceType = ResponsiveHelper.deviceTypeOf(context);
    final int columns = deviceType == DeviceType.mobile ? 1 : 3;

    final List<StatCard> cards = [
      StatCard(
        label: 'Revenue',
        value: AppFormatters.currency(summary.revenue),
        icon: Icons.trending_up,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: 'Net Profit',
        value: AppFormatters.currency(summary.netProfit),
        icon: Icons.savings_outlined,
        accentColor: AppColors.success,
      ),
      StatCard(
        label: 'Active Clients',
        value: '${summary.activeClients}',
        icon: Icons.business_outlined,
        accentColor: AppColors.info,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = AppSpacing.md;
        final double cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final StatCard card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
