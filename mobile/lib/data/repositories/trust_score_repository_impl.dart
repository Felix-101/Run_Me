import '../../domain/entities/trust_score.dart';
import '../../domain/repositories/trust_score_repository.dart';
import '../../domain/usecases/calculate_trust_score.dart';

/// Default implementation: uses [CalculateTrustScoreUseCase] with local / stub inputs.
/// Replace [defaultFactors] with remote data when an API exists.
class TrustScoreRepositoryImpl implements TrustScoreRepository {
  TrustScoreRepositoryImpl(this._calculateTrustScore);

  final CalculateTrustScoreUseCase _calculateTrustScore;

  /// Demo factors until a remote source is wired.
  static const TrustScoreFactors defaultFactors = TrustScoreFactors(
    verificationScore: 88,
    repaymentScore: 92,
    socialScore: 76,
    activityScore: 84,
  );

  @override
  Future<TrustScore> getCurrentTrustScore() async {
    return _calculateTrustScore(defaultFactors);
  }

  @override
  Future<TrustScore> calculateFromFactors(TrustScoreFactors factors) async {
    return _calculateTrustScore(factors);
  }
}
