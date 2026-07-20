import '../../models/operating_expense.dart';
import '../operating_expense_repository.dart';

/// In-memory [OperatingExpenseRepository]. Seeded with the same 3
/// months of demo data as `scripts/seed/seed.js`.
class MockOperatingExpenseRepository implements OperatingExpenseRepository {
  MockOperatingExpenseRepository() : _expenses = _seedExpenses();

  final List<OperatingExpense> _expenses;

  @override
  Future<List<OperatingExpense>> getAllExpenses() async {
    await _simulateLatency();
    final List<OperatingExpense> sorted = [..._expenses]..sort((a, b) => a.month.compareTo(b.month));
    return sorted;
  }

  @override
  Future<OperatingExpense?> getExpenseForMonth(String month) async {
    await _simulateLatency();
    for (final OperatingExpense expense in _expenses) {
      if (expense.month == month) return expense;
    }
    return null;
  }

  @override
  Future<OperatingExpense> upsertExpense(OperatingExpense expense) async {
    await _simulateLatency();
    final DateTime now = DateTime.now();
    final int index = _expenses.indexWhere((e) => e.month == expense.month);

    if (index == -1) {
      final OperatingExpense created = expense.copyWith(
        id: 'EXP-${expense.month}',
        createdAt: now,
        updatedAt: now,
      );
      _expenses.add(created);
      return created;
    }

    final OperatingExpense updated = expense.copyWith(
      id: _expenses[index].id,
      createdAt: _expenses[index].createdAt,
      updatedAt: now,
    );
    _expenses[index] = updated;
    return updated;
  }

  static Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));

  /// Matches `scripts/seed/seed.js`'s `operatingExpenses` array
  /// exactly.
  static List<OperatingExpense> _seedExpenses() {
    const List<({String month, double tools, double misc})> seed = [
      (month: '2026-05', tools: 5000, misc: 1500),
      (month: '2026-06', tools: 5000, misc: 1500),
      (month: '2026-07', tools: 5000, misc: 1500),
    ];

    return [
      for (final entry in seed)
        OperatingExpense(
          id: 'EXP-${entry.month}',
          month: entry.month,
          toolsExpense: entry.tools,
          miscellaneousExpense: entry.misc,
          createdAt: DateTime.parse('${entry.month}-01'),
          updatedAt: DateTime.parse('${entry.month}-01'),
        ),
    ];
  }
}
