import '../../domain/entities/loan.dart';

extension LoanDisplay on Loan {
  String get displayTitle {
    return switch (id) {
      'loan_seed_textbook' => 'Textbook bridge',
      'loan_seed_lab' => 'Lab equipment',
      'loan_seed_rent' => 'Campus rent float',
      _ => '${purpose.label} · $durationDays days',
    };
  }

  String get displaySubtitle {
    return switch (id) {
      'loan_seed_textbook' => 'Due Mar 30 · 0% APR peer pool',
      'loan_seed_lab' => 'Installment 2 of 4',
      'loan_seed_rent' => 'Backed by peers',
      _ => '${status.name} · ${durationDays}d',
    };
  }
}
