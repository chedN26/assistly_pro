import 'package:flutter/material.dart';

import '../../models/status.dart';

/// Status filter dropdown (UI/UX spec Section 18). Per spec, changing
/// the filter automatically refreshes the table — the caller's
/// [onChanged] should trigger a reload immediately, unlike
/// [AppSearchBar] which waits for an explicit submit.
class StatusFilterDropdown extends StatelessWidget {
  const StatusFilterDropdown({super.key, required this.value, required this.onChanged});

  /// null represents "All".
  final Status? value;
  final ValueChanged<Status?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Status?>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Status'),
      items: const [
        DropdownMenuItem(value: null, child: Text('All')),
        DropdownMenuItem(value: Status.active, child: Text('Active')),
        DropdownMenuItem(value: Status.inactive, child: Text('Inactive')),
      ],
      onChanged: onChanged,
    );
  }
}
