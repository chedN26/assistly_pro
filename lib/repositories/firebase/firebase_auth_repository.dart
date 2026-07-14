import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_strings.dart';
import '../auth_repository.dart';

/// Firebase Authentication implementation of [AuthRepository].
///
/// The "username" field is treated as the manager's email address —
/// [FirebaseAuth] requires email/password sign-in. This is a data
/// contract change only; [AuthProvider] and the Login form are
/// completely unaware of it since they only ever call [login] with a
/// username/password pair, exactly as they did against
/// [MockAuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthResult> login({required String username, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: username.trim(), password: password);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_messageFor(e));
    } catch (_) {
      return const AuthResult.failure('Unable to sign in. Please try again.');
    }
  }

  @override
  Future<void> logout() => _firebaseAuth.signOut();

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.authInvalidCredentials;
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Unable to sign in. Please try again.';
    }
  }
}
