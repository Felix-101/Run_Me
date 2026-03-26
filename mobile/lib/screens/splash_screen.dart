import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repo_provider.dart';

/// First screen: gradient splash with branding; navigates after [kSplashDuration].
const Duration kSplashDuration = Duration(seconds: 3);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Color _blueTop = Color(0xFF007BFF);
  static const Color _tealBottom = Color(0xFF004D40);
  static const Color _accentMint = Color(0xFFA7FFEB);
  static const Color _taglineGreen = Color(0xFF90EE90);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(kSplashDuration);
    if (!mounted) return;
    final token = await ref.read(authRepositoryProvider).getAccessToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      token == null ? '/onboarding' : '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GradientBackground(),
          const Positioned.fill(child: _BuildingWatermark()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: _blueTop,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'runme',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FUELING YOUR ACADEMIC AMBITION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _taglineGreen.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: _tealBottom.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _accentMint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SYSTEM READY',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ESTABLISHING SECURE LINK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3.2,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF007BFF),
            Color(0xFF00695C),
            Color(0xFF004D40),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

/// Low-opacity geometric pattern suggesting a building facade behind the UI.
class _BuildingWatermark extends StatelessWidget {
  const _BuildingWatermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BuildingPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    final w = size.width;
    final h = size.height;
    final colW = w * 0.28;
    final left = w * 0.12;
    canvas.drawRect(Rect.fromLTWH(left, h * 0.08, colW, h * 0.78), paint);

    final paint2 = Paint()..color = Colors.white.withValues(alpha: 0.045);
    canvas.drawRect(Rect.fromLTWH(left + colW + w * 0.06, h * 0.15, colW * 0.95, h * 0.72), paint2);

    final win = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var row = 0; row < 6; row++) {
      for (var c = 0; c < 3; c++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + 8 + c * 22.0,
              h * 0.18 + row * 28.0,
              14,
              18,
            ),
            const Radius.circular(2),
          ),
          win,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
