import 'package:uuid/uuid.dart';

import '../../models/employee.dart';
import '../../models/employee_hour.dart';
import '../../models/status.dart';
import '../employee_repository.dart';

/// In-memory [EmployeeRepository]. Seeded with the same demo data as
/// `scripts/seed/seed.js` (the Firebase seed script), so Mock and
/// Firebase modes show identical records when freshly seeded.
class MockEmployeeRepository implements EmployeeRepository {
  MockEmployeeRepository()
      : _employees = _seedEmployees(),
        _hours = _seedHours();

  final List<Employee> _employees;
  final List<EmployeeHour> _hours;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Employee>> getEmployees({Status? status, String? searchQuery}) async {
    await _simulateLatency();

    Iterable<Employee> result = _employees;
    if (status != null) {
      result = result.where((e) => e.status == status);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final String query = searchQuery.trim().toLowerCase();
      result = result.where((e) => e.name.toLowerCase().contains(query));
    }

    return result.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Employee?> getEmployeeById(String id) async {
    await _simulateLatency();
    for (final Employee employee in _employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  @override
  Future<Employee> addEmployee(Employee employee) async {
    await _simulateLatency();
    final DateTime now = DateTime.now();
    // The repository — not UI call sites — is authoritative for
    // id/createdAt/updatedAt on creation, matching
    // FirebaseEmployeeRepository's behavior.
    final Employee newEmployee = employee.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    _employees.add(newEmployee);
    return newEmployee;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    await _simulateLatency();
    final int index = _employees.indexWhere((e) => e.id == employee.id);
    if (index == -1) {
      throw StateError('Employee with id "${employee.id}" not found.');
    }
    final Employee updated = employee.copyWith(updatedAt: DateTime.now());
    _employees[index] = updated;
    return updated;
  }

  @override
  Future<Employee> deactivateEmployee(String id) async {
    await _simulateLatency();
    final int index = _employees.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw StateError('Employee with id "$id" not found.');
    }
    final Employee updated = _employees[index].copyWith(status: Status.inactive, updatedAt: DateTime.now());
    _employees[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await _simulateLatency();
    _employees.removeWhere((e) => e.id == id);
    _hours.removeWhere((h) => h.employeeId == id);
  }

  @override
  Future<List<EmployeeHour>> getEmployeeHours(String employeeId) async {
    await _simulateLatency();
    final List<EmployeeHour> hours = _hours.where((h) => h.employeeId == employeeId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return hours;
  }

  @override
  Future<EmployeeHour> addEmployeeHour(EmployeeHour hour) async {
    await _simulateLatency();
    final DateTime now = DateTime.now();
    final EmployeeHour newHour = hour.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    _hours.add(newHour);
    return newHour;
  }

  @override
  Future<List<EmployeeHour>> getAllHours() async {
    await _simulateLatency();
    return List<EmployeeHour>.unmodifiable(_hours);
  }

  static Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 400));

  // ---------------------------------------------------------------------
  // Seed data — matches scripts/seed/seed.js exactly (same records,
  // same IDs, same dateHired/createdAt values).
  // ---------------------------------------------------------------------

  static List<Employee> _seedEmployees() {
    return [
      _seedEmployee(
        id: 'EMP001',
        name: 'John Smith',
        email: 'john.smith@assistlypro.com',
        phone: '09171234501',
        position: 'Virtual Assistant',
        hourlyRate: 180,
        status: Status.active,
        dateHired: DateTime(2026, 1, 15),
        department: 'Operations',
        supervisor: 'Robert Tan',
        assignedClientId: 'CLI001',
      ),
      _seedEmployee(
        id: 'EMP002',
        name: 'Maria Santos',
        email: 'maria.santos@assistlypro.com',
        phone: '09171234502',
        position: 'Customer Support Specialist',
        hourlyRate: 165,
        status: Status.active,
        dateHired: DateTime(2026, 1, 20),
        department: 'Human Resources',
        supervisor: 'Jane Smith',
        assignedClientId: 'CLI002',
      ),
      _seedEmployee(
        id: 'EMP003',
        name: 'Michael Reyes',
        email: 'michael.reyes@assistlypro.com',
        phone: '09171234503',
        position: 'Bookkeeper',
        hourlyRate: 200,
        status: Status.active,
        dateHired: DateTime(2026, 2, 1),
        department: 'Finance',
        supervisor: 'Robert Tan',
      ),
      _seedEmployee(
        id: 'EMP004',
        name: 'Angela Cruz',
        email: 'angela.cruz@assistlypro.com',
        phone: '09171234504',
        position: 'Social Media Manager',
        hourlyRate: 175,
        status: Status.active,
        dateHired: DateTime(2026, 2, 10),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
        assignedClientId: 'CLI003',
      ),
      _seedEmployee(
        id: 'EMP005',
        name: 'Daniel Garcia',
        email: 'daniel.garcia@assistlypro.com',
        phone: '09171234505',
        position: 'Graphic Designer',
        hourlyRate: 190,
        status: Status.active,
        dateHired: DateTime(2026, 3, 1),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
        assignedClientId: 'CLI001',
      ),
      _seedEmployee(
        id: 'EMP006',
        name: 'Patricia Lim',
        email: 'patricia.lim@assistlypro.com',
        phone: '09171234506',
        position: 'Data Entry Specialist',
        hourlyRate: 150,
        status: Status.inactive,
        dateHired: DateTime(2026, 1, 5),
        department: 'Human Resources',
        supervisor: 'Jane Smith',
      ),
      _seedEmployee(
        id: 'EMP007',
        name: 'Robert Tan',
        email: 'robert.tan@assistlypro.com',
        phone: '09171234507',
        position: 'Executive Assistant',
        hourlyRate: 210,
        status: Status.active,
        dateHired: DateTime(2026, 3, 15),
        department: 'Operations',
        supervisor: 'Jane Smith',
      ),
      _seedEmployee(
        id: 'EMP008',
        name: 'Sophia Dela Cruz',
        email: 'sophia.delacruz@assistlypro.com',
        phone: '09171234508',
        position: 'Content Writer',
        hourlyRate: 170,
        status: Status.inactive,
        dateHired: DateTime(2026, 2, 20),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
      ),
    ];
  }

  /// [dateHired] doubles as `createdAt`/`updatedAt` for seed data,
  /// matching how `seed.js` stamps its records.
  static Employee _seedEmployee({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String position,
    required double hourlyRate,
    required Status status,
    required DateTime dateHired,
    required String department,
    required String supervisor,
    String? assignedClientId,
  }) {
    return Employee(
      id: id,
      name: name,
      email: email,
      phone: phone,
      position: position,
      hourlyRate: hourlyRate,
      status: status,
      createdAt: dateHired,
      updatedAt: dateHired,
      dateHired: dateHired,
      department: department,
      supervisor: supervisor,
      assignedClientId: assignedClientId,
    );
  }

  /// Two work-weeks of weekday hours (ending just before the app's
  /// "current" demo date of July 12, 2026) for every active employee,
  /// so the Employee Details hours chart has meaningful data. A
  /// rotation offset per employee avoids every row looking identical
  /// while staying fully deterministic. Matches `seed.js`'s
  /// `WEEKDAYS`/`BASE_PATTERN`/`HOURS_ROTATIONS` exactly.
  static List<EmployeeHour> _seedHours() {
    final List<DateTime> weekdays = [
      DateTime(2026, 6, 22),
      DateTime(2026, 6, 23),
      DateTime(2026, 6, 24),
      DateTime(2026, 6, 25),
      DateTime(2026, 6, 26),
      DateTime(2026, 6, 29),
      DateTime(2026, 6, 30),
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 2),
      DateTime(2026, 7, 3),
    ];
    const List<double> basePattern = [8, 7.5, 8, 6, 8, 8, 7, 8, 8, 6.5];

    final List<EmployeeHour> hours = [];
    int counter = 1;

    void addHoursFor(String employeeId, int rotation) {
      for (int i = 0; i < weekdays.length; i++) {
        final double value = basePattern[(i + rotation) % basePattern.length];
        final DateTime workDate = weekdays[i];
        hours.add(
          EmployeeHour(
            id: 'HR${counter.toString().padLeft(3, '0')}',
            employeeId: employeeId,
            date: workDate,
            hoursWorked: value,
            createdAt: workDate,
            updatedAt: workDate,
          ),
        );
        counter++;
      }
    }

    addHoursFor('EMP001', 0);
    addHoursFor('EMP002', 2);
    addHoursFor('EMP003', 4);
    addHoursFor('EMP004', 1);
    addHoursFor('EMP005', 3);
    addHoursFor('EMP007', 5);

    return hours;
  }
}
