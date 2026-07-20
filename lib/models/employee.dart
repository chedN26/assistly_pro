import 'status.dart';

/// Mirrors the `employees` Firestore collection per the Firebase
/// Database Design Document. Dart property names are intentionally
/// UNCHANGED from before this migration (id, name, phone,
/// assignedClientId) even though the DDD uses different Firestore
/// field names (employeeId, fullName, contactNumber, assignedClient)
/// — only fromMap()/toMap()'s serialization keys changed, so no UI
/// file that references `.id`/`.name`/`.phone`/etc. needs to change.
class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.hourlyRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.dateHired,
    required this.department,
    required this.supervisor,
    this.assignedClientId,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final double hourlyRate;
  final Status status;
  final DateTime createdAt;

  /// Last-modified timestamp. Repository write methods (not UI code)
  /// are responsible for stamping this to "now" on every add/update —
  /// see [MockEmployeeRepository]/[FirebaseEmployeeRepository].
  final DateTime updatedAt;

  /// Date this employee was hired — distinct from [createdAt] (when
  /// the record itself was created in the system), per the DDD.
  final DateTime dateHired;

  /// Department name (e.g. "Human Resources"). Free-text — departments
  /// are derived groupings of employees, not a separate persisted
  /// collection (see [DepartmentSummary]).
  final String department;

  /// This employee's supervisor / department head name.
  final String supervisor;

  /// The [Client.id] this employee is currently assigned to, if any.
  /// Null means unassigned.
  final String? assignedClientId;

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    double? hourlyRate,
    Status? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateHired,
    String? department,
    String? supervisor,
    String? assignedClientId,
    bool clearAssignedClientId = false,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateHired: dateHired ?? this.dateHired,
      department: department ?? this.department,
      supervisor: supervisor ?? this.supervisor,
      assignedClientId:
          clearAssignedClientId ? null : (assignedClientId ?? this.assignedClientId),
    );
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['employeeId'] as String,
      name: map['fullName'] as String,
      email: map['email'] as String,
      phone: map['contactNumber'] as String,
      position: map['position'] as String,
      hourlyRate: (map['hourlyRate'] as num).toDouble(),
      status: StatusX.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      // Defaulted for backward compatibility with any pre-existing
      // records that predate these fields.
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? (map['createdAt'] as String)),
      dateHired: DateTime.parse((map['dateHired'] as String?) ?? (map['createdAt'] as String)),
      department: (map['department'] as String?) ?? 'Unassigned',
      supervisor: (map['supervisor'] as String?) ?? 'Unassigned',
      assignedClientId: map['assignedClient'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': id,
      'fullName': name,
      'email': email,
      'contactNumber': phone,
      'position': position,
      'hourlyRate': hourlyRate,
      'status': status.label,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dateHired': dateHired.toIso8601String(),
      'department': department,
      'supervisor': supervisor,
      'assignedClient': assignedClientId,
    };
  }
}
