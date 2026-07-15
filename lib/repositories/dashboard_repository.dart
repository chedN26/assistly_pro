import '../models/dashboard_summary.dart';
import '../models/employee_productivity.dart';
import '../models/forecast_point.dart';
import '../models/monthly_financial_data.dart';

/// Contract for Dashboard data access. Deliberately independent from
/// [EmployeeRepository] and [ClientRepository] — the Dashboard is now
/// its own module with its own demo/mock data source, not an
/// aggregation computed from Employee/Client records (see the old,
/// retired `DashboardCalculator`).
///
/// Method list maps directly onto the enhancement brief's requested
/// data:
/// - Dashboard Summary   → [getDashboardSummary]
/// - Revenue Trend + Net Profit Trend → [getMonthlyFinancialTrend]
///   (merged into one method since both series share the same
///   month-by-month data and the Tab 1 chart plots them together —
///   two separate methods would just return overlapping data)
/// - Employee Productivity → [getEmployeeProductivity]
/// - Forecast Data        → [getHistoricalNetProfit]
/// - Mock AI Recommendation → [getMockAIRecommendation] (a simple
///   static fallback string; the primary, data-driven recommendation
///   path is [AIService.generateBusinessInsights], which this
///   repository intentionally does not depend on — see
///   `services/ai_service.dart`)
abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();

  Future<List<MonthlyFinancialData>> getMonthlyFinancialTrend();

  Future<List<EmployeeProductivity>> getEmployeeProductivity();

  /// Historical Net Profit series (all points with `isForecast:
  /// false`) for the Forecast tab. [DashboardProvider] appends
  /// predicted points on top of this via linear regression — the
  /// repository only ever supplies real historical data, never
  /// predictions.
  Future<List<ForecastPoint>> getHistoricalNetProfit();

  Future<String> getMockAIRecommendation();
}
