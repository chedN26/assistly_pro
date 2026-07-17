import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../models/department_summary.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/departments/department_card.dart';
import '../../widgets/layout/app_shell.dart';

/// Departments page: displays all company departments, generated
/// dynamically from [EmployeeProvider]'s employee list grouped by
/// [Employee.department] — there is no separate Department
/// repository/collection.
class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({super.key});

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  void _viewDepartment(DepartmentSummary department) {
    Navigator.of(context).pushNamed(AppRoutes.departmentDetails, arguments: department.name);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.departments,
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.employees.isEmpty) {
            return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadEmployees);
          }

          final List<DepartmentSummary> departments =
              DepartmentSummary.groupByDepartment(provider.employees);

          if (departments.isEmpty) {
            return const PlaceholderPageContent(
              icon: Icons.apartment_outlined,
              title: AppStrings.departmentsEmptyMessage,
              message: 'Departments are generated from employee records — add an employee first.',
            );
          }

          final int columns = switch (ResponsiveHelper.deviceTypeOf(context)) {
            DeviceType.desktop => 3,
            DeviceType.tablet => 2,
            DeviceType.mobile => 1,
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = AppSpacing.md;
                final double cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final DepartmentSummary department in departments)
                      SizedBox(
                        width: cardWidth,
                        child: DepartmentCard(
                          department: department,
                          onTap: () => _viewDepartment(department),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
