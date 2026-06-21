import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../services/smart_control_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/premium_lock_card.dart';
import 'payment_detail_screen.dart';
import 'paywall_screen.dart';

class SmartControlCenterScreen extends StatelessWidget {
  const SmartControlCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final snapshot = appState.smartControlSnapshot;
    final canUseFull = appState.hasPremiumFeatureAccess;
    final visibleInsights = canUseFull
        ? snapshot.insights
        : snapshot.insights.take(1).toList(growable: false);

    return AppScaffold(
      title: localeText(
        context,
        en: 'Smart Control',
        da: 'Smart Control',
        de: 'Smart Control',
        es: 'Smart Control',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          _HealthScoreV2Card(snapshot: snapshot),
          const SizedBox(height: 16),
          _EssentialBurdenCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 16),
          _RenewalRiskCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
            onOpenPayment: (paymentId) =>
                _openPayment(context, appState, paymentId),
          ),
          const SizedBox(height: 16),
          _PriceIncreaseCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
            onOpenPayment: (paymentId) =>
                _openPayment(context, appState, paymentId),
          ),
          const SizedBox(height: 16),
          if (visibleInsights.isEmpty)
            EmptyState(
              title: localeText(
                context,
                en: 'No smart control insights yet.',
                da: 'Ingen Smart Control-indsigter endnu.',
                de: 'Noch keine Smart-Control-Einblicke.',
                es: 'Aún no hay insights de Smart Control.',
              ),
              body: localeText(
                context,
                en: 'Add a few recurring essentials and Bizoot will start finding opportunities.',
                da: 'Tilføj et par tilbagevendende basisudgifter, så begynder Bizoot at finde muligheder.',
                de: 'Füge einige wiederkehrende Grundkosten hinzu, dann beginnt Bizoot, Chancen zu erkennen.',
                es: 'Agrega algunos gastos esenciales recurrentes y Bizoot empezará a encontrar oportunidades.',
              ),
            )
          else
            ...visibleInsights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ControlInsightCard(
                  insight: insight,
                  onTap: insight.relatedPaymentId == null
                      ? null
                      : () => _openPayment(
                          context,
                          appState,
                          insight.relatedPaymentId,
                        ),
                ),
              ),
            ),
          if (!canUseFull) ...[
            const SizedBox(height: 8),
            PremiumLockCard(
              title: localeText(
                context,
                en: 'Advanced Smart Control is premium',
                da: 'Avanceret Smart Control er premium',
                de: 'Erweitertes Smart Control ist Premium',
                es: 'Smart Control avanzado es premium',
              ),
              body: localeText(
                context,
                en: 'Unlock full health explanations, price increase alerts, renewal risks, and savings recommendations.',
                da: 'Lås op for fulde sundhedsforklaringer, prisstigningsadvarsler, fornyelsesrisici og spareanbefalinger.',
                de: 'Schalte vollständige Gesundheitserklärungen, Preiswarnungen, Verlängerungsrisiken und Spartipps frei.',
                es: 'Desbloquea explicaciones completas de salud, alertas de subida de precios, riesgos de renovación y recomendaciones de ahorro.',
              ),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
            ),
          ],
        ],
      ),
    );
  }

  void _openPayment(
    BuildContext context,
    AppState appState,
    String? paymentId,
  ) {
    if (paymentId == null) return;
    final index = appState.payments.indexWhere((item) => item.id == paymentId);
    if (index == -1) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentDetailScreen(payment: appState.payments[index]),
      ),
    );
  }
}

class _HealthScoreV2Card extends StatelessWidget {
  final SmartControlSnapshot snapshot;

  const _HealthScoreV2Card({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final score = snapshot.healthScore.score;
    final delta = snapshot.healthScore.delta;
    final deltaLabel = delta == 0
        ? localeText(
            context,
            en: 'No change',
            da: 'Ingen aendring',
            de: 'Keine Aenderung',
            es: 'Sin cambios',
          )
        : delta > 0
        ? localeText(
            context,
            en: '+$delta since last update',
            da: '+$delta siden sidste opdatering',
            de: '+$delta seit dem letzten Update',
            es: '+$delta desde la ultima actualizacion',
          )
        : localeText(
            context,
            en: '${delta.abs()} point drop',
            da: '${delta.abs()} point fald',
            de: '${delta.abs()} Punkte Rueckgang',
            es: 'Bajada de ${delta.abs()} puntos',
          );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Health Score V2',
              da: 'Sundhedsscore V2',
              de: 'Gesundheitswert V2',
              es: 'Puntuacion de salud V2',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 100',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${snapshot.healthScore.status} • $deltaLabel',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ...snapshot.healthScore.topReasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $reason',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.textPrimary,
                ),
              ),
            ),
          ),
          if (snapshot.healthScore.improvements.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              localeText(
                context,
                en: 'Action checklist',
                da: 'Handlingsliste',
                de: 'Aktionsliste',
                es: 'Lista de acciones',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...snapshot.healthScore.improvements.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EssentialBurdenCard extends StatelessWidget {
  final SmartControlSnapshot snapshot;
  final String currency;

  const _EssentialBurdenCard({required this.snapshot, required this.currency});

  @override
  Widget build(BuildContext context) {
    final burden = snapshot.essentialBurden;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Essential burden',
              da: 'Fast belastning',
              de: 'Belastung durch Grundkosten',
              es: 'Carga esencial',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricPill(
                label: localeText(
                  context,
                  en: 'Essential',
                  da: 'Fast',
                  de: 'Grundlegend',
                  es: 'Esencial',
                ),
                value: formatCurrency(burden.essentialMonthlySpend, currency),
              ),
              _MetricPill(
                label: localeText(
                  context,
                  en: 'Non-essential',
                  da: 'Ikke-fast',
                  de: 'Nicht essenziell',
                  es: 'No esencial',
                ),
                value: formatCurrency(
                  burden.nonEssentialMonthlySpend,
                  currency,
                ),
              ),
              _MetricPill(
                label: localeText(
                  context,
                  en: 'Income used',
                  da: 'Andel af indkomst',
                  de: 'Einkommensanteil',
                  es: 'Ingreso usado',
                ),
                value:
                    '${burden.essentialBurdenPercentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localeText(
              context,
              en: 'Non-essential subscriptions represent ${burden.nonEssentialSharePercentage.toStringAsFixed(1)}% of recurring spend.',
              da: 'Ikke-faste abonnementer udgoer ${burden.nonEssentialSharePercentage.toStringAsFixed(1)}% af de tilbagevendende udgifter.',
              de: 'Nicht essenzielle Abos machen ${burden.nonEssentialSharePercentage.toStringAsFixed(1)}% der wiederkehrenden Ausgaben aus.',
              es: 'Las suscripciones no esenciales representan el ${burden.nonEssentialSharePercentage.toStringAsFixed(1)}% del gasto recurrente.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RenewalRiskCard extends StatelessWidget {
  final SmartControlSnapshot snapshot;
  final String currency;
  final ValueChanged<String?> onOpenPayment;

  const _RenewalRiskCard({
    required this.snapshot,
    required this.currency,
    required this.onOpenPayment,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.renewalRisks.isEmpty) {
      return AppCard(
        child: Text(
          localeText(
            context,
            en: 'No renewal risks are coming up right now.',
            da: 'Der er ingen fornyelsesrisici lige nu.',
            de: 'Derzeit stehen keine Verlaengerungsrisiken an.',
            es: 'No hay riesgos de renovacion en este momento.',
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Renewal risks',
              da: 'Fornyelsesrisici',
              de: 'Verlaengerungsrisiken',
              es: 'Riesgos de renovacion',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...snapshot.renewalRisks
              .take(3)
              .map(
                (risk) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ControlRow(
                    title: risk.payment.name,
                    subtitle: localeText(
                      context,
                      en: '${risk.label} in ${risk.daysRemaining} day${risk.daysRemaining == 1 ? '' : 's'}',
                      da: '${risk.label} om ${risk.daysRemaining} dag${risk.daysRemaining == 1 ? '' : 'e'}',
                      de: '${risk.label} in ${risk.daysRemaining} Tag${risk.daysRemaining == 1 ? '' : 'en'}',
                      es: '${risk.label} en ${risk.daysRemaining} dia${risk.daysRemaining == 1 ? '' : 's'}',
                    ),
                    trailing: risk.missingManagementLink
                        ? localeText(
                            context,
                            en: 'Link missing',
                            da: 'Link mangler',
                            de: 'Link fehlt',
                            es: 'Falta enlace',
                          )
                        : formatCurrency(risk.payment.amount, currency),
                    onTap: () => onOpenPayment(risk.payment.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _PriceIncreaseCard extends StatelessWidget {
  final SmartControlSnapshot snapshot;
  final String currency;
  final ValueChanged<String?> onOpenPayment;

  const _PriceIncreaseCard({
    required this.snapshot,
    required this.currency,
    required this.onOpenPayment,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.priceIncreaseSignals.isEmpty) {
      return AppCard(
        child: Text(
          localeText(
            context,
            en: 'No recent price increases detected.',
            da: 'Ingen nylige prisstigninger registreret.',
            de: 'Keine aktuellen Preiserhoehungen erkannt.',
            es: 'No se detectaron aumentos de precio recientes.',
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Price increase alerts',
              da: 'Advarsler om prisstigninger',
              de: 'Preissteigerungswarnungen',
              es: 'Alertas de subida de precio',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...snapshot.priceIncreaseSignals
              .take(3)
              .map(
                (signal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ControlRow(
                    title: signal.payment.name,
                    subtitle: localeText(
                      context,
                      en: signal.shouldUsePercentCopy
                          ? 'Increased by ${signal.displayPercentage.toStringAsFixed(0)}% since the last update'
                          : 'Up by ${formatCurrency(signal.deltaAmount, currency)}/month since the last update',
                      da: signal.shouldUsePercentCopy
                          ? 'Steg med ${signal.displayPercentage.toStringAsFixed(0)}% siden sidste opdatering'
                          : 'Steg med ${formatCurrency(signal.deltaAmount, currency)}/maaned siden sidste opdatering',
                      de: signal.shouldUsePercentCopy
                          ? 'Seit dem letzten Update um ${signal.displayPercentage.toStringAsFixed(0)}% gestiegen'
                          : 'Seit dem letzten Update um ${formatCurrency(signal.deltaAmount, currency)}/Monat gestiegen',
                      es: signal.shouldUsePercentCopy
                          ? 'Aumento del ${signal.displayPercentage.toStringAsFixed(0)}% desde la ultima actualizacion'
                          : 'Subio ${formatCurrency(signal.deltaAmount, currency)}/mes desde la ultima actualizacion',
                    ),
                    trailing:
                        '${formatCurrency(signal.deltaAmount, currency)}/month',
                    onTap: () => onOpenPayment(signal.payment.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ControlInsightCard extends StatelessWidget {
  final SmartControlInsight insight;
  final VoidCallback? onTap;

  const _ControlInsightCard({required this.insight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insight.title,
              maxLines: 2,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (insight.impactLabel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  insight.impactLabel!,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: BizootColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              insight.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Text(
                insight.actionLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  const _ControlRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BizootColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                trailing,
                textAlign: TextAlign.right,
                maxLines: 2,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
