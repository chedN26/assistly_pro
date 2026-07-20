import 'package:flutter/foundation.dart';

import '../models/operating_expense.dart';
import '../repositories/operating_expense_repository.dart';

/// Holds the currently-selected month's [OperatingExpense] record for
/// the Settings page. Replaces the old `SettingsProvider` — "Settings"
/// is no longer a single global document (Tools %/Misc %/Owner Share
/// %/Company Name); it's now a per-month record of absolute Tools and
/// Miscellaneous expense amounts, so this provider tracks which month
/// is selected and loads/saves that month's figures.
class OperatingExpenseProvider extends ChangeNotifier {
  OperatingExpenseProvider(this._repository) : _selectedMonth = _currentMonthKey();

  final OperatingExpenseRepository _repository;

  String _selectedMonth;
  OperatingExpense? _expense;
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  String get selectedMonth => _selectedMonth;
  OperatingExpense? get expense => _expense;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;

  /// "YYYY-MM" for the current calendar month, used as the default
  /// selection when the Settings page first loads.
  static String _currentMonthKey() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// The last 6 months (including the current one), most recent
  /// first — populates the Settings page's month selector.
  static List<String> recentMonths() {
    final DateTime now = DateTime.now();
    return [
      for (int i = 0; i < 6; i++) _monthKey(DateTime(now.year, now.month - i)),
    ];
  }

  static String _monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Future<void> loadExpenseForSelectedMonth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expense = await _repository.getExpenseForMonth(_selectedMonth);
    } catch (_) {
      _errorMessage = 'Failed to load operating expenses.';
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  Future<void> selectMonth(String month) async {
    _selectedMonth = month;
    await loadExpenseForSelectedMonth();
  }

  Future<bool> saveExpense({required double toolsExpense, required double miscellaneousExpense}) async {
    final DateTime now = DateTime.now();
    final OperatingExpense toSave = OperatingExpense(
      id: _expense?.id ?? 'EXP-$_selectedMonth',
      month: _selectedMonth,
      toolsExpense: toolsExpense,
      miscellaneousExpense: miscellaneousExpense,
      createdAt: _expense?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      _expense = await _repository.upsertExpense(toSave);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to save operating expenses.';
      notifyListeners();
      return false;
    }
  }
}
