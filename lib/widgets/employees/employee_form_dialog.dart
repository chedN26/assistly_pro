import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee.dart';
import '../../models/status.dart';
import '../../providers/employee_provider.dart';
import '../../utils/validators.dart';

/// Add/Edit Employee dialog (UI/UX spec Section 15). A single widget
/// handles both modes — [employee] is null for Add, non-null for
/// Edit — since the fields are identical, avoiding duplicated form
/// code. Status is intentionally not editable here: new employees are
/// always Active, and status only changes via the separate Deactivate
/// action per the UI/UX spec's action list.
class EmployeeFormDialog extends StatefulWidget {
  const EmployeeFormDialog({super.key, this.employee});

  final Employee? employee;

  bool get isEditMode => employee != null;

  /// Shows the dialog and returns `true` if the employee was
  /// successfully added/updated, `false`/`null` otherwise.
  static Future<bool?> show(BuildContext context, {Employee? employee}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => EmployeeFormDialog(employee: employee),
    );
  }

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _positionController;
  late final TextEditingController _hourlyRateController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final Employee? e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _positionController = TextEditingController(text: e?.position ?? '');
    _hourlyRateController = TextEditingController(text: e != null ? _formatRate(e.hourlyRate) : '');
  }

  String _formatRate(double rate) => rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final EmployeeProvider provider = context.read<EmployeeProvider>();
    final double hourlyRate = double.parse(_hourlyRateController.text.trim());
    bool success;

    if (widget.isEditMode) {
      final Employee updated = widget.employee!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        position: _positionController.text.trim(),
        hourlyRate: hourlyRate,
      );
      success = await provider.updateEmployee(updated);
    } else {
      final Employee newEmployee = Employee(
        id: '', // Repository assigns the real ID; placeholder here is discarded.
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        position: _positionController.text.trim(),
        hourlyRate: hourlyRate,
        status: Status.active,
        createdAt: DateTime.now(),
      );
      success = await provider.addEmployee(newEmployee);
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
      title: Text(widget.isEditMode ? AppStrings.editEmployeeTitle : AppStrings.addEmployeeTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeeNameLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeeEmailLabel),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeePhoneLabel),
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _positionController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeePositionLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _hourlyRateController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: AppStrings.employeeHourlyRateLabel,
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
