import 'status.dart';

/// Mirrors the `clients` Firestore collection (DDD Section 6).
class Client {
  const Client({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.monthlyPayment,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final double monthlyPayment;
  final Status status;
  final DateTime createdAt;

  Client copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    double? monthlyPayment,
    Status? status,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      companyName: map['companyName'] as String,
      contactPerson: map['contactPerson'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      monthlyPayment: (map['monthlyPayment'] as num).toDouble(),
      status: StatusX.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'monthlyPayment': monthlyPayment,
      'status': status.label,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
