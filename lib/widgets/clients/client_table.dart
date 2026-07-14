import 'package:flutter/material.dart';

import '../../models/client.dart';
import '../../models/status.dart';
import '../../utils/formatters.dart';
import '../common/status_badge.dart';

/// Client data table (UI/UX spec Section 11). Purely presentational —
/// receives the already-filtered list and reports user actions via
/// callbacks, mirroring [EmployeeTable]'s design.
class ClientTable extends StatelessWidget {
  const ClientTable({
    super.key,
    required this.clients,
    required this.onView,
    required this.onEdit,
    required this.onDeactivate,
  });

  final List<Client> clients;
  final ValueChanged<Client> onView;
  final ValueChanged<Client> onEdit;
  final ValueChanged<Client> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Company Name')),
          DataColumn(label: Text('Contact Person')),
          DataColumn(label: Text('Monthly Payment')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final Client client in clients)
            DataRow(
              cells: [
                DataCell(Text(client.companyName)),
                DataCell(Text(client.contactPerson)),
                DataCell(Text(AppFormatters.currency(client.monthlyPayment))),
                DataCell(StatusBadge(status: client.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        tooltip: 'View',
                        onPressed: () => onView(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => onEdit(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.block),
                        tooltip: 'Deactivate',
                        onPressed: client.status == Status.active ? () => onDeactivate(client) : null,
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
