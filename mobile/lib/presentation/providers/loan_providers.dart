import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../domain/usecases/create_loan_request.dart';

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryImpl(),
);

final createLoanRequestUseCaseProvider = Provider<CreateLoanRequestUseCase>(
  (ref) => CreateLoanRequestUseCase(ref.read(loanRepositoryProvider)),
);

/// Until auth exposes a stable user id, use a stable mock id (override in tests).
final currentBorrowerIdProvider = Provider<String>((ref) => 'local-borrower');

final activeLoansProvider = FutureProvider<List<Loan>>((ref) async {
  return ref.read(loanRepositoryProvider).listLoans();
});

final loanByIdProvider = FutureProvider.family<Loan?, String>((ref, id) async {
  return ref.read(loanRepositoryProvider).getLoanById(id);
});

final loanRequestControllerProvider =
    StateNotifierProvider<LoanRequestController, LoanRequestState>(
  (ref) => LoanRequestController(
    ref.read(createLoanRequestUseCaseProvider),
    ref.read(currentBorrowerIdProvider),
  ),
);

class LoanRequestState {
  const LoanRequestState({
    this.isSubmitting = false,
    this.loan,
    this.errorMessage,
    this.amountError,
    this.durationError,
  });

  final bool isSubmitting;
  final Loan? loan;
  final String? errorMessage;
  final String? amountError;
  final String? durationError;

  bool get isSuccess => loan != null;
}

class LoanRequestController extends StateNotifier<LoanRequestState> {
  LoanRequestController(this._useCase, this._borrowerId)
      : super(const LoanRequestState());

  final CreateLoanRequestUseCase _useCase;
  final String _borrowerId;

  static const double _maxAmount = 50_000;
  static const List<int> allowedDurations = [7, 14, 30, 60, 90];

  void reset() {
    state = const LoanRequestState();
  }

  ({String? amount, String? duration}) validate({
    required String amountText,
    required int? durationDays,
  }) {
    String? amountErr;
    final cleaned = amountText.replaceAll(',', '').trim();
    final parsed = double.tryParse(cleaned);
    if (cleaned.isEmpty) {
      amountErr = 'Enter an amount';
    } else if (parsed == null || parsed <= 0) {
      amountErr = 'Enter a valid positive amount';
    } else if (parsed > _maxAmount) {
      amountErr = 'Amount cannot exceed ${_maxAmount.toStringAsFixed(0)}';
    }

    String? durationErr;
    if (durationDays == null) {
      durationErr = 'Choose a duration';
    } else if (!allowedDurations.contains(durationDays)) {
      durationErr = 'Invalid duration';
    }

    return (amount: amountErr, duration: durationErr);
  }

  Future<void> submit({
    required String amountText,
    required LoanPurpose purpose,
    required int? durationDays,
  }) async {
    final v = validate(amountText: amountText, durationDays: durationDays);
    if (v.amount != null || v.duration != null) {
      state = LoanRequestState(
        amountError: v.amount,
        durationError: v.duration,
      );
      return;
    }

    final amount = double.parse(amountText.replaceAll(',', '').trim());

    state = const LoanRequestState(isSubmitting: true);

    try {
      final loan = await _useCase(
        CreateLoanRequestParams(
          borrowerId: _borrowerId,
          amount: amount,
          purpose: purpose,
          durationDays: durationDays!,
        ),
      );
      state = LoanRequestState(loan: loan);
    } catch (e) {
      state = LoanRequestState(errorMessage: e.toString());
    }
  }
}
