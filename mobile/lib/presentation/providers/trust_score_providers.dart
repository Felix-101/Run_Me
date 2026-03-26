import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/trust_score_repository_impl.dart';
import '../../domain/entities/trust_score.dart';
import '../../domain/repositories/trust_score_repository.dart';
import '../../domain/usecases/calculate_trust_score.dart';

final calculateTrustScoreUseCaseProvider =
    Provider<CalculateTrustScoreUseCase>(
  (ref) => CalculateTrustScoreUseCase(),
);

final trustScoreRepositoryProvider = Provider<TrustScoreRepository>(
  (ref) => TrustScoreRepositoryImpl(
    ref.read(calculateTrustScoreUseCaseProvider),
  ),
);

/// Current trust score (async for future remote loading).
final trustScoreProvider = FutureProvider<TrustScore>(
  (ref) => ref.read(trustScoreRepositoryProvider).getCurrentTrustScore(),
);

/// Recalculate when factors change (call with [TrustScoreFactors]).
final trustScoreFromFactorsProvider =
    FutureProvider.family<TrustScore, TrustScoreFactors>(
  (ref, factors) =>
      ref.read(trustScoreRepositoryProvider).calculateFromFactors(factors),
);
