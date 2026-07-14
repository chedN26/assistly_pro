import 'package:flutter/material.dart';

import '../../models/client_payment.dart';
import '../../utils/formatters.dart';

/// Payment History table (UI/UX spec Section 12): Date, Amount — most
/// recent payments first.
class PaymentHistoryTable extends StatelessWidget {
  const PaymentHistoryTable({super.key, required this.payments});

  final List<ClientPayment> payments;

  @override
  Widget build(BuildContext context) {
    final List<ClientPayment> sorted = [...payments]..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Amount')),
        ],
        rows: [
          for (final ClientPayment payment in sorted)
            DataRow(
              cells: [
                DataCell(Text(AppFormatters.date(payment.date))),
                DataCell(Text(AppFormatters.currency(payment.amount))),
              ],
            ),
        ],
      ),
    );
  }
}
