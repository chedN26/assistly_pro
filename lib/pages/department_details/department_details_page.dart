import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/department_summary.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_shell.dart';

/// Department details page: department name, head, employee count,
/// then a hierarchical list of the department's employees. Tapping an
/// employee navigates to the *existing* Employee Details page — no
/// duplicate employee-details screen is created.
///
/// [departmentName] arrives via `Navigator` route arguments from the
/// department card's tap action. Departments have no ID of their own
/// (they aren't a persisted entity), so the name itself is the key.
class DepartmentDetailsPage extends StatelessWidget {
  const DepartmentDetailsPage({super.key, this.departmentName});

  final String? departmentName;

  void _viewEmployee(BuildContext context, Employee employee) {
    Navigator.of(context).pushNamed(AppRoutes.employeeDetails, arguments: employee.id);
  }

  static void _noOp() {}

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.departmentDetails,
      pageTitle: departmentName ?? AppStrings.pageTitleDepartmentDetails,
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final String? name = departmentName;
          if (name == null) {
            return const AppErrorState(message: 'No department specified.', onRetry: _noOp);
          }

          if (provider.isLoading && provider.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.employees.isEmpty) {
            return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadEmployees);
          }

          final List<Employee> departmentEmployees =
              provider.employees.where((e) => e.department == name).toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          if (departmentEmployees.isEmpty) {
            return AppErrorState(
              message: 'Department "$name" not found.',
              onRetry: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.departments);
                }
              },
            );
          }

          final DepartmentSummary department =
              DepartmentSummary(name: name, employees: departmentEmployees);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DepartmentBackButton(),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(department.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.md),
                        _DetailRow(label: 'Department Head', value: department.departmentHead),
                        _DetailRow(label: 'Employee Count', value: '${department.employeeCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Employees', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: departmentEmployees.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final Employee employee = departmentEmployees[index];
                      return ListTile(
                        leading: const Icon(Icons.subdirectory_arrow_right, color: AppColors.textSecondary),
                        title: Text(employee.name),
                        subtitle: Text(employee.position),
                        trailing: StatusBadge(status: employee.status),
                        onTap: () => _viewEmployee(context, employee),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _DepartmentBackButton extends StatelessWidget {
  const _DepartmentBackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.departments);
          }
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
    );
  }
}
