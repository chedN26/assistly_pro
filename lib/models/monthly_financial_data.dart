/// One calendar month's Revenue and Net Profit figures, used by the
/// "Revenue vs Net Profit Trend" chart on the Dashboard tab.
class MonthlyFinancialData {
  const MonthlyFinancialData({
    required this.month,
    required this.revenue,
    required this.netProfit,
  });

  /// First day of the month this data represents.
  final DateTime month;
  final double revenue;
  final double netProfit;
}
