import 'package:uuid/uuid.dart';

import '../../models/employee.dart';
import '../../models/employee_hour.dart';
import '../../models/status.dart';
import '../employee_repository.dart';

/// In-memory [EmployeeRepository] used for all development phases
/// prior to Firebase integration. Seeded with realistic demo data so
/// the UI has something meaningful to display once Phases 4/5 build
/// the actual pages. Replaced by a Firestore-backed implementation in
/// the Firebase phase.
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
    final Employee newEmployee = employee.copyWith(id: _uuid.v4());
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
    _employees[index] = employee;
    return employee;
  }

  @override
  Future<Employee> deactivateEmployee(String id) async {
    await _simulateLatency();
    final int index = _employees.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw StateError('Employee with id "$id" not found.');
    }
    final Employee updated = _employees[index].copyWith(status: Status.inactive);
    _employees[index] = updated;
    return updated;
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
    final EmployeeHour newHour = hour.copyWith(id: _uuid.v4());
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
  // Seed data
  // ---------------------------------------------------------------------

  static List<Employee> _seedEmployees() {
    return [
      Employee(
        id: 'EMP001',
        name: 'John Smith',
        email: 'john.smith@assistlypro.com',
        phone: '09171234501',
        position: 'Virtual Assistant',
        hourlyRate: 180,
        status: Status.active,
        createdAt: DateTime(2026, 1, 15),
        department: 'Operations',
        supervisor: 'Robert Tan',
        assignedClientId: 'CLI001',
      ),
      Employee(
        id: 'EMP002',
        name: 'Maria Santos',
        email: 'maria.santos@assistlypro.com',
        phone: '09171234502',
        position: 'Customer Support Specialist',
        hourlyRate: 165,
        status: Status.active,
        createdAt: DateTime(2026, 1, 20),
        department: 'Human Resources',
        supervisor: 'Jane Smith',
        assignedClientId: 'CLI002',
      ),
      Employee(
        id: 'EMP003',
        name: 'Michael Reyes',
        email: 'michael.reyes@assistlypro.com',
        phone: '09171234503',
        position: 'Bookkeeper',
        hourlyRate: 200,
        status: Status.active,
        createdAt: DateTime(2026, 2, 1),
        department: 'Finance',
        supervisor: 'Robert Tan',
      ),
      Employee(
        id: 'EMP004',
        name: 'Angela Cruz',
        email: 'angela.cruz@assistlypro.com',
        phone: '09171234504',
        position: 'Social Media Manager',
        hourlyRate: 175,
        status: Status.active,
        createdAt: DateTime(2026, 2, 10),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
        assignedClientId: 'CLI003',
      ),
      Employee(
        id: 'EMP005',
        name: 'Daniel Garcia',
        email: 'daniel.garcia@assistlypro.com',
        phone: '09171234505',
        position: 'Graphic Designer',
        hourlyRate: 190,
        status: Status.active,
        createdAt: DateTime(2026, 3, 1),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
        assignedClientId: 'CLI001',
      ),
      Employee(
        id: 'EMP006',
        name: 'Patricia Lim',
        email: 'patricia.lim@assistlypro.com',
        phone: '09171234506',
        position: 'Data Entry Specialist',
        hourlyRate: 150,
        status: Status.inactive,
        createdAt: DateTime(2026, 1, 5),
        department: 'Human Resources',
        supervisor: 'Jane Smith',
      ),
      Employee(
        id: 'EMP007',
        name: 'Robert Tan',
        email: 'robert.tan@assistlypro.com',
        phone: '09171234507',
        position: 'Executive Assistant',
        hourlyRate: 210,
        status: Status.active,
        createdAt: DateTime(2026, 3, 15),
        department: 'Operations',
        supervisor: 'Jane Smith',
      ),
      Employee(
        id: 'EMP008',
        name: 'Sophia Dela Cruz',
        email: 'sophia.delacruz@assistlypro.com',
        phone: '09171234508',
        position: 'Content Writer',
        hourlyRate: 170,
        status: Status.inactive,
        createdAt: DateTime(2026, 2, 20),
        department: 'Marketing',
        supervisor: 'Kevin Lee',
      ),
    ];
  }

  /// Two work-weeks of weekday hours (ending just before the app's
  /// "current" demo date of July 12, 2026) for every active employee,
  /// so the Employee Details hours chart (Phase 5) has meaningful
  /// data. A rotation offset per employee avoids every row looking
  /// identical while staying fully deterministic.
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
        hours.add(
          EmployeeHour(
            id: 'HR${counter.toString().padLeft(3, '0')}',
            employeeId: employeeId,
            date: weekdays[i],
            hoursWorked: value,
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
