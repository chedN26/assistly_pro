import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/client.dart';
import '../../models/client_payment.dart';
import '../../models/status.dart';
import '../client_repository.dart';
import 'firestore_date_codec.dart';

/// Firestore implementation of [ClientRepository], backing the
/// `clients` and `client_payments` collections per the Firebase
/// Database Design Document. Mirrors
/// [FirebaseEmployeeRepository]'s structure, including
/// [FirestoreDateCodec] usage for Timestamp<->String conversion.
class FirebaseClientRepository implements ClientRepository {
  FirebaseClientRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<String> _clientDateFields = ['createdAt', 'updatedAt'];
  static const List<String> _paymentDateFields = ['paymentDate', 'createdAt', 'updatedAt'];

  CollectionReference<Map<String, dynamic>> get _clients => _firestore.collection('clients');
  CollectionReference<Map<String, dynamic>> get _clientPayments => _firestore.collection('client_payments');

  Client _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data(), _clientDateFields);
    return Client.fromMap({...decoded, 'clientId': doc.id});
  }

  ClientPayment _paymentFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data(), _paymentDateFields);
    return ClientPayment.fromMap({...decoded, 'paymentId': doc.id});
  }

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
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data()!, _clientDateFields);
    return Client.fromMap({...decoded, 'clientId': doc.id});
  }

  @override
  Future<Client> addClient(Client client) async {
    final DocumentReference<Map<String, dynamic>> docRef = _clients.doc();
    final DateTime now = DateTime.now();
    final Client newClient = client.copyWith(id: docRef.id, createdAt: now, updatedAt: now);
    await docRef.set(FirestoreDateCodec.encode(newClient.toMap(), _clientDateFields));
    return newClient;
  }

  @override
  Future<Client> updateClient(Client client) async {
    final Client updated = client.copyWith(updatedAt: DateTime.now());
    await _clients.doc(updated.id).set(FirestoreDateCodec.encode(updated.toMap(), _clientDateFields));
    return updated;
  }

  @override
  Future<Client> deactivateClient(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _clients.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Client with id "$id" not found.');
    }
    final Map<String, dynamic> decoded = FirestoreDateCodec.decode(doc.data()!, _clientDateFields);
    final Client current = Client.fromMap({...decoded, 'clientId': doc.id});
    final Client updated = current.copyWith(status: Status.inactive, updatedAt: DateTime.now());
    await _clients.doc(id).set(FirestoreDateCodec.encode(updated.toMap(), _clientDateFields));
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
    final DateTime now = DateTime.now();
    final ClientPayment newPayment = payment.copyWith(id: docRef.id, createdAt: now, updatedAt: now);
    await docRef.set(FirestoreDateCodec.encode(newPayment.toMap(), _paymentDateFields));
    return newPayment;
  }

  @override
  Future<List<ClientPayment>> getAllPayments() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _clientPayments.get();
    return snapshot.docs.map(_paymentFromDoc).toList();
  }
}
