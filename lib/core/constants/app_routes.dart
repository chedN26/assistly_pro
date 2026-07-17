/// Centralized named-route identifiers.
///
/// Widgets must always navigate using these constants (e.g.
/// `Navigator.pushNamed(context, AppRoutes.employees)`) instead of raw
/// path strings, so route names stay consistent and typo-proof across
/// the app.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String employees = '/employees';
  static const String employeeDetails = '/employees/details';
  static const String clients = '/clients';
  static const String clientDetails = '/clients/details';
  static const String departments = '/departments';
  static const String departmentDetails = '/departments/details';
  static const String settings = '/settings';
  static const String about = '/about';
}
