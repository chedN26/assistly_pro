import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Wraps a chart widget in a titled [Card] with consistent padding
/// and a fixed plot height, matching the dashboard's other cards.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.height = 280,
  });

  final String title;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(height: height, child: child),
          ],
        ),
      ),
    );
  }
}
