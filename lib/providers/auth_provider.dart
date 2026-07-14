import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

/// UI-facing authentication state. [AuthResult] (from the repository)
/// is intentionally not exposed to widgets — this enum plus
/// [AuthProvider.errorMessage] is the only thing pages read.
enum AuthStatus { unauthenticated, authenticating, authenticated }

/// Holds the app's authentication session for the lifetime of the running
/// app instance (in-memory — a full page reload returns to the Login
/// screen, which is acceptable for this prototype since no persistence
/// package is in scope). Every protected page and the sidebar depend on
/// this provider rather than talking to [AuthRepository] directly.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  String? _username;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get username => _username;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> login({required String username, required String password}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final AuthResult result = await _authRepository.login(username: username, password: password);

    if (result.isSuccess) {
      _status = AuthStatus.authenticated;
      _username = username.trim();
      _errorMessage = null;
    } else {
      _status = AuthStatus.unauthenticated;
      _username = null;
      _errorMessage = result.errorMessage;
    }

    notifyListeners();
    return result.isSuccess;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _status = AuthStatus.unauthenticated;
    _username = null;
    _errorMessage = null;
    notifyListeners();
  }
}
