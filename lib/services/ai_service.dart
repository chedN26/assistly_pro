import '../models/dashboard_summary.dart';
import '../models/employee_productivity.dart';

/// Placeholder AI-assistance service.
///
/// Currently always returns a locally-generated mock recommendation —
/// no OpenAI (or other LLM) API is integrated yet, by design. When one
/// is added later, only this class's internals change: swap the mock
/// generation in [generateBusinessInsights] for a real API call.
/// [DashboardProvider] and the AI Assistant tab call this exact same
/// method signature either way, so no UI or Provider changes will be
/// needed when the real integration lands.
///
/// The mock output is loosely data-driven (it names the actual top
/// performer from [employeeProductivity]) so it reads as a plausible
/// stand-in for a real generated response, and to demonstrate the
/// kind of structured input a real API call would take as its prompt
/// context.
class AIService {
  const AIService();

  Future<String> generateBusinessInsights({
    required DashboardSummary summary,
    required List<EmployeeProductivity> employeeProductivity,
  }) async {
    // TODO(real-ai-integration): replace the body below with a real
    // LLM API call (e.g. OpenAI), passing `summary` and
    // `employeeProductivity` as prompt context. If that call is
    // unavailable/unconfigured or throws, fall back to
    // _mockRecommendation so the UI never shows an empty or broken
    // state (see enhancement brief's "Fallback Behavior").
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRecommendation(summary, employeeProductivity);
  }

  String _mockRecommendation(DashboardSummary summary, List<EmployeeProductivity> productivity) {
    final String topEmployeeName = _topPerformer(productivity);

    return 'Business Summary\n'
        'Revenue has remained stable over the past months. Net Profit is showing '
        'positive growth. Employee $topEmployeeName has the highest productivity. '
        'Client contribution to revenue remains concentrated among the top '
        'accounts.\n\n'
        'Recommendations\n'
        '• Maintain current workforce allocation.\n'
        '• Monitor operating expenses.\n'
        '• Continue focusing on high-value clients.';
  }

  String _topPerformer(List<EmployeeProductivity> productivity) {
    if (productivity.isEmpty) return 'N/A';
    final List<EmployeeProductivity> sorted = [...productivity]
      ..sort((a, b) => b.totalHours.compareTo(a.totalHours));
    return sorted.first.employeeName;
  }
}
