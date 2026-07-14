import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee_hour.dart';
import '../../providers/employee_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';

/// Add Hours dialog (UI/UX spec Section 10/15). Validation:
/// Date required, Hours Worked between 0 and 24 (DDD Section 12).
class AddHoursDialog extends StatefulWidget {
  const AddHoursDialog({super.key, required this.employeeId});

  final String employeeId;

  /// Shows the dialog and returns `true` if hours were successfully
  /// added, `false`/`null` otherwise.
  static Future<bool?> show(BuildContext context, {required String employeeId}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AddHoursDialog(employeeId: employeeId),
    );
  }

  @override
  State<AddHoursDialog> createState() => _AddHoursDialogState();
}

class _AddHoursDialogState extends State<AddHoursDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hoursController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _submitAttempted = false;

  @override
  void dispose() {
    _hoursController.dispose();
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

    final EmployeeProvider provider = context.read<EmployeeProvider>();
    final EmployeeHour hour = EmployeeHour(
      id: '', // Repository assigns the real ID; placeholder here is discarded.
      employeeId: widget.employeeId,
      date: _selectedDate!,
      hoursWorked: double.parse(_hoursController.text.trim()),
    );
    final bool success = await provider.addHour(hour);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to add work hours.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addHoursTitle),
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
                controller: _hoursController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(labelText: AppStrings.employeeHoursWorkedLabel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => AppValidators.numberInRange(
                  value,
                  min: 0,
                  max: 24,
                  message: 'Hours must be between 0 and 24.',
                ),
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
