import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/business_settings.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/layout/app_shell.dart';

/// Business configuration page (UI/UX spec Section 13): company name
/// and expense-percentage fields, with Save/Reset actions. Saving
/// immediately refreshes [DashboardProvider] so the dashboard's
/// figures reflect the new settings without waiting for the user to
/// navigate there first.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _toolsController = TextEditingController();
  final TextEditingController _miscController = TextEditingController();
  final TextEditingController _ownerShareController = TextEditingController();

  bool _isSaving = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final SettingsProvider provider = context.read<SettingsProvider>();
      await provider.loadSettings();
      if (!mounted) return;
      _populateControllers(provider.settings);
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _toolsController.dispose();
    _miscController.dispose();
    _ownerShareController.dispose();
    super.dispose();
  }

  void _populateControllers(BusinessSettings? settings) {
    if (settings == null) return;
    _companyNameController.text = settings.companyName;
    _toolsController.text = _formatPercentage(settings.toolsPercentage);
    _miscController.text = _formatPercentage(settings.miscellaneousPercentage);
    _ownerShareController.text = _formatPercentage(settings.ownerSharePercentage);
    setState(() => _controllersInitialized = true);
  }

  String _formatPercentage(double value) => value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();

  /// Discards any unsaved edits, reverting the fields to the last
  /// successfully saved settings (not a hardcoded default).
  void _resetFields() {
    _populateControllers(context.read<SettingsProvider>().settings);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final SettingsProvider settingsProvider = context.read<SettingsProvider>();
    final BusinessSettings updated = BusinessSettings(
      companyName: _companyNameController.text.trim(),
      toolsPercentage: double.parse(_toolsController.text.trim()),
      miscellaneousPercentage: double.parse(_miscController.text.trim()),
      ownerSharePercentage: double.parse(_ownerShareController.text.trim()),
    );

    final bool success = await settingsProvider.updateSettings(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Refresh the dashboard right away so its figures are correct
      // the instant settings change, not just the next time the
      // Dashboard page happens to remount.
      context.read<DashboardProvider>().refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.settingsSavedMessage), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settingsProvider.errorMessage ?? 'Failed to save settings.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.settings,
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.settings == null) {
            return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadSettings);
          }

          // Populate once, right when settings first become available.
          // Guarded so later rebuilds (e.g. from unrelated provider
          // notifications) never overwrite in-progress unsaved edits.
          if (!_controllersInitialized && provider.settings != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _populateControllers(provider.settings);
            });
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Business Information', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _companyNameController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(labelText: AppStrings.settingsCompanyNameLabel),
                                validator: AppValidators.required,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expense Percentages', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _toolsController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.settingsToolsPercentageLabel,
                                  suffixText: '%',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) => AppValidators.numberInRange(value, min: 0, max: 100),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _miscController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.settingsMiscellaneousPercentageLabel,
                                  suffixText: '%',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) => AppValidators.numberInRange(value, min: 0, max: 100),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _ownerShareController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.settingsOwnerSharePercentageLabel,
                                  suffixText: '%',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) => AppValidators.numberInRange(value, min: 0, max: 100),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : _resetFields,
                              child: const Text(AppStrings.resetButton),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(AppStrings.saveButton),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
