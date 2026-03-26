import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/loan_providers.dart';
import '../utils/loan_display.dart';
import '../widgets/loan_list_tile.dart';

/// Browse loans you can vouch for (Back a friend).
class FriendsLoansTab extends ConsumerWidget {
  const FriendsLoansTab({super.key});

  static const Color _pageBg = Color(0xFFF2F4F7);
  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final async = ref.watch(activeLoansProvider);

    return ColoredBox(
      color: _pageBg,
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load loans: $e')),
          data: (loans) {
            if (loans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No loans to show yet.',
                    style: textTheme.bodyLarge?.copyWith(color: _muted),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Text(
                  'Back a friend',
                  style: textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Open a loan to see backers and add your guarantee.',
                  style: textTheme.bodyMedium?.copyWith(color: _muted),
                ),
                const SizedBox(height: 20),
                ...loans.map(
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
