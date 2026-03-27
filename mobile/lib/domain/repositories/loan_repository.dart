import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Loan> createLoan(Loan loan);

  Future<List<Loan>> loansForBorrower(String borrowerId);

  Future<List<Loan>> listLoans();

  Future<Loan?> getLoanById(String id);

  /// Adds to [Loan.repaidAmount] and may set status to [LoanStatus.repaid].
  Future<Loan?> applyRepayment(String loanId, double amount);
}
