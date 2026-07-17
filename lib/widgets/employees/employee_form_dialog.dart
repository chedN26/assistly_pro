import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../models/employee.dart';
import '../../models/status.dart';
import '../../providers/client_provider.dart';
import '../../providers/employee_provider.dart';
import '../../utils/validators.dart';
import '../common/app_snackbar.dart';

/// Add/Edit Employee dialog (UI/UX spec Section 15). A single widget
/// handles both modes — [employee] is null for Add, non-null for
/// Edit — since the fields are identical, avoiding duplicated form
/// code. Status is intentionally not editable here: new employees are
/// always Active, and status only changes via the separate
/// Activate/Deactivate action per the UI/UX spec's action list.
///
/// Includes Department, Supervisor (free text), and Assigned Client
/// (a dropdown of existing clients, sourced from [ClientProvider] —
/// a read-only cross-module dependency, not a modification of the
/// Client module itself).
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
  late final TextEditingController _departmentController;
  late final TextEditingController _supervisorController;
  String? _assignedClientId;
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
    _departmentController = TextEditingController(text: e?.department ?? '');
    _supervisorController = TextEditingController(text: e?.supervisor ?? '');
    _assignedClientId = e?.assignedClientId;

    // Ensure the Assigned Client dropdown has data even if the Client
    // list page was never visited this session.
    Future.microtask(() {
      if (!mounted) return;
      final ClientProvider clientProvider = context.read<ClientProvider>();
      if (clientProvider.clients.isEmpty) {
        clientProvider.loadClients();
      }
    });
  }

  String _formatRate(double rate) => rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _hourlyRateController.dispose();
    _departmentController.dispose();
    _supervisorController.dispose();
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
        department: _departmentController.text.trim(),
        supervisor: _supervisorController.text.trim(),
        assignedClientId: _assignedClientId,
        clearAssignedClientId: _assignedClientId == null,
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
        department: _departmentController.text.trim(),
        supervisor: _supervisorController.text.trim(),
        assignedClientId: _assignedClientId,
      );
      success = await provider.addEmployee(newEmployee);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String?>> clientItems = [
      const DropdownMenuItem<String?>(value: null, child: Text(AppStrings.employeeAssignedClientNone)),
      for (final client in context.watch<ClientProvider>().clients)
        DropdownMenuItem<String?>(value: client.id, child: Text(client.companyName)),
    ];

    // If the previously-assigned client is no longer in the loaded
    // list (e.g. not yet fetched), keep its id selected but fall back
    // to null in the dropdown's displayed value to avoid a Flutter
    // assertion about a value with no matching item.
    final bool selectedClientStillListed =
        clientItems.any((item) => item.value == _assignedClientId);

    return AlertDialog(
      title: Text(widget.isEditMode ? AppStrings.editEmployeeTitle : AppStrings.addEmployeeTitle),
      content: SizedBox(
        width: ResponsiveHelper.dialogContentWidth(context, preferred: 440),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _departmentController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeeDepartmentLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _supervisorController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(labelText: AppStrings.employeeSupervisorLabel),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String?>(
                  initialValue: selectedClientStillListed ? _assignedClientId : null,
                  decoration: const InputDecoration(labelText: AppStrings.employeeAssignedClientLabel),
                  items: clientItems,
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() => _assignedClientId = value),
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
