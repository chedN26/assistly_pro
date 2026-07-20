/// Mirrors the `employee_time_logs` Firestore collection per the
/// Firebase Database Design Document (renamed from `employee_hours`).
/// A single day's recorded work hours for one employee.
///
/// Dart property names (id, date) are unchanged — only the Firestore
/// field names (timeLogId, workDate) and collection name changed.
class EmployeeHour {
  const EmployeeHour({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.hoursWorked,
    required this.createdAt,
    required this.updatedAt,
    this.remarks,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final double hoursWorked;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optional notes, per the DDD ("remarks", Required: No). No UI
  /// currently sets this — always null unless set by a future
  /// feature.
  final String? remarks;

  EmployeeHour copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    double? hoursWorked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
  }) {
    return EmployeeHour(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
    );
  }

  factory EmployeeHour.fromMap(Map<String, dynamic> map) {
    return EmployeeHour(
      id: map['timeLogId'] as String,
      employeeId: map['employeeId'] as String,
      date: DateTime.parse(map['workDate'] as String),
      hoursWorked: (map['hoursWorked'] as num).toDouble(),
      createdAt: DateTime.parse((map['createdAt'] as String?) ?? (map['workDate'] as String)),
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? (map['workDate'] as String)),
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timeLogId': id,
      'employeeId': employeeId,
      'workDate': date.toIso8601String(),
      'hoursWorked': hoursWorked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}
