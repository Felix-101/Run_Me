import '../../domain/entities/loan.dart';

class LoanModel {
  const LoanModel({
    required this.id,
    required this.borrowerId,
    this.lenderId,
    required this.amount,
    required this.purpose,
    required this.durationDays,
    required this.interestRate,
    required this.status,
    required this.createdAt,
    this.audience,
    this.reason,
    this.proofFileLabel,
    this.repaidAmount,
  });

  final String id;
  final String borrowerId;
  final String? lenderId;
  final double amount;
  final String purpose;
  final int durationDays;
  final double interestRate;
  final String status;
  final String createdAt;
  final String? audience;
  final String? reason;
  final String? proofFileLabel;
  final double? repaidAmount;

  factory LoanModel.fromEntity(Loan loan) {
    return LoanModel(
      id: loan.id,
      borrowerId: loan.borrowerId,
      lenderId: loan.lenderId,
      amount: loan.amount,
      purpose: loan.purpose.name,
      durationDays: loan.durationDays,
      interestRate: loan.interestRate,
      status: loan.status.name,
      createdAt: loan.createdAt.toIso8601String(),
      audience: loan.audience.name,
      reason: loan.reason,
      proofFileLabel: loan.proofFileLabel,
      repaidAmount: loan.repaidAmount,
    );
  }

  Loan toEntity() {
    return Loan(
      id: id,
      borrowerId: borrowerId,
      lenderId: lenderId,
      amount: amount,
      purpose: LoanPurpose.values.firstWhere((e) => e.name == purpose),
      durationDays: durationDays,
      interestRate: interestRate,
      status: LoanStatus.values.firstWhere((e) => e.name == status),
      createdAt: DateTime.parse(createdAt),
      audience: audience != null
          ? LoanAudience.values.firstWhere((e) => e.name == audience)
          : LoanAudience.public,
      reason: reason,
      proofFileLabel: proofFileLabel,
      repaidAmount: repaidAmount ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'borrowerId': borrowerId,
        if (lenderId != null) 'lenderId': lenderId,
        'amount': amount,
        'purpose': purpose,
        'durationDays': durationDays,
        'interestRate': interestRate,
        'status': status,
        'createdAt': createdAt,
        if (audience != null) 'audience': audience,
        if (reason != null) 'reason': reason,
        if (proofFileLabel != null) 'proofFileLabel': proofFileLabel,
        if (repaidAmount != null) 'repaidAmount': repaidAmount,
      };

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      borrowerId: json['borrowerId'] as String,
      lenderId: json['lenderId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      interestRate: (json['interestRate'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      audience: json['audience'] as String?,
      reason: json['reason'] as String?,
      proofFileLabel: json['proofFileLabel'] as String?,
      repaidAmount: (json['repaidAmount'] as num?)?.toDouble(),
    );
  }
}
