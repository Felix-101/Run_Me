import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Entry point (remove if adding to existing app) ───────────────────────────

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
  static const iconLend = Color(0xFF2ECC71);
  static const cardShadow = Color(0x0F000000);
}

// ─── Main screen ──────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // physics: const BouncingScrollPhysics(),
        child: Column(
          children: const [
            _ProfileHeader(),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ScoreCard(),
                  SizedBox(height: 16),
                  _StatsRow(),
                  SizedBox(height: 28),
                  _SecuritySection(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(color: _C.bg),
      child: Column(
        children: [
          // Avatar with ring + badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer gradient ring
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
                  child: ClipOval(child: _AvatarIllustration()),
                ),
              ),
              // Verified badge
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
          const Text(
            'Alex Thompson',
            style: TextStyle(
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
                Icon(Icons.school_rounded, size: 14, color: _C.blue),
                const SizedBox(width: 6),
                Text(
                  'Babcock University',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.blue,
                    letterSpacing: 0.8,
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

// ─── Simple avatar illustration ────────────────────────────────────────────────
class _AvatarIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Renders a clean avatar using a CircleAvatar placeholder with a person icon
    // Replace with Image.asset/Image.network for a real photo.
    return Container(
      color: const Color(0xFF2B3A52),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Head
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
                // Hair
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
                // Ears
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
          // Suit body
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

// ─── Score card ────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Stack(
        children: [
          // Top-right icon
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.bar_chart_rounded, color: _C.divider, size: 32),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
              // Circular progress
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(painter: _ScoreRingPainter(score: 85)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '85',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: _C.scoreBlue,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
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
                    // TOP 5% badge
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
                        child: Text(
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
              const SizedBox(height: 20),
              const Text(
                'Excellent Standing',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _C.text,
                ),
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
                          "Your reliability is exceptional. You're\namong our most trusted ",
                    ),
                    TextSpan(
                      text: 'academic\nlenders.',
                      style: TextStyle(
                        color: _C.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Score ring painter ────────────────────────────────────────────────────────
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

// ─── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            label: 'BORROWING',
            amount: '\$450',
            sub: '12 Active Cycles',
            iconData: Icons.south_west_rounded,
            iconColor: _C.iconBorrow,
            iconBg: _C.blueLight,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            label: 'LENDING',
            amount: '\$1,200',
            sub: '100% Repaid',
            iconData: Icons.north_east_rounded,
            iconColor: _C.green,
            iconBg: _C.greenLight,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final String sub;
  final IconData iconData;
  final Color iconColor;
  final Color iconBg;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.sub,
    required this.iconData,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.textSub,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _C.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: _C.textSub)),
        ],
      ),
    );
  }
}

// ─── Security section ──────────────────────────────────────────────────────────
class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'SECURITY & CREDENTIALS',
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
              _SecurityTile(
                icon: Icons.badge_rounded,
                iconBg: _C.green,
                iconColor: Colors.white,
                title: 'Campus Credentials',
                subtitle: 'VERIFIED STUDENT STATUS',
                subtitleColor: _C.green,
                isFirst: true,
                hasBorder: true,
              ),
              _SecurityTile(
                icon: Icons.security_rounded,
                iconBg: _C.blueLight,
                iconColor: _C.blue,
                title: 'Account Protection',
                hasBorder: true,
              ),
              _SecurityTile(
                icon: Icons.notifications_rounded,
                iconBg: _C.badgeBg,
                iconColor: _C.textSub,
                title: 'Notifications',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isFirst;
  final bool isLast;
  final bool hasBorder;

  const _SecurityTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.isFirst = false,
    this.isLast = false,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: isFirst
                ? const Border(left: BorderSide(color: _C.green, width: 3))
                : null,
            borderRadius: isFirst
                ? const BorderRadius.only(topLeft: Radius.circular(16))
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(16) : Radius.zero,
                bottom: isLast ? const Radius.circular(16) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _C.textLight,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasBorder)
          Divider(height: 1, thickness: 1, color: _C.divider, indent: 76),
      ],
    );
  }
}

// ─── Reusable card ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _Card({required this.child, this.padding});

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
