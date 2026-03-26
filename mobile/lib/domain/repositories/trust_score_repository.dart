import '../entities/trust_score.dart';

/// Abstract access to trust score data and calculation.
abstract class TrustScoreRepository {
  /// Returns the current trust score (e.g. from cache, API, or local compute).
  Future<TrustScore> getCurrentTrustScore();

  /// Recomputes trust score from explicit factor inputs.
  Future<TrustScore> calculateFromFactors(TrustScoreFactors factors);
}
