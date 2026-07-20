/// Mirrors the `operating_expenses` Firestore collection per the
/// Firebase Database Design Document — one document per calendar
/// month, storing absolute dollar amounts.
///
/// Replaces the old `BusinessSettings` model entirely. That model's
/// `toolsPercentage`/`miscellaneousPercentage` (computed against
/// Salary Expense) and `ownerSharePercentage` (user-configurable) had
/// no equivalent in the new DDD — Tools/Miscellaneous are now
/// directly-entered monthly figures, and Owner Share is a fixed 5%
/// constant (see `services/dashboard_calculator.dart`, added in the
/// next migration step). `companyName` also had no DDD equivalent and
/// was confirmed unused anywhere outside its own settings-page field,
/// so it's dropped too — see the migration notes.
class OperatingExpense {
  const OperatingExpense({
    required this.id,
    required this.month,
    required this.toolsExpense,
    required this.miscellaneousExpense,
    required this.createdAt,
    required this.updatedAt,
    this.remarks,
  });

  final String id;

  /// "YYYY-MM" format (e.g. "2026-07"), matching the DDD's `month`
  /// field and `scripts/seed/seed.js`'s seeded values. Acts as the
  /// natural key — one document per month.
  final String month;

  final double toolsExpense;
  final double miscellaneousExpense;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optional notes, per the DDD ("remarks", Required: No).
  final String? remarks;

  OperatingExpense copyWith({
    String? id,
    String? month,
    double? toolsExpense,
    double? miscellaneousExpense,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
  }) {
    return OperatingExpense(
      id: id ?? this.id,
      month: month ?? this.month,
      toolsExpense: toolsExpense ?? this.toolsExpense,
      miscellaneousExpense: miscellaneousExpense ?? this.miscellaneousExpense,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
    );
  }

  factory OperatingExpense.fromMap(Map<String, dynamic> map) {
    return OperatingExpense(
      id: map['expenseId'] as String,
      month: map['month'] as String,
      toolsExpense: (map['toolsExpense'] as num).toDouble(),
      miscellaneousExpense: (map['miscellaneousExpense'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? (map['createdAt'] as String)),
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': id,
      'month': month,
      'toolsExpense': toolsExpense,
      'miscellaneousExpense': miscellaneousExpense,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}
