import 'package:intl/intl.dart';

/// Shared number/date formatting helpers so currency and date display
/// stay consistent across every page that needs them (not just the
/// Dashboard — Employee/Client modules will reuse [currency] and
/// [date] for hourly rates, payments, and history tables).
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

  static final NumberFormat _compactCurrencyFormat =
      NumberFormat.compactCurrency(locale: 'en_PH', symbol: '₱', decimalDigits: 1);

  static final DateFormat _monthLabelFormat = DateFormat.MMM();
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('M/d');

  static String currency(double value) => _currencyFormat.format(value);

  /// Abbreviated currency for tight spaces like chart axis labels
  /// (e.g. "₱50K" instead of "₱50,000.00").
  static String compactCurrency(double value) => _compactCurrencyFormat.format(value);

  /// Three-letter month label (e.g. "Jul") for chart x-axes.
  static String monthLabel(DateTime month) => _monthLabelFormat.format(month);

  static String date(DateTime date) => _dateFormat.format(date);

  /// Compact "M/d" label (e.g. "6/22") for dense chart x-axes like the
  /// Employee Hours line chart, where full month names would crowd.
  static String shortDate(DateTime date) => _shortDateFormat.format(date);
}
