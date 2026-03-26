/// Underwriting risk for a loan; improves as total peer backing covers more principal.
enum LoanRiskLevel {
  high,
  elevated,
  medium,
  low,
}

extension LoanRiskLevelLabel on LoanRiskLevel {
  String get label {
    switch (this) {
      case LoanRiskLevel.high:
        return 'High';
      case LoanRiskLevel.elevated:
        return 'Elevated';
      case LoanRiskLevel.medium:
        return 'Medium';
      case LoanRiskLevel.low:
        return 'Low';
    }
  }
}

/// Maps coverage (total guaranteed / principal, capped at 1) to a discrete risk band.
class LoanRiskCalculator {
  LoanRiskCalculator._();

  /// [coverageRatio] in \[0, 1\]: fraction of principal covered by guarantees.
  static LoanRiskLevel fromCoverage(double coverageRatio) {
    final r = coverageRatio.clamp(0.0, 1.0);
    if (r >= 0.75) return LoanRiskLevel.low;
    if (r >= 0.45) return LoanRiskLevel.medium;
    if (r >= 0.2) return LoanRiskLevel.elevated;
    return LoanRiskLevel.high;
  }

  static double coverageRatio({
    required double principal,
    required double totalGuaranteed,
  }) {
    if (principal <= 0) return 0;
    return (totalGuaranteed / principal).clamp(0.0, 1.0);
  }
}
