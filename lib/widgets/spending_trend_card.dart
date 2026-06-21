import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../services/financial_intelligence_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'gradient_text.dart';
import 'mini_trend_chart.dart';

class SpendingTrendCard extends StatelessWidget {
  final SpendingTrendPoint point;
  final List<SpendingTrendPoint> points;
  final int highlightIndex;
  final String currency;

  const SpendingTrendCard({
    super.key,
    required this.point,
    required this.points,
    required this.highlightIndex,
    required this.currency,
  });

  String? _statusLabel(BuildContext context) {
    if (!point.hasComparison) {
      return null;
    }
    if (point.isIncrease) {
      return localeText(
        context,
        en: 'Increased',
        da: 'Steget',
        de: 'Gestiegen',
        es: 'Aumentó',
      );
    }
    if (point.isDecrease) {
      return localeText(
        context,
        en: 'Decreased',
        da: 'Faldet',
        de: 'Gesunken',
        es: 'Disminuyó',
      );
    }
    return localeText(
      context,
      en: 'Stable',
      da: 'Stabil',
      de: 'Stabil',
      es: 'Estable',
    );
  }

  IconData get _statusIcon {
    if (!point.hasComparison || point.isStable) {
      return Icons.trending_flat_rounded;
    }
    return point.isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
  }

  Color get _accentColor {
    if (!point.hasComparison || point.isStable) {
      return BizootColors.textSecondary;
    }
    return point.isIncrease ? BizootColors.orange : BizootColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final changeLabel = !point.hasComparison
        ? null
        : point.isStable
            ? localeText(
                context,
                en: 'No meaningful change',
                da: 'Ingen væsentlig ændring',
                de: 'Keine wesentliche Änderung',
                es: 'Sin cambios importantes',
              )
            : localeText(
                context,
                en: '${point.changePercentage.isNegative ? '-' : '+'}${point.changePercentage.abs().toStringAsFixed(0)}% vs previous',
                da: '${point.changePercentage.isNegative ? '-' : '+'}${point.changePercentage.abs().toStringAsFixed(0)}% i forhold til forrige',
                de: '${point.changePercentage.isNegative ? '-' : '+'}${point.changePercentage.abs().toStringAsFixed(0)}% gegenüber dem vorherigen Wert',
                es: '${point.changePercentage.isNegative ? '-' : '+'}${point.changePercentage.abs().toStringAsFixed(0)}% frente al periodo anterior',
              );
    final statusLabel = _statusLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 34,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: GradientText(
                            formatCurrency(point.amount, currency),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (statusLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _accentColor.withValues(alpha: 0.24)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, size: 14, color: _accentColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                statusLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _accentColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (statusLabel != null && changeLabel != null) const SizedBox(height: 8),
                    if (changeLabel != null)
                      Text(
                        changeLabel,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _accentColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: MiniTrendChart(
                points: points,
                highlightIndex: highlightIndex,
                forceStableBars: point.isStable,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
