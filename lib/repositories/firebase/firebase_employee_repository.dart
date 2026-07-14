import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/employee.dart';
import '../../models/employee_hour.dart';
import '../../models/status.dart';
import '../employee_repository.dart';

/// Firestore implementation of [EmployeeRepository], backing the
/// `employees` and `employee_hours` collections (DDD Sections 4 & 5).
///
/// Dates round-trip as the same ISO8601 strings [Employee.toMap]/
/// [EmployeeHour.toMap] already produce for [MockEmployeeRepository]
/// — no Firestore [Timestamp] conversion is needed anywhere in this
/// file, by design (see Phase 3 model comments).
class FirebaseEmployeeRepository implements EmployeeRepository {
  FirebaseEmployeeRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _employees => _firestore.collection('employees');
  CollectionReference<Map<String, dynamic>> get _employeeHours => _firestore.collection('employee_hours');

  /// Firestore's document ID is always the source of truth for `id`,
  /// even though the field is also stored in the document body (per
  /// the DDD sample documents) — this guards against the two ever
  /// drifting out of sync.
  Employee _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      Employee.fromMap({...doc.data(), 'id': doc.id});

  EmployeeHour _hourFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      EmployeeHour.fromMap({...doc.data(), 'id': doc.id});

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
    return Employee.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<Employee> addEmployee(Employee employee) async {
    final DocumentReference<Map<String, dynamic>> docRef = _employees.doc();
    final Employee newEmployee = employee.copyWith(id: docRef.id);
    await docRef.set(newEmployee.toMap());
    return newEmployee;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    await _employees.doc(employee.id).set(employee.toMap());
    return employee;
  }

  @override
  Future<Employee> deactivateEmployee(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _employees.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Employee with id "$id" not found.');
    }
    final Employee current = Employee.fromMap({...doc.data()!, 'id': doc.id});
    final Employee updated = current.copyWith(status: Status.inactive);
    await _employees.doc(id).set(updated.toMap());
    return updated;
  }

  @override
  Future<List<EmployeeHour>> getEmployeeHours(String employeeId) async {
    // Sorted client-side rather than via Firestore orderBy() to avoid
    // requiring a composite index (equality + order-by on different
    // fields) to be manually configured in the Firebase console.
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _employeeHours.where('employeeId', isEqualTo: employeeId).get();
    final List<EmployeeHour> hours = snapshot.docs.map(_hourFromDoc).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return hours;
  }

  @override
  Future<EmployeeHour> addEmployeeHour(EmployeeHour hour) async {
    final DocumentReference<Map<String, dynamic>> docRef = _employeeHours.doc();
    final EmployeeHour newHour = hour.copyWith(id: docRef.id);
    await docRef.set(newHour.toMap());
    return newHour;
  }

  @override
  Future<List<EmployeeHour>> getAllHours() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _employeeHours.get();
    return snapshot.docs.map(_hourFromDoc).toList();
  }
}
