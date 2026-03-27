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

/// Who can see and fund the request.
enum LoanAudience {
  public,
  friendsOnly,
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

extension LoanAudienceLabel on LoanAudience {
  String get label {
    switch (this) {
      case LoanAudience.public:
        return 'Public';
      case LoanAudience.friendsOnly:
        return 'Friends only';
    }
  }
}

/// Domain entity for a loan record.
class Loan {
  const Loan({
    required this.id,
    required this.borrowerId,
    this.lenderId,
    required this.amount,
    required this.purpose,
    required this.durationDays,
    required this.interestRate,
    required this.status,
    required this.createdAt,
    this.audience = LoanAudience.public,
    this.reason,
    this.proofFileLabel,
    this.repaidAmount = 0,
  });

  final String id;
  final String borrowerId;
  /// When funded, the peer who supplied capital (for “you are owed” summaries).
  final String? lenderId;
  final double amount;
  final LoanPurpose purpose;
  final int durationDays;
  /// Annual rate as decimal, e.g. 0.05 for 5%.
  final double interestRate;
  final LoanStatus status;
  final DateTime createdAt;
  final LoanAudience audience;
  /// Optional borrower narrative (why you need this loan).
  final String? reason;
  /// Display name of an attached proof file, if any.
  final String? proofFileLabel;
  /// Principal repaid so far (mock ledger until API exists).
  final double repaidAmount;

  /// Loan end date for “time remaining” (simple: created + duration).
  DateTime get dueAtUtc => createdAt.add(Duration(days: durationDays));

  double get outstandingPrincipal => (amount - repaidAmount).clamp(0.0, amount);

  Loan copyWith({
    String? id,
    String? borrowerId,
    String? lenderId,
    double? amount,
    LoanPurpose? purpose,
    int? durationDays,
    double? interestRate,
    LoanStatus? status,
    DateTime? createdAt,
    LoanAudience? audience,
    String? reason,
    String? proofFileLabel,
    double? repaidAmount,
  }) {
    return Loan(
      id: id ?? this.id,
      borrowerId: borrowerId ?? this.borrowerId,
      lenderId: lenderId ?? this.lenderId,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      durationDays: durationDays ?? this.durationDays,
      interestRate: interestRate ?? this.interestRate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      audience: audience ?? this.audience,
      reason: reason ?? this.reason,
      proofFileLabel: proofFileLabel ?? this.proofFileLabel,
      repaidAmount: repaidAmount ?? this.repaidAmount,
    );
  }
}
