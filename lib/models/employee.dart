import 'status.dart';

/// Mirrors the `employees` Firestore collection (DDD Section 4).
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
      department: department ?? this.department,
      supervisor: supervisor ?? this.supervisor,
      assignedClientId:
          clearAssignedClientId ? null : (assignedClientId ?? this.assignedClientId),
    );
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      position: map['position'] as String,
      hourlyRate: (map['hourlyRate'] as num).toDouble(),
      status: StatusX.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      // Defaulted for backward compatibility with any pre-existing
      // records that predate these fields.
      department: (map['department'] as String?) ?? 'Unassigned',
      supervisor: (map['supervisor'] as String?) ?? 'Unassigned',
      assignedClientId: map['assignedClientId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'hourlyRate': hourlyRate,
      'status': status.label,
      'createdAt': createdAt.toIso8601String(),
      'department': department,
      'supervisor': supervisor,
      'assignedClientId': assignedClientId,
    };
  }
}
