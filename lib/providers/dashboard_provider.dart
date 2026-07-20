import 'package:flutter/foundation.dart';

import '../models/dashboard_summary.dart';
import '../models/employee_productivity.dart';
import '../models/forecast_point.dart';
import '../models/monthly_financial_data.dart';
import '../repositories/dashboard_repository.dart';
import '../services/ai_service.dart';

/// Holds all state for the redesigned three-tab Dashboard page:
/// Tab 1 (KPI summary, financial trend, employee productivity),
/// Tab 2 (Forecast — historical Net Profit + generated predictions),
/// and Tab 3 (AI Assistant recommendation).
///
/// Depends only on [DashboardRepository] and [AIService] — no longer
/// on [EmployeeRepository]/[ClientRepository]/[OperatingExpenseRepository].
/// The Dashboard is its own independent module now; it always shows
/// demo data regardless of Employee/Client module state or whether
/// Firebase is configured (see enhancement brief's "Fallback
/// Behavior").
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required DashboardRepository dashboardRepository,
    AIService aiService = const AIService(),
  })  : _repository = dashboardRepository,
        _aiService = aiService;

  final DashboardRepository _repository;
  final AIService _aiService;

  // Tab 1 state
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  DashboardSummary _summary = const DashboardSummary(revenue: 0, netProfit: 0, activeClients: 0);
  List<MonthlyFinancialData> _monthlyTrend = [];
  List<EmployeeProductivity> _employeeProductivity = [];

  // Tab 2 (Forecast) state
  List<ForecastPoint> _historicalNetProfit = [];
  List<ForecastPoint> _forecastPoints = [];
  bool _isGeneratingForecast = false;

  // Tab 3 (AI Assistant) state
  String? _aiRecommendation;
  bool _isGeneratingRecommendation = false;

  bool get isLoading => _isLoading;

  /// True once a load attempt (success or failure) has completed at
  /// least once. Used to distinguish "first load in progress" (show a
  /// full-page spinner) from "refreshing already-visible data".
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? get errorMessage => _errorMessage;
  DashboardSummary get summary => _summary;
  List<MonthlyFinancialData> get monthlyTrend => _monthlyTrend;
  List<EmployeeProductivity> get employeeProductivity => _employeeProductivity;

  /// Top 5 employees by total hours, descending — used by the
  /// "Top 5 Employee Productivity" chart.
  List<EmployeeProductivity> get topEmployeeProductivity {
    final List<EmployeeProductivity> sorted = [..._employeeProductivity]
      ..sort((a, b) => b.totalHours.compareTo(a.totalHours));
    return sorted.take(5).toList();
  }

  /// Historical points plus any generated forecast points combined,
  /// in chronological order — this is what the Forecast tab's chart
  /// renders directly.
  List<ForecastPoint> get forecastPoints => _forecastPoints;

  bool get isGeneratingForecast => _isGeneratingForecast;

  String? get aiRecommendation => _aiRecommendation;
  bool get isGeneratingRecommendation => _isGeneratingRecommendation;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repository.getDashboardSummary();
      _monthlyTrend = await _repository.getMonthlyFinancialTrend();
      _employeeProductivity = await _repository.getEmployeeProductivity();
      _historicalNetProfit = await _repository.getHistoricalNetProfit();
      // Reset the displayed forecast series to historical-only on
      // every (re)load; a stale forecast from a previous load
      // shouldn't linger after a refresh.
      _forecastPoints = List.of(_historicalNetProfit);
    } catch (_) {
      _errorMessage = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Re-runs [loadDashboard]. Exposed under its own name so the page
  /// can call it after returning to this tab, and as the
  /// [RefreshIndicator] callback.
  Future<void> refresh() => loadDashboard();

  /// Simple linear regression (least squares) over the historical Net
  /// Profit series, extrapolated 3 months forward. Intentionally
  /// simple per the enhancement brief — this demonstrates the
  /// forecasting concept, not a production-grade model.
  Future<void> generateForecast() async {
    if (_historicalNetProfit.isEmpty) return;

    _isGeneratingForecast = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400)); // simulate work

    final int n = _historicalNetProfit.length;
    final List<double> xs = List.generate(n, (i) => i.toDouble());
    final List<double> ys = _historicalNetProfit.map((p) => p.netProfit).toList();

    final double xMean = xs.reduce((a, b) => a + b) / n;
    final double yMean = ys.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;
    for (int i = 0; i < n; i++) {
      numerator += (xs[i] - xMean) * (ys[i] - yMean);
      denominator += (xs[i] - xMean) * (xs[i] - xMean);
    }
    final double slope = denominator == 0 ? 0 : numerator / denominator;
    final double intercept = yMean - slope * xMean;

    final DateTime lastMonth = _historicalNetProfit.last.month;
    final List<ForecastPoint> predicted = [
      for (int i = 1; i <= 3; i++)
        ForecastPoint(
          month: DateTime(lastMonth.year, lastMonth.month + i),
          netProfit: slope * (n - 1 + i) + intercept,
          isForecast: true,
        ),
    ];

    _forecastPoints = [..._historicalNetProfit, ...predicted];
    _isGeneratingForecast = false;
    notifyListeners();
  }

  Future<void> generateAIRecommendation() async {
    _isGeneratingRecommendation = true;
    notifyListeners();

    try {
      _aiRecommendation = await _aiService.generateBusinessInsights(
        summary: _summary,
        employeeProductivity: _employeeProductivity,
      );
    } catch (_) {
      // Defensive ultimate fallback: AIService already guarantees a
      // mock response internally, but a future real-API version of it
      // could throw (network error, etc.) — the UI must never be left
      // blank ("No runtime errors due to unavailable services").
      _aiRecommendation = 'Business Summary\n'
          'Unable to generate a recommendation right now. Please try again.';
    } finally {
      _isGeneratingRecommendation = false;
      notifyListeners();
    }
  }
}
