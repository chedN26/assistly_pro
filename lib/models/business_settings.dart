/// Mirrors the `settings` Firestore collection (DDD Section 8), which
/// holds exactly one document (`default`). Drives the dashboard's
/// business computations (SDD Section 13).
class BusinessSettings {
  const BusinessSettings({
    required this.companyName,
    required this.toolsPercentage,
    required this.miscellaneousPercentage,
    required this.ownerSharePercentage,
  });

  final String companyName;
  final double toolsPercentage;
  final double miscellaneousPercentage;
  final double ownerSharePercentage;

  BusinessSettings copyWith({
    String? companyName,
    double? toolsPercentage,
    double? miscellaneousPercentage,
    double? ownerSharePercentage,
  }) {
    return BusinessSettings(
      companyName: companyName ?? this.companyName,
      toolsPercentage: toolsPercentage ?? this.toolsPercentage,
      miscellaneousPercentage: miscellaneousPercentage ?? this.miscellaneousPercentage,
      ownerSharePercentage: ownerSharePercentage ?? this.ownerSharePercentage,
    );
  }

  factory BusinessSettings.fromMap(Map<String, dynamic> map) {
    return BusinessSettings(
      companyName: map['companyName'] as String,
      toolsPercentage: (map['toolsPercentage'] as num).toDouble(),
      miscellaneousPercentage: (map['miscellaneousPercentage'] as num).toDouble(),
      ownerSharePercentage: (map['ownerSharePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'toolsPercentage': toolsPercentage,
      'miscellaneousPercentage': miscellaneousPercentage,
      'ownerSharePercentage': ownerSharePercentage,
    };
  }
}
