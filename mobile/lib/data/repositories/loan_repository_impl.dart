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
      borrowerId: 'local-borrower',
      lenderId: 'peer_amina',
      amount: 420,
      purpose: LoanPurpose.rent,
      durationDays: 30,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 3, 1),
      audience: LoanAudience.public,
      reason: 'Bridge until textbook stipend lands.',
      repaidAmount: 105,
    ),
    Loan(
      id: 'loan_seed_lab',
      borrowerId: 'local-borrower',
      lenderId: 'peer_chidi',
      amount: 1280.5,
      purpose: LoanPurpose.emergency,
      durationDays: 60,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 2, 15),
      audience: LoanAudience.friendsOnly,
      repaidAmount: 320,
    ),
    Loan(
      id: 'loan_seed_rent',
      borrowerId: 'local-borrower',
      lenderId: 'peer_amina',
      amount: 900,
      purpose: LoanPurpose.rent,
      durationDays: 30,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 1, 10),
      audience: LoanAudience.public,
      repaidAmount: 0,
    ),
    Loan(
      id: 'loan_seed_lent_out',
      borrowerId: 'peer_other',
      lenderId: 'local-borrower',
      amount: 2500,
      purpose: LoanPurpose.food,
      durationDays: 30,
      interestRate: 0,
      status: LoanStatus.funded,
      createdAt: DateTime.utc(2025, 3, 5),
      audience: LoanAudience.public,
      repaidAmount: 0,
    ),
    Loan(
      id: 'loan_seed_lent_out_2',
      borrowerId: 'peer_other',
      lenderId: 'local-borrower',
      amount: 750,
      purpose: LoanPurpose.emergency,
      durationDays: 14,
      interestRate: 0,
      status: LoanStatus.pending,
      createdAt: DateTime.utc(2025, 3, 20),
      audience: LoanAudience.friendsOnly,
      repaidAmount: 0,
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

  @override
  Future<Loan?> applyRepayment(String loanId, double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final i = _loans.indexWhere((l) => l.id == loanId);
    if (i < 0) return null;
    final loan = _loans[i];
    if (amount <= 0) return loan;
    final newRepaid = loan.repaidAmount + amount;
    var status = loan.status;
    if (newRepaid >= loan.amount && loan.status != LoanStatus.repaid) {
      status = LoanStatus.repaid;
    }
    final updated = loan.copyWith(
      repaidAmount: newRepaid >= loan.amount ? loan.amount : newRepaid,
      status: status,
    );
    _loans[i] = updated;
    return updated;
  }
}
