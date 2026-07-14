import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/client_payment.dart';
import '../../providers/client_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';

/// Add Payment dialog (UI/UX spec Section 12/15). Validation: Date
/// required, Amount > 0 (DDD Section 12).
class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key, required this.clientId});

  final String clientId;

  /// Shows the dialog and returns `true` if the payment was
  /// successfully added, `false`/`null` otherwise.
  static Future<bool?> show(BuildContext context, {required String clientId}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AddPaymentDialog(clientId: clientId),
    );
  }

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _submitAttempted = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitAttempted = true);

    final bool isFormValid = _formKey.currentState!.validate();
    if (!isFormValid || _selectedDate == null) return;

    setState(() => _isSubmitting = true);

    final ClientProvider provider = context.read<ClientProvider>();
    final ClientPayment payment = ClientPayment(
      id: '', // Repository assigns the real ID; placeholder here is discarded.
      clientId: widget.clientId,
      date: _selectedDate!,
      amount: double.parse(_amountController.text.trim()),
    );
    final bool success = await provider.addPayment(payment);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to add payment.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addPaymentTitle),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _isSubmitting ? null : _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppStrings.dateLabel,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    errorText: _submitAttempted && _selectedDate == null ? 'Date is required.' : null,
                  ),
                  child: Text(
                    _selectedDate == null ? 'Select a date' : AppFormatters.date(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: AppStrings.clientPaymentAmountLabel,
                  prefixText: '₱ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: AppValidators.positiveNumber,
              ),
            ],
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
              : const Text(AppStrings.addButton),
        ),
      ],
    );
  }
}
