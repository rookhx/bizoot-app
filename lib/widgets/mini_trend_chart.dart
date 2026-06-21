import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/financial_intelligence_service.dart';
import '../theme/app_theme.dart';

class MiniTrendChart extends StatelessWidget {
  final List<SpendingTrendPoint> points;
  final int highlightIndex;
  final bool forceStableBars;

  const MiniTrendChart({
    super.key,
    required this.points,
    required this.highlightIndex,
    this.forceStableBars = false,
  });

  @override
  Widget build(BuildContext context) {
    final trackedPoints = points.where((point) => point.hasTrackedData).toList(growable: false);
    final maxAmount = trackedPoints.fold<double>(
      1.0,
      (best, point) => math.max(best, point.amount),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4-month recurring total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(
                    3,
                    (index) => Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(
                    points.length,
                    (index) {
                      final point = points[index];
                      final isHighlight = index == highlightIndex;
                      final targetHeight = !point.hasTrackedData
                          ? 12.0
                          : forceStableBars
                              ? 34.0
                              : math.max(18.0, (point.amount / maxAmount) * 56);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: targetHeight),
                              duration: BizootDurations.medium,
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return AnimatedContainer(
                                  duration: BizootDurations.medium,
                                  curve: Curves.easeOutCubic,
                                  width: isHighlight ? 16 : 12,
                                  height: value,
                                  decoration: BoxDecoration(
                                    gradient: !point.hasTrackedData
                                        ? null
                                        : isHighlight
                                            ? BizootGradients.main
                                            : LinearGradient(
                                                colors: [
                                                  BizootColors.surfaceElevated.withValues(alpha: 0.95),
                                                  BizootColors.secondary.withValues(alpha: 0.34),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                    color: point.hasTrackedData ? null : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isHighlight
                                          ? Colors.white.withValues(alpha: 0.24)
                                          : Colors.white.withValues(alpha: 0.08),
                                    ),
                                    boxShadow: isHighlight
                                        ? [
                                            BoxShadow(
                                              color: BizootColors.primary.withValues(alpha: 0.22),
                                              blurRadius: 18,
                                              spreadRadius: -8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List<Widget>.generate(
            points.length,
            (index) {
              final point = points[index];
              final isHighlight = index == highlightIndex;
              return Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isHighlight ? BizootColors.textPrimary : BizootColors.textMuted,
                        fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
