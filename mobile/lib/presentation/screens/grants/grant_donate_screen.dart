import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/grant_providers.dart';

const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);

class GrantDonateScreen extends ConsumerStatefulWidget {
  const GrantDonateScreen({super.key, required this.grantId});

  final String grantId;

  @override
  ConsumerState<GrantDonateScreen> createState() => _GrantDonateScreenState();
}

class _GrantDonateScreenState extends ConsumerState<GrantDonateScreen> {
  final _amountController = TextEditingController();
  bool _busy = false;

  static const _quick = [500.0, 1000, 2000, 5000, 10000, 25000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _donate(double amount) async {
    if (amount <= 0) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    ref.read(grantStoreProvider.notifier).donate(
          grantId: widget.grantId,
          amountNaira: amount,
          donorLabel: 'You',
        );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you! ${NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(amount)} gifted.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final state = ref.watch(grantStoreProvider);
    final g = state.grantById(widget.grantId);
    if (g == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donate')),
        body: const Center(child: Text('Grant not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a gift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                g.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '100% gift — no repayment. Runs on trust.',
                style: textTheme.bodyMedium?.copyWith(color: _muted),
              ),
              const SizedBox(height: 24),
              Text(
                'Amount',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  prefixText: '₦ ',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick donate',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quick.map((v) {
                  final amount = v.toDouble();
                  return ActionChip(
                    label: Text(currency.format(amount)),
                    onPressed: _busy
                        ? null
                        : () {
                            _amountController.text = amount.toStringAsFixed(0);
                            _donate(amount);
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Or enter any amount above, then confirm.',
                style: textTheme.bodySmall?.copyWith(color: _muted),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () {
                        final raw = _amountController.text.replaceAll(',', '');
                        final v = double.tryParse(raw);
                        if (v == null || v <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid amount')),
                          );
                          return;
                        }
                        _donate(v);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
