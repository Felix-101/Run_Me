/// Domain entity: composite trust score and its contributing factors.
class TrustScore {
  const TrustScore({
    required this.score,
    required this.level,
    required this.factors,
  });

  /// Weighted result in [0, 100].
  final int score;

  /// Human-readable tier, e.g. "Low", "Medium", "High".
  final String level;

  final TrustScoreFactors factors;
}

/// Raw factor inputs, each typically on a 0–100 scale before weighting.
class TrustScoreFactors {
  const TrustScoreFactors({
    required this.verificationScore,
    required this.repaymentScore,
    required this.socialScore,
    required this.activityScore,
  })  : assert(verificationScore >= 0 && verificationScore <= 100),
        assert(repaymentScore >= 0 && repaymentScore <= 100),
        assert(socialScore >= 0 && socialScore <= 100),
        assert(activityScore >= 0 && activityScore <= 100);

  final int verificationScore;
  final int repaymentScore;
  final int socialScore;
  final int activityScore;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrustScoreFactors &&
            verificationScore == other.verificationScore &&
            repaymentScore == other.repaymentScore &&
            socialScore == other.socialScore &&
            activityScore == other.activityScore;
  }

  @override
  int get hashCode =>
      Object.hash(verificationScore, repaymentScore, socialScore, activityScore);
}
