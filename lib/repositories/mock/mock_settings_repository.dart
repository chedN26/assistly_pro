import '../../models/business_settings.dart';
import '../settings_repository.dart';

/// In-memory [SettingsRepository] holding the single business
/// configuration document, seeded with the exact values from the DDD
/// sample document (Section 8). Replaced by a Firestore-backed
/// implementation in the Firebase phase.
class MockSettingsRepository implements SettingsRepository {
  BusinessSettings _settings = const BusinessSettings(
    companyName: 'Assistly Pro LLC',
    toolsPercentage: 10,
    miscellaneousPercentage: 3,
    ownerSharePercentage: 5,
  );

  @override
  Future<BusinessSettings> getSettings() async {
    await _simulateLatency();
    return _settings;
  }

  @override
  Future<BusinessSettings> updateSettings(BusinessSettings settings) async {
    await _simulateLatency();
    _settings = settings;
    return _settings;
  }

  static Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));
}
