import 'employee.dart';

/// A department, derived entirely from [Employee] records grouped by
/// their [Employee.department] field — there is no separate
/// `departments` collection/repository (per the enhancement brief).
/// Use [groupByDepartment] to build this from an [EmployeeProvider]'s
/// employee list.
class DepartmentSummary {
  const DepartmentSummary({required this.name, required this.employees});

  final String name;
  final List<Employee> employees;

  int get employeeCount => employees.length;

  /// The most common [Employee.supervisor] value among this
  /// department's employees, shown as the "Department Head". Since
  /// departments aren't a persisted entity with their own dedicated
  /// "head" field, this is a simple, deterministic heuristic rather
  /// than an authoritative assignment.
  String get departmentHead {
    if (employees.isEmpty) return 'Unassigned';
    final Map<String, int> counts = {};
    for (final Employee employee in employees) {
      counts[employee.supervisor] = (counts[employee.supervisor] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Groups [employees] by [Employee.department], sorted
  /// alphabetically by department name.
  static List<DepartmentSummary> groupByDepartment(List<Employee> employees) {
    final Map<String, List<Employee>> grouped = {};
    for (final Employee employee in employees) {
      grouped.putIfAbsent(employee.department, () => []).add(employee);
    }

    final List<DepartmentSummary> summaries = [
      for (final MapEntry<String, List<Employee>> entry in grouped.entries)
        DepartmentSummary(name: entry.key, employees: entry.value),
    ];
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }
}
