import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';

const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);

/// Repayment schedule + pay full / partial (mock ledger via [LoanRepository.applyRepayment]).
class LoanRepaymentScreen extends ConsumerStatefulWidget {
  const LoanRepaymentScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanRepaymentScreen> createState() =>
      _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends ConsumerState<LoanRepaymentScreen> {
  final _partialController = TextEditingController();
  bool _paying = false;
  String? _error;

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  Future<void> _pay(double amount) async {
    if (amount <= 0) {
      setState(() => _error = 'Enter a positive amount');
      return;
    }
    setState(() {
      _error = null;
      _paying = true;
    });
    try {
      final repo = ref.read(loanRepositoryProvider);
      final updated = await repo.applyRepayment(widget.loanId, amount);
      if (!mounted) return;
      if (updated == null) {
        setState(() => _error = 'Could not apply payment');
        return;
      }
      ref.invalidate(loanByIdProvider(widget.loanId));
      ref.invalidate(activeLoansProvider);
      ref.invalidate(borrowerLoansProvider);
      _partialController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paid ${NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(amount)}',
          ),
        ),
      );
      if (updated.status == LoanStatus.repaid && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final loanAsync = ref.watch(loanByIdProvider(widget.loanId));

    return Scaffold(
      appBar: AppBar(title: const Text('Repayment')),
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (loan) {
          if (loan == null) {
            return const Center(child: Text('Loan not found.'));
          }
          final outstanding = loan.outstandingPrincipal;
          final schedule = _buildSchedule(loan);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Repayment schedule',
                    style: textTheme.titleLarge?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Principal ${currency.format(loan.amount)} · '
                    'Paid ${currency.format(loan.repaidAmount)} · '
                    'Outstanding ${currency.format(outstanding)}',
                    style: textTheme.bodyMedium?.copyWith(color: _muted),
                  ),
                  const SizedBox(height: 20),
                  ...schedule.map(
                    (row) => _ScheduleRow(
                      label: row.label,
                      due: row.due,
                      amount: row.amount,
                      status: row.status,
                      currency: currency,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _paying || outstanding <= 0
                        ? null
                        : () => _pay(outstanding),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1B833E),
                    ),
                    child: _paying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            outstanding <= 0
                                ? 'Fully repaid'
                                : 'Pay now (${currency.format(outstanding)})',
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Partial payment',
                    style: textTheme.titleSmall?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _partialController,
                    enabled: !_paying && outstanding > 0,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '₦ ',
                      hintText: '0.00',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _paying || outstanding <= 0
                        ? null
                        : () {
                            final cleaned =
                                _partialController.text.replaceAll(',', '').trim();
                            final v = double.tryParse(cleaned);
                            if (v == null || v <= 0) {
                              setState(() => _error = 'Enter a valid amount');
                              return;
                            }
                            if (v > outstanding) {
                              setState(
                                () => _error =
                                    'Cannot exceed outstanding ${currency.format(outstanding)}',
                              );
                              return;
                            }
                            _pay(v);
                          },
                    child: const Text('Pay partial amount'),
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

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.label,
    required this.due,
    required this.amount,
    required this.status,
    required this.currency,
    required this.textTheme,
  });

  final String label;
  final String due;
  final double amount;
  final String status;
  final NumberFormat currency;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.titleSmall?.copyWith(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      due,
                      style: textTheme.bodySmall?.copyWith(color: _muted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(amount),
                    style: textTheme.titleSmall?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    status,
                    style: textTheme.labelSmall?.copyWith(
                      color: status == 'Paid'
                          ? const Color(0xFF166534)
                          : _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleLine {
  const _ScheduleLine({
    required this.label,
    required this.due,
    required this.amount,
    required this.status,
  });

  final String label;
  final String due;
  final double amount;
  final String status;
}

List<_ScheduleLine> _buildSchedule(Loan loan) {
  const installments = 4;
  final each = loan.amount / installments;
  final dayStep = (loan.durationDays / installments).ceil();
  final dateFmt = DateFormat.MMMd();
  final repaid = loan.repaidAmount;
  var cumulative = 0.0;
  final lines = <_ScheduleLine>[];
  for (var i = 0; i < installments; i++) {
    cumulative += each;
    final dueDate = loan.createdAt.add(Duration(days: dayStep * (i + 1)));
    final covered = repaid >= cumulative - 1e-6;
    lines.add(
      _ScheduleLine(
        label: 'Installment ${i + 1} of $installments',
        due: 'Due ${dateFmt.format(dueDate.toLocal())}',
        amount: each,
        status: covered ? 'Paid' : 'Pending',
      ),
    );
  }
  return lines;
}
