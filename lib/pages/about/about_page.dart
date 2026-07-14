import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_shell.dart';
import '../../widgets/navigation/app_logo.dart';

/// Application information page (UI/UX spec Section 14): logo,
/// application name, description, technologies used, developers, and
/// version. Static content — no provider needed.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<String> _technologies = [
    'Flutter (Web & Android)',
    'Dart',
    'Provider (state management)',
    'Cloud Firestore (planned — currently Mock Repositories)',
    'fl_chart',
    'Material Design 3',
  ];

  static const List<String> _developers = [
    '[Your Name]',
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.about,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(iconSize: 48)),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _Section(
                  title: 'Description',
                  child: Text(
                    'Assistly Pro is a workforce and client operations dashboard built as a '
                    'prototype for the Application Development and Emerging Technologies course. '
                    'It manages employees, work hours, clients, and payments, and computes '
                    'business financials (revenue, expenses, owner share, and net profit) from '
                    'that data in real time.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: 'Technologies Used',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final String tech in _technologies)
                        Chip(
                          label: Text(tech),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: 'Developers',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final String developer in _developers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(developer, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: 'Version',
                  child: Text('0.1.0 (Prototype)', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
