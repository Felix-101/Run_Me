/// A peer guarantee on a loan (vouch / back a friend).
class Backing {
  const Backing({
    required this.id,
    required this.loanId,
    required this.backerId,
    required this.amountGuaranteed,
  });

  final String id;
  final String loanId;
  final String backerId;
  final double amountGuaranteed;
}
