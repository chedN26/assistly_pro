/// KPI summary shown on the Dashboard tab's three cards (Revenue,
/// Net Profit, Active Clients).
///
/// Deliberately independent from [Employee]/[Client] models and from
/// the old [DashboardCalculator]-based approach: this is sourced
/// directly from [DashboardRepository] using demo data, not computed
/// from live Employee/Client records. No `fromMap`/`toMap` — there is
/// no Firestore collection backing this (dashboard figures were
/// always derived/demo, never a stored document).
class DashboardSummary {
  const DashboardSummary({
    required this.revenue,
    required this.netProfit,
    required this.activeClients,
  });

  final double revenue;
  final double netProfit;
  final int activeClients;
}
