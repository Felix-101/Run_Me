import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_decentralized_screen.dart';

/// Phase 04 — reputation as capital; compact single-screen layout.
class OnboardingTrustCapitalScreen extends StatelessWidget {
  const OnboardingTrustCapitalScreen({super.key});

  static const String scoreCircleAsset = 'assets/images/score_circle.png';

  static const Color _bg = Color(0xFFF8F9FE);
  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _blue = Color(0xFF1A69C4);
  static const Color _green = Color(0xFF34A853);
  static const Color _greenLeft = Color(0xFF2E9B4A);
  static const Color _greenRight = Color(0xFF5DD879);
  static const Color _cardBlueTint = Color(0xFFE8F1FF);
  static const Color _cardGreenTint = Color(0xFFE8F8EC);

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final side = math.min(
                      math.min(w * 0.58, h * 0.34),
                      168.0,
                    );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: textTheme.titleLarge?.copyWith(
                                  color: _ink,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                  fontSize: 19,
                                ),
                                children: [
                                  const TextSpan(text: 'Your Reputation\n'),
                                  TextSpan(
                                    text: 'is your Capital.',
                                    style: TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We convert your academic achievements and campus '
                              'behavior into high-limit P2P credit.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: _muted,
                                height: 1.35,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Semantics(
                            label: 'Trust score illustration',
                            child: Image.asset(
                              scoreCircleAsset,
                              width: side,
                              height: side,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FeatureCard(
                              iconBg: _cardBlueTint,
                              icon: Icons.school_rounded,
                              iconColor: _blue,
                              title: 'Academic Merit',
                              body:
                                  'Your GPA and research contributions directly '
                                  'lower your interest rates.',
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 8),
                            _FeatureCard(
                              iconBg: _cardGreenTint,
                              icon: Icons.handshake_rounded,
                              iconColor: _green,
                              title: 'Reputation Yield',
                              body:
                                  'On-campus reliability converts into higher '
                                  'peer-to-peer lending limits.',
                              textTheme: textTheme,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
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
                      color: _green.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _goLogin(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Proceed to Next',
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              OnboardingDecentralizedScreen.arrowAsset,
                              height: 17,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => _goLogin(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Skip to login',
                    style: textTheme.bodyMedium?.copyWith(
                      color: _blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.textTheme,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                    height: 1.35,
                    fontSize: 11,
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
