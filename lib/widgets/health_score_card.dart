import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../services/financial_intelligence_service.dart';
import '../theme/app_theme.dart';
import 'animated_pressable.dart';
import 'app_card.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScoreSnapshot snapshot;
  final VoidCallback onPressed;

  const HealthScoreCard({
    super.key,
    required this.snapshot,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final boundedDelta = snapshot.delta.clamp(-100, 100).toInt();
    final hasHistory = boundedDelta != 0;
    final pointsFromIdeal = (100 - snapshot.score).clamp(0, 100);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeText(
                        context,
                        en: 'Health score',
                        da: 'Sundhedsscore',
                        de: 'Gesundheitswert',
                        es: 'Puntuación de salud',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.explanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _HealthRing(score: snapshot.score),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            snapshot.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            !hasHistory
                ? (pointsFromIdeal == 0
                    ? localeText(
                        context,
                        en: 'You are at the ideal score.',
                        da: 'Du er på den ideelle score.',
                        de: 'Du hast den idealen Wert erreicht.',
                        es: 'Has alcanzado la puntuación ideal.',
                      )
                    : localeText(
                        context,
                        en: '$pointsFromIdeal points below the ideal score.',
                        da: '$pointsFromIdeal point under den ideelle score.',
                        de: '$pointsFromIdeal Punkte unter dem idealen Wert.',
                        es: '$pointsFromIdeal puntos por debajo de la puntuación ideal.',
                      ))
                : boundedDelta > 0
                    ? localeText(
                        context,
                        en: 'Your score improved by $boundedDelta points.',
                        da: 'Din score er forbedret med $boundedDelta point.',
                        de: 'Dein Wert hat sich um $boundedDelta Punkte verbessert.',
                        es: 'Tu puntuación mejoró en $boundedDelta puntos.',
                      )
                    : localeText(
                        context,
                        en: 'Your score dropped by ${boundedDelta.abs()} points.',
                        da: 'Din score er faldet med ${boundedDelta.abs()} point.',
                        de: 'Dein Wert ist um ${boundedDelta.abs()} Punkte gesunken.',
                        es: 'Tu puntuación bajó ${boundedDelta.abs()} puntos.',
                      ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 18),
          AnimatedPressable(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: BizootGradients.main,
              ),
              child: Center(
                child: Text(
                  localeText(
                    context,
                    en: 'Improve score',
                    da: 'Forbedr score',
                    de: 'Score verbessern',
                    es: 'Mejorar puntuación',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  final int score;

  const _HealthRing({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size.square(96),
                painter: _RingPainter(progress: value),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                '/100',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 10.0;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = BizootGradients.main.createShader(rect);

    canvas.drawArc(rect.deflate(10), -math.pi / 2, math.pi * 2, false, base);
    canvas.drawArc(rect.deflate(10), -math.pi / 2, math.pi * 2 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
