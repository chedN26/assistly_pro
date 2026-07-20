import 'status.dart';

/// Mirrors the `clients` Firestore collection per the Firebase
/// Database Design Document. Dart property names are unchanged
/// (id, phone) even though the Firestore-side field names differ
/// (clientId, contactNumber) — only fromMap()/toMap() changed.
///
/// `monthlyPayment` no longer exists — the DDD replaces it with
/// `serviceType` (a category, not a dollar figure). Revenue is, and
/// always was, computed from `client_payments.amount`, never from
/// this field, so removing it doesn't affect any calculation.
class Client {
  const Client({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;

  /// Category of service this client receives (e.g. "Bookkeeping
  /// Services"). Free-text, matching the DDD's `serviceType` field.
  final String serviceType;

  final Status status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? serviceType,
    Status? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['clientId'] as String,
      companyName: map['companyName'] as String,
      contactPerson: map['contactPerson'] as String,
      email: map['email'] as String,
      phone: map['contactNumber'] as String,
      serviceType: (map['serviceType'] as String?) ?? 'Unspecified',
      status: StatusX.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? (map['createdAt'] as String)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': id,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'contactNumber': phone,
      'serviceType': serviceType,
      'status': status.label,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
