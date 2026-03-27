import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/entities/trust_score.dart';
import '../presentation/providers/profile_stats_provider.dart';
import '../presentation/providers/trust_score_providers.dart';

// ─── Colour palette ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFEEF2F8);
  static const white = Colors.white;
  static const green = Color(0xFF1B8A4E);
  static const greenLight = Color(0xFFE8F5EE);
  static const greenTrack = Color(0xFFDCEDE5);
  static const blue = Color(0xFF1565C0);
  static const blueLight = Color(0xFFE8F0FE);
  static const scoreBlue = Color(0xFF1A4FBD);
  static const text = Color(0xFF0D1B2A);
  static const textSub = Color(0xFF6B7A8D);
  static const textLight = Color(0xFF9BA8B8);
  static const divider = Color(0xFFE4EAF2);
  static const badgeBg = Color(0xFFF0F4FA);
  static const iconBorrow = Color(0xFF3A7BD5);
  static const cardShadow = Color(0x0F000000);
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: _C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const _TrustScoreBlock(),
                    const SizedBox(height: 16),
                    const _ProfileStatsGrid(),
                    const SizedBox(height: 24),
                    const _EndorsementsSection(),
                    const SizedBox(height: 24),
                    const _SettingsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── User info ─────────────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileDisplayNameProvider);
    final school = ref.watch(profileSchoolProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(color: _C.bg),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1B8A4E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _C.blue.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2B3A52),
                  ),
                  child: const ClipOval(child: _AvatarIllustration()),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 0,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _C.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _C.badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, size: 14, color: _C.blue),
                const SizedBox(width: 6),
                Text(
                  school,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.blue,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verification badge · Student ID on file',
            style: TextStyle(
              fontSize: 12,
              color: _C.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarIllustration extends StatelessWidget {
  const _AvatarIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2B3A52),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5C6A0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    width: 42,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B2314),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(21),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 16,
                  child: Container(
                    width: 7,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5C6A0),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 16,
                  child: Container(
                    width: 7,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5C6A0),
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 35,
            decoration: const BoxDecoration(
              color: Color(0xFF1B2E4A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 22,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trust score (repayment, activity, peer ratings) ───────────────────────────
class _TrustScoreBlock extends ConsumerWidget {
  const _TrustScoreBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trustScoreProvider);

    return async.when(
      loading: () => const _Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => _Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Trust score unavailable',
            style: TextStyle(color: _C.textSub),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (ts) => _ScoreCardBody(trustScore: ts),
    );
  }
}

class _ScoreCardBody extends StatelessWidget {
  const _ScoreCardBody({required this.trustScore});

  final TrustScore trustScore;

  @override
  Widget build(BuildContext context) {
    final score = trustScore.score.clamp(0, 100);
    final f = trustScore.factors;
    final standing = trustScore.level;

    return _Card(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.bar_chart_rounded, color: _C.divider, size: 32),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _ScoreRingPainter(score: score),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: _C.scoreBlue,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _C.textSub,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    if (score >= 80)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _C.greenLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _C.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'TOP 5%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _C.green,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$standing standing',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _C.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your score blends repayment history, on-platform activity, and peer ratings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _C.textSub,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _FactorChip(
                    label: 'Repayment',
                    value: f.repaymentScore,
                    color: const Color(0xFF166534),
                  ),
                  _FactorChip(
                    label: 'Activity',
                    value: f.activityScore,
                    color: _C.blue,
                  ),
                  _FactorChip(
                    label: 'Peer ratings',
                    value: f.socialScore,
                    color: const Color(0xFF7C3AED),
                  ),
                  _FactorChip(
                    label: 'Verification',
                    value: f.verificationScore,
                    color: _C.textSub,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.textSub,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "You're building a reputation as one of our most trusted ",
                    ),
                    TextSpan(
                      text: 'academic peers.',
                      style: TextStyle(
                        color: _C.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FactorChip extends StatelessWidget {
  const _FactorChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.divider),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  const _ScoreRingPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;
    const startAngle = -math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = _C.greenTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final scorePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B8A4E), Color(0xFF26C97D)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(rect, startAngle, sweepFull, false, trackPaint);
    canvas.drawArc(
      rect,
      startAngle,
      sweepFull * (score / 100),
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.score != score;
}

// ─── Stats grid ──────────────────────────────────────────────────────────────
class _ProfileStatsGrid extends ConsumerWidget {
  const _ProfileStatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'STATS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.textLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Loans taken',
                value: '${stats.loansTaken}',
                icon: Icons.description_outlined,
                iconColor: _C.iconBorrow,
                iconBg: _C.blueLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Loans repaid',
                value: '${stats.loansRepaid}',
                icon: Icons.task_alt_rounded,
                iconColor: _C.green,
                iconBg: _C.greenLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Amount lent',
                value: currency.format(stats.amountLentNaira),
                icon: Icons.north_east_rounded,
                iconColor: _C.green,
                iconBg: _C.greenLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Grants given',
                value: currency.format(stats.grantsGivenNaira),
                icon: Icons.volunteer_activism_outlined,
                iconColor: const Color(0xFFEA580C),
                iconBg: const Color(0xFFFFF7ED),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _C.textSub,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _C.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Endorsements ─────────────────────────────────────────────────────────────
class _EndorsementsSection extends ConsumerWidget {
  const _EndorsementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final extra = <String>[];
    if (stats.loansRepaid > 0) {
      extra.add('Paid back on time');
    }
    if (stats.loansTaken > 0 && stats.loansRepaid == stats.loansTaken) {
      extra.add('Trusted borrower');
    }
    if (stats.amountLentNaira > 0) {
      extra.add('Active lender');
    }
    if (stats.grantsGivenNaira > 0) {
      extra.add('Community supporter');
    }

    const base = [
      'Reliable peer',
      'Responds quickly',
      'Transparent communication',
    ];

    final tags = <String>[...base, ...extra];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'REVIEWS & ENDORSEMENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.textLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _Card(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        backgroundColor: _C.greenLight,
                        side: BorderSide.none,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.text,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Endorsements are generated from your repayment record, lender feedback, and grant activity.',
                style: TextStyle(fontSize: 12, color: _C.textSub, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Settings ──────────────────────────────────────────────────────────────────
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.textLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.account_balance_rounded,
                iconBg: _C.blueLight,
                iconColor: _C.blue,
                title: 'Bank account',
                subtitle: 'Payouts & verified withdrawals',
                onTap: () => _toast(
                  context,
                  'Link a bank account in production — demo only.',
                ),
              ),
              const Divider(height: 1, indent: 76, color: _C.divider),
              _SettingsTile(
                icon: Icons.notifications_rounded,
                iconBg: _C.badgeBg,
                iconColor: _C.textSub,
                title: 'Notifications',
                subtitle: 'Push, email, grant alerts',
                onTap: () =>
                    Navigator.of(context).pushNamed('/notifications'),
              ),
              const Divider(height: 1, indent: 76, color: _C.divider),
              _SettingsTile(
                icon: Icons.lock_rounded,
                iconBg: _C.greenLight,
                iconColor: _C.green,
                title: 'Security',
                subtitle: 'PIN, biometrics, sessions',
                onTap: () => _toast(
                  context,
                  'Security center — add PIN / Face ID in a future build.',
                ),
              ),
              const Divider(height: 1, indent: 76, color: _C.divider),
              _SettingsTile(
                icon: Icons.badge_rounded,
                iconBg: _C.green,
                iconColor: Colors.white,
                title: 'Campus credentials',
                subtitle: 'VERIFIED STUDENT STATUS',
                subtitleColor: _C.green,
                onTap: () => _toast(
                  context,
                  'Student verification is active.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.subtitleColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: subtitleColor ?? _C.textSub,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _C.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
