import '../models/business_settings.dart';
import '../models/client.dart';
import '../models/client_payment.dart';
import '../models/employee.dart';
import '../models/employee_hour.dart';
import '../models/status.dart';

/// The computed figures shown on the Dashboard's summary cards
/// (UI/UX spec Section 8). Charts (Phase 4) will derive their own
/// grouped/time-series data separately — this is the flat summary
/// only.
class DashboardSummary {
  const DashboardSummary({
    required this.revenue,
    required this.salaryExpense,
    required this.toolsExpense,
    required this.miscellaneousExpense,
    required this.ownerShare,
    required this.netProfit,
    required this.activeEmployees,
    required this.activeClients,
  });

  final double revenue;
  final double salaryExpense;
  final double toolsExpense;
  final double miscellaneousExpense;
  final double ownerShare;
  final double netProfit;
  final int activeEmployees;
  final int activeClients;

  static const DashboardSummary empty = DashboardSummary(
    revenue: 0,
    salaryExpense: 0,
    toolsExpense: 0,
    miscellaneousExpense: 0,
    ownerShare: 0,
    netProfit: 0,
    activeEmployees: 0,
    activeClients: 0,
  );
}

/// One calendar month's worth of the same figures as
/// [DashboardSummary] (minus the point-in-time counts), used to power
/// the Revenue-by-Month and Monthly-Profit-Trend charts (Phase 4).
class MonthlyFinancials {
  const MonthlyFinancials({
    required this.month,
    required this.revenue,
    required this.salaryExpense,
    required this.toolsExpense,
    required this.miscellaneousExpense,
    required this.ownerShare,
    required this.netProfit,
  });

  /// The first day of the month this data represents. Only the
  /// year/month components are meaningful.
  final DateTime month;
  final double revenue;
  final double salaryExpense;
  final double toolsExpense;
  final double miscellaneousExpense;
  final double ownerShare;
  final double netProfit;
}

/// Stateless implementation of the SDD Section 13 business
/// computations:
///   Salary Expense = Σ(hoursWorked × hourlyRate) per employee
///   Revenue         = Σ client payments
///   Tools Expense   = Salary Expense × Tools %
///   Misc. Expense   = Salary Expense × Miscellaneous %
///   Remaining       = Revenue − Salary − Tools − Misc.
///   Owner Share     = Remaining × Owner Share %
///   Net Profit      = Remaining − Owner Share
///
/// Kept separate from [DashboardProvider] so the formulas can be
/// tested/reasoned about independently of state management and data
/// loading.
class DashboardCalculator {
  DashboardCalculator._();

  static DashboardSummary calculate({
    required List<Employee> employees,
    required List<EmployeeHour> employeeHours,
    required List<Client> clients,
    required List<ClientPayment> payments,
    required BusinessSettings settings,
  }) {
    final double revenue = payments.fold(0.0, (sum, payment) => sum + payment.amount);

    final Map<String, double> hourlyRateByEmployeeId = {
      for (final Employee employee in employees) employee.id: employee.hourlyRate,
    };
    final double salaryExpense = employeeHours.fold(0.0, (sum, hour) {
      final double rate = hourlyRateByEmployeeId[hour.employeeId] ?? 0;
      return sum + (hour.hoursWorked * rate);
    });

    final double toolsExpense = salaryExpense * (settings.toolsPercentage / 100);
    final double miscellaneousExpense = salaryExpense * (settings.miscellaneousPercentage / 100);
    final double remainingBalance = revenue - salaryExpense - toolsExpense - miscellaneousExpense;
    final double ownerShare = remainingBalance * (settings.ownerSharePercentage / 100);
    final double netProfit = remainingBalance - ownerShare;

    final int activeEmployees = employees.where((e) => e.status == Status.active).length;
    final int activeClients = clients.where((c) => c.status == Status.active).length;

    return DashboardSummary(
      revenue: revenue,
      salaryExpense: salaryExpense,
      toolsExpense: toolsExpense,
      miscellaneousExpense: miscellaneousExpense,
      ownerShare: ownerShare,
      netProfit: netProfit,
      activeEmployees: activeEmployees,
      activeClients: activeClients,
    );
  }

  /// Groups revenue (client payments) and salary expense (employee
  /// hours × rate) by calendar month, then applies the exact same
  /// Tools/Miscellaneous/Owner Share/Net Profit formulas as
  /// [calculate] independently to each month. Powers the
  /// Revenue-by-Month and Monthly-Profit-Trend charts (Phase 4).
  ///
  /// Returned list is sorted chronologically and only includes months
  /// that have at least one payment or hour record.
  static List<MonthlyFinancials> calculateMonthly({
    required List<Employee> employees,
    required List<EmployeeHour> employeeHours,
    required List<ClientPayment> payments,
    required BusinessSettings settings,
  }) {
    final Map<String, double> hourlyRateByEmployeeId = {
      for (final Employee employee in employees) employee.id: employee.hourlyRate,
    };

    final Map<DateTime, double> revenueByMonth = {};
    for (final ClientPayment payment in payments) {
      final DateTime key = DateTime(payment.date.year, payment.date.month);
      revenueByMonth[key] = (revenueByMonth[key] ?? 0) + payment.amount;
    }

    final Map<DateTime, double> salaryByMonth = {};
    for (final EmployeeHour hour in employeeHours) {
      final DateTime key = DateTime(hour.date.year, hour.date.month);
      final double rate = hourlyRateByEmployeeId[hour.employeeId] ?? 0;
      salaryByMonth[key] = (salaryByMonth[key] ?? 0) + (hour.hoursWorked * rate);
    }

    final Set<DateTime> months = {...revenueByMonth.keys, ...salaryByMonth.keys};
    final List<DateTime> sortedMonths = months.toList()..sort();

    return [
      for (final DateTime month in sortedMonths)
        _monthlyFinancialsFor(
          month: month,
          revenue: revenueByMonth[month] ?? 0,
          salaryExpense: salaryByMonth[month] ?? 0,
          settings: settings,
        ),
    ];
  }

  static MonthlyFinancials _monthlyFinancialsFor({
    required DateTime month,
    required double revenue,
    required double salaryExpense,
    required BusinessSettings settings,
  }) {
    final double toolsExpense = salaryExpense * (settings.toolsPercentage / 100);
    final double miscellaneousExpense = salaryExpense * (settings.miscellaneousPercentage / 100);
    final double remainingBalance = revenue - salaryExpense - toolsExpense - miscellaneousExpense;
    final double ownerShare = remainingBalance * (settings.ownerSharePercentage / 100);
    final double netProfit = remainingBalance - ownerShare;

    return MonthlyFinancials(
      month: month,
      revenue: revenue,
      salaryExpense: salaryExpense,
      toolsExpense: toolsExpense,
      miscellaneousExpense: miscellaneousExpense,
      ownerShare: ownerShare,
      netProfit: netProfit,
    );
  }
}
