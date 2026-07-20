import '../models/employee.dart';
import '../models/employee_hour.dart';
import '../models/status.dart';

/// Contract for employee data access (DDD Section 4 & 5, query
/// requirements Section 13). [EmployeeProvider] depends on this
/// abstraction only, never on a concrete implementation, so the
/// Firebase phase can swap [MockEmployeeRepository] with no changes
/// to the provider or UI layers.
abstract class EmployeeRepository {
  /// Returns employees optionally filtered by [status] (null = all)
  /// and/or matched against [searchQuery] (matched on name).
  Future<List<Employee>> getEmployees({Status? status, String? searchQuery});

  Future<Employee?> getEmployeeById(String id);

  Future<Employee> addEmployee(Employee employee);

  Future<Employee> updateEmployee(Employee employee);

  /// Sets the employee's status to [Status.inactive]. Employees are
  /// deactivated, never deleted, per the UI/UX spec's "Deactivate"
  /// action.
  Future<Employee> deactivateEmployee(String id);

  /// Permanently removes an employee record.
  Future<void> deleteEmployee(String id);

  /// Work-hour records for a single employee, sorted by date.
  Future<List<EmployeeHour>> getEmployeeHours(String employeeId);

  Future<EmployeeHour> addEmployeeHour(EmployeeHour hour);

  /// All work-hour records across every employee, regardless of
  /// status. Needed for the dashboard's total Salary Expense
  /// calculation (DDD Section 10 — Dashboard Data Sources), which is
  /// not expressible through [getEmployeeHours] alone.
  Future<List<EmployeeHour>> getAllHours();
}
