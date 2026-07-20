import 'package:uuid/uuid.dart';

import '../../models/client.dart';
import '../../models/client_payment.dart';
import '../../models/status.dart';
import '../client_repository.dart';

/// In-memory [ClientRepository]. Seeded with the same demo data as
/// `scripts/seed/seed.js`, so Mock and Firebase modes show identical
/// records when freshly seeded.
class MockClientRepository implements ClientRepository {
  MockClientRepository()
      : _clients = _seedClients(),
        _payments = _seedPayments();

  final List<Client> _clients;
  final List<ClientPayment> _payments;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Client>> getClients({Status? status, String? searchQuery}) async {
    await _simulateLatency();

    Iterable<Client> result = _clients;
    if (status != null) {
      result = result.where((c) => c.status == status);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final String query = searchQuery.trim().toLowerCase();
      result = result.where((c) => c.companyName.toLowerCase().contains(query));
    }

    return result.toList()..sort((a, b) => a.companyName.compareTo(b.companyName));
  }

  @override
  Future<Client?> getClientById(String id) async {
    await _simulateLatency();
    for (final Client client in _clients) {
      if (client.id == id) return client;
    }
    return null;
  }

  @override
  Future<Client> addClient(Client client) async {
    await _simulateLatency();
    final DateTime now = DateTime.now();
    final Client newClient = client.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    _clients.add(newClient);
    return newClient;
  }

  @override
  Future<Client> updateClient(Client client) async {
    await _simulateLatency();
    final int index = _clients.indexWhere((c) => c.id == client.id);
    if (index == -1) {
      throw StateError('Client with id "${client.id}" not found.');
    }
    final Client updated = client.copyWith(updatedAt: DateTime.now());
    _clients[index] = updated;
    return updated;
  }

  @override
  Future<Client> deactivateClient(String id) async {
    await _simulateLatency();
    final int index = _clients.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw StateError('Client with id "$id" not found.');
    }
    final Client updated = _clients[index].copyWith(status: Status.inactive, updatedAt: DateTime.now());
    _clients[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteClient(String id) async {
    await _simulateLatency();
    _clients.removeWhere((c) => c.id == id);
    _payments.removeWhere((p) => p.clientId == id);
  }

  @override
  Future<List<ClientPayment>> getClientPayments(String clientId) async {
    await _simulateLatency();
    final List<ClientPayment> payments = _payments.where((p) => p.clientId == clientId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return payments;
  }

  @override
  Future<ClientPayment> addClientPayment(ClientPayment payment) async {
    await _simulateLatency();
    final DateTime now = DateTime.now();
    final ClientPayment newPayment = payment.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    _payments.add(newPayment);
    return newPayment;
  }

  @override
  Future<List<ClientPayment>> getAllPayments() async {
    await _simulateLatency();
    return List<ClientPayment>.unmodifiable(_payments);
  }

  static Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 400));

  // ---------------------------------------------------------------------
  // Seed data — matches scripts/seed/seed.js exactly.
  // ---------------------------------------------------------------------

  static List<Client> _seedClients() {
    return [
      _seedClient(
        id: 'CLI001',
        companyName: 'ABC Retail Corp',
        contactPerson: 'Michael Cruz',
        email: 'abc@retailcorp.com',
        phone: '09221234501',
        serviceType: 'Full-Service Virtual Assistance',
        status: Status.active,
        createdAt: DateTime(2026, 1, 10),
      ),
      _seedClient(
        id: 'CLI002',
        companyName: 'Bright Ideas Marketing',
        contactPerson: 'Jenny Uy',
        email: 'jenny@brightideas.com',
        phone: '09221234502',
        serviceType: 'Social Media Management',
        status: Status.active,
        createdAt: DateTime(2026, 1, 25),
      ),
      _seedClient(
        id: 'CLI003',
        companyName: 'Solid Rock Realty',
        contactPerson: 'Mark Villanueva',
        email: 'mark@solidrockrealty.com',
        phone: '09221234503',
        serviceType: 'Administrative Support',
        status: Status.active,
        createdAt: DateTime(2026, 2, 5),
      ),
      _seedClient(
        id: 'CLI004',
        companyName: 'Fresh Bites Café',
        contactPerson: 'Karen Ong',
        email: 'karen@freshbites.com',
        phone: '09221234504',
        serviceType: 'Bookkeeping Services',
        status: Status.inactive,
        createdAt: DateTime(2026, 1, 5),
      ),
      _seedClient(
        id: 'CLI005',
        companyName: 'Nova Tech Solutions',
        contactPerson: 'Paul Mendoza',
        email: 'paul@novatech.com',
        phone: '09221234505',
        serviceType: 'Full-Service Virtual Assistance',
        status: Status.active,
        createdAt: DateTime(2026, 3, 1),
      ),
      _seedClient(
        id: 'CLI006',
        companyName: 'Golden Gate Logistics',
        contactPerson: 'Ella Ramos',
        email: 'ella@goldengate.com',
        phone: '09221234506',
        serviceType: 'Customer Support Outsourcing',
        status: Status.inactive,
        createdAt: DateTime(2026, 2, 15),
      ),
    ];
  }

  static Client _seedClient({
    required String id,
    required String companyName,
    required String contactPerson,
    required String email,
    required String phone,
    required String serviceType,
    required Status status,
    required DateTime createdAt,
  }) {
    return Client(
      id: id,
      companyName: companyName,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      serviceType: serviceType,
      status: status,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  /// Three months of payment history (May–July 2026) for every client
  /// that was active at seed time, matching `seed.js`'s
  /// `PAYMENT_AMOUNTS` exactly (these amounts previously mirrored
  /// each client's now-removed `monthlyPayment` field — kept
  /// unchanged since Revenue is computed from these actual payments,
  /// never from `monthlyPayment`).
  static List<ClientPayment> _seedPayments() {
    final List<DateTime> paymentDates = [
      DateTime(2026, 5, 1),
      DateTime(2026, 6, 1),
      DateTime(2026, 7, 1),
    ];

    final List<ClientPayment> payments = [];
    int counter = 1;

    void addPaymentsFor(String clientId, double amount) {
      for (final DateTime date in paymentDates) {
        payments.add(
          ClientPayment(
            id: 'PAY${counter.toString().padLeft(3, '0')}',
            clientId: clientId,
            date: date,
            amount: amount,
            createdAt: date,
            updatedAt: date,
          ),
        );
        counter++;
      }
    }

    addPaymentsFor('CLI001', 50000);
    addPaymentsFor('CLI002', 35000);
    addPaymentsFor('CLI003', 42000);
    addPaymentsFor('CLI005', 60000);

    return payments;
  }
}
