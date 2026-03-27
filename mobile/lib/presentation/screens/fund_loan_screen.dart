import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_risk_level.dart';
import '../providers/backing_providers.dart';
import '../providers/fund_providers.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_display.dart';
import '../widgets/loan_list_tile.dart';

/// Fund tab: Marketplace (browse & filter requests) + Portfolio (invested, returns, backers).
class FundShellScreen extends ConsumerStatefulWidget {
  const FundShellScreen({super.key});

  @override
  ConsumerState<FundShellScreen> createState() => _FundShellScreenState();
}

class _FundShellScreenState extends ConsumerState<FundShellScreen> {
  int _subIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0F4FA),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Marketplace'),
                    icon: Icon(Icons.storefront_outlined),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Portfolio'),
                    icon: Icon(Icons.pie_chart_outline_rounded),
                  ),
                ],
                selected: {_subIndex},
                onSelectionChanged: (s) =>
                    setState(() => _subIndex = s.first),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _subIndex,
                children: const [
                  _MarketplaceTab(),
                  _PortfolioTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Marketplace ─────────────────────────────────────────────────────────────

class _MarketplaceTab extends ConsumerStatefulWidget {
  const _MarketplaceTab();

  @override
  ConsumerState<_MarketplaceTab> createState() => _MarketplaceTabState();
}

enum _AmountFilter { any, under1k, between1k5k, over5k }

enum _DurationFilter { any, short, medium, long }

enum _RiskFilter { any, low, medium, elevated, high }

class _MarketplaceTabState extends ConsumerState<_MarketplaceTab> {
  int _chipFilter = 0;
  _AmountFilter _amountFilter = _AmountFilter.any;
  _DurationFilter _durationFilter = _DurationFilter.any;
  _RiskFilter _riskFilter = _RiskFilter.any;

  static const _filters = ['All Requests', 'Near Me', 'High Trust', 'Urgent'];
  static const _filterIcons = [
    Icons.grid_view_rounded,
    Icons.near_me_rounded,
    Icons.verified_rounded,
    Icons.flash_on_rounded,
  ];

  final _currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  bool _passesAmount(Loan l) {
    switch (_amountFilter) {
      case _AmountFilter.any:
        return true;
      case _AmountFilter.under1k:
        return l.amount < 1000;
      case _AmountFilter.between1k5k:
        return l.amount >= 1000 && l.amount <= 5000;
      case _AmountFilter.over5k:
        return l.amount > 5000;
    }
  }

  bool _passesDuration(Loan l) {
    switch (_durationFilter) {
      case _DurationFilter.any:
        return true;
      case _DurationFilter.short:
        return l.durationDays <= 7;
      case _DurationFilter.medium:
        return l.durationDays > 7 && l.durationDays <= 30;
      case _DurationFilter.long:
        return l.durationDays > 30;
    }
  }

  bool _passesRisk(Loan loan, LoanRiskLevel risk) {
    switch (_riskFilter) {
      case _RiskFilter.any:
        return true;
      case _RiskFilter.low:
        return risk == LoanRiskLevel.low;
      case _RiskFilter.medium:
        return risk == LoanRiskLevel.medium;
      case _RiskFilter.elevated:
        return risk == LoanRiskLevel.elevated;
      case _RiskFilter.high:
        return risk == LoanRiskLevel.high;
    }
  }

  bool _passesChips(Loan loan, double fundedPct) {
    switch (_chipFilter) {
      case 0:
        return true;
      case 1:
        return true;
      case 2:
        return trustScoreForBorrower(loan.borrowerId) >= 800;
      case 3:
        return loan.durationDays <= 14 || fundedPct < 50;
      default:
        return true;
    }
  }

  List<Loan> _applyFilters(List<Loan> loans) {
    return loans.where((loan) {
      final total = ref.read(totalGuaranteedForLoanProvider(loan.id));
      final cov = LoanRiskCalculator.coverageRatio(
        principal: loan.amount,
        totalGuaranteed: total,
      );
      final risk = LoanRiskCalculator.fromCoverage(cov);
      final fundedPct = loan.amount <= 0 ? 0.0 : (total / loan.amount) * 100;
      return _passesAmount(loan) &&
          _passesDuration(loan) &&
          _passesRisk(loan, risk) &&
          _passesChips(loan, fundedPct);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(marketplaceLoansProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (loans) {
        final filtered = _applyFilters(loans);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lending\nMarketplace',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D1B2A),
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Support your peers with micro-loans powered\n'
                      'by AI-driven risk assessment and the\nAcademic Ledger.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7A8D),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0D1B2A),
                          ),
                    ),
                    const SizedBox(height: 8),
                    _FilterDropdownRow(
                      label: 'Amount',
                      value: _amountFilter,
                      items: const [
                        (_AmountFilter.any, 'Any'),
                        (_AmountFilter.under1k, 'Under ₦1k'),
                        (_AmountFilter.between1k5k, '₦1k – ₦5k'),
                        (_AmountFilter.over5k, 'Over ₦5k'),
                      ],
                      onChanged: (v) => setState(() => _amountFilter = v),
                    ),
                    const SizedBox(height: 8),
                    _FilterDropdownRow(
                      label: 'Duration',
                      value: _durationFilter,
                      items: const [
                        (_DurationFilter.any, 'Any'),
                        (_DurationFilter.short, '≤ 7 days'),
                        (_DurationFilter.medium, '8 – 30 days'),
                        (_DurationFilter.long, '> 30 days'),
                      ],
                      onChanged: (v) => setState(() => _durationFilter = v),
                    ),
                    const SizedBox(height: 8),
                    _FilterDropdownRow(
                      label: 'Risk level',
                      value: _riskFilter,
                      items: const [
                        (_RiskFilter.any, 'Any'),
                        (_RiskFilter.low, 'Low'),
                        (_RiskFilter.medium, 'Medium'),
                        (_RiskFilter.elevated, 'Elevated'),
                        (_RiskFilter.high, 'High'),
                      ],
                      onChanged: (v) => setState(() => _riskFilter = v),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_filters.length, (i) {
                        final active = _chipFilter == i;
                        return _FilterChip(
                          label: _filters[i],
                          icon: _filterIcons[i],
                          active: active,
                          onTap: () => setState(() => _chipFilter = i),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No loan requests match these filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7A8D)),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final loan = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _MarketplaceLoanCard(
                          loan: loan,
                          currency: _currency,
                          onFund: () => Navigator.of(context).pushNamed(
                            '/loan-detail',
                            arguments: loan.id,
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FilterDropdownRow<T> extends StatelessWidget {
  const _FilterDropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A4557),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE3EE)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.$1,
                        child: Text(e.$2),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Portfolio ─────────────────────────────────────────────────────────────────

class _PortfolioTab extends ConsumerWidget {
  const _PortfolioTab();

  static const _pageBg = Color(0xFFF2F4F7);
  static const _ink = Color(0xFF101828);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final invested = ref.watch(userTotalInvestedProvider);
    final expected = ref.watch(userExpectedReturnsProvider);
    final backedAsync = ref.watch(userBackedLoansProvider);
    final allLoansAsync = ref.watch(activeLoansProvider);

    return ColoredBox(
      color: _pageBg,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio',
                    style: textTheme.headlineSmall?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Capital you’ve deployed and loans you’re backing.',
                    style: textTheme.bodyMedium?.copyWith(color: _muted),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total invested',
                          value: currency.format(invested),
                          textTheme: textTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Expected returns',
                          value: currency.format(expected),
                          subtitle: 'Demo 2% on deployed',
                          textTheme: textTheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Active loans you back',
                    style: textTheme.titleMedium?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Loans where you’ve added a guarantee.',
                    style: textTheme.bodySmall?.copyWith(color: _muted),
                  ),
                ],
              ),
            ),
          ),
          backedAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('$e')),
            ),
            data: (backed) {
              if (backed.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'You haven’t backed any loans yet. Browse the Marketplace.',
                      style: textTheme.bodyMedium?.copyWith(color: _muted),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final loan = backed[i];
                      return Padding(
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
                      );
                    },
                    childCount: backed.length,
                  ),
                ),
              );
            },
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'All loans — backers & guarantees',
                style: textTheme.titleMedium?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Open any loan to see lenders and add your guarantee.',
                style: textTheme.bodySmall?.copyWith(color: _muted),
              ),
            ),
          ),
          allLoansAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (loans) {
              if (loans.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final loan = loans[i];
                      return Padding(
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
                      );
                    },
                    childCount: loans.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.textTheme,
    this.subtitle,
  });

  final String label;
  final String value;
  final TextTheme textTheme;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(color: _PortfolioTab._muted),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: _PortfolioTab._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: _PortfolioTab._muted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Marketplace loan card (real Loan) ───────────────────────────────────────────

class _MarketplaceLoanCard extends ConsumerWidget {
  const _MarketplaceLoanCard({
    required this.loan,
    required this.currency,
    required this.onFund,
  });

  final Loan loan;
  final NumberFormat currency;
  final VoidCallback onFund;

  static RiskLevel _riskBand(LoanRiskLevel r) {
    switch (r) {
      case LoanRiskLevel.low:
        return RiskLevel.low;
      case LoanRiskLevel.medium:
        return RiskLevel.moderate;
      case LoanRiskLevel.elevated:
      case LoanRiskLevel.high:
        return RiskLevel.high;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalGuaranteedForLoanProvider(loan.id));
    final fundedPct = loan.amount <= 0
        ? 0.0
        : ((total / loan.amount) * 100).clamp(0.0, 100.0);
    final cov = LoanRiskCalculator.coverageRatio(
      principal: loan.amount,
      totalGuaranteed: total,
    );
    final risk = LoanRiskCalculator.fromCoverage(cov);
    final band = _riskBand(risk);
    final name = borrowerDisplayName(loan.borrowerId);
    final trust = trustScoreForBorrower(loan.borrowerId);
    final verified = trust >= 800;
    final reason = loan.reason?.isNotEmpty ?? false
        ? loan.reason!
        : '${loan.purpose.label} — ${loan.durationDays} days';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8EDF5),
                    border: Border.all(
                      color: const Color(0xFFD0D8E8),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFB0BAC8),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF1A56DB),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'TRUST SCORE: $trust',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7A8D),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RiskBadge(risk: band),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFF0F4FA)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'REQUESTING',
                    value: currency.format(loan.amount),
                    valueStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A56DB),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'FUNDED',
                    value: '${fundedPct.toStringAsFixed(1)}%',
                    valueStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D1B2A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onFund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Fund this',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterPill(
                  icon: Icons.schedule_rounded,
                  label: '${loan.durationDays} days term',
                ),
                const SizedBox(width: 10),
                _FooterPill(
                  icon: Icons.public_rounded,
                  label: loan.audience.label,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '"$reason"',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6B7A8D),
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI bits (from original marketplace) ────────────────────────────────

enum RiskLevel { low, moderate, high }

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A56DB) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: active
                ? const Color(0xFF1A56DB)
                : const Color(0xFFDDE3EE),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : const Color(0xFF6B7A8D),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF3A4557),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  const _RiskBadge({required this.risk});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (risk) {
      RiskLevel.low => (
          'LOW RISK',
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
        ),
      RiskLevel.moderate => (
          'MODERATE RISK',
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
        ),
      RiskLevel.high => (
          'HIGH RISK',
          const Color(0xFFFFEEEE),
          const Color(0xFFDC2626),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9BA8B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _FooterPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9BA8B8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF9BA8B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
