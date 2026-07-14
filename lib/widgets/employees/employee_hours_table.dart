import 'package:flutter/material.dart';

import '../../models/employee_hour.dart';
import '../../utils/formatters.dart';

/// Hours History table (UI/UX spec Section 10): Date, Hours Worked —
/// most recent entries first.
class EmployeeHoursTable extends StatelessWidget {
  const EmployeeHoursTable({super.key, required this.hours});

  final List<EmployeeHour> hours;

  @override
  Widget build(BuildContext context) {
    final List<EmployeeHour> sorted = [...hours]..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Hours Worked')),
        ],
        rows: [
          for (final EmployeeHour hour in sorted)
            DataRow(
              cells: [
                DataCell(Text(AppFormatters.date(hour.date))),
                DataCell(Text(hour.hoursWorked.toStringAsFixed(1))),
              ],
            ),
        ],
      ),
    );
  }
}
