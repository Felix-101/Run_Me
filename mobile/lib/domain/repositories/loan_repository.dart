import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Loan> createLoan(Loan loan);

  Future<List<Loan>> loansForBorrower(String borrowerId);

  Future<List<Loan>> listLoans();

  Future<Loan?> getLoanById(String id);
}
