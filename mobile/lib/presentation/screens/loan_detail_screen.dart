import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan_risk_level.dart';
import '../providers/backing_providers.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_display.dart';

const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);

class LoanDetailScreen extends ConsumerWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final loanAsync = ref.watch(loanByIdProvider(loanId));
    final backers = ref.watch(backingsForLoanProvider(loanId));
    final totalGuaranteed = ref.watch(totalGuaranteedForLoanProvider(loanId));
    final risk = ref.watch(loanRiskLevelProvider(loanId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan details'),
      ),
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (loan) {
          if (loan == null) {
            return const Center(child: Text('Loan not found.'));
          }
          final cov = LoanRiskCalculator.coverageRatio(
            principal: loan.amount,
            totalGuaranteed: totalGuaranteed,
          );
          final canBackMore = totalGuaranteed < loan.amount;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loan.displayTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loan.displaySubtitle,
                    style: textTheme.bodyMedium?.copyWith(color: _muted),
                  ),
                  const SizedBox(height: 20),
                  _RiskCard(risk: risk, coveragePercent: cov * 100),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Principal',
                    value: currency.format(loan.amount),
                    textTheme: textTheme,
                  ),
                  _SummaryRow(
                    label: 'Total guaranteed',
                    value: currency.format(totalGuaranteed),
                    textTheme: textTheme,
                    valueColor: const Color(0xFF166534),
                  ),
                  _SummaryRow(
                    label: 'Coverage',
                    value: '${(cov * 100).toStringAsFixed(0)}%',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Backers (${backers.length})',
                    style: textTheme.titleSmall?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (backers.isEmpty)
                    Text(
                      'No backers yet — be the first to vouch.',
                      style: textTheme.bodyMedium?.copyWith(color: _muted),
                    )
                  else
                    ...backers.map(
                      (b) => _BackerTile(
                        backerId: b.backerId,
                        amount: b.amountGuaranteed,
                        currency: currency,
                        textTheme: textTheme,
                        currentBackerId: ref.watch(currentBackerIdProvider),
                      ),
                    ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: canBackMore
                        ? () => _openBackModal(
                              context,
                              ref,
                              loanId: loanId,
                              principal: loan.amount,
                              currentTotal: totalGuaranteed,
                            )
                        : null,
                    icon: const Icon(Icons.verified_user_outlined),
                    label: Text(
                      canBackMore ? 'Back this loan' : 'Fully backed',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _openBackModal(
  BuildContext context,
  WidgetRef ref, {
  required String loanId,
  required double principal,
  required double currentTotal,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
        ),
        child: _BackLoanSheet(
          principal: principal,
          currentTotalGuaranteed: currentTotal,
          onSubmit: (amount) async {
            final backerId = ref.read(currentBackerIdProvider);
            await ref.read(backingListProvider.notifier).addBacking(
                  loanId: loanId,
                  backerId: backerId,
                  amountGuaranteed: amount,
                );
            if (ctx.mounted) Navigator.of(ctx).pop();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Backed ${NumberFormat.currency(symbol: r'$').format(amount)}.',
                  ),
                ),
              );
            }
          },
        ),
      );
    },
  );
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.risk,
    required this.coveragePercent,
  });

  final LoanRiskLevel risk;
  final double coveragePercent;

  Color _riskColor() {
    switch (risk) {
      case LoanRiskLevel.high:
        return const Color(0xFFB91C1C);
      case LoanRiskLevel.elevated:
        return const Color(0xFFC2410C);
      case LoanRiskLevel.medium:
        return const Color(0xFFD97706);
      case LoanRiskLevel.low:
        return const Color(0xFF166534);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = _riskColor();
    return Material(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk level',
                    style: textTheme.labelMedium?.copyWith(color: _muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    risk.label,
                    style: textTheme.headlineSmall?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Peer coverage',
                  style: textTheme.labelMedium?.copyWith(color: _muted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${coveragePercent.toStringAsFixed(0)}%',
                  style: textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextTheme textTheme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: _muted),
          ),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              color: valueColor ?? _ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackerTile extends StatelessWidget {
  const _BackerTile({
    required this.backerId,
    required this.amount,
    required this.currency,
    required this.textTheme,
    required this.currentBackerId,
  });

  final String backerId;
  final double amount;
  final NumberFormat currency;
  final TextTheme textTheme;
  final String currentBackerId;

  @override
  Widget build(BuildContext context) {
    final label = backerId == currentBackerId
        ? 'You'
        : 'Backer ${backerId.length > 6 ? backerId.substring(backerId.length - 6) : backerId}';
    return Material(
      color: const Color(0xFFE8EEF5),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: _ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              currency.format(amount),
              style: textTheme.titleSmall?.copyWith(
                color: _ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackLoanSheet extends StatefulWidget {
  const _BackLoanSheet({
    required this.principal,
    required this.currentTotalGuaranteed,
    required this.onSubmit,
  });

  final double principal;
  final double currentTotalGuaranteed;
  final Future<void> Function(double amount) onSubmit;

  @override
  State<_BackLoanSheet> createState() => _BackLoanSheetState();
}

class _BackLoanSheetState extends State<_BackLoanSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _remaining {
    final r = widget.principal - widget.currentTotalGuaranteed;
    return r < 0 ? 0.0 : r;
  }

  Future<void> _submit() async {
    final cleaned = _controller.text.replaceAll(',', '').trim();
    final v = double.tryParse(cleaned);
    setState(() => _error = null);
    if (v == null || v <= 0) {
      setState(() => _error = 'Enter a positive amount');
      return;
    }
    if (_remaining > 0 && v > _remaining) {
      setState(
        () => _error =
            'Amount exceeds uncovered principal (${NumberFormat.currency(symbol: r'$').format(_remaining)} left)',
      );
      return;
    }
    if (_remaining <= 0 && v > 0) {
      setState(() => _error = 'Principal is already fully covered by guarantees.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(v);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Guarantee amount',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _remaining > 0
              ? 'Up to ${NumberFormat.currency(symbol: r'$').format(_remaining)} uncovered.'
              : 'This loan is fully covered.',
          style: textTheme.bodySmall?.copyWith(color: _muted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: !_submitting && _remaining > 0,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            prefixText: r'$ ',
            hintText: '0.00',
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting || _remaining <= 0 ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm guarantee'),
        ),
      ],
    );
  }
}
