import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/auth/demo_credentials_banner.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/navigation/app_logo.dart';

/// Standalone authentication screen (UI/UX spec Section 7 — Login Page).
///
/// Does not use [AppShell] since the login screen has no sidebar/top
/// bar. Composed of reusable widgets: [LoginForm] (fields, validation,
/// submit) and [DemoCredentialsBanner] (grading convenience).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(iconSize: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const LoginForm(),
                    const SizedBox(height: AppSpacing.lg),
                    const DemoCredentialsBanner(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
