import '../../domain/entities/loan.dart';

class LoanModel {
  const LoanModel({
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
  final String purpose;
  final int durationDays;
  final double interestRate;
  final String status;
  final String createdAt;

  factory LoanModel.fromEntity(Loan loan) {
    return LoanModel(
      id: loan.id,
      borrowerId: loan.borrowerId,
      amount: loan.amount,
      purpose: loan.purpose.name,
      durationDays: loan.durationDays,
      interestRate: loan.interestRate,
      status: loan.status.name,
      createdAt: loan.createdAt.toIso8601String(),
    );
  }

  Loan toEntity() {
    return Loan(
      id: id,
      borrowerId: borrowerId,
      amount: amount,
      purpose: LoanPurpose.values.firstWhere((e) => e.name == purpose),
      durationDays: durationDays,
      interestRate: interestRate,
      status: LoanStatus.values.firstWhere((e) => e.name == status),
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'borrowerId': borrowerId,
        'amount': amount,
        'purpose': purpose,
        'durationDays': durationDays,
        'interestRate': interestRate,
        'status': status,
        'createdAt': createdAt,
      };

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      borrowerId: json['borrowerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      interestRate: (json['interestRate'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
