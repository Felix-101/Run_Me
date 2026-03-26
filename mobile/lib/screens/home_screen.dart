import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/entities/trust_score.dart';
import '../models/admin_summary.dart';
import '../models/me.dart';
import '../presentation/providers/loan_providers.dart';
import '../presentation/providers/trust_score_providers.dart';
import '../presentation/screens/friends_loans_tab.dart';
import '../presentation/screens/loan_request_screen.dart';
import '../presentation/utils/loan_display.dart';
import '../presentation/widgets/loan_list_tile.dart';
import '../presentation/widgets/trust_score_ring_widget.dart';
import '../providers/repo_provider.dart';
import './profile_screen.dart';

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
  static const Color _cardSocial = Color(0xFFE8EEF5);
  static const Color _blue = Color(0xFF1A73E8);

  bool _loading = true;
  String? _profileHint;
  Me? _me;
  AdminSummary? _adminSummary;

  /// Bottom nav: Home, Borrow, Fund, Friends.
  int _navIndex = 0;

  static const List<String> _navTitles = [
    'Home',
    'Borrow',
    'Fund',
    'Friends',
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
            onPressed: () => Navigator.of(context).pushNamed('/example'),
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Example',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeTab(textTheme, currency),
          const LoanRequestScreen(embedInShell: true),
          _LedgerPlaceholderTab(
            title: 'Fund a loan',
            subtitle: 'Browse requests and fund peers — coming soon.',
            icon: Icons.savings_outlined,
            textTheme: textTheme,
          ),
          const FriendsLoansTab(),
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
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2_rounded),
            label: 'Friends',
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
              const _TrustScoreSection(),
              const SizedBox(height: 16),
              _WalletCard(
                textTheme: textTheme,
                balance: 12480.52,
                currency: currency,
              ),
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
                data: (loans) => Column(
                  children: loans
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
              'Trust score',
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

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.textTheme,
    required this.balance,
    required this.currency,
  });

  final TextTheme textTheme;
  final double balance;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet balance',
              style: textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currency.format(balance),
              // '₦$balance',
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Available for P2P lending & instant transfers',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerPlaceholderTab extends StatelessWidget {
  const _LedgerPlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.textTheme,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _HomeScreenState._pageBg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                color: _HomeScreenState._cardSocial,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 48, color: _HomeScreenState._ink),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          color: _HomeScreenState._ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: _HomeScreenState._muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
