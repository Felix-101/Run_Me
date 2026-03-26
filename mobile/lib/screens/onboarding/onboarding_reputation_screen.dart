import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Phase 01 intro: animates [kVisualOrbitAsset], then crossfades into static copy.
class OnboardingReputationScreen extends StatefulWidget {
  const OnboardingReputationScreen({super.key});

  static const String visualOrbitAsset = 'assets/images/visual orbit.png';

  @override
  State<OnboardingReputationScreen> createState() =>
      _OnboardingReputationScreenState();
}

class _OnboardingReputationScreenState extends State<OnboardingReputationScreen>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF4B5563);
  static const Color _blue = Color(0xFF1A73E8);
  static const Color _badgeBg = Color(0xFFE8EEF9);
  static const Color _cardTint = Color(0xFFE8F1FF);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF60D66A);

  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _crossfadeController;

  late final Animation<double> _orbitFade;
  late final Animation<double> _orbitScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  Timer? _revealTimer;
  bool _orbitRemoved = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _crossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );

    _orbitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _crossfadeController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _orbitScale = Tween<double>(begin: 1, end: 0.82).animate(
      CurvedAnimation(
        parent: _crossfadeController,
        curve: Curves.easeInCubic,
      ),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _crossfadeController,
        curve: const Interval(0.18, 1, curve: Curves.easeOutCubic),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _crossfadeController,
        curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
      ),
    );

    _revealTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _crossfadeController.forward();
    });

    _crossfadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _rotationController.stop();
        _pulseController.stop();
        setState(() => _orbitRemoved = true);
      }
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    _crossfadeController.dispose();
    super.dispose();
  }

  void _goLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goPeerOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding-peer');
  }

  void _skip() {
    _revealTimer?.cancel();
    _goLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_orbitRemoved)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _rotationController,
                  _pulseController,
                  _crossfadeController,
                ]),
                builder: (context, child) {
                  final pulse = 0.96 + (_pulseController.value * 0.06);
                  final angle = _rotationController.value * 2 * math.pi * 0.08;
                  final fade = _orbitFade.value;
                  final scale = _orbitScale.value * pulse;

                  if (fade <= 0.001) return const SizedBox.shrink();

                  return Opacity(
                    opacity: fade.clamp(0.0, 1.0),
                    child: Center(
                      child: Transform.rotate(
                        angle: angle,
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: FractionallySizedBox(
                  widthFactor: 0.88,
                  child: Image.asset(
                    OnboardingReputationScreen.visualOrbitAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _crossfadeController,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: _contentFade.value < 0.05,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: child,
                    ),
                  ),
                );
              },
              child: _StaticIntroContent(
                onProceed: _goPeerOnboarding,
                onSkip: _skip,
                ink: _ink,
                muted: _muted,
                blue: _blue,
                badgeBg: _badgeBg,
                cardTint: _cardTint,
                greenLeft: _greenLeft,
                greenRight: _greenRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticIntroContent extends StatelessWidget {
  const _StaticIntroContent({
    required this.onProceed,
    required this.onSkip,
    required this.ink,
    required this.muted,
    required this.blue,
    required this.badgeBg,
    required this.cardTint,
    required this.greenLeft,
    required this.greenRight,
  });

  final VoidCallback onProceed;
  final VoidCallback onSkip;
  final Color ink;
  final Color muted;
  final Color blue;
  final Color badgeBg;
  final Color cardTint;
  final Color greenLeft;
  final Color greenRight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'PHASE 01: REPUTATION',
                  style: textTheme.labelSmall?.copyWith(
                    color: blue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  style: textTheme.headlineMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    fontSize: 28,
                  ),
                  children: [
                    const TextSpan(text: 'Trust is Your\n'),
                    TextSpan(
                      text: 'Currency.',
                      style: TextStyle(color: blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'In our campus ecosystem, your academic reputation earns you '
                'more than just grades. We turn your integrity and hard work '
                'into a liquid financial asset.',
                style: textTheme.bodyLarge?.copyWith(
                  color: muted,
                  height: 1.45,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardTint,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_rounded, color: blue, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Borrow on Honor',
                            style: textTheme.titleMedium?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Access zero-interest micro-loans based purely on '
                            'your verified student standing.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_graph_rounded, color: greenLeft, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dynamic Growth',
                          style: textTheme.titleMedium?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Watch your credit limit expand as you engage with '
                          'the community and maintain your GPA.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              children: [
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [greenLeft, greenRight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: greenLeft.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: onProceed,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Proceed to Next Step',
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip Intro',
                      style: textTheme.titleSmall?.copyWith(
                        color: blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
