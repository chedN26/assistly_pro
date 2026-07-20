import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/employee.dart';
import '../../models/employee_hour.dart';
import '../../models/status.dart';
import '../employee_repository.dart';
import 'firestore_date_codec.dart';

/// Firestore implementation of [EmployeeRepository], backing the
/// `employees` and `employee_time_logs` collections per the Firebase
/// Database Design Document.
///
/// Dates are stored as native Firestore [Timestamp] values (matching
/// what `seed.js` writes via the Admin SDK), converted to/from the
/// ISO8601 strings the models expect via [FirestoreDateCodec] — the
/// models themselves stay DB-agnostic and never import
/// `cloud_firestore`.
class FirebaseEmployeeRepository implements EmployeeRepository {
  FirebaseEmployeeRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<String> _employeeDateFields = ['createdAt', 'updatedAt', 'dateHired'];
  static const List<String> _hourDateFields = ['workDate', 'createdAt', 'updatedAt'];

  CollectionReference<Map<String, dynamic>> get _employees => _firestore.collection('employees');
  CollectionReference<Map<String, dynamic>> get _employeeTimeLogs =>
      _firestore.collection('employee_time_logs');

  /// Firestore's document ID is always the source of truth for `id`,
  /// even though the field is also stored in the document body (per
  /// the DDD sample documents) — this guards against the two ever
  /// drifting out of sync. `employeeId` is the Firestore-side field
  /// name for `Employee.id` (see the model's doc comment).
  Employee _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data(), _employeeDateFields);
    return Employee.fromMap({...decoded, 'employeeId': doc.id});
  }

  EmployeeHour _hourFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data(), _hourDateFields);
    return EmployeeHour.fromMap({...decoded, 'timeLogId': doc.id});
  }

  @override
  Future<List<Employee>> getEmployees({Status? status, String? searchQuery}) async {
    Query<Map<String, dynamic>> query = _employees;
    if (status != null) {
      query = query.where('status', isEqualTo: status.label);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    Iterable<Employee> employees = snapshot.docs.map(_fromDoc);

    // Firestore has no case-insensitive "contains" query, so the name
    // search is applied client-side after the (much cheaper) status
    // filter runs server-side.
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final String query2 = searchQuery.trim().toLowerCase();
      employees = employees.where((e) => e.name.toLowerCase().contains(query2));
    }

    return employees.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Employee?> getEmployeeById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _employees.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data()!, _employeeDateFields);
    return Employee.fromMap({...decoded, 'employeeId': doc.id});
  }

  @override
  Future<Employee> addEmployee(Employee employee) async {
    final DocumentReference<Map<String, dynamic>> docRef = _employees.doc();
    final DateTime now = DateTime.now();
    // The repository — not UI call sites — is authoritative for
    // id/createdAt/updatedAt on creation.
    final Employee newEmployee = employee.copyWith(id: docRef.id, createdAt: now, updatedAt: now);
    await docRef.set(FirestoreDateCodec.encode(newEmployee.toMap(), _employeeDateFields));
    return newEmployee;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    // createdAt is preserved as passed in; only updatedAt is stamped
    // fresh here, since this method is also reused by
    // EmployeeProvider.activateEmployee (a status-only change).
    final Employee updated = employee.copyWith(updatedAt: DateTime.now());
    await _employees.doc(updated.id).set(FirestoreDateCodec.encode(updated.toMap(), _employeeDateFields));
    return updated;
  }

  @override
  Future<Employee> deactivateEmployee(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _employees.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Employee with id "$id" not found.');
    }
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data()!, _employeeDateFields);
    final Employee current = Employee.fromMap({...decoded, 'employeeId': doc.id});
    final Employee updated = current.copyWith(status: Status.inactive, updatedAt: DateTime.now());
    await _employees.doc(id).set(FirestoreDateCodec.encode(updated.toMap(), _employeeDateFields));
    return updated;
  }

  @override
  Future<void> deleteEmployee(String id) async {
    final QuerySnapshot<Map<String, dynamic>> hourDocs =
        await _employeeTimeLogs.where('employeeId', isEqualTo: id).get();
    final WriteBatch batch = _firestore.batch();
    batch.delete(_employees.doc(id));
    for (final doc in hourDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<List<EmployeeHour>> getEmployeeHours(String employeeId) async {
    // Sorted client-side rather than via Firestore orderBy() to avoid
    // requiring a composite index (equality + order-by on different
    // fields) to be manually configured in the Firebase console.
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _employeeTimeLogs.where('employeeId', isEqualTo: employeeId).get();
    final List<EmployeeHour> hours = snapshot.docs.map(_hourFromDoc).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return hours;
  }

  @override
  Future<EmployeeHour> addEmployeeHour(EmployeeHour hour) async {
    final DocumentReference<Map<String, dynamic>> docRef = _employeeTimeLogs.doc();
    final DateTime now = DateTime.now();
    final EmployeeHour newHour = hour.copyWith(id: docRef.id, createdAt: now, updatedAt: now);
    await docRef.set(FirestoreDateCodec.encode(newHour.toMap(), _hourDateFields));
    return newHour;
  }

  @override
  Future<List<EmployeeHour>> getAllHours() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _employeeTimeLogs.get();
    return snapshot.docs.map(_hourFromDoc).toList();
  }
}
