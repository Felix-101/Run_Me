import '../../domain/entities/trust_score.dart';

/// Data-layer DTO for persistence / API mapping.
class TrustScoreModel {
  const TrustScoreModel({
    required this.score,
    required this.level,
    required this.verificationScore,
    required this.repaymentScore,
    required this.socialScore,
    required this.activityScore,
  });

  final int score;
  final String level;
  final int verificationScore;
  final int repaymentScore;
  final int socialScore;
  final int activityScore;

  factory TrustScoreModel.fromEntity(TrustScore entity) {
    return TrustScoreModel(
      score: entity.score,
      level: entity.level,
      verificationScore: entity.factors.verificationScore,
      repaymentScore: entity.factors.repaymentScore,
      socialScore: entity.factors.socialScore,
      activityScore: entity.factors.activityScore,
    );
  }

  TrustScore toEntity() {
    return TrustScore(
      score: score,
      level: level,
      factors: TrustScoreFactors(
        verificationScore: verificationScore,
        repaymentScore: repaymentScore,
        socialScore: socialScore,
        activityScore: activityScore,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'level': level,
        'verificationScore': verificationScore,
        'repaymentScore': repaymentScore,
        'socialScore': socialScore,
        'activityScore': activityScore,
      };

  factory TrustScoreModel.fromJson(Map<String, dynamic> json) {
    return TrustScoreModel(
      score: (json['score'] as num).round(),
      level: json['level'] as String,
      verificationScore: (json['verificationScore'] as num).round(),
      repaymentScore: (json['repaymentScore'] as num).round(),
      socialScore: (json['socialScore'] as num).round(),
      activityScore: (json['activityScore'] as num).round(),
    );
  }
}
