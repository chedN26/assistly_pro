/// Shared [TextFormField] validators implementing the DDD Section 12
/// data validation rules. Kept generic (not employee/client-specific)
/// so both the Employee module (Phase 5) and Client module (Phase 6)
/// reuse the same logic instead of duplicating it.
class AppValidators {
  AppValidators._();

  static String? required(String? value, {String message = 'This field is required.'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static final RegExp _emailPattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  /// Validates a numeric field that must be strictly greater than 0
  /// (e.g. Hourly Rate, Monthly Payment, Payment Amount).
  static String? positiveNumber(String? value, {String message = 'Enter a value greater than 0.'}) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    final double? parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number.';
    if (parsed <= 0) return message;
    return null;
  }

  /// Validates a numeric field that must fall within an inclusive
  /// [min]/[max] range (e.g. Hours Worked, 0–24).
  static String? numberInRange(String? value, {required double min, required double max, String? message}) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    final double? parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number.';
    if (parsed < min || parsed > max) {
      return message ?? 'Enter a value between $min and $max.';
    }
    return null;
  }
}
