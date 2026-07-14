import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../services/dashboard_calculator.dart';
import '../../utils/formatters.dart';
import 'stat_card.dart';

/// Lays out the 8 summary cards from [DashboardSummary] (UI/UX spec
/// Section 8), resizing automatically by screen width: 4 columns on
/// desktop, 2 on tablet, 1 on mobile (spec Section 4 — "Cards: Single
/// column" on mobile).
class DashboardSummaryGrid extends StatelessWidget {
  const DashboardSummaryGrid({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final DeviceType deviceType = ResponsiveHelper.deviceTypeOf(context);
    final int columns = switch (deviceType) {
      DeviceType.desktop => 4,
      DeviceType.tablet => 2,
      DeviceType.mobile => 1,
    };

    final List<StatCard> cards = [
      StatCard(
        label: AppStrings.dashboardRevenue,
        value: AppFormatters.currency(summary.revenue),
        icon: Icons.trending_up,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: AppStrings.dashboardSalaryExpense,
        value: AppFormatters.currency(summary.salaryExpense),
        icon: Icons.groups_outlined,
        accentColor: AppColors.secondary,
      ),
      StatCard(
        label: AppStrings.dashboardToolsExpense,
        value: AppFormatters.currency(summary.toolsExpense),
        icon: Icons.build_outlined,
        accentColor: AppColors.warning,
      ),
      StatCard(
        label: AppStrings.dashboardMiscellaneousExpense,
        value: AppFormatters.currency(summary.miscellaneousExpense),
        icon: Icons.receipt_long_outlined,
        accentColor: AppColors.secondary,
      ),
      StatCard(
        label: AppStrings.dashboardOwnerShare,
        value: AppFormatters.currency(summary.ownerShare),
        icon: Icons.account_balance_wallet_outlined,
        accentColor: AppColors.info,
      ),
      StatCard(
        label: AppStrings.dashboardNetProfit,
        value: AppFormatters.currency(summary.netProfit),
        icon: Icons.savings_outlined,
        accentColor: AppColors.success,
      ),
      StatCard(
        label: AppStrings.dashboardActiveEmployees,
        value: '${summary.activeEmployees}',
        icon: Icons.people_outline,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: AppStrings.dashboardActiveClients,
        value: '${summary.activeClients}',
        icon: Icons.business_outlined,
        accentColor: AppColors.primary,
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
