import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Data model ────────────────────────────────────────────────────────────────
enum RiskLevel { low, moderate, high }

class LoanRequest {
  final String name;
  final bool verified;
  final int trustScore;
  final double amount;
  final double probability;
  final RiskLevel risk;
  final String expires;
  final String distance;
  final String quote;

  const LoanRequest({
    required this.name,
    required this.verified,
    required this.trustScore,
    required this.amount,
    required this.probability,
    required this.risk,
    required this.expires,
    required this.distance,
    required this.quote,
  });
}

// ─── Mock data ─────────────────────────────────────────────────────────────────
const _mockRequests = [
  LoanRequest(
    name: 'Oguntoye Samuel',
    verified: true,
    trustScore: 942,
    amount: 450,
    probability: 98.2,
    risk: RiskLevel.low,
    expires: 'Expires in 4h',
    distance: '0.8 miles away',
    quote: '"Covering lab equipment fees for senior thesis."',
  ),
  LoanRequest(
    name: 'Mayowa Adeleke',
    verified: false,
    trustScore: 710,
    amount: 1200,
    probability: 84.5,
    risk: RiskLevel.moderate,
    expires: 'Expires in 2 days',
    distance: '2.4 miles away',
    quote: '"Tuition gap bridge for final semester semester."',
  ),
  LoanRequest(
    name: 'Ekpoiba Ini',
    verified: true,
    trustScore: 880,
    amount: 300,
    probability: 95.1,
    risk: RiskLevel.low,
    expires: 'Expires in 1 day',
    distance: '1.1 miles away',
    quote: '"Books and supplies for spring term."',
  ),
];

// ─── Screen ────────────────────────────────────────────────────────────────────
class LendingMarketplaceScreen extends StatefulWidget {
  const LendingMarketplaceScreen({super.key});

  @override
  State<LendingMarketplaceScreen> createState() =>
      _LendingMarketplaceScreenState();
}

class _LendingMarketplaceScreenState extends State<LendingMarketplaceScreen> {
  int _activeFilter = 0;

  static const _filters = ['All Requests', 'Near Me', 'High Trust', 'Urgent'];
  static const _filterIcons = [
    Icons.grid_view_rounded,
    Icons.near_me_rounded,
    Icons.verified_rounded,
    Icons.flash_on_rounded,
  ];

  final _currency = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0F4FA),
      child: SafeArea(
        child: CustomScrollView(
          // physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(22, 24, 22, 0),
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
                    const SizedBox(height: 20),
                    // ── Filter chips ────────────────────────────────────────
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_filters.length, (i) {
                        final active = _activeFilter == i;
                        return _FilterChip(
                          label: _filters[i],
                          icon: _filterIcons[i],
                          active: active,
                          onTap: () => setState(() => _activeFilter = i),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),

            // ── Cards ────────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _LoanCard(
                      request: _mockRequests[i],
                      currency: _currency,
                      onFund: () {},
                    ),
                  ),
                  childCount: _mockRequests.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter chip ───────────────────────────────────────────────────────────────
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

// ─── Loan card ─────────────────────────────────────────────────────────────────
class _LoanCard extends StatelessWidget {
  final LoanRequest request;
  final NumberFormat currency;
  final VoidCallback onFund;

  const _LoanCard({
    required this.request,
    required this.currency,
    required this.onFund,
  });

  @override
  Widget build(BuildContext context) {
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
            // ── Top row: avatar + name + risk badge ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blank avatar
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
                              request.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ),
                          if (request.verified) ...[
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
                        'TRUST SCORE: ${request.trustScore}',
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
                _RiskBadge(risk: request.risk),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFF0F4FA)),
            const SizedBox(height: 16),

            // ── Requesting + Probability ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'REQUESTING',
                    value: currency.format(request.amount),
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
                    label: 'PROBABILITY',
                    value: '${request.probability}%',
                    trailing: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
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

            // ── Fund button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onFund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Text(
                  'Fund This',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Footer: expires / distance / quote ────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterPill(
                  icon: Icons.access_time_rounded,
                  label: request.expires,
                ),
                const SizedBox(width: 10),
                _FooterPill(
                  icon: Icons.place_rounded,
                  label: request.distance,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.quote,
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

// ─── Risk badge ────────────────────────────────────────────────────────────────
class _RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  const _RiskBadge({required this.risk});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (risk) {
      RiskLevel.low => ('LOW RISK', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
      RiskLevel.moderate => ('MODERATE RISK', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
      RiskLevel.high => ('HIGH RISK', const Color(0xFFFFEEEE), const Color(0xFFDC2626)),
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

// ─── Stat column ───────────────────────────────────────────────────────────────
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  final Widget? trailing;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.valueStyle,
    this.trailing,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value, style: valueStyle),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Footer pill ───────────────────────────────────────────────────────────────
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