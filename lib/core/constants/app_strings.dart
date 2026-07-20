/// Centralized, reusable text used across multiple pages/widgets.
///
/// Page-specific copy (validation messages, empty states, dialog text,
/// etc.) is added here as each module phase implements it, rather than
/// being pre-declared before it is needed.
class AppStrings {
  AppStrings._();

  static const String appName = 'Assistly Pro';
  static const String appTagline = 'Workforce and Client Operations Dashboard';

  // Sidebar / drawer navigation labels
  static const String navDashboard = 'Dashboard';
  static const String navEmployees = 'Employees';
  static const String navClients = 'Clients';
  static const String navDepartments = 'Departments';
  static const String navSettings = 'Settings';
  static const String navAbout = 'About';
  static const String navLogout = 'Logout';

  // Page titles (shown in the top app bar)
  static const String pageTitleLogin = 'Login';
  static const String pageTitleDashboard = 'Dashboard';
  static const String pageTitleEmployees = 'Employees';
  static const String pageTitleEmployeeDetails = 'Employee Details';
  static const String pageTitleClients = 'Clients';
  static const String pageTitleClientDetails = 'Client Details';
  static const String pageTitleDepartments = 'Departments';
  static const String pageTitleDepartmentDetails = 'Department Details';
  static const String pageTitleSettings = 'Settings';
  static const String pageTitleAbout = 'About';

  // Phase 1 placeholder messaging — removed once each module is built.
  static const String comingSoonMessage =
      'This section will be implemented in a later development phase.';

  static const String routeNotFoundTitle = 'Page Not Found';
  static const String routeNotFoundMessage = "The page you're looking for doesn't exist.";

  // Authentication (Phase 2)
  static const String authUsernameLabel = 'Username';
  static const String authPasswordLabel = 'Password';
  static const String authUsernameRequired = 'Username is required.';
  static const String authPasswordRequired = 'Password is required.';
  static const String authInvalidCredentials = 'Incorrect username or password.';
  static const String authLoginButton = 'Login';
  static const String authDemoCredentialsTitle = 'Demo Credentials';

  // Logout confirmation dialog
  static const String logoutConfirmTitle = 'Log Out';
  static const String logoutConfirmMessage = 'Are you sure you want to log out?';
  static const String logoutConfirmButton = 'Logout';
  static const String cancelButton = 'Cancel';

  static const String retryButton = 'Retry';

  // Dashboard (Phase 4)
  static const String dashboardRevenue = 'Revenue';
  static const String dashboardSalaryExpense = 'Salary Expense';
  static const String dashboardToolsExpense = 'Tools Expense';
  static const String dashboardMiscellaneousExpense = 'Miscellaneous Expense';
  static const String dashboardOwnerShare = 'Owner Share';
  static const String dashboardNetProfit = 'Net Profit';
  static const String dashboardActiveEmployees = 'Active Employees';
  static const String dashboardActiveClients = 'Active Clients';

  static const String dashboardChartRevenueByMonth = 'Revenue by Month';
  static const String dashboardChartExpenseBreakdown = 'Expense Breakdown';
  static const String dashboardChartProfitTrend = 'Monthly Profit Trend';

  static const String dashboardEmptyMessage = 'No business data available.';
  static const String dashboardErrorMessage = 'Failed to load dashboard data.';

  // Generic field/action labels shared across Employee (Phase 5) and
  // Client (Phase 6) forms.
  static const String saveButton = 'Save';
  static const String addButton = 'Add';
  static const String dateLabel = 'Date';

  // Employee module (Phase 5)
  static const String employeesEmptyMessage = 'No employees found.';
  static const String employeeHoursEmptyMessage = 'No work hours recorded.';

  static const String addEmployeeTitle = 'Add Employee';
  static const String editEmployeeTitle = 'Edit Employee';
  static const String deactivateEmployeeTitle = 'Deactivate Employee';
  static const String activateEmployeeTitle = 'Activate Employee';
  static const String addHoursTitle = 'Add Hours';

  static const String employeeNameLabel = 'Name';
  static const String employeeEmailLabel = 'Email';
  static const String employeePhoneLabel = 'Phone';
  static const String employeePositionLabel = 'Position';
  static const String employeeHourlyRateLabel = 'Hourly Rate';
  static const String employeeHoursWorkedLabel = 'Hours Worked';
  static const String employeeDepartmentLabel = 'Department';
  static const String employeeSupervisorLabel = 'Supervisor';
  static const String employeeAssignedClientLabel = 'Assigned Client';
  static const String employeeAssignedClientNone = 'None';

  static const String searchEmployeesHint = 'Search employees by name...';

  static const String employeeAddedMessage = 'Employee added successfully.';
  static const String employeeUpdatedMessage = 'Employee updated successfully.';
  static const String employeeDeactivatedMessage = 'Employee deactivated successfully.';
  static const String employeeActivatedMessage = 'Employee activated successfully.';
  static const String hoursAddedMessage = 'Hours added successfully.';

  // Client module (Phase 6)
  static const String clientsEmptyMessage = 'No clients found.';
  static const String departmentsEmptyMessage = 'No departments found.';
  static const String clientPaymentsEmptyMessage = 'No payments available.';

  static const String addClientTitle = 'Add Client';
  static const String editClientTitle = 'Edit Client';
  static const String deactivateClientTitle = 'Deactivate Client';
  static const String activateClientTitle = 'Activate Client';
  static const String addPaymentTitle = 'Add Payment';

  static const String clientCompanyNameLabel = 'Company Name';
  static const String clientContactPersonLabel = 'Contact Person';
  static const String clientEmailLabel = 'Email';
  static const String clientPhoneLabel = 'Phone';
  static const String clientServiceTypeLabel = 'Service Type';
  static const String clientPaymentAmountLabel = 'Amount';

  static const String searchClientsHint = 'Search clients by company name...';

  static const String clientAddedMessage = 'Client added successfully.';
  static const String clientUpdatedMessage = 'Client updated successfully.';
  static const String clientDeactivatedMessage = 'Client deactivated successfully.';
  static const String clientActivatedMessage = 'Client activated successfully.';
  static const String paymentAddedMessage = 'Payment added successfully.';

  // Settings module (Phase 7)
  static const String resetButton = 'Reset';
  static const String settingsCompanyNameLabel = 'Company Name';
  static const String settingsToolsPercentageLabel = 'Tools Expense %';
  static const String settingsMiscellaneousPercentageLabel = 'Miscellaneous Expense %';
  static const String settingsOwnerSharePercentageLabel = 'Owner Share %';
  static const String settingsSavedMessage = 'Settings saved successfully.';
}
