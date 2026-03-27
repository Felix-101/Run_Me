import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class CreateLoanRequestParams {
  const CreateLoanRequestParams({
    required this.borrowerId,
    required this.amount,
    required this.purpose,
    required this.durationDays,
    this.audience = LoanAudience.public,
    this.reason,
    this.proofFileLabel,
  });

  final String borrowerId;
  final double amount;
  final LoanPurpose purpose;
  final int durationDays;
  final LoanAudience audience;
  final String? reason;
  final String? proofFileLabel;
}

/// Creates a pending loan with a simple interest policy (mock / MVP).
class CreateLoanRequestUseCase {
  CreateLoanRequestUseCase(this._repository);

  final LoanRepository _repository;

  /// Flat 0% peer rate for micro-loans under policy; adjust as product evolves.
  static const double _peerMicroLoanApr = 0.0;

  Future<Loan> call(CreateLoanRequestParams params) async {
    final id = 'loan_${DateTime.now().millisecondsSinceEpoch}';
    final reasonTrim = params.reason?.trim();
    final loan = Loan(
      id: id,
      borrowerId: params.borrowerId,
      lenderId: null,
      amount: params.amount,
      purpose: params.purpose,
      durationDays: params.durationDays,
      interestRate: _peerMicroLoanApr,
      status: LoanStatus.pending,
      createdAt: DateTime.now().toUtc(),
      audience: params.audience,
      reason: (reasonTrim == null || reasonTrim.isEmpty) ? null : reasonTrim,
      proofFileLabel: params.proofFileLabel,
    );
    return _repository.createLoan(loan);
  }
}
