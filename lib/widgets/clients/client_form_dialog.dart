import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/client.dart';
import '../../models/status.dart';
import '../../providers/client_provider.dart';
import '../../utils/validators.dart';

/// Add/Edit Client dialog (UI/UX spec Section 15). A single widget
/// handles both modes — [client] is null for Add, non-null for Edit.
/// Status is not editable here: new clients are always Active, and
/// status only changes via the separate Deactivate action.
class ClientFormDialog extends StatefulWidget {
  const ClientFormDialog({super.key, this.client});

  final Client? client;

  bool get isEditMode => client != null;

  /// Shows the dialog and returns `true` if the client was
  /// successfully added/updated, `false`/`null` otherwise.
  static Future<bool?> show(BuildContext context, {Client? client}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ClientFormDialog(client: client),
    );
  }

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyNameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _monthlyPaymentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final Client? c = widget.client;
    _companyNameController = TextEditingController(text: c?.companyName ?? '');
    _contactPersonController = TextEditingController(text: c?.contactPerson ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _monthlyPaymentController = TextEditingController(text: c != null ? _formatAmount(c.monthlyPayment) : '');
  }

  String _formatAmount(double amount) => amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toString();

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _monthlyPaymentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final ClientProvider provider = context.read<ClientProvider>();
    final double monthlyPayment = double.parse(_monthlyPaymentController.text.trim());
    bool success;

    if (widget.isEditMode) {
      final Client updated = widget.client!.copyWith(
        companyName: _companyNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        monthlyPayment: monthlyPayment,
      );
      success = await provider.updateClient(updated);
    } else {
      final Client newClient = Client(
        id: '', // Repository assigns the real ID; placeholder here is discarded.
        companyName: _companyNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        monthlyPayment: monthlyPayment,
        status: Status.active,
        createdAt: DateTime.now(),
      );
      success = await provider.addClient(newClient);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditMode ? AppStrings.editClientTitle : AppStrings.addClientTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _companyNameController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.clientCompanyNameLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _contactPersonController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.clientContactPersonLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.clientEmailLabel),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.clientPhoneLabel),
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _monthlyPaymentController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: AppStrings.clientMonthlyPaymentLabel,
                    prefixText: '₱ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: AppValidators.positiveNumber,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelButton),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(widget.isEditMode ? AppStrings.saveButton : AppStrings.addButton),
        ),
      ],
    );
  }
}
