import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Phase 02: animates [peerNetworkAsset], then image eases up while content rises in.
class OnboardingPeerNetworkScreen extends StatefulWidget {
  const OnboardingPeerNetworkScreen({super.key});

  static const String peerNetworkAsset = 'assets/images/peer_network_onboarding.png';
  static const String arrowAsset = 'assets/images/Arrow.png';

  @override
  State<OnboardingPeerNetworkScreen> createState() =>
      _OnboardingPeerNetworkScreenState();
}

class _OnboardingPeerNetworkScreenState extends State<OnboardingPeerNetworkScreen>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _blue = Color(0xFF1A73E8);
  static const Color _greenTitle = Color(0xFF1B5E20);
  static const Color _ringTrack = Color(0xFFD6E8F5);
  static const Color _ringFill = Color(0xFF1B5E20);
  static const Color _cardBg = Color(0xFFF0F4F8);
  static const Color _greenLeft = Color(0xFF1B5E20);
  static const Color _greenRight = Color(0xFF66BB6A);

  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _revealController;

  late final Animation<Offset> _imageSlide;
  late final Animation<double> _imageFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  Timer? _revealTimer;
  bool _imageLayerRemoved = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _imageSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.42),
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _imageFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.92, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.08, 1, curve: Curves.easeOutCubic),
      ),
    );

    _revealTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      _revealController.forward();
    });

    _revealController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _floatController.stop();
        _pulseController.stop();
        setState(() => _imageLayerRemoved = true);
      }
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _floatController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _goLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goNextOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding-decentralized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_imageLayerRemoved)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _floatController,
                  _pulseController,
                  _revealController,
                ]),
                builder: (context, child) {
                  final fade = _imageFade.value;
                  if (fade <= 0.001) return const SizedBox.shrink();

                  final drift = 10 * math.sin(_floatController.value * math.pi);
                  final pulse = 0.97 + (_pulseController.value * 0.05);

                  return SlideTransition(
                    position: _imageSlide,
                    child: FadeTransition(
                      opacity: AlwaysStoppedAnimation(fade.clamp(0.0, 1.0)),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, drift),
                          child: Transform.scale(
                            scale: pulse,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Image.asset(
                    OnboardingPeerNetworkScreen.peerNetworkAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _revealController,
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
              child: _PeerNetworkContent(
                onProceed: _goNextOnboarding,
                onSkipIntro: _goLogin,
                ink: _ink,
                muted: _muted,
                blue: _blue,
                greenTitle: _greenTitle,
                cardBg: _cardBg,
                ringTrack: _ringTrack,
                ringFill: _ringFill,
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

class _PeerNetworkContent extends StatelessWidget {
  const _PeerNetworkContent({
    required this.onProceed,
    required this.onSkipIntro,
    required this.ink,
    required this.muted,
    required this.blue,
    required this.greenTitle,
    required this.cardBg,
    required this.ringTrack,
    required this.ringFill,
    required this.greenLeft,
    required this.greenRight,
  });

  final VoidCallback onProceed;
  final VoidCallback onSkipIntro;
  final Color ink;
  final Color muted;
  final Color blue;
  final Color greenTitle;
  final Color cardBg;
  final Color ringTrack;
  final Color ringFill;
  final Color greenLeft;
  final Color greenRight;

  static const double _trustProgress = 0.84;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Text(
                  'THE COMMUNITY ENGINE',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: blue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: textTheme.headlineMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    fontSize: 28,
                  ),
                  children: [
                    const TextSpan(text: 'Peer-Powered '),
                    TextSpan(
                      text: 'Growth.',
                      style: TextStyle(color: greenTitle),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                'We’ve digitized the campus ledger. This isn’t a bank; it’s a '
                'network of students helping students. Borrow when you need, '
                'invest when you can, and watch the collective trust of your '
                'campus unlock financial opportunities traditional institutions '
                "won't offer.",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: muted,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 132,
                      width: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(132, 132),
                            painter: _TrustRingPainter(
                              progress: _trustProgress,
                              trackColor: ringTrack,
                              fillColor: ringFill,
                              strokeWidth: 12,
                            ),
                          ),
                          Text(
                            '84%',
                            style: textTheme.headlineSmall?.copyWith(
                              color: blue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Community Trust Score',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your campus currently maintains a high-liquidity rating '
                      'based on 2,400+ successful peer transactions.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
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
                        blurRadius: 20,
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
                            const SizedBox(width: 10),
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                OnboardingPeerNetworkScreen.arrowAsset,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
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
                    onPressed: onSkipIntro,
                    child: Text(
                      'Skip Intro',
                      style: textTheme.titleSmall?.copyWith(
                        color: blue,
                        fontWeight: FontWeight.w700,
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

class _TrustRingPainter extends CustomPainter {
  _TrustRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    final arc = Rect.fromCircle(center: center, radius: radius);
    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arc,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrustRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
