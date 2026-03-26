import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';

/// In-memory store simulating a backend until an API is wired.
class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl() {
    _loans.addAll(_seedLoans);
  }

  final List<Loan> _loans = [];

  static final List<Loan> _seedLoans = [
    Loan(
      id: 'loan_seed_textbook',
      borrowerId: 'borrower_demo',
      amount: 420,
      purpose: LoanPurpose.rent,
      durationDays: 30,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 3, 1),
    ),
    Loan(
      id: 'loan_seed_lab',
      borrowerId: 'borrower_demo',
      amount: 1280.5,
      purpose: LoanPurpose.emergency,
      durationDays: 60,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 2, 15),
    ),
    Loan(
      id: 'loan_seed_rent',
      borrowerId: 'borrower_demo',
      amount: 900,
      purpose: LoanPurpose.rent,
      durationDays: 30,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 1, 10),
    ),
  ];

  @override
  Future<Loan> createLoan(Loan loan) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _loans.add(loan);
    return loan;
  }

  @override
  Future<List<Loan>> loansForBorrower(String borrowerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _loans.where((l) => l.borrowerId == borrowerId).toList();
  }

  @override
  Future<List<Loan>> listLoans() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<Loan>.from(_loans);
  }

  @override
  Future<Loan?> getLoanById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    try {
      return _loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
