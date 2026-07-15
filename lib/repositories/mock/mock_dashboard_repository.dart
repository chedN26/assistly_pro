import '../../models/dashboard_summary.dart';
import '../../models/employee_productivity.dart';
import '../../models/forecast_point.dart';
import '../../models/monthly_financial_data.dart';
import '../dashboard_repository.dart';

/// In-memory [DashboardRepository] with hardcoded demo data.
///
/// Deliberately does NOT read from [MockEmployeeRepository] or
/// [MockClientRepository] — per the enhancement brief, the Dashboard
/// module's data is now fully independent so it "always displays
/// demo data" regardless of what's happening in the Employee/Client
/// modules, and works with zero dependency on Firebase being
/// configured.
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository()
      : _monthlyTrend = _seedMonthlyTrend(),
        _productivity = _seedProductivity();

  final List<MonthlyFinancialData> _monthlyTrend;
  final List<EmployeeProductivity> _productivity;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await _simulateLatency();
    final MonthlyFinancialData latest = _monthlyTrend.last;
    return DashboardSummary(
      revenue: latest.revenue,
      netProfit: latest.netProfit,
      activeClients: 5,
    );
  }

  @override
  Future<List<MonthlyFinancialData>> getMonthlyFinancialTrend() async {
    await _simulateLatency();
    return List<MonthlyFinancialData>.unmodifiable(_monthlyTrend);
  }

  @override
  Future<List<EmployeeProductivity>> getEmployeeProductivity() async {
    await _simulateLatency();
    return List<EmployeeProductivity>.unmodifiable(_productivity);
  }

  @override
  Future<List<ForecastPoint>> getHistoricalNetProfit() async {
    await _simulateLatency();
    return [
      for (final MonthlyFinancialData m in _monthlyTrend)
        ForecastPoint(month: m.month, netProfit: m.netProfit, isForecast: false),
    ];
  }

  @override
  Future<String> getMockAIRecommendation() async {
    await _simulateLatency();
    return 'Business performance is trending positively based on the latest available data.';
  }

  static Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 400));

  // ---------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------

  /// Six months of demo figures: revenue roughly stable, net profit
  /// trending upward — matches the narrative the AI Assistant tab's
  /// mock recommendation describes.
  static List<MonthlyFinancialData> _seedMonthlyTrend() {
    return [
      MonthlyFinancialData(month: DateTime(2026, 2, 1), revenue: 480000, netProfit: 210000),
      MonthlyFinancialData(month: DateTime(2026, 3, 1), revenue: 495000, netProfit: 225000),
      MonthlyFinancialData(month: DateTime(2026, 4, 1), revenue: 510000, netProfit: 240000),
      MonthlyFinancialData(month: DateTime(2026, 5, 1), revenue: 505000, netProfit: 245000),
      MonthlyFinancialData(month: DateTime(2026, 6, 1), revenue: 525000, netProfit: 260000),
      MonthlyFinancialData(month: DateTime(2026, 7, 1), revenue: 540000, netProfit: 275000),
    ];
  }

  static List<EmployeeProductivity> _seedProductivity() {
    return const [
      EmployeeProductivity(employeeName: 'John Smith', totalHours: 420),
      EmployeeProductivity(employeeName: 'Maria Santos', totalHours: 390),
      EmployeeProductivity(employeeName: 'Robert Tan', totalHours: 375),
      EmployeeProductivity(employeeName: 'Daniel Garcia', totalHours: 360),
      EmployeeProductivity(employeeName: 'Michael Reyes', totalHours: 340),
      EmployeeProductivity(employeeName: 'Angela Cruz', totalHours: 310),
      EmployeeProductivity(employeeName: 'Patricia Lim', totalHours: 280),
    ];
  }
}
