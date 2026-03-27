import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';
import 'fund_providers.dart';
import 'grant_providers.dart';
import 'loan_providers.dart';

/// Aggregated profile metrics for the current user (mock IDs until full auth).
class ProfileStats {
  const ProfileStats({
    required this.loansTaken,
    required this.loansRepaid,
    required this.amountLentNaira,
    required this.grantsGivenNaira,
  });

  final int loansTaken;
  final int loansRepaid;
  final double amountLentNaira;
  final double grantsGivenNaira;
}

final profileStatsProvider = Provider<ProfileStats>((ref) {
  final loansAsync = ref.watch(activeLoansProvider);
  final loans = loansAsync.asData?.value ?? <Loan>[];
  final borrowerId = ref.watch(currentBorrowerIdProvider);
  final mine = loans.where((l) => l.borrowerId == borrowerId).toList();

  final loansTaken = mine.length;
  final loansRepaid = mine.where((l) => l.status == LoanStatus.repaid).length;

  final amountLent = ref.watch(userTotalInvestedProvider);

  final grantState = ref.watch(grantStoreProvider);
  var grantsGiven = 0.0;
  for (final list in grantState.donationsByGrant.values) {
    for (final d in list) {
      if (d.donorLabel == 'You') {
        grantsGiven += d.amountNaira;
      }
    }
  }

  return ProfileStats(
    loansTaken: loansTaken,
    loansRepaid: loansRepaid,
    amountLentNaira: amountLent,
    grantsGivenNaira: grantsGiven,
  );
});

/// Display strings until `/me` exposes name & school.
final profileDisplayNameProvider = Provider<String>((ref) => 'Alex Thompson');

final profileSchoolProvider = Provider<String>((ref) => 'Babcock University');
