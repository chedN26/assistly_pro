import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../models/status.dart';
import '../../utils/formatters.dart';
import '../common/flex_table.dart';
import '../common/status_badge.dart';

/// Employee data table (UI/UX spec Section 9), rewritten on top of
/// [FlexTable] so it fills the available width instead of stopping
/// partway across the page. Purely presentational — receives the
/// already-filtered list and reports user actions via callbacks; all
/// actual CRUD logic and dialogs live in the page.
class EmployeeTable extends StatelessWidget {
  const EmployeeTable({
    super.key,
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final List<Employee> employees;
  final ValueChanged<Employee> onView;
  final ValueChanged<Employee> onEdit;

  /// Called when the user taps Activate or Deactivate — the page
  /// decides which action applies based on the employee's current
  /// [Employee.status].
  final ValueChanged<Employee> onToggleStatus;

  static const List<FlexTableColumn> _columns = [
    FlexTableColumn(label: 'Employee Name', flex: 3),
    FlexTableColumn(label: 'Position', flex: 2),
    FlexTableColumn(label: 'Department', flex: 2),
    FlexTableColumn(label: 'Hourly Rate', flex: 2),
    FlexTableColumn(label: 'Status', flex: 1),
    FlexTableColumn(label: 'Actions', flex: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return FlexTable(
      columns: _columns,
      itemCount: employees.length,
      minWidth: 860,
      rowBuilder: (context, index) {
        final Employee employee = employees[index];
        final bool isActive = employee.status == Status.active;

        return [
          Text(employee.name, overflow: TextOverflow.ellipsis),
          Text(employee.position, overflow: TextOverflow.ellipsis),
          Text(employee.department, overflow: TextOverflow.ellipsis),
          Text(AppFormatters.currency(employee.hourlyRate)),
          StatusBadge(status: employee.status),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View',
                onPressed: () => onView(employee),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => onEdit(employee),
              ),
              IconButton(
                icon: Icon(isActive ? Icons.block : Icons.check_circle_outline),
                tooltip: isActive ? 'Deactivate' : 'Activate',
                onPressed: () => onToggleStatus(employee),
              ),
            ],
          ),
        ];
      },
    );
  }
}
