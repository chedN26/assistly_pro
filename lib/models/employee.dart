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
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final double hourlyRate;
  final Status status;
  final DateTime createdAt;

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    double? hourlyRate,
    Status? status,
    DateTime? createdAt,
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
    };
  }
}
