/// Mirrors the `client_payments` Firestore collection per the
/// Firebase Database Design Document. Dart property names (id, date)
/// unchanged — only fromMap()/toMap()'s Firestore-side keys
/// (paymentId, paymentDate) changed. Collection name itself is
/// unchanged (`client_payments` in both the old and new schema).
class ClientPayment {
  const ClientPayment({
    required this.id,
    required this.clientId,
    required this.date,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.remarks,
  });

  final String id;
  final String clientId;
  final DateTime date;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optional notes, per the DDD ("remarks", Required: No). No UI
  /// currently sets this.
  final String? remarks;

  ClientPayment copyWith({
    String? id,
    String? clientId,
    DateTime? date,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
  }) {
    return ClientPayment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
    );
  }

  factory ClientPayment.fromMap(Map<String, dynamic> map) {
    return ClientPayment(
      id: map['paymentId'] as String,
      clientId: map['clientId'] as String,
      date: DateTime.parse(map['paymentDate'] as String),
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse((map['createdAt'] as String?) ?? (map['paymentDate'] as String)),
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? (map['paymentDate'] as String)),
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': id,
      'clientId': clientId,
      'paymentDate': date.toIso8601String(),
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}
