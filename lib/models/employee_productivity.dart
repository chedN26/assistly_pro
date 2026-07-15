/// A single employee's total recorded hours, used to rank
/// "Top 5 Employee Productivity" on the Dashboard tab.
///
/// Independent from the [Employee]/[EmployeeHour] models — sourced
/// from [DashboardRepository]'s demo data, not computed from the
/// Employee module's live records.
class EmployeeProductivity {
  const EmployeeProductivity({
    required this.employeeName,
    required this.totalHours,
  });

  final String employeeName;
  final double totalHours;
}
