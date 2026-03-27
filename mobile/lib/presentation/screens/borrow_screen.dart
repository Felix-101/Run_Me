import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_display.dart';
import '../widgets/loan_list_tile.dart';

const _colorInk = Color(0xFF101828);
const _colorMuted = Color(0xFF667085);

/// Borrow tab: landing with active loans + create request flow.
class BorrowScreen extends ConsumerStatefulWidget {
  const BorrowScreen({super.key, this.embedInShell = false});

  final bool embedInShell;

  @override
  ConsumerState<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends ConsumerState<BorrowScreen> {
  bool _showForm = false;

  void _openForm() {
    ref.read(loanRequestControllerProvider.notifier).reset();
    setState(() => _showForm = true);
  }

  void _closeForm() {
    ref.read(loanRequestControllerProvider.notifier).reset();
    setState(() => _showForm = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    final body = _showForm
        ? _LoanRequestForm(
            onBack: _closeForm,
            onSubmittedSuccess: () {
              ref.read(loanRequestControllerProvider.notifier).reset();
              setState(() => _showForm = false);
              ref.invalidate(borrowerLoansProvider);
              ref.invalidate(activeLoansProvider);
            },
          )
        : _BorrowLanding(
            onRequestLoan: _openForm,
            textTheme: textTheme,
            currency: currency,
          );

    if (widget.embedInShell) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow')),
      body: body,
    );
  }
}

class _BorrowLanding extends ConsumerWidget {
  const _BorrowLanding({
    required this.onRequestLoan,
    required this.textTheme,
    required this.currency,
  });

  final VoidCallback onRequestLoan;
  final TextTheme textTheme;
  final NumberFormat currency;

  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF5DD879);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(borrowerLoansProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Borrow',
                style: textTheme.headlineSmall?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Request a new loan or track what you already owe.',
                style: textTheme.bodyMedium?.copyWith(color: _colorMuted),
              ),
              const SizedBox(height: 24),
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
                    onTap: onRequestLoan,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Request loan',
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
              const SizedBox(height: 32),
              Text(
                'Your active loans',
                style: textTheme.titleMedium?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              loansAsync.when(
                data: (loans) {
                  final active = loans
                      .where((l) => l.status != LoanStatus.repaid)
                      .toList();
                  if (active.isEmpty) {
                    return Text(
                      'No active loans yet. Tap Request loan to get started.',
                      style: textTheme.bodyMedium?.copyWith(color: _colorMuted),
                    );
                  }
                  return Column(
                    children: active
                        .map(
                          (loan) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LoanListTile(
                              title: loan.displayTitle,
                              subtitle: loan.displaySubtitle,
                              amount: loan.amount,
                              currency: currency,
                              textTheme: textTheme,
                              onTap: () => Navigator.of(context).pushNamed(
                                '/loan-detail',
                                arguments: loan.id,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Could not load loans: $e',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanRequestForm extends ConsumerStatefulWidget {
  const _LoanRequestForm({
    required this.onBack,
    required this.onSubmittedSuccess,
  });

  final VoidCallback onBack;
  final VoidCallback onSubmittedSuccess;

  @override
  ConsumerState<_LoanRequestForm> createState() => _LoanRequestFormState();
}

class _LoanRequestFormState extends ConsumerState<_LoanRequestForm> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  LoanPurpose _purpose = LoanPurpose.rent;
  int _durationDays = 30;
  LoanAudience _audience = LoanAudience.public;
  String? _proofLabel;

  static const Color _fieldFill = Color(0xFFE8F0FA);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF5DD879);

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (r != null && r.files.isNotEmpty) {
      final n = r.files.single.name;
      setState(() => _proofLabel = n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loanRequestControllerProvider);
    final notifier = ref.read(loanRequestControllerProvider.notifier);

    ref.listen<LoanRequestState>(loanRequestControllerProvider, (prev, next) {
      if (next.isSuccess && prev?.loan?.id != next.loan?.id) {
        ref.invalidate(activeLoansProvider);
        ref.invalidate(borrowerLoansProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loan request ${next.loan!.id} submitted (${next.loan!.status.name}).',
            ),
          ),
        );
        widget.onSubmittedSuccess();
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: state.isSubmitting ? null : widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      'Request a loan',
                      style: textTheme.headlineSmall?.copyWith(
                        color: _colorInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Amount, duration, reason, and who can see your request.',
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
                  prefixText: '₦ ',
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
                'Duration',
                style: textTheme.labelLarge?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${LoanRequestController.minDurationDays}d',
                    style: textTheme.labelSmall?.copyWith(color: _colorMuted),
                  ),
                  Expanded(
                    child: Slider(
                      value: _durationDays.toDouble(),
                      min: LoanRequestController.minDurationDays.toDouble(),
                      max: LoanRequestController.maxDurationDays.toDouble(),
                      divisions: LoanRequestController.maxDurationDays -
                          LoanRequestController.minDurationDays,
                      label: '$_durationDays days',
                      onChanged: state.isSubmitting
                          ? null
                          : (v) {
                              setState(() => _durationDays = v.round());
                            },
                    ),
                  ),
                  Text(
                    '${LoanRequestController.maxDurationDays}d',
                    style: textTheme.labelSmall?.copyWith(color: _colorMuted),
                  ),
                ],
              ),
              Center(
                child: Text(
                  '$_durationDays days to repay',
                  style: textTheme.titleSmall?.copyWith(
                    color: _colorInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                'Reason (optional)',
                style: textTheme.labelLarge?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A short note helps lenders decide faster.',
                style: textTheme.bodySmall?.copyWith(color: _colorMuted),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                maxLength: 500,
                enabled: !state.isSubmitting,
                decoration: InputDecoration(
                  hintText: 'e.g. Medical emergency, rent gap until payday…',
                  filled: true,
                  fillColor: _fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload proof (optional)',
                style: textTheme.labelLarge?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: state.isSubmitting ? null : _pickProof,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(
                  _proofLabel ?? 'Choose file (JPG, PNG, PDF)',
                ),
              ),
              if (_proofLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Attached: $_proofLabel',
                    style: textTheme.bodySmall?.copyWith(color: _colorMuted),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Who can see this?',
                style: textTheme.labelLarge?.copyWith(
                  color: _colorInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<LoanAudience>(
                segments: const [
                  ButtonSegment(
                    value: LoanAudience.public,
                    label: Text('Public'),
                    icon: Icon(Icons.public),
                  ),
                  ButtonSegment(
                    value: LoanAudience.friendsOnly,
                    label: Text('Friends only'),
                    icon: Icon(Icons.group_outlined),
                  ),
                ],
                selected: {_audience},
                onSelectionChanged: state.isSubmitting
                    ? (_) {}
                    : (s) => setState(() => _audience = s.first),
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
                              audience: _audience,
                              reason: _reasonController.text,
                              proofFileLabel: _proofLabel,
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
                              '₦${state.loan!.amount.toStringAsFixed(2)}',
                          textTheme: textTheme,
                        ),
                        _SuccessRow(
                          label: 'Audience',
                          value: state.loan!.audience.label,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            notifier.reset();
                            _amountController.clear();
                            _reasonController.clear();
                            setState(() {
                              _purpose = LoanPurpose.rent;
                              _durationDays = 30;
                              _audience = LoanAudience.public;
                              _proofLabel = null;
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
