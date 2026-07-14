import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../models/status.dart';
import 'search_bar.dart';
import 'status_filter_dropdown.dart';

/// Combines [AppSearchBar], [StatusFilterDropdown], and an "Add"
/// button into the toolbar layout shared by the Employee List (UI/UX
/// spec Section 9) and Client List (Section 11) pages: search →
/// filter → add button. Row layout on desktop/tablet, stacked on
/// mobile to avoid overflow.
class ListPageToolbar extends StatelessWidget {
  const ListPageToolbar({
    super.key,
    required this.searchHint,
    required this.initialSearchValue,
    required this.onSearch,
    required this.statusFilter,
    required this.onFilterChanged,
    required this.addButtonLabel,
    required this.onAddPressed,
  });

  final String searchHint;
  final String initialSearchValue;
  final ValueChanged<String> onSearch;
  final Status? statusFilter;
  final ValueChanged<Status?> onFilterChanged;
  final String addButtonLabel;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    final Widget search = AppSearchBar(
      hintText: searchHint,
      initialValue: initialSearchValue,
      onSearch: onSearch,
    );
    final Widget filter = SizedBox(
      width: isMobile ? double.infinity : 180,
      child: StatusFilterDropdown(value: statusFilter, onChanged: onFilterChanged),
    );
    final Widget addButton = ElevatedButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add),
      label: Text(addButtonLabel),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: AppSpacing.sm),
          filter,
          const SizedBox(height: AppSpacing.sm),
          addButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: search),
        const SizedBox(width: AppSpacing.md),
        filter,
        const SizedBox(width: AppSpacing.md),
        addButton,
      ],
    );
  }
}
