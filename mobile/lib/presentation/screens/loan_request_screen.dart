import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';

const _colorInk = Color(0xFF101828);
const _colorMuted = Color(0xFF667085);

class LoanRequestScreen extends ConsumerStatefulWidget {
  const LoanRequestScreen({super.key, this.embedInShell = false});

  /// When true, omits [Scaffold] / app bar so the screen can sit inside a shell with bottom nav.
  final bool embedInShell;

  @override
  ConsumerState<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends ConsumerState<LoanRequestScreen> {
  final _amountController = TextEditingController();
  LoanPurpose _purpose = LoanPurpose.rent;
  int? _durationDays = 30;

  static const Color _fieldFill = Color(0xFFE8F0FA);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF5DD879);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loanRequestControllerProvider);
    final notifier = ref.read(loanRequestControllerProvider.notifier);

    ref.listen<LoanRequestState>(loanRequestControllerProvider, (prev, next) {
      if (next.isSuccess && prev?.loan?.id != next.loan?.id) {
        ref.invalidate(activeLoansProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loan request ${next.loan!.id} submitted (${next.loan!.status.name}).',
            ),
          ),
        );
      }
    });

    final scroll = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Text(
                  'Request a loan',
                  style: textTheme.headlineSmall?.copyWith(
                    color: _colorInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter amount, purpose, and how long you need to repay.',
                  style: textTheme.bodyMedium?.copyWith(color: _colorMuted),
                ),
                const SizedBox(height: 24),
                Text(
                  'Amount',
                  style: textTheme.labelLarge?.copyWith(
                    color: _colorInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  style: textTheme.bodyLarge?.copyWith(color: _colorInk),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: _fieldFill,
                    errorText: state.amountError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Purpose',
                  style: textTheme.labelLarge?.copyWith(
                    color: _colorInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<LoanPurpose>(
                  value: _purpose,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: LoanPurpose.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.label),
                        ),
                      )
                      .toList(),
                  onChanged: state.isSubmitting
                      ? null
                      : (v) {
                          if (v != null) setState(() => _purpose = v);
                        },
                ),
                const SizedBox(height: 20),
                Text(
                  'Duration',
                  style: textTheme.labelLarge?.copyWith(
                    color: _colorInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LoanRequestController.allowedDurations.map((d) {
                    final selected = _durationDays == d;
                    return ChoiceChip(
                      label: Text('$d days'),
                      selected: selected,
                      onSelected: state.isSubmitting
                          ? null
                          : (sel) {
                              setState(() => _durationDays = sel ? d : null);
                            },
                    );
                  }).toList(),
                ),
                if (state.durationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.durationError!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [_greenLeft, _greenRight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _greenLeft.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: state.isSubmitting
                          ? null
                          : () async {
                              await notifier.submit(
                                amountText: _amountController.text,
                                purpose: _purpose,
                                durationDays: _durationDays,
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit request',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.isSuccess) ...[
                  const SizedBox(height: 24),
                  Material(
                    color: const Color(0xFFE8F8EC),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request recorded',
                            style: textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SuccessRow(
                            label: 'ID',
                            value: state.loan!.id,
                            textTheme: textTheme,
                          ),
                          _SuccessRow(
                            label: 'Amount',
                            value:
                                '\$${state.loan!.amount.toStringAsFixed(2)}',
                            textTheme: textTheme,
                          ),
                          _SuccessRow(
                            label: 'Purpose',
                            value: state.loan!.purpose.label,
                            textTheme: textTheme,
                          ),
                          _SuccessRow(
                            label: 'Duration',
                            value: '${state.loan!.durationDays} days',
                            textTheme: textTheme,
                          ),
                          _SuccessRow(
                            label: 'Status',
                            value: state.loan!.status.name,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              notifier.reset();
                              _amountController.clear();
                              setState(() {
                                _purpose = LoanPurpose.rent;
                                _durationDays = 30;
                              });
                            },
                            child: const Text('New request'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );

    if (widget.embedInShell) {
      return scroll;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan request'),
      ),
      body: scroll,
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: _colorMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: _colorInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
