import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.employeeAddedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _openEditDialog(Employee employee) async {
    final bool? result = await EmployeeFormDialog.show(context, employee: employee);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.employeeUpdatedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  void _viewEmployee(Employee employee) {
    Navigator.of(context).pushNamed(AppRoutes.employeeDetails, arguments: employee.id);
  }

  Future<void> _deactivateEmployee(Employee employee) async {
    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: AppStrings.deactivateEmployeeTitle,
      message: 'Are you sure you want to deactivate "${employee.name}"?',
      confirmLabel: 'Deactivate',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    final EmployeeProvider provider = context.read<EmployeeProvider>();
    final bool success = await provider.deactivateEmployee(employee.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? AppStrings.employeeDeactivatedMessage : (provider.errorMessage ?? 'Failed to deactivate employee.'),
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
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
                const SizedBox(height: AppSpacing.lg),
                Expanded(child: _buildContent(provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(EmployeeProvider provider) {
    if (provider.isLoading && provider.employees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.employees.isEmpty) {
      return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadEmployees);
    }

    if (provider.employees.isEmpty) {
      return const PlaceholderPageContent(
        icon: Icons.people_outline,
        title: AppStrings.employeesEmptyMessage,
        message: 'Try adjusting your search or filters, or add a new employee.',
      );
    }

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: EmployeeTable(
            employees: provider.employees,
            onView: _viewEmployee,
            onEdit: _openEditDialog,
            onDeactivate: _deactivateEmployee,
          ),
        ),
      ),
    );
  }
}
