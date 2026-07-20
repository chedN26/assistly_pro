import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/operating_expense_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/layout/app_shell.dart';

/// Business configuration page: monthly Tools/Miscellaneous expense
/// entry (one record per month), replacing the old percentage-based
/// settings entirely. Owner Share is now a fixed 5% (see
/// `DashboardCalculator`) and is shown here only as an informational
/// note, not an editable field — and Company Name has no equivalent
/// in the new schema (it was confirmed unused anywhere else in the
/// app before being dropped). Saving immediately refreshes
/// [DashboardProvider] so figures reflect the change without waiting
/// for the user to navigate there first.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _toolsController = TextEditingController();
  final TextEditingController _miscController = TextEditingController();

  bool _isSaving = false;

  /// Which month's data the text fields currently reflect — compared
  /// against the provider's selected month each build so switching
  /// months (or the initial load completing) repopulates the fields,
  /// without wiping out in-progress edits for the month already shown.
  String? _populatedForMonth;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OperatingExpenseProvider>().loadExpenseForSelectedMonth();
    });
  }

  @override
  void dispose() {
    _toolsController.dispose();
    _miscController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) => value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();

  String _monthLabel(String monthKey) {
    final List<String> parts = monthKey.split('-');
    final int year = int.parse(parts[0]);
    final int month = int.parse(parts[1]);
    return '${_monthNames[month - 1]} $year';
  }

  void _populateControllers(OperatingExpenseProvider provider) {
    _toolsController.text = provider.expense != null ? _formatAmount(provider.expense!.toolsExpense) : '';
    _miscController.text =
        provider.expense != null ? _formatAmount(provider.expense!.miscellaneousExpense) : '';
    _populatedForMonth = provider.selectedMonth;
  }

  /// Discards any unsaved edits, reverting the fields to the last
  /// saved values for the currently-selected month (not a hardcoded
  /// default) — empty if that month has no record yet.
  void _resetFields(OperatingExpenseProvider provider) {
    setState(() => _populateControllers(provider));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final OperatingExpenseProvider provider = context.read<OperatingExpenseProvider>();
    final bool success = await provider.saveExpense(
      toolsExpense: double.parse(_toolsController.text.trim()),
      miscellaneousExpense: double.parse(_miscController.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Refresh the dashboard right away so its figures are correct
      // the instant expenses change, not just the next time the
      // Dashboard page happens to remount.
      context.read<DashboardProvider>().refresh();
      AppSnackBar.showSuccess(context, AppStrings.settingsSavedMessage);
    } else {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Failed to save operating expenses.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.settings,
      body: Consumer<OperatingExpenseProvider>(
        builder: (context, provider, _) {
          if (!provider.hasLoadedOnce && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasLoadedOnce) {
            return AppErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadExpenseForSelectedMonth,
            );
          }

          if (_populatedForMonth != provider.selectedMonth) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _populateControllers(provider));
            });
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Operating Expenses', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.md),
                              DropdownButtonFormField<String>(
                                value: provider.selectedMonth,
                                decoration: const InputDecoration(labelText: AppStrings.settingsMonthLabel),
                                items: [
                                  for (final String month in OperatingExpenseProvider.recentMonths())
                                    DropdownMenuItem(value: month, child: Text(_monthLabel(month))),
                                ],
                                onChanged: _isSaving
                                    ? null
                                    : (value) {
                                        if (value != null) provider.selectMonth(value);
                                      },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _toolsController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.settingsToolsExpenseLabel,
                                  prefixText: '₱ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: AppValidators.nonNegativeNumber,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _miscController,
                                enabled: !_isSaving,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.settingsMiscellaneousExpenseLabel,
                                  prefixText: '₱ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: AppValidators.nonNegativeNumber,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Owner Share is fixed at 5% of the remaining balance after all '
                                'expenses — it is not user-configurable.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : () => _resetFields(provider),
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
