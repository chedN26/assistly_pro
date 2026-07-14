import 'package:flutter/foundation.dart';

import '../models/business_settings.dart';
import '../repositories/settings_repository.dart';

/// Holds the single [BusinessSettings] document for the Settings page
/// (Phase 7). Depends only on [SettingsRepository].
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  BusinessSettings? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  BusinessSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
    } catch (_) {
      _errorMessage = 'Failed to load settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(BusinessSettings settings) async {
    try {
      _settings = await _repository.updateSettings(settings);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update settings.';
      notifyListeners();
      return false;
    }
  }
}
