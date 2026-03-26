import '../entities/backing.dart';

abstract class BackingRepository {
  List<Backing> backingForLoan(String loanId);

  Future<Backing> addBacking({
    required String loanId,
    required String backerId,
    required double amountGuaranteed,
  });
}
