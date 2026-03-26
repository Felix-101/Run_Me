import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _kSquircleGlow = Color(0xFF90CAF9);
const Color _kSquircleDash = Color(0xFFB2DFDB);

/// Phase 03 — University Ledger: branding, [runMeTextAsset], CTA with [arrowAsset].
class OnboardingDecentralizedScreen extends StatelessWidget {
  const OnboardingDecentralizedScreen({super.key});

  static const String onboardingBackgroundAsset =
      'assets/images/onboarding_background.png';
  static const String arrowAsset = 'assets/images/Arrow.png';
  static const String runMeTextAsset = 'assets/images/run_me_text.png';

  static const Color _ink = Color(0xFF1A1C1E);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _headerGrey = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF1A73E8);
  static const Color _greenWord = Color(0xFF166534);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF66BB6A);
  static const Color _badgeBg = Color(0xFFF3F4F6);

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goTrustCapital(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/onboarding-trust-capital');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F4FC),
                  Color(0xFFF8FAFC),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                onboardingBackgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 110,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 1,
                            color: _headerGrey.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'UNIVERSITY LEDGER V.2.0',
                            style: textTheme.labelSmall?.copyWith(
                              color: _headerGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Center(
                              child: _LedgerSquircle(
                                boltColor: _blue,
                                outerSize: 80,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Image.asset(
                                runMeTextAsset,
                                height: 38,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text.rich(
                              TextSpan(
                                style: textTheme.titleLarge?.copyWith(
                                  color: _ink,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  fontSize: 21,
                                ),
                                children: [
                                  const TextSpan(text: 'Fueling '),
                                  TextSpan(
                                    text: 'Academic',
                                    style: TextStyle(color: _greenWord),
                                  ),
                                  const TextSpan(text: ' Ambition.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The peer-to-peer ledger designed for '
                              'high-achievers. Secure, fast, and student-first.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: _muted,
                                height: 1.45,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [_greenLeft, _greenRight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _greenLeft.withValues(alpha: 0.38),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => _goTrustCapital(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Proceed to Next',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      arrowAsset,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => _goLogin(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign in to your account',
                            style: textTheme.bodySmall?.copyWith(
                              color: _ink.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 14,
                                color: _greenLeft,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ENCRYPTED ACADEMIC LEDGER',
                                style: textTheme.labelSmall?.copyWith(
                                  color: _muted,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White squircle, blue glow, dashed mint border, lightning bolt.
class _LedgerSquircle extends StatelessWidget {
  const _LedgerSquircle({
    required this.boltColor,
    this.outerSize = 92,
  });

  final Color boltColor;
  final double outerSize;

  @override
  Widget build(BuildContext context) {
    final inset = outerSize * (3 / 92);
    final innerR = outerSize * (22 / 92);
    final outerR = outerSize * (26 / 92);
    final dashR = outerSize * (24 / 92);
    final iconSize = outerSize * (44 / 92);
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerR),
        boxShadow: [
          BoxShadow(
            color: _kSquircleGlow.withValues(alpha: 0.55),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedRRectPainter(
                color: _kSquircleDash,
                strokeWidth: 1.5,
                borderRadius: dashR,
              ),
            ),
          ),
          Container(
            width: outerSize - inset * 2,
            height: outerSize - inset * 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(innerR),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.bolt_rounded,
              size: iconSize,
              color: boltColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashLen = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + dashLen, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
