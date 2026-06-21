import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../services/financial_intelligence_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'animated_pressable.dart';
import 'app_card.dart';
import 'gradient_text.dart';

class CategoryDonutCard extends StatelessWidget {
  final List<CategorySpendBreakdown> breakdown;
  final String currency;
  final VoidCallback onPressed;

  const CategoryDonutCard({
    super.key,
    required this.breakdown,
    required this.currency,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final top = breakdown.take(5).toList(growable: false);
    final total = top.fold<double>(0, (sum, item) => sum + item.monthlySpend);

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
                        en: 'Category distribution',
                        da: 'Kategorifordeling',
                        de: 'Kategorienverteilung',
                        es: 'Distribucion por categorias',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localeText(
                        context,
                        en: 'Where your recurring spend is concentrated each month.',
                        da: 'Hvor dine tilbagevendende udgifter er mest koncentreret hver maaned.',
                        de: 'Wo sich deine wiederkehrenden Ausgaben jeden Monat konzentrieren.',
                        es: 'Donde se concentra cada mes tu gasto recurrente.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPressable(
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: BizootColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    localeText(
                      context,
                      en: 'View full breakdown',
                      da: 'Se fuld oversigt',
                      de: 'Vollstaendige Aufschluesselung ansehen',
                      es: 'Ver desglose completo',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 420;
              if (top.isEmpty) {
                return Text(
                  localeText(
                    context,
                    en: 'Add more recurring payments to unlock category distribution.',
                    da: 'Tilfoej flere tilbagevendende betalinger for at laase op for kategorifordeling.',
                    de: 'Fuege mehr wiederkehrende Zahlungen hinzu, um die Kategorienverteilung freizuschalten.',
                    es: 'Agrega mas pagos recurrentes para desbloquear la distribucion por categorias.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                );
              }
              if (stacked) {
                return Column(
                  children: [
                    _DonutChart(
                      total: total,
                      currency: currency,
                      segments: top,
                    ),
                    const SizedBox(height: 18),
                    ...top.asMap().entries.map(
                      (entry) => _LegendRow(
                        item: entry.value,
                        color: _DonutPainter
                            .palette[entry.key % _DonutPainter.palette.length],
                        total: total,
                        currency: currency,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _DonutChart(total: total, currency: currency, segments: top),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: top
                          .asMap()
                          .entries
                          .map(
                            (entry) => _LegendRow(
                              item: entry.value,
                              color:
                                  _DonutPainter.palette[entry.key %
                                      _DonutPainter.palette.length],
                              total: total,
                              currency: currency,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final double total;
  final String currency;
  final List<CategorySpendBreakdown> segments;

  const _DonutChart({
    required this.total,
    required this.currency,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BizootColors.primary.withValues(alpha: 0.18),
                  BizootColors.secondary.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
          CustomPaint(
            size: const Size.square(184),
            painter: _DonutPainter(segments: segments, total: total),
          ),
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BizootColors.surfaceElevated.withValues(alpha: 0.94),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: BizootColors.primary.withValues(alpha: 0.12),
                  blurRadius: 22,
                  spreadRadius: -10,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GradientText(
                    formatCurrency(total, currency),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localeText(
                  context,
                  en: 'Monthly total',
                  da: 'Maaned i alt',
                  de: 'Monatlich gesamt',
                  es: 'Total mensual',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final CategorySpendBreakdown item;
  final Color color;
  final double total;
  final String currency;

  const _LegendRow({
    required this.item,
    required this.color,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total <= 0 ? 0 : (item.monthlySpend / total) * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                    Text(
                      ' / ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: GradientText(
                        formatCurrency(item.monthlySpend, currency),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CategorySpendBreakdown> segments;
  final double total;

  static const palette = <Color>[
    Color(0xFF43E7B1),
    Color(0xFF3FA8FF),
    Color(0xFF8E6BFF),
    Color(0xFFFFA24D),
    Color(0xFFFF5CA8),
  ];

  const _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 20.0;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawArc(
      rect.deflate(22),
      -math.pi / 2,
      math.pi * 2,
      false,
      basePaint,
    );

    if (total <= 0) return;

    final arcRect = rect.deflate(22);
    final gap = 0.12;
    var startAngle = -math.pi / 2;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      final rawSweep = (segment.monthlySpend / total) * math.pi * 2;
      final sweep = math.max(0.02, rawSweep - gap);
      final color = palette[index % palette.length];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = strokeWidth
        ..color = color;
      final clampedSweep = sweep > math.pi * 2 ? math.pi * 2 : sweep;
      canvas.drawArc(arcRect, startAngle, clampedSweep, false, paint);
      if (clampedSweep > 0) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = strokeWidth + 3
          ..color = color.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(arcRect, startAngle, clampedSweep, false, glowPaint);
      }
      startAngle += rawSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.segments != segments;
  }
}
