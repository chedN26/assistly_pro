/// Mirrors the `employee_hours` Firestore collection (DDD Section 5).
/// A single day's recorded work hours for one employee.
class EmployeeHour {
  const EmployeeHour({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.hoursWorked,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final double hoursWorked;

  EmployeeHour copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    double? hoursWorked,
  }) {
    return EmployeeHour(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      hoursWorked: hoursWorked ?? this.hoursWorked,
    );
  }

  factory EmployeeHour.fromMap(Map<String, dynamic> map) {
    return EmployeeHour(
      id: map['id'] as String,
      employeeId: map['employeeId'] as String,
      date: DateTime.parse(map['date'] as String),
      hoursWorked: (map['hoursWorked'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'hoursWorked': hoursWorked,
    };
  }
}
