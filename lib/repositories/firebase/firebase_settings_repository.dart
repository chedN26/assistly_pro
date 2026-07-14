import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/business_settings.dart';
import '../settings_repository.dart';

/// Firestore implementation of [SettingsRepository], backing the
/// single `settings/default` document (DDD Section 8).
class FirebaseSettingsRepository implements SettingsRepository {
  FirebaseSettingsRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore.collection('settings').doc('default');

  /// Matches the DDD Section 8 sample document — used to self-seed a
  /// fresh Firebase project on first read, so Settings/Dashboard work
  /// immediately without requiring manual console setup first.
  static const BusinessSettings _defaults = BusinessSettings(
    companyName: 'Assistly Pro LLC',
    toolsPercentage: 10,
    miscellaneousPercentage: 3,
    ownerSharePercentage: 5,
  );

  @override
  Future<BusinessSettings> getSettings() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _settingsDoc.get();
    if (doc.exists && doc.data() != null) {
      return BusinessSettings.fromMap(doc.data()!);
    }

    await _settingsDoc.set(_defaults.toMap());
    return _defaults;
  }

  @override
  Future<BusinessSettings> updateSettings(BusinessSettings settings) async {
    await _settingsDoc.set(settings.toMap());
    return settings;
  }
}
