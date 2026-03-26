import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/trust_score.dart';

/// Circular progress with score, level label, and optional caption.
class TrustScoreRingWidget extends StatelessWidget {
  const TrustScoreRingWidget({
    super.key,
    required this.trustScore,
    this.size = 200,
    this.strokeWidth = 12,
    this.trackColor,
    this.progressColor,
  });

  final TrustScore trustScore;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;

  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _green = Color(0xFF34A853);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (trustScore.score / 100).clamp(0.0, 1.0);
    final track = trackColor ?? const Color(0xFFE4E7EC);
    final fill = progressColor ?? _green;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                backgroundColor: track,
                color: fill,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRUST SCORE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${trustScore.score}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.18,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _levelBackground(trustScore.level),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trustScore.level,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _levelForeground(trustScore.level),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _levelBackground(String level) {
    switch (level) {
      case 'High':
        return const Color(0xFFE8F8EC);
      case 'Medium':
        return const Color(0xFFFFF7E6);
      default:
        return const Color(0xFFF2F4F7);
    }
  }

  Color _levelForeground(String level) {
    switch (level) {
      case 'High':
        return const Color(0xFF166534);
      case 'Medium':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF475467);
    }
  }
}
