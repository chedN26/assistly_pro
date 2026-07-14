import 'package:uuid/uuid.dart';

import '../../models/client.dart';
import '../../models/client_payment.dart';
import '../../models/status.dart';
import '../client_repository.dart';

/// In-memory [ClientRepository] used for all development phases prior
/// to Firebase integration. Seeded with realistic demo data. Replaced
/// by a Firestore-backed implementation in the Firebase phase.
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
    final Client newClient = client.copyWith(id: _uuid.v4());
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
    _clients[index] = client;
    return client;
  }

  @override
  Future<Client> deactivateClient(String id) async {
    await _simulateLatency();
    final int index = _clients.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw StateError('Client with id "$id" not found.');
    }
    final Client updated = _clients[index].copyWith(status: Status.inactive);
    _clients[index] = updated;
    return updated;
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
    final ClientPayment newPayment = payment.copyWith(id: _uuid.v4());
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
  // Seed data
  // ---------------------------------------------------------------------

  static List<Client> _seedClients() {
    return [
      Client(
        id: 'CLI001',
        companyName: 'ABC Retail Corp',
        contactPerson: 'Michael Cruz',
        email: 'abc@retailcorp.com',
        phone: '09221234501',
        monthlyPayment: 50000,
        status: Status.active,
        createdAt: DateTime(2026, 1, 10),
      ),
      Client(
        id: 'CLI002',
        companyName: 'Bright Ideas Marketing',
        contactPerson: 'Jenny Uy',
        email: 'jenny@brightideas.com',
        phone: '09221234502',
        monthlyPayment: 35000,
        status: Status.active,
        createdAt: DateTime(2026, 1, 25),
      ),
      Client(
        id: 'CLI003',
        companyName: 'Solid Rock Realty',
        contactPerson: 'Mark Villanueva',
        email: 'mark@solidrockrealty.com',
        phone: '09221234503',
        monthlyPayment: 42000,
        status: Status.active,
        createdAt: DateTime(2026, 2, 5),
      ),
      Client(
        id: 'CLI004',
        companyName: 'Fresh Bites Café',
        contactPerson: 'Karen Ong',
        email: 'karen@freshbites.com',
        phone: '09221234504',
        monthlyPayment: 28000,
        status: Status.inactive,
        createdAt: DateTime(2026, 1, 5),
      ),
      Client(
        id: 'CLI005',
        companyName: 'Nova Tech Solutions',
        contactPerson: 'Paul Mendoza',
        email: 'paul@novatech.com',
        phone: '09221234505',
        monthlyPayment: 60000,
        status: Status.active,
        createdAt: DateTime(2026, 3, 1),
      ),
      Client(
        id: 'CLI006',
        companyName: 'Golden Gate Logistics',
        contactPerson: 'Ella Ramos',
        email: 'ella@goldengate.com',
        phone: '09221234506',
        monthlyPayment: 45000,
        status: Status.inactive,
        createdAt: DateTime(2026, 2, 15),
      ),
    ];
  }

  /// Three months of payment history (May–July 2026) for every active
  /// client, matching their agreed monthlyPayment amount, so the
  /// Client Details revenue chart (Phase 6) has meaningful data.
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
