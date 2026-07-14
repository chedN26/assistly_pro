import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../models/client_payment.dart';
import '../models/status.dart';
import '../repositories/client_repository.dart';

/// Holds client list state (with search/filter), CRUD operations, and
/// per-client payment records for the Client List and Client Details
/// pages (Phase 6). Depends only on [ClientRepository] — never talks
/// to Firestore or the mock data directly.
class ClientProvider extends ChangeNotifier {
  ClientProvider(this._repository);

  final ClientRepository _repository;

  List<Client> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;
  Status? _statusFilter;
  String _searchQuery = '';

  final Map<String, List<ClientPayment>> _paymentsByClientId = {};
  bool _isLoadingPayments = false;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Status? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  bool get isLoadingPayments => _isLoadingPayments;

  /// Loads clients using the current [statusFilter]/[searchQuery].
  /// Called on initial page load and after any CRUD operation so the
  /// list stays in sync with the repository.
  Future<void> loadClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clients = await _repository.getClients(
        status: _statusFilter,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (_) {
      _errorMessage = 'Failed to load clients.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    await loadClients();
  }

  Future<void> filterByStatus(Status? status) async {
    _statusFilter = status;
    await loadClients();
  }

  /// Looks up an already-loaded client from the current list
  /// (synchronous, no repository call). Returns null if not present
  /// in the currently loaded/filtered list — use [fetchById] when the
  /// client may not be in the list (e.g. deep-linked details page).
  Client? getById(String id) {
    for (final Client client in _clients) {
      if (client.id == id) return client;
    }
    return null;
  }

  Future<Client?> fetchById(String id) => _repository.getClientById(id);

  Future<bool> addClient(Client client) async {
    try {
      await _repository.addClient(client);
      await loadClients();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add client.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    try {
      await _repository.updateClient(client);
      await loadClients();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update client.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateClient(String id) async {
    try {
      await _repository.deactivateClient(id);
      await loadClients();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to deactivate client.';
      notifyListeners();
      return false;
    }
  }

  List<ClientPayment> paymentsFor(String clientId) => _paymentsByClientId[clientId] ?? const [];

  Future<void> loadPayments(String clientId) async {
    _isLoadingPayments = true;
    notifyListeners();

    try {
      _paymentsByClientId[clientId] = await _repository.getClientPayments(clientId);
    } catch (_) {
      _errorMessage = 'Failed to load payment history.';
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment(ClientPayment payment) async {
    try {
      await _repository.addClientPayment(payment);
      await loadPayments(payment.clientId);
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add payment.';
      notifyListeners();
      return false;
    }
  }
}
