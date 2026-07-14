import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../models/client_payment.dart';
import '../models/employee.dart';
import '../models/employee_hour.dart';
import '../repositories/client_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/dashboard_calculator.dart';

/// Loads the data needed for the Dashboard's summary cards and charts
/// (Phase 4) from all three repositories and computes the results via
/// [DashboardCalculator]. This provider coordinates multiple
/// repositories directly — a legitimate exception to the usual
/// one-provider-per-repository pattern, since the dashboard is
/// inherently an aggregate view across employees, clients, and
/// settings (DDD Section 10 — Dashboard Data Sources).
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required EmployeeRepository employeeRepository,
    required ClientRepository clientRepository,
    required SettingsRepository settingsRepository,
  })  : _employeeRepository = employeeRepository,
        _clientRepository = clientRepository,
        _settingsRepository = settingsRepository;

  final EmployeeRepository _employeeRepository;
  final ClientRepository _clientRepository;
  final SettingsRepository _settingsRepository;

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  DashboardSummary _summary = DashboardSummary.empty;
  List<MonthlyFinancials> _monthlyFinancials = [];

  bool get isLoading => _isLoading;

  /// True once a load attempt (success or failure) has completed at
  /// least once. Used by the Dashboard page to distinguish "first
  /// load in progress" (show a full-page spinner) from "refreshing
  /// already-visible data" (let [RefreshIndicator] show its own
  /// smaller spinner over the existing content instead).
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? get errorMessage => _errorMessage;
  DashboardSummary get summary => _summary;
  List<MonthlyFinancials> get monthlyFinancials => _monthlyFinancials;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Employee> employees = await _employeeRepository.getEmployees();
      final List<EmployeeHour> hours = await _employeeRepository.getAllHours();
      final List<Client> clients = await _clientRepository.getClients();
      final List<ClientPayment> payments = await _clientRepository.getAllPayments();
      final settings = await _settingsRepository.getSettings();

      _summary = DashboardCalculator.calculate(
        employees: employees,
        employeeHours: hours,
        clients: clients,
        payments: payments,
        settings: settings,
      );

      _monthlyFinancials = DashboardCalculator.calculateMonthly(
        employees: employees,
        employeeHours: hours,
        payments: payments,
        settings: settings,
      );
    } catch (_) {
      _errorMessage = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Re-runs [loadDashboard]. Exposed under its own name so the
  /// Dashboard page can call it after returning from
  /// Employee/Client/Settings pages to reflect any CRUD changes,
  /// without the call site needing to know it's identical to the
  /// initial load. Also used as the [RefreshIndicator] callback.
  Future<void> refresh() => loadDashboard();
}
