import 'package:flutter/material.dart';

import '../../models/client.dart';
import '../../models/status.dart';
import '../common/flex_table.dart';
import '../common/status_badge.dart';

/// Client data table (UI/UX spec Section 11), rewritten on top of
/// [FlexTable] so it fills the available width instead of stopping
/// partway across the page. Mirrors [EmployeeTable]'s structure.
class ClientTable extends StatelessWidget {
  const ClientTable({
    super.key,
    required this.clients,
    required this.onView,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final List<Client> clients;
  final ValueChanged<Client> onView;
  final ValueChanged<Client> onEdit;

  /// Called when the user taps Activate or Deactivate — the page
  /// decides which action applies based on the client's current
  /// [Client.status].
  final ValueChanged<Client> onToggleStatus;

  final ValueChanged<Client> onDelete;

  static const List<FlexTableColumn> _columns = [
    FlexTableColumn(label: 'Company Name', flex: 3),
    FlexTableColumn(label: 'Contact Person', flex: 2),
    FlexTableColumn(label: 'Service Type', flex: 2),
    FlexTableColumn(label: 'Status', flex: 1),
    FlexTableColumn(label: 'Actions', flex: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return FlexTable(
      columns: _columns,
      itemCount: clients.length,
      minWidth: 760,
      rowBuilder: (context, index) {
        final Client client = clients[index];
        final bool isActive = client.status == Status.active;

        return [
          Text(client.companyName, overflow: TextOverflow.ellipsis),
          Text(client.contactPerson, overflow: TextOverflow.ellipsis),
          Text(client.serviceType, overflow: TextOverflow.ellipsis),
          StatusBadge(status: client.status),
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
                icon: Icon(isActive ? Icons.block : Icons.check_circle_outline),
                tooltip: isActive ? 'Deactivate' : 'Activate',
                onPressed: () => onToggleStatus(client),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => onDelete(client),
              ),
            ],
          ),
        ];
      },
    );
  }
}
