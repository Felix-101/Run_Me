import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/backing.dart';
import '../../domain/entities/loan_risk_level.dart';
import '../../domain/repositories/backing_repository.dart';
import 'loan_providers.dart';

/// Mock backer id until auth supplies a real profile id.
final currentBackerIdProvider = Provider<String>((ref) => 'local-backer');

/// In-memory backing list; implements [BackingRepository] for tests / injection.
class BackingNotifier extends StateNotifier<List<Backing>> implements BackingRepository {
  BackingNotifier() : super(_seedBackings);

  static final List<Backing> _seedBackings = [
    Backing(
      id: 'seed_b_txt1',
      loanId: 'loan_seed_textbook',
      backerId: 'local-backer',
      amountGuaranteed: 200,
    ),
    Backing(
      id: 'seed_b_txt2',
      loanId: 'loan_seed_textbook',
      backerId: 'lender_chidi',
      amountGuaranteed: 220,
    ),
    Backing(
      id: 'seed_b_lab1',
      loanId: 'loan_seed_lab',
      backerId: 'lender_pool',
      amountGuaranteed: 800,
    ),
    Backing(
      id: 'seed_b_lab2',
      loanId: 'loan_seed_lab',
      backerId: 'lender_friends',
      amountGuaranteed: 480.5,
    ),
    Backing(
      id: 'seed_b_rent',
      loanId: 'loan_seed_rent',
      backerId: 'lender_amina',
      amountGuaranteed: 900,
    ),
    Backing(
      id: 'seed_b_pend',
      loanId: 'loan_seed_lent_out_2',
      backerId: 'local-backer',
      amountGuaranteed: 250,
    ),
  ];

  @override
  List<Backing> backingForLoan(String loanId) {
    return state.where((b) => b.loanId == loanId).toList();
  }

  @override
  Future<Backing> addBacking({
    required String loanId,
    required String backerId,
    required double amountGuaranteed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final id = 'backing_${DateTime.now().millisecondsSinceEpoch}';
    final created = Backing(
      id: id,
      loanId: loanId,
      backerId: backerId,
      amountGuaranteed: amountGuaranteed,
    );
    state = [...state, created];
    return created;
  }
}

final backingListProvider =
    StateNotifierProvider<BackingNotifier, List<Backing>>((ref) => BackingNotifier());

final backingRepositoryProvider = Provider<BackingRepository>((ref) {
  return ref.read(backingListProvider.notifier);
});

final backingsForLoanProvider = Provider.family<List<Backing>, String>((ref, loanId) {
  return ref.watch(backingListProvider).where((b) => b.loanId == loanId).toList();
});

final totalGuaranteedForLoanProvider = Provider.family<double, String>((ref, loanId) {
  return ref.watch(backingsForLoanProvider(loanId)).fold(0.0, (a, b) => a + b.amountGuaranteed);
});

/// Recomputes when backings or loan data change.
final loanRiskLevelProvider = Provider.family<LoanRiskLevel, String>((ref, loanId) {
  final loanAsync = ref.watch(loanByIdProvider(loanId));
  final loan = loanAsync.valueOrNull;
  if (loan == null) return LoanRiskLevel.high;
  final total = ref.watch(totalGuaranteedForLoanProvider(loanId));
  final cov = LoanRiskCalculator.coverageRatio(
    principal: loan.amount,
    totalGuaranteed: total,
  );
  return LoanRiskCalculator.fromCoverage(cov);
});
