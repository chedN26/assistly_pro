import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../constants/app_routes.dart';

/// Wraps every protected page (everything except Login). If the user
/// is not authenticated — including someone typing a protected URL
/// directly into the browser on Flutter Web — this redirects to Login
/// instead of rendering [child].
///
/// Used centrally by [RouteGenerator] so individual pages never need
/// to implement their own auth checks.
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AuthStatus status = context.watch<AuthProvider>().status;

    if (status == AuthStatus.authenticated) {
      return child;
    }

    // Navigator mutations aren't allowed during build, so the redirect
    // is scheduled for right after this frame finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
