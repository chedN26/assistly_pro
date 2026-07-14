import 'package:flutter/material.dart';

import '../../pages/about/about_page.dart';
import '../../pages/client_details/client_details_page.dart';
import '../../pages/clients/client_list_page.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/employee_details/employee_details_page.dart';
import '../../pages/employees/employee_list_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/settings/settings_page.dart';
import '../constants/app_routes.dart';
import '../constants/app_strings.dart';
import 'auth_guard.dart';

/// Resolves [RouteSettings] into concrete page widgets.
///
/// IDs for the details pages are passed via `Navigator` route
/// arguments (e.g. `Navigator.pushNamed(context, AppRoutes.employeeDetails,
/// arguments: employee.id)`) rather than URL path parameters, per
/// project decision to keep routing simple for local demonstration.
///
/// Every route except Login is wrapped in [AuthGuard] so unauthorized
/// access (including a direct URL on Flutter Web) redirects to Login
/// instead of rendering the page.
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _route(const LoginPage(), settings);

      case AppRoutes.dashboard:
        return _route(const AuthGuard(child: DashboardPage()), settings);

      case AppRoutes.employees:
        return _route(const AuthGuard(child: EmployeeListPage()), settings);

      case AppRoutes.employeeDetails:
        final String? employeeId = settings.arguments as String?;
        return _route(
          AuthGuard(child: EmployeeDetailsPage(employeeId: employeeId)),
          settings,
        );

      case AppRoutes.clients:
        return _route(const AuthGuard(child: ClientListPage()), settings);

      case AppRoutes.clientDetails:
        final String? clientId = settings.arguments as String?;
        return _route(
          AuthGuard(child: ClientDetailsPage(clientId: clientId)),
          settings,
        );

      case AppRoutes.settings:
        return _route(const AuthGuard(child: SettingsPage()), settings);

      case AppRoutes.about:
        return _route(const AuthGuard(child: AboutPage()), settings);

      default:
        return _route(const _RouteNotFoundPage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _route(Widget page, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }
}

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.routeNotFoundTitle)),
      body: const Center(child: Text(AppStrings.routeNotFoundMessage)),
    );
  }
}
