import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../models/status.dart';
import '../../utils/formatters.dart';
import '../common/status_badge.dart';

/// Employee data table (UI/UX spec Section 9). Purely presentational —
/// receives the already-filtered list and reports user actions via
/// callbacks. All actual CRUD logic and dialogs live in the page,
/// keeping this widget reusable/testable in isolation.
class EmployeeTable extends StatelessWidget {
  const EmployeeTable({
    super.key,
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onDeactivate,
  });

  final List<Employee> employees;
  final ValueChanged<Employee> onView;
  final ValueChanged<Employee> onEdit;
  final ValueChanged<Employee> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Employee Name')),
          DataColumn(label: Text('Position')),
          DataColumn(label: Text('Hourly Rate')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final Employee employee in employees)
            DataRow(
              cells: [
                DataCell(Text(employee.name)),
                DataCell(Text(employee.position)),
                DataCell(Text(AppFormatters.currency(employee.hourlyRate))),
                DataCell(StatusBadge(status: employee.status)),
                DataCell(
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
                        icon: const Icon(Icons.block),
                        tooltip: 'Deactivate',
                        onPressed:
                            employee.status == Status.active ? () => onDeactivate(employee) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
