import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/entities/trust_score.dart';
import '../models/admin_summary.dart';
import '../models/me.dart';
import '../domain/entities/loan.dart';
import '../presentation/providers/loan_providers.dart';
import '../presentation/providers/trust_score_providers.dart';
import '../presentation/screens/borrow_screen.dart';
import '../presentation/utils/loan_display.dart';
import '../presentation/widgets/loan_list_tile.dart';
import '../presentation/widgets/trust_score_ring_widget.dart';
import '../providers/repo_provider.dart';
import './profile_screen.dart';
import '../presentation/screens/fund_loan_screen.dart';
import '../presentation/screens/grants/grants_shell_screen.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color _pageBg = Color(0xFFF2F4F7);
  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF5DD879);
  static const Color _blue = Color(0xFF1A73E8);

  bool _loading = true;
  String? _profileHint;
  Me? _me;
  AdminSummary? _adminSummary;

  /// Bottom nav: Home, Borrow, Fund, Grants, Profile.
  int _navIndex = 0;

  static const List<String> _navTitles = [
    'Home',
    'Borrow',
    'Fund',
    'Grants',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _profileHint = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final me = await repo.fetchMe();
      _me = me;
      if (me.role == 'admin') {
        _adminSummary = await repo.fetchAdminSummary();
      } else {
        _adminSummary = null;
      }
    } catch (e) {
      _me = null;
      _adminSummary = null;
      _profileHint = 'Could not load profile — showing dashboard preview.';
    } finally {
      ref.invalidate(trustScoreProvider);
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).clearAccessToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        title: Text(_navTitles[_navIndex]),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () => setState(() => _navIndex = 4),
            tooltip: 'Profile',
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE4E7EC),
              child: Icon(
                Icons.person_rounded,
                size: 22,
                color: _ink.withValues(alpha: 0.85),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'example') {
                Navigator.of(context).pushNamed('/example');
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'example',
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Example'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Log out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeTab(textTheme, currency),
          const BorrowScreen(embedInShell: true),
       /*    _LedgerPlaceholderTab(
            title: 'Fund a loan',
            subtitle: 'Browse requests and fund peers — coming soon.',
            icon: Icons.savings_outlined,
            textTheme: textTheme,
          ), */
          const FundShellScreen(),
          const GrantsShellScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD1F5DB),
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_quote_outlined),
            selectedIcon: Icon(Icons.request_quote_rounded),
            label: 'Borrow',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Fund',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Grants',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_outlined),
            selectedIcon: Icon(Icons.person_2_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(TextTheme textTheme, NumberFormat currency) {
    final loansAsync = ref.watch(activeLoansProvider);
    final borrowerId = ref.watch(currentBorrowerIdProvider);
    final loans = loansAsync.asData?.value ?? <Loan>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_profileHint != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _profileHint!,
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_me != null) _ProfileChips(me: _me!, textTheme: textTheme),
              if (_me != null) const SizedBox(height: 12),
              Text(
                'Overview',
                style: textTheme.titleLarge?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _WalletCard(
                textTheme: textTheme,
                balance: 12480.52,
                currency: currency,
                onFundWallet: () => _stub('Fund wallet'),
                onWithdraw: () => _stub('Withdraw'),
              ),
              const SizedBox(height: 20),
              _QuickActionsRow(
                textTheme: textTheme,
                onBorrow: () => setState(() => _navIndex = 1),
                onLend: () => setState(() => _navIndex = 2),
                onGiveGrant: () => _stub('Give grant'),
                onRequestMoney: () => setState(() => _navIndex = 1),
              ),
              const SizedBox(height: 24),
              _ActiveLoansSummaryCard(
                textTheme: textTheme,
                currency: currency,
                youOwe: _sumActiveBorrowing(loans, borrowerId),
                youAreOwed: _sumActiveLending(loans, borrowerId),
                isLoading: loansAsync.isLoading,
              ),
              const SizedBox(height: 20),
              _ActivityFeedCard(
                textTheme: textTheme,
                currency: currency,
                loans: loans,
              ),
              const SizedBox(height: 24),
              const _TrustScoreSection(),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active loans',
                    style: textTheme.titleMedium?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _stub('View all'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              loansAsync.when(
                data: (loanList) => Column(
                  children: loanList
                      .map(
                        (loan) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: LoanListTile(
                            title: loan.displayTitle,
                            subtitle: loan.displaySubtitle,
                            amount: loan.amount,
                            currency: currency,
                            textTheme: textTheme,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed('/loan-detail', arguments: loan.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Could not load loans: $e',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ),
              if (_adminSummary != null) ...[
                const SizedBox(height: 16),
                _AdminSummaryCard(
                  summary: _adminSummary!,
                  textTheme: textTheme,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static double _sumActiveBorrowing(List<Loan> loans, String borrowerId) {
    return loans
        .where(
          (l) =>
              l.borrowerId == borrowerId &&
              l.status != LoanStatus.repaid,
        )
        .fold<double>(0, (a, l) => a + l.amount);
  }

  static double _sumActiveLending(List<Loan> loans, String lenderId) {
    return loans
        .where(
          (l) =>
              l.lenderId == lenderId &&
              l.status != LoanStatus.repaid,
        )
        .fold<double>(0, (a, l) => a + l.amount);
  }

  void _stub(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — coming soon.')));
  }
}

class _ProfileChips extends StatelessWidget {
  const _ProfileChips({required this.me, required this.textTheme});

  final Me me;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            me.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: _HomeScreenState._muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FA),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            me.role,
            style: textTheme.labelSmall?.copyWith(
              color: _HomeScreenState._blue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustScoreSection extends ConsumerWidget {
  const _TrustScoreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(trustScoreProvider);

    return _ShadowCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credit & trust score',
              style: textTheme.titleMedium?.copyWith(
                color: _HomeScreenState._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weighted: verification 30%, repayment 40%, social 20%, activity 10%.',
              style: textTheme.bodySmall?.copyWith(
                color: _HomeScreenState._muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: async.when(
                data: (ts) => Column(
                  children: [
                    TrustScoreRingWidget(trustScore: ts, size: 200),
                    const SizedBox(height: 14),
                    _RepaymentStreakRow(trustScore: ts, textTheme: textTheme),
                    const SizedBox(height: 14),
                    _FactorGrid(factors: ts.factors, textTheme: textTheme),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Trust score unavailable',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorGrid extends StatelessWidget {
  const _FactorGrid({required this.factors, required this.textTheme});

  final TrustScoreFactors factors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: textTheme.labelSmall?.copyWith(
        color: _HomeScreenState._muted,
        fontSize: 10,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          Text('V ${factors.verificationScore} (30%)'),
          Text('R ${factors.repaymentScore} (40%)'),
          Text('S ${factors.socialScore} (20%)'),
          Text('A ${factors.activityScore} (10%)'),
        ],
      ),
    );
  }
}

/// Maps repayment factor into a simple streak label for the home “differentiator” row.
class _RepaymentStreakRow extends StatelessWidget {
  const _RepaymentStreakRow({
    required this.trustScore,
    required this.textTheme,
  });

  final TrustScore trustScore;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final months = (trustScore.factors.repaymentScore / 12.5).round().clamp(1, 24);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repayment streak',
                  style: textTheme.labelMedium?.copyWith(
                    color: _HomeScreenState._ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$months months on-time — keep it going',
                  style: textTheme.bodySmall?.copyWith(
                    color: _HomeScreenState._muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.textTheme,
    required this.onBorrow,
    required this.onLend,
    required this.onGiveGrant,
    required this.onRequestMoney,
  });

  final TextTheme textTheme;
  final VoidCallback onBorrow;
  final VoidCallback onLend;
  final VoidCallback onGiveGrant;
  final VoidCallback onRequestMoney;

  @override
  Widget build(BuildContext context) {
    return _ShadowCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick actions',
              style: textTheme.titleSmall?.copyWith(
                color: _HomeScreenState._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    icon: Icons.request_quote_rounded,
                    label: 'Borrow',
                    onTap: onBorrow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionChip(
                    icon: Icons.savings_rounded,
                    label: 'Lend',
                    onTap: onLend,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    icon: Icons.volunteer_activism_rounded,
                    label: 'Give grant',
                    onTap: onGiveGrant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionChip(
                    icon: Icons.payments_rounded,
                    label: 'Request money',
                    onTap: onRequestMoney,
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

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: _HomeScreenState._blue, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _HomeScreenState._ink,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveLoansSummaryCard extends StatelessWidget {
  const _ActiveLoansSummaryCard({
    required this.textTheme,
    required this.currency,
    required this.youOwe,
    required this.youAreOwed,
    required this.isLoading,
  });

  final TextTheme textTheme;
  final NumberFormat currency;
  final double youOwe;
  final double youAreOwed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _ShadowCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active loans summary',
              style: textTheme.titleSmall?.copyWith(
                color: _HomeScreenState._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _SummaryLine(
              label: 'You owe',
              amount: youOwe,
              currency: currency,
              textTheme: textTheme,
              valueColor: const Color(0xFFB91C1C),
              isLoading: isLoading,
            ),
            const SizedBox(height: 10),
            _SummaryLine(
              label: 'You are owed',
              amount: youAreOwed,
              currency: currency,
              textTheme: textTheme,
              valueColor: const Color(0xFF166534),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.amount,
    required this.currency,
    required this.textTheme,
    required this.valueColor,
    required this.isLoading,
  });

  final String label;
  final double amount;
  final NumberFormat currency;
  final TextTheme textTheme;
  final Color valueColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label (₦)',
          style: textTheme.bodyMedium?.copyWith(
            color: _HomeScreenState._muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: valueColor,
            ),
          )
        else
          Text(
            currency.format(amount),
            style: textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _ActivityFeedCard extends StatelessWidget {
  const _ActivityFeedCard({
    required this.textTheme,
    required this.currency,
    required this.loans,
  });

  final TextTheme textTheme;
  final NumberFormat currency;
  final List<Loan> loans;

  @override
  Widget build(BuildContext context) {
    final recentLoan = loans.isNotEmpty ? loans.first : null;
    return _ShadowCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: textTheme.titleSmall?.copyWith(
                color: _HomeScreenState._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _FeedSection(
              title: 'Recent transactions',
              textTheme: textTheme,
              children: [
                _FeedRow(
                  icon: Icons.account_balance_wallet_outlined,
                  text: 'Wallet top-up · ${currency.format(5000)}',
                  textTheme: textTheme,
                ),
                _FeedRow(
                  icon: Icons.swap_horiz_rounded,
                  text: 'Transfer to pool · ${currency.format(120)}',
                  textTheme: textTheme,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FeedSection(
              title: 'Loan updates',
              textTheme: textTheme,
              children: [
                if (recentLoan != null)
                  _FeedRow(
                    icon: Icons.update_rounded,
                    text:
                        '${recentLoan.displayTitle} · ${recentLoan.status.name}',
                    textTheme: textTheme,
                  )
                else
                  _FeedRow(
                    icon: Icons.update_rounded,
                    text: 'No loan updates yet',
                    textTheme: textTheme,
                    muted: true,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _FeedSection(
              title: 'Repayments',
              textTheme: textTheme,
              children: [
                _FeedRow(
                  icon: Icons.check_circle_outline_rounded,
                  text:
                      'Installment received · ${currency.format(320)} · Lab equipment',
                  textTheme: textTheme,
                ),
                _FeedRow(
                  icon: Icons.schedule_rounded,
                  text: 'Next due · ${currency.format(210)} · Campus rent float',
                  textTheme: textTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSection extends StatelessWidget {
  const _FeedSection({
    required this.title,
    required this.textTheme,
    required this.children,
  });

  final String title;
  final TextTheme textTheme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: _HomeScreenState._ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({
    required this.icon,
    required this.text,
    required this.textTheme,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final TextTheme textTheme;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: muted
                ? _HomeScreenState._muted
                : _HomeScreenState._blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: muted ? _HomeScreenState._muted : _HomeScreenState._ink,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatefulWidget {
  const _WalletCard({
    required this.textTheme,
    required this.balance,
    required this.currency,
    required this.onFundWallet,
    required this.onWithdraw,
  });

  final TextTheme textTheme;
  final double balance;
  final NumberFormat currency;
  final VoidCallback onFundWallet;
  final VoidCallback onWithdraw;

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_HomeScreenState._greenLeft, _HomeScreenState._greenRight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _HomeScreenState._greenLeft.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Balance (₦)',
                    style: t.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _balanceHidden = !_balanceHidden),
                  icon: Icon(
                    _balanceHidden
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 22,
                  ),
                  tooltip: _balanceHidden ? 'Show balance' : 'Hide balance',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _balanceHidden ? '••••••' : widget.currency.format(widget.balance),
              style: t.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: _balanceHidden ? 2 : -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Available for P2P lending & instant transfers',
              style: t.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onFundWallet,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _HomeScreenState._greenLeft,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Fund wallet'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onWithdraw,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Withdraw'),
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

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _HomeScreenState._ink.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AdminSummaryCard extends StatelessWidget {
  const _AdminSummaryCard({required this.summary, required this.textTheme});

  final AdminSummary summary;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _ShadowCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text('Users: ${summary.usersCount}'),
            Text('Generated: ${summary.generatedAt}'),
          ],
        ),
      ),
    );
  }
}
