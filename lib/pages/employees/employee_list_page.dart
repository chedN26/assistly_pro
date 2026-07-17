import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/employee.dart';
import '../../models/status.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/list_page_toolbar.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/employees/employee_form_dialog.dart';
import '../../widgets/employees/employee_table.dart';
import '../../widgets/layout/app_shell.dart';

/// Employee management page (UI/UX spec Section 9): search, status
/// filter, Add/Edit/Deactivate actions, and the employee table.
class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  Future<void> _openAddDialog() async {
    final bool? result = await EmployeeFormDialog.show(context);
    if (result == true && mounted) {
      AppSnackBar.showSuccess(context, AppStrings.employeeAddedMessage);
    }
  }

  Future<void> _openEditDialog(Employee employee) async {
    final bool? result = await EmployeeFormDialog.show(context, employee: employee);
    if (result == true && mounted) {
      AppSnackBar.showSuccess(context, AppStrings.employeeUpdatedMessage);
    }
  }

  void _viewEmployee(Employee employee) {
    Navigator.of(context).pushNamed(AppRoutes.employeeDetails, arguments: employee.id);
  }

  Future<void> _toggleEmployeeStatus(Employee employee) async {
    final bool isActivating = employee.status == Status.inactive;

    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: isActivating ? AppStrings.activateEmployeeTitle : AppStrings.deactivateEmployeeTitle,
      message: isActivating
          ? 'Activate this employee?'
          : 'Are you sure you want to deactivate "${employee.name}"?',
      confirmLabel: isActivating ? 'Activate' : 'Deactivate',
      isDanger: !isActivating,
    );
    if (!confirmed || !mounted) return;

    final EmployeeProvider provider = context.read<EmployeeProvider>();
    final bool success = isActivating
        ? await provider.activateEmployee(employee.id)
        : await provider.deactivateEmployee(employee.id);
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(
        context,
        isActivating ? AppStrings.employeeActivatedMessage : AppStrings.employeeDeactivatedMessage,
      );
    } else {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Failed to update employee status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.employees,
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListPageToolbar(
                  searchHint: AppStrings.searchEmployeesHint,
                  initialSearchValue: provider.searchQuery,
                  onSearch: provider.search,
                  statusFilter: provider.statusFilter,
                  onFilterChanged: provider.filterByStatus,
                  addButtonLabel: AppStrings.addEmployeeTitle,
                  onAddPressed: _openAddDialog,
                ),
                const SizedBox(height: AppSpacing.md),
                // Thin progress indicator during search/filter refetch,
                // separate from the full-page spinner shown only on the
                // very first load — keeps the existing table visible
                // while new results come in.
                SizedBox(
                  height: 2,
                  child: provider.isLoading && provider.employees.isNotEmpty
                      ? const LinearProgressIndicator(minHeight: 2)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildContent(provider),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(EmployeeProvider provider) {
    if (provider.isLoading && provider.employees.isEmpty) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.employees.isEmpty) {
      return AppErrorState(
        key: const ValueKey('error'),
        message: provider.errorMessage!,
        onRetry: provider.loadEmployees,
      );
    }

    if (provider.employees.isEmpty) {
      return const PlaceholderPageContent(
        key: ValueKey('empty'),
        icon: Icons.people_outline,
        title: AppStrings.employeesEmptyMessage,
        message: 'Try adjusting your search or filters, or add a new employee.',
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('content'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: EmployeeTable(
            employees: provider.employees,
            onView: _viewEmployee,
            onEdit: _openEditDialog,
            onToggleStatus: _toggleEmployeeStatus,
          ),
        ),
      ),
    );
  }
}
