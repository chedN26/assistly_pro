import '../models/business_settings.dart';

/// Contract for business-configuration data access (DDD Section 8,
/// query requirements Section 13). Only one settings document is ever
/// expected to exist.
abstract class SettingsRepository {
  Future<BusinessSettings> getSettings();

  Future<BusinessSettings> updateSettings(BusinessSettings settings);
}
