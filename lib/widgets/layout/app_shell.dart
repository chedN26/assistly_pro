import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/app_sidebar.dart';

/// Wraps every authenticated page (Dashboard, Employees, Clients,
/// Settings, About) with the responsive navigation shell described in
/// UI/UX spec Section 5 (Global Layout) and Section 4 (Responsive
/// Layout):
///  - Desktop: permanent full sidebar + top bar.
///  - Tablet: collapsible icon-only sidebar rail + top bar.
///  - Mobile: drawer navigation + top app bar with menu icon.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.currentRoute,
    required this.body,
    this.pageTitle,
  });

  final String currentRoute;
  final Widget body;
  final String? pageTitle;

  static const Map<String, String> _routeTitles = {
    AppRoutes.dashboard: AppStrings.pageTitleDashboard,
    AppRoutes.employees: AppStrings.pageTitleEmployees,
    AppRoutes.employeeDetails: AppStrings.pageTitleEmployeeDetails,
    AppRoutes.clients: AppStrings.pageTitleClients,
    AppRoutes.clientDetails: AppStrings.pageTitleClientDetails,
    AppRoutes.departments: AppStrings.pageTitleDepartments,
    AppRoutes.departmentDetails: AppStrings.pageTitleDepartmentDetails,
    AppRoutes.settings: AppStrings.pageTitleSettings,
    AppRoutes.about: AppStrings.pageTitleAbout,
  };

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Only relevant on tablet, where the sidebar starts collapsed and can
  // be expanded/collapsed via the toggle button in AppSidebar.
  bool _railExpanded = false;

  String get _title =>
      widget.pageTitle ?? AppShell._routeTitles[widget.currentRoute] ?? AppStrings.appName;

  @override
  Widget build(BuildContext context) {
    final DeviceType deviceType = ResponsiveHelper.deviceTypeOf(context);

    if (deviceType == DeviceType.mobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(_title)),
        drawer: Drawer(
          width: AppSpacing.sidebarWidthExpanded,
          child: AppSidebar(currentRoute: widget.currentRoute, expanded: true),
        ),
        body: SafeArea(child: widget.body),
      );
    }

    final bool expanded = deviceType == DeviceType.desktop || _railExpanded;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            currentRoute: widget.currentRoute,
            expanded: expanded,
            onToggleCollapse: deviceType == DeviceType.tablet
                ? () => setState(() => _railExpanded = !_railExpanded)
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(title: _title),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Top app bar used on desktop/tablet, where there is no [AppBar]
/// provided by [Scaffold] (the sidebar occupies the leading area
/// instead of a hamburger icon).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          title,
          key: ValueKey<String>(title),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
