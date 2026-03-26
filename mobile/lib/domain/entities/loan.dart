/// Lifecycle of a loan in the peer ledger.
enum LoanStatus {
  pending,
  funded,
  repaid,
}

/// Allowed loan purposes for requests.
enum LoanPurpose {
  rent,
  food,
  emergency,
}

extension LoanPurposeLabel on LoanPurpose {
  String get label {
    switch (this) {
      case LoanPurpose.rent:
        return 'Rent';
      case LoanPurpose.food:
        return 'Food';
      case LoanPurpose.emergency:
        return 'Emergency';
    }
  }
}

/// Domain entity for a loan record.
class Loan {
  const Loan({
    required this.id,
    required this.borrowerId,
    required this.amount,
    required this.purpose,
    required this.durationDays,
    required this.interestRate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String borrowerId;
  final double amount;
  final LoanPurpose purpose;
  final int durationDays;
  /// Annual rate as decimal, e.g. 0.05 for 5%.
  final double interestRate;
  final LoanStatus status;
  final DateTime createdAt;
}
