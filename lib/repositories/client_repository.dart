import '../models/client.dart';
import '../models/client_payment.dart';
import '../models/status.dart';

/// Contract for client data access (DDD Section 6 & 7, query
/// requirements Section 13). [ClientProvider] depends on this
/// abstraction only, never on a concrete implementation.
abstract class ClientRepository {
  /// Returns clients optionally filtered by [status] (null = all)
  /// and/or matched against [searchQuery] (matched on company name).
  Future<List<Client>> getClients({Status? status, String? searchQuery});

  Future<Client?> getClientById(String id);

  Future<Client> addClient(Client client);

  Future<Client> updateClient(Client client);

  /// Sets the client's status to [Status.inactive]. Clients are
  /// deactivated, never deleted, per the UI/UX spec's "Deactivate"
  /// action.
  Future<Client> deactivateClient(String id);

  /// Payment records for a single client, sorted by date.
  Future<List<ClientPayment>> getClientPayments(String clientId);

  Future<ClientPayment> addClientPayment(ClientPayment payment);

  /// All payment records across every client, regardless of status.
  /// Needed for the dashboard's total Revenue calculation (DDD
  /// Section 10 — Dashboard Data Sources), which is not expressible
  /// through [getClientPayments] alone.
  Future<List<ClientPayment>> getAllPayments();
}
