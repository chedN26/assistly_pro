import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// One column definition for [FlexTable]: a header label and a
/// relative width weighting ([flex]) — mirrors [Expanded]'s `flex`
/// semantics, so a column with `flex: 3` gets 3x the width of a
/// column with `flex: 1`.
class FlexTableColumn {
  const FlexTableColumn({required this.label, this.flex = 2});

  final String label;
  final int flex;
}

/// A table that fills its available width and distributes that width
/// across columns proportionally by [FlexTableColumn.flex] — the
/// behavior [DataTable] cannot provide natively (it sizes to its
/// content's intrinsic width, which is what left tables looking like
/// they "stop around the middle of the page" on wide screens).
///
/// Falls back to horizontal scrolling at a fixed [minWidth] on
/// screens narrower than that, preserving the original UI/UX spec's
/// "Tables horizontally scrollable" behavior on mobile.
class FlexTable extends StatelessWidget {
  const FlexTable({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.rowBuilder,
    this.minWidth = 760,
  });

  final List<FlexTableColumn> columns;
  final int itemCount;

  /// Returns the cell widgets for row [index], in the same order as
  /// [columns] (one cell per column).
  final List<Widget> Function(BuildContext context, int index) rowBuilder;

  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool fillsAvailableWidth = constraints.maxWidth >= minWidth;
        final double tableWidth = fillsAvailableWidth ? constraints.maxWidth : minWidth;

        final Widget table = SizedBox(
          width: tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FlexTableHeaderRow(columns: columns),
              const Divider(height: 1, color: AppColors.border),
              for (int i = 0; i < itemCount; i++) ...[
                _FlexTableDataRow(columns: columns, cells: rowBuilder(context, i)),
                if (i != itemCount - 1) const Divider(height: 1, color: AppColors.border),
              ],
            ],
          ),
        );

        if (fillsAvailableWidth) return table;
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: table);
      },
    );
  }
}

class _FlexTableHeaderRow extends StatelessWidget {
  const _FlexTableHeaderRow({required this.columns});

  final List<FlexTableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          for (final FlexTableColumn column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.label,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _FlexTableDataRow extends StatelessWidget {
  const _FlexTableDataRow({required this.columns, required this.cells});

  final List<FlexTableColumn> columns;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            Expanded(flex: columns[i].flex, child: cells[i]),
        ],
      ),
    );
  }
}
