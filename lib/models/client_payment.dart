/// Mirrors the `client_payments` Firestore collection (DDD Section 7).
class ClientPayment {
  const ClientPayment({
    required this.id,
    required this.clientId,
    required this.date,
    required this.amount,
  });

  final String id;
  final String clientId;
  final DateTime date;
  final double amount;

  ClientPayment copyWith({
    String? id,
    String? clientId,
    DateTime? date,
    double? amount,
  }) {
    return ClientPayment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }

  factory ClientPayment.fromMap(Map<String, dynamic> map) {
    return ClientPayment(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
}
