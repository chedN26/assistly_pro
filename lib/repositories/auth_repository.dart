/// Result of an authentication attempt. Kept as a plain value object
/// (rather than throwing exceptions) so [AuthProvider] can translate
/// failures into user-facing messages without try/catch noise.
class AuthResult {
  const AuthResult.success() : isSuccess = true, errorMessage = null;

  const AuthResult.failure(this.errorMessage) : isSuccess = false;

  final bool isSuccess;
  final String? errorMessage;
}

/// Contract for authentication data access. [AuthProvider] depends on
/// this abstraction only — never on a concrete implementation — so the
/// Firebase phase can swap [MockAuthRepository] for a Firebase-backed
/// implementation without touching the Provider or UI layers.
abstract class AuthRepository {
  Future<AuthResult> login({required String username, required String password});

  Future<void> logout();
}
