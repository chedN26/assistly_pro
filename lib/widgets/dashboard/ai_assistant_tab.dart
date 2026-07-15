import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';

/// Tab 3 — AI Assistant: a single large card with a "Generate AI
/// Recommendation" button. Calls [DashboardProvider.generateAIRecommendation],
/// which delegates to [AIService] — currently always the mock
/// fallback, since no real LLM API is integrated yet (by design; see
/// AIService's doc comment).
class AiAssistantTab extends StatelessWidget {
  const AiAssistantTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_outlined, color: AppColors.primary, size: 28),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text('AI Business Assistant', style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Generate a quick AI-assisted summary and recommendations based on '
                        'your current business data.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: provider.isGeneratingRecommendation ? null : provider.generateAIRecommendation,
                        icon: provider.isGeneratingRecommendation
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.psychology_outlined),
                        label: const Text('Generate AI Recommendation'),
                      ),
                      if (provider.aiRecommendation != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          provider.aiRecommendation!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
