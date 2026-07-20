import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/operating_expense.dart';
import '../operating_expense_repository.dart';
import 'firestore_date_codec.dart';

/// Firestore implementation of [OperatingExpenseRepository], backing
/// the `operating_expenses` collection per the Firebase Database
/// Design Document. Document IDs follow `seed.js`'s convention
/// (`EXP-YYYY-MM`) so seeded and app-created records use the same
/// scheme.
class FirebaseOperatingExpenseRepository implements OperatingExpenseRepository {
  FirebaseOperatingExpenseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<String> _dateFields = ['createdAt', 'updatedAt'];

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('operating_expenses');

  OperatingExpense _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data(), _dateFields);
    return OperatingExpense.fromMap({...decoded, 'expenseId': doc.id});
  }

  @override
  Future<List<OperatingExpense>> getAllExpenses() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _expenses.get();
    final List<OperatingExpense> expenses = snapshot.docs.map(_fromDoc).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return expenses;
  }

  @override
  Future<OperatingExpense?> getExpenseForMonth(String month) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _expenses.doc('EXP-$month').get();
    if (!doc.exists || doc.data() == null) return null;
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data()!, _dateFields);
    return OperatingExpense.fromMap({...decoded, 'expenseId': doc.id});
  }

  @override
  Future<OperatingExpense> upsertExpense(OperatingExpense expense) async {
    final String docId = 'EXP-${expense.month}';
    final DocumentReference<Map<String, dynamic>> docRef = _expenses.doc(docId);
    final DocumentSnapshot<Map<String, dynamic>> existingDoc = await docRef.get();
    final DateTime now = DateTime.now();

    // Explicitly determine createdAt rather than relying on
    // copyWith's `??` fallback, which can't distinguish "preserve the
    // existing value" from "the caller didn't pass one" once a `null`
    // literal is involved.
    final DateTime createdAt;
    if (existingDoc.exists && existingDoc.data() != null) {
      final Map<String, dynamic> decoded = FirestoreDateCodec.decode(existingDoc.data()!, _dateFields);
      createdAt = DateTime.parse(decoded['createdAt'] as String);
    } else {
      createdAt = now;
    }

    final OperatingExpense finalExpense = expense.copyWith(id: docId, createdAt: createdAt, updatedAt: now);
    await docRef.set(FirestoreDateCodec.encode(finalExpense.toMap(), _dateFields));
    return finalExpense;
  }
}
