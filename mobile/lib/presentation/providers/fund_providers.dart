import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';
import 'backing_providers.dart';
import 'loan_providers.dart';

/// Loans visible on the lending marketplace (not own borrowings, not repaid).
final marketplaceLoansProvider = Provider<AsyncValue<List<Loan>>>((ref) {
  return ref.watch(activeLoansProvider).whenData((loans) {
    final uid = ref.read(currentBorrowerIdProvider);
    return loans
        .where(
          (l) => l.borrowerId != uid && l.status != LoanStatus.repaid,
        )
        .toList();
  });
});

/// Total ₦ this user has committed as guarantees / fundings.
final userTotalInvestedProvider = Provider<double>((ref) {
  final backerId = ref.watch(currentBackerIdProvider);
  return ref.watch(backingListProvider).fold<double>(
        0,
        (a, b) => b.backerId == backerId ? a + b.amountGuaranteed : a,
      );
});

/// Mock expected return (2% on outstanding for demo).
final userExpectedReturnsProvider = Provider<double>((ref) {
  final invested = ref.watch(userTotalInvestedProvider);
  return invested * 0.02;
});

/// Loans the user has backed (for portfolio “active”).
final userBackedLoansProvider = FutureProvider<List<Loan>>((ref) async {
  final repo = ref.read(loanRepositoryProvider);
  final all = await repo.listLoans();
  final backedIds = ref.watch(backingListProvider).map((b) => b.loanId).toSet();
  return all
      .where(
        (l) => backedIds.contains(l.id) && l.status != LoanStatus.repaid,
      )
      .toList();
});

/// Trust score label for marketplace cards (until API provides real scores).
int trustScoreForBorrower(String borrowerId) {
  final h = borrowerId.hashCode.abs();
  return 650 + (h % 350);
}

String borrowerDisplayName(String borrowerId) {
  if (borrowerId == 'peer_other') return 'Peer borrower';
  if (borrowerId == 'local-borrower') return 'You';
  if (borrowerId.startsWith('peer_')) {
    final tail = borrowerId.length > 5 ? borrowerId.substring(5) : borrowerId;
    return tail.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}';
    }).join(' ');
  }
  return 'Borrower ${borrowerId.length > 8 ? borrowerId.substring(borrowerId.length - 8) : borrowerId}';
}
