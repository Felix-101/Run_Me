import '../entities/trust_score.dart';

/// Computes weighted trust score from factor inputs.
///
/// Weights:
/// - verificationScore: 30%
/// - repaymentScore: 40%
/// - socialScore: 20%
/// - activityScore: 10%
class CalculateTrustScoreUseCase {
  static const double _wVerification = 0.30;
  static const double _wRepayment = 0.40;
  static const double _wSocial = 0.20;
  static const double _wActivity = 0.10;

  TrustScore call(TrustScoreFactors factors) {
    final raw = factors.verificationScore * _wVerification +
        factors.repaymentScore * _wRepayment +
        factors.socialScore * _wSocial +
        factors.activityScore * _wActivity;
    final score = raw.round().clamp(0, 100);
    return TrustScore(
      score: score,
      level: _levelForScore(score),
      factors: factors,
    );
  }

  static String _levelForScore(int score) {
    if (score >= 71) return 'High';
    if (score >= 41) return 'Medium';
    return 'Low';
  }
}
