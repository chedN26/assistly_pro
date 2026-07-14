import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/chart_card.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/employees/add_hours_dialog.dart';
import '../../widgets/employees/employee_hours_line_chart.dart';
import '../../widgets/employees/employee_hours_table.dart';
import '../../widgets/employees/employee_info_card.dart';
import '../../widgets/layout/app_shell.dart';

/// Employee details page (UI/UX spec Section 10): employee info card,
/// hours history table, Add Hours action, and hours-worked line
/// chart. [employeeId] arrives via `Navigator` route arguments from
/// the employee table's "View" action.
class EmployeeDetailsPage extends StatefulWidget {
  const EmployeeDetailsPage({super.key, this.employeeId});

  final String? employeeId;

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  Employee? _employee;
  bool _isLoadingEmployee = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final String? id = widget.employeeId;
    if (id == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingEmployee = false;
        _loadError = 'No employee specified.';
      });
      return;
    }

    final EmployeeProvider provider = context.read<EmployeeProvider>();
    // Fast path: check the already-loaded list first. Falls back to a
    // direct repository fetch for cases where the list hasn't been
    // loaded yet (e.g. a fresh page load via direct navigation).
    Employee? employee = provider.getById(id);
    employee ??= await provider.fetchById(id);

    if (!mounted) return;

    if (employee == null) {
      setState(() {
        _isLoadingEmployee = false;
        _loadError = 'Employee not found.';
      });
      return;
    }

    setState(() {
      _employee = employee;
      _isLoadingEmployee = false;
    });

    await provider.loadHours(id);
  }

  Future<void> _openAddHoursDialog() async {
    final Employee? employee = _employee;
    if (employee == null) return;

    final bool? result = await AddHoursDialog.show(context, employeeId: employee.id);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.hoursAddedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.employeeDetails,
      pageTitle: _employee?.name ?? AppStrings.pageTitleEmployeeDetails,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingEmployee) {
      return const Center(child: CircularProgressIndicator());
    }

    final Employee? employee = _employee;
    if (_loadError != null || employee == null) {
      return AppErrorState(
        message: _loadError ?? 'Employee not found.',
        onRetry: () {
          setState(() => _isLoadingEmployee = true);
          _load();
        },
      );
    }

    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        final hours = provider.hoursFor(employee.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BackButton(),
              const SizedBox(height: AppSpacing.md),
              EmployeeInfoCard(employee: employee),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hours History', style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: _openAddHoursDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addHoursTitle),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (provider.isLoadingHours && hours.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (hours.isEmpty)
                const PlaceholderPageContent(
                  icon: Icons.schedule_outlined,
                  title: AppStrings.employeeHoursEmptyMessage,
                  message: 'Add the first work-hours entry using the button above.',
                )
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: EmployeeHoursTable(hours: hours),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ChartCard(
                  title: 'Hours Worked Per Day',
                  child: EmployeeHoursLineChart(hours: hours),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.employees);
          }
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
    );
  }
}
