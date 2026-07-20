import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_config.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/navigation/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/client_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/operating_expense_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/client_repository.dart';
import 'repositories/dashboard_repository.dart';
import 'repositories/employee_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firebase_client_repository.dart';
import 'repositories/firebase/firebase_employee_repository.dart';
import 'repositories/firebase/firebase_operating_expense_repository.dart';
import 'repositories/mock/mock_auth_repository.dart';
import 'repositories/mock/mock_client_repository.dart';
import 'repositories/mock/mock_dashboard_repository.dart';
import 'repositories/mock/mock_employee_repository.dart';
import 'repositories/mock/mock_operating_expense_repository.dart';
import 'repositories/operating_expense_repository.dart';

/// Root widget of the Assistly Pro application.
///
/// Wires together the global theme (Phase 1), named routing (Phase 1),
/// and app-wide state management via [MultiProvider] (Phase 2 onward).
///
/// The active repository implementations are constructed exactly once
/// here — the only place in the app that knows whether Mock or
/// Firebase repositories are active, controlled by [kUseFirebase].
/// [EmployeeRepository], [ClientRepository], and
/// [OperatingExpenseRepository] instances are each shared between
/// their dedicated provider and any other provider that needs them.
/// [DashboardProvider] is the one exception: it depends on its own
/// dedicated [DashboardRepository], always [MockDashboardRepository]
/// regardless of [kUseFirebase] — the Dashboard module always shows
/// demo data and has zero dependency on Firebase being configured
/// (this will change in the next migration step, wiring it to real
/// Employee/Client/OperatingExpense data instead).
class AssistlyProApp extends StatelessWidget {
  const AssistlyProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository =
        kUseFirebase ? FirebaseAuthRepository() : MockAuthRepository();
    final EmployeeRepository employeeRepository =
        kUseFirebase ? FirebaseEmployeeRepository() : MockEmployeeRepository();
    final ClientRepository clientRepository =
        kUseFirebase ? FirebaseClientRepository() : MockClientRepository();
    final OperatingExpenseRepository operatingExpenseRepository =
        kUseFirebase ? FirebaseOperatingExpenseRepository() : MockOperatingExpenseRepository();
    // Dashboard is intentionally never Firebase-gated: it always
    // shows demo data (enhancement brief's "Fallback Behavior").
    final DashboardRepository dashboardRepository = MockDashboardRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider<EmployeeProvider>(
          create: (_) => EmployeeProvider(employeeRepository),
        ),
        ChangeNotifierProvider<ClientProvider>(
          create: (_) => ClientProvider(clientRepository),
        ),
        ChangeNotifierProvider<OperatingExpenseProvider>(
          create: (_) => OperatingExpenseProvider(operatingExpenseRepository),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(dashboardRepository: dashboardRepository),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
