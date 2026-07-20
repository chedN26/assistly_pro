import '../models/operating_expense.dart';

/// Contract for operating-expense data access (DDD's `operating_expenses`
/// collection — one document per month). Replaces the old
/// `SettingsRepository` entirely; there is no longer a single global
/// settings document.
abstract class OperatingExpenseRepository {
  /// All months on record, sorted chronologically. Needed for the
  /// Dashboard's monthly expense trend, not just the Settings page's
  /// single-month editor.
  Future<List<OperatingExpense>> getAllExpenses();

  /// The record for a specific "YYYY-MM" [month], or null if that
  /// month has no entry yet.
  Future<OperatingExpense?> getExpenseForMonth(String month);

  /// Creates a new month's record, or updates it if one already
  /// exists for [expense.month] — "upsert" semantics, since a month is
  /// a natural unique key rather than something added repeatedly like
  /// an employee or payment.
  Future<OperatingExpense> upsertExpense(OperatingExpense expense);
}
