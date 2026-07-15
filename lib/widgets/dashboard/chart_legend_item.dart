import 'package:flutter/material.dart';

/// A single legend entry (color swatch + label) used by
/// [RevenueProfitTrendChart] and [NetProfitForecastChart] so both
/// charts' legends look identical instead of each rolling its own.
class ChartLegendItem extends StatelessWidget {
  const ChartLegendItem({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
