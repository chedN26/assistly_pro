import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/client.dart';
import '../../models/client_payment.dart';
import '../../models/status.dart';
import '../client_repository.dart';

/// Firestore implementation of [ClientRepository], backing the
/// `clients` and `client_payments` collections (DDD Sections 6 & 7).
/// Mirrors [FirebaseEmployeeRepository]'s structure.
class FirebaseClientRepository implements ClientRepository {
  FirebaseClientRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clients => _firestore.collection('clients');
  CollectionReference<Map<String, dynamic>> get _clientPayments => _firestore.collection('client_payments');

  Client _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) => Client.fromMap({...doc.data(), 'id': doc.id});

  ClientPayment _paymentFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      ClientPayment.fromMap({...doc.data(), 'id': doc.id});

  @override
  Future<List<Client>> getClients({Status? status, String? searchQuery}) async {
    Query<Map<String, dynamic>> query = _clients;
    if (status != null) {
      query = query.where('status', isEqualTo: status.label);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    Iterable<Client> clients = snapshot.docs.map(_fromDoc);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final String query2 = searchQuery.trim().toLowerCase();
      clients = clients.where((c) => c.companyName.toLowerCase().contains(query2));
    }

    return clients.toList()..sort((a, b) => a.companyName.compareTo(b.companyName));
  }

  @override
  Future<Client?> getClientById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _clients.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Client.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<Client> addClient(Client client) async {
    final DocumentReference<Map<String, dynamic>> docRef = _clients.doc();
    final Client newClient = client.copyWith(id: docRef.id);
    await docRef.set(newClient.toMap());
    return newClient;
  }

  @override
  Future<Client> updateClient(Client client) async {
    await _clients.doc(client.id).set(client.toMap());
    return client;
  }

  @override
  Future<Client> deactivateClient(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _clients.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Client with id "$id" not found.');
    }
    final Client current = Client.fromMap({...doc.data()!, 'id': doc.id});
    final Client updated = current.copyWith(status: Status.inactive);
    await _clients.doc(id).set(updated.toMap());
    return updated;
  }

  @override
  Future<List<ClientPayment>> getClientPayments(String clientId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _clientPayments.where('clientId', isEqualTo: clientId).get();
    final List<ClientPayment> payments = snapshot.docs.map(_paymentFromDoc).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return payments;
  }

  @override
  Future<ClientPayment> addClientPayment(ClientPayment payment) async {
    final DocumentReference<Map<String, dynamic>> docRef = _clientPayments.doc();
    final ClientPayment newPayment = payment.copyWith(id: docRef.id);
    await docRef.set(newPayment.toMap());
    return newPayment;
  }

  @override
  Future<List<ClientPayment>> getAllPayments() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _clientPayments.get();
    return snapshot.docs.map(_paymentFromDoc).toList();
  }
}
