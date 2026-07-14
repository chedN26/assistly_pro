import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../models/employee_hour.dart';
import '../models/status.dart';
import '../repositories/employee_repository.dart';

/// Holds employee list state (with search/filter), CRUD operations,
/// and per-employee work-hour records for the Employee List and
/// Employee Details pages (Phase 5). Depends only on
/// [EmployeeRepository] — never talks to Firestore or the mock data
/// directly.
class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider(this._repository);

  final EmployeeRepository _repository;

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;
  Status? _statusFilter;
  String _searchQuery = '';

  final Map<String, List<EmployeeHour>> _hoursByEmployeeId = {};
  bool _isLoadingHours = false;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Status? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  bool get isLoadingHours => _isLoadingHours;

  /// Loads employees using the current [statusFilter]/[searchQuery].
  /// Called on initial page load and after any CRUD operation so the
  /// list stays in sync with the repository.
  Future<void> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _repository.getEmployees(
        status: _statusFilter,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (_) {
      _errorMessage = 'Failed to load employees.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    await loadEmployees();
  }

  Future<void> filterByStatus(Status? status) async {
    _statusFilter = status;
    await loadEmployees();
  }

  /// Looks up an already-loaded employee from the current list
  /// (synchronous, no repository call). Returns null if not present
  /// in the currently loaded/filtered list — use [fetchById] when the
  /// employee may not be in the list (e.g. deep-linked details page).
  Employee? getById(String id) {
    for (final Employee employee in _employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  Future<Employee?> fetchById(String id) => _repository.getEmployeeById(id);

  Future<bool> addEmployee(Employee employee) async {
    try {
      await _repository.addEmployee(employee);
      await loadEmployees();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add employee.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee) async {
    try {
      await _repository.updateEmployee(employee);
      await loadEmployees();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update employee.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateEmployee(String id) async {
    try {
      await _repository.deactivateEmployee(id);
      await loadEmployees();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to deactivate employee.';
      notifyListeners();
      return false;
    }
  }

  List<EmployeeHour> hoursFor(String employeeId) => _hoursByEmployeeId[employeeId] ?? const [];

  Future<void> loadHours(String employeeId) async {
    _isLoadingHours = true;
    notifyListeners();

    try {
      _hoursByEmployeeId[employeeId] = await _repository.getEmployeeHours(employeeId);
    } catch (_) {
      _errorMessage = 'Failed to load work hours.';
    } finally {
      _isLoadingHours = false;
      notifyListeners();
    }
  }

  Future<bool> addHour(EmployeeHour hour) async {
    try {
      await _repository.addEmployeeHour(hour);
      await loadHours(hour.employeeId);
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add work hours.';
      notifyListeners();
      return false;
    }
  }
}
