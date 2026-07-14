import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../auth_repository.dart';

/// Mock authentication using hardcoded demo credentials
/// ([AppConstants.demoUsername] / [AppConstants.demoPassword]).
///
/// Simulates realistic network latency so the UI's loading state is
/// visibly exercised. Replaced by a Firebase-backed implementation in
/// the Firebase phase.
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login({required String username, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final bool isValid =
        username.trim() == AppConstants.demoUsername && password == AppConstants.demoPassword;

    if (isValid) {
      return const AuthResult.success();
    }
    return const AuthResult.failure(AppStrings.authInvalidCredentials);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
