import '../models/recurring_payment.dart';
import '../models/user_settings.dart';
import '../l10n/localized_text_sanitizer.dart';
import '../utils/formatters.dart';
import '../utils/payment_math.dart';
import 'financial_intelligence_service.dart';

enum SmartInsightSeverity { info, warning, savings, urgent }

class SmartInsightCard {
  final String id;
  final String title;
  final String explanation;
  final String? impactLabel;
  final SmartInsightSeverity severity;
  final String actionLabel;
  final String? relatedPaymentId;
  final bool premiumLocked;

  const SmartInsightCard({
    required this.id,
    required this.title,
    required this.explanation,
    required this.severity,
    required this.actionLabel,
    this.impactLabel,
    this.relatedPaymentId,
    this.premiumLocked = false,
  });
}

class SmartInsightsService {
  const SmartInsightsService({
    this.financialIntelligenceService = const FinancialIntelligenceService(),
  });

  final FinancialIntelligenceService financialIntelligenceService;

  List<SmartInsightCard> buildInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
  }) {
    final snapshot = financialIntelligenceService.buildSnapshot(
      settings,
      payments,
      isPremiumUser: isPremiumUser,
    );

    final cards = <SmartInsightCard>[];

    if (snapshot.dormantSubscriptions.isNotEmpty) {
      final totalYearly = snapshot.dormantSubscriptions.fold<double>(
        0,
        (sum, item) => sum + item.yearlyCost,
      );
      cards.add(
        SmartInsightCard(
          id: 'savings-dormant',
          title: _t(
            settings,
            en: 'Savings opportunity',
            da: 'Sparemulighed',
            de: 'Sparmöglichkeit',
            es: 'Oportunidad de ahorro',
          ),
          explanation: _t(
            settings,
            en: 'Cancelling ${snapshot.dormantSubscriptions.length} dormant subscription${snapshot.dormantSubscriptions.length == 1 ? '' : 's'} could reduce recurring drag.',
            da: 'Opsigelse af ${snapshot.dormantSubscriptions.length} inaktivt abonnement${snapshot.dormantSubscriptions.length == 1 ? '' : 'er'} kan reducere dine faste udgifter.',
            de: 'Das Kündigen von ${snapshot.dormantSubscriptions.length} inaktivem Abonnement${snapshot.dormantSubscriptions.length == 1 ? '' : 's'} könnte deine wiederkehrenden Kosten senken.',
            es: 'Cancelar ${snapshot.dormantSubscriptions.length} suscripción${snapshot.dormantSubscriptions.length == 1 ? '' : 'es'} inactiva${snapshot.dormantSubscriptions.length == 1 ? '' : 's'} podría reducir tu carga recurrente.',
          ),
          impactLabel: '${formatCurrency(totalYearly, settings.currency)}/year',
          severity: SmartInsightSeverity.savings,
          actionLabel: _t(
            settings,
            en: 'Review subscriptions',
            da: 'Gennemgå abonnementer',
            de: 'Abos prüfen',
            es: 'Revisar suscripciones',
          ),
          relatedPaymentId: snapshot.dormantSubscriptions.first.payment.id,
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    if (snapshot.duplicateGroups.isNotEmpty) {
      final group = snapshot.duplicateGroups.first;
      cards.add(
        SmartInsightCard(
          id: 'duplicate-categories',
          title: _t(
            settings,
            en: 'Duplicate category overlap',
            da: 'Overlap i samme kategori',
            de: 'Überschneidung in derselben Kategorie',
            es: 'Solapamiento de categorías duplicadas',
          ),
          explanation: _t(
            settings,
            en: 'You have ${group.payments.length} ${group.label.toLowerCase()} subscriptions. Consider keeping only the ones you use most.',
            da: 'Du har ${group.payments.length} abonnement${group.payments.length == 1 ? '' : 'er'} i kategorien ${group.label.toLowerCase()}. Overvej kun at beholde dem, du bruger mest.',
            de: 'Du hast ${group.payments.length} Abonnement${group.payments.length == 1 ? '' : 's'} in der Kategorie ${group.label.toLowerCase()}. Behalte am besten nur die, die du wirklich nutzt.',
            es: 'Tienes ${group.payments.length} suscripción${group.payments.length == 1 ? '' : 'es'} de ${group.label.toLowerCase()}. Plantéate conservar solo las que más uses.',
          ),
          impactLabel:
              '${formatCurrency(group.yearlyImpact, settings.currency)}/year',
          severity: SmartInsightSeverity.warning,
          actionLabel: _t(
            settings,
            en: 'View subscriptions',
            da: 'Se abonnementer',
            de: 'Abos ansehen',
            es: 'Ver suscripciones',
          ),
          relatedPaymentId: group.payments.first.id,
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    if (snapshot.recurringBurdenPercentage >= 20) {
      cards.add(
        SmartInsightCard(
          id: 'recurring-burden',
          title: _t(
            settings,
            en: 'High recurring burden',
            da: 'Høj fast belastning',
            de: 'Hohe wiederkehrende Belastung',
            es: 'Alta carga recurrente',
          ),
          explanation: _t(
            settings,
            en: 'Your recurring payments use ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% of your monthly income.',
            da: 'Dine faste betalinger bruger ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% af din månedlige indkomst.',
            de: 'Deine wiederkehrenden Zahlungen machen ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% deines Monatseinkommens aus.',
            es: 'Tus pagos recurrentes consumen ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% de tus ingresos mensuales.',
          ),
          impactLabel:
              '${formatCurrency(snapshot.monthlyRecurringSpend, settings.currency)}/month',
          severity: snapshot.recurringBurdenPercentage >= 28
              ? SmartInsightSeverity.urgent
              : SmartInsightSeverity.warning,
          actionLabel: _t(
            settings,
            en: 'Improve score',
            da: 'Forbedr scoren',
            de: 'Score verbessern',
            es: 'Mejorar puntuación',
          ),
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    final riskyTrials = payments
        .where((item) {
          if (!item.isTrial || item.trialEndDate == null || !item.isActive) {
            return false;
          }
          final days = item.trialEndDate!.difference(DateTime.now()).inDays;
          return days >= 0 && days <= 7;
        })
        .toList(growable: false);
    if (riskyTrials.isNotEmpty) {
      final totalTrialCost = riskyTrials.fold<double>(
        0,
        (sum, item) => sum + (item.convertsToPaidAmount ?? item.amount),
      );
      cards.add(
        SmartInsightCard(
          id: 'trial-risk',
          title: _t(
            settings,
            en: 'Trial risk',
            da: 'Prøverisiko',
            de: 'Testphasen-Risiko',
            es: 'Riesgo de prueba',
          ),
          explanation: _t(
            settings,
            en: '${riskyTrials.length} free trial${riskyTrials.length == 1 ? '' : 's'} may turn into paid subscriptions this week.',
            da: '${riskyTrials.length} gratis prøveperiode${riskyTrials.length == 1 ? '' : 'r'} kan blive til betalte abonnementer denne uge.',
            de: '${riskyTrials.length} kostenlose Testphase${riskyTrials.length == 1 ? '' : 'n'} könnte diese Woche in bezahlte Abos übergehen.',
            es: '${riskyTrials.length} prueba${riskyTrials.length == 1 ? '' : 's'} gratuita${riskyTrials.length == 1 ? '' : 's'} podría${riskyTrials.length == 1 ? '' : 'n'} convertirse en suscripciones de pago esta semana.',
          ),
          impactLabel:
              '${formatCurrency(totalTrialCost, settings.currency)}/month',
          severity: SmartInsightSeverity.urgent,
          actionLabel: _t(
            settings,
            en: 'View trials',
            da: 'Se prøver',
            de: 'Testphasen ansehen',
            es: 'Ver pruebas',
          ),
          relatedPaymentId: riskyTrials.first.id,
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    if (snapshot.largestSubscription != null) {
      final payment = snapshot.largestSubscription!;
      cards.add(
        SmartInsightCard(
          id: 'largest-cost',
          title: _t(
            settings,
            en: 'Biggest cost',
            da: 'Største udgift',
            de: 'Größter Kostenpunkt',
            es: 'Mayor coste',
          ),
          explanation: _t(
            settings,
            en: 'Your largest recurring payment is ${payment.name}.',
            da: 'Din største faste betaling er ${payment.name}.',
            de: 'Deine größte wiederkehrende Zahlung ist ${payment.name}.',
            es: 'Tu mayor pago recurrente es ${payment.name}.',
          ),
          impactLabel:
              '${formatCurrency(monthlyEquivalent(payment), settings.currency)}/month',
          severity: SmartInsightSeverity.info,
          actionLabel: _t(
            settings,
            en: 'View subscription',
            da: 'Se abonnement',
            de: 'Abo ansehen',
            es: 'Ver suscripción',
          ),
          relatedPaymentId: payment.id,
          premiumLocked: false,
        ),
      );
    }

    if (snapshot.categoryBreakdown.length >= 2) {
      final sorted = [...snapshot.categoryBreakdown]
        ..sort((a, b) => b.monthlySpend.compareTo(a.monthlySpend));
      final first = sorted[0];
      final second = sorted[1];
      cards.add(
        SmartInsightCard(
          id: 'category-warning',
          title: _t(
            settings,
            en: 'Category intelligence',
            da: 'Kategoriindsigt',
            de: 'Kategorie-Intelligenz',
            es: 'Inteligencia por categoría',
          ),
          explanation: _t(
            settings,
            en: 'You spend more on ${first.label.toLowerCase()} than ${second.label.toLowerCase()}.',
            da: 'Du bruger mere på ${first.label.toLowerCase()} end på ${second.label.toLowerCase()}.',
            de: 'Du gibst mehr für ${first.label.toLowerCase()} aus als für ${second.label.toLowerCase()}.',
            es: 'Gastas más en ${first.label.toLowerCase()} que en ${second.label.toLowerCase()}.',
          ),
          severity: SmartInsightSeverity.info,
          actionLabel: _t(
            settings,
            en: 'View full breakdown',
            da: 'Se fuld oversigt',
            de: 'Vollständige Aufschlüsselung ansehen',
            es: 'Ver desglose completo',
          ),
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    final comparableTrend = snapshot.monthlyTrend
        .where((item) => item.hasComparison)
        .toList(growable: false);
    if (comparableTrend.isNotEmpty) {
      final latest = comparableTrend.last;
      cards.add(
        SmartInsightCard(
          id: 'monthly-increase',
          title: latest.changePercentage >= 0
              ? _t(
                  settings,
                  en: 'Monthly increase',
                  da: 'Månedlig stigning',
                  de: 'Monatlicher Anstieg',
                  es: 'Aumento mensual',
                )
              : _t(
                  settings,
                  en: 'Monthly decrease',
                  da: 'Månedligt fald',
                  de: 'Monatlicher Rückgang',
                  es: 'Descenso mensual',
                ),
          explanation: latest.changePercentage >= 0
              ? _t(
                  settings,
                  en: 'Your recurring spending increased by ${latest.changePercentage.toStringAsFixed(1)}% compared to last month.',
                  da: 'Dine faste udgifter steg med ${latest.changePercentage.toStringAsFixed(1)}% sammenlignet med sidste måned.',
                  de: 'Deine wiederkehrenden Ausgaben sind im Vergleich zum letzten Monat um ${latest.changePercentage.toStringAsFixed(1)}% gestiegen.',
                  es: 'Tu gasto recurrente aumentó un ${latest.changePercentage.toStringAsFixed(1)}% en comparación con el mes pasado.',
                )
              : _t(
                  settings,
                  en: 'Your recurring spending decreased by ${latest.changePercentage.abs().toStringAsFixed(1)}% compared to last month.',
                  da: 'Dine faste udgifter faldt med ${latest.changePercentage.abs().toStringAsFixed(1)}% sammenlignet med sidste måned.',
                  de: 'Deine wiederkehrenden Ausgaben sind im Vergleich zum letzten Monat um ${latest.changePercentage.abs().toStringAsFixed(1)}% gesunken.',
                  es: 'Tu gasto recurrente disminuyó un ${latest.changePercentage.abs().toStringAsFixed(1)}% en comparación con el mes pasado.',
                ),
          impactLabel:
              '${formatCurrency(latest.amount, settings.currency)}/month',
          severity: latest.changePercentage >= 8
              ? SmartInsightSeverity.warning
              : SmartInsightSeverity.info,
          actionLabel: _t(
            settings,
            en: 'View trend',
            da: 'Se udvikling',
            de: 'Trend ansehen',
            es: 'Ver tendencia',
          ),
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    final consideringCancellation = payments.where(
      (item) =>
          item.isActive &&
          item.cancellationStatus == CancellationStatus.considering,
    );
    if (consideringCancellation.isNotEmpty) {
      final payment = consideringCancellation.first;
      cards.add(
        SmartInsightCard(
          id: 'cancellation-suggestion',
          title: _t(
            settings,
            en: 'Cancellation suggestion',
            da: 'Forslag til opsigelse',
            de: 'Kündigungsvorschlag',
            es: 'Sugerencia de cancelación',
          ),
          explanation: _t(
            settings,
            en: 'You marked ${payment.name} as considering cancellation. Cancel before the next billing date to avoid the next charge.',
            da: 'Du har markeret ${payment.name} som mulig opsigelse. Opsig før næste betalingsdato for at undgå næste opkrævning.',
            de: 'Du hast ${payment.name} als möglichen Kündigungskandidaten markiert. Kündige vor dem nächsten Abbuchungsdatum, um die nächste Belastung zu vermeiden.',
            es: 'Marcaste ${payment.name} como una posible cancelación. Cancela antes de la próxima fecha de cobro para evitar el siguiente cargo.',
          ),
          impactLabel:
              '${formatCurrency(monthlyEquivalent(payment), settings.currency)}/month',
          severity: SmartInsightSeverity.savings,
          actionLabel: _t(
            settings,
            en: 'View subscription',
            da: 'Se abonnement',
            de: 'Abo ansehen',
            es: 'Ver suscripción',
          ),
          relatedPaymentId: payment.id,
          premiumLocked: !isPremiumUser,
        ),
      );
    }

    cards.sort(
      (a, b) => _severityRank(b.severity).compareTo(_severityRank(a.severity)),
    );
    return cards.take(8).toList(growable: false);
  }

  int _severityRank(SmartInsightSeverity severity) {
    return switch (severity) {
      SmartInsightSeverity.urgent => 4,
      SmartInsightSeverity.warning => 3,
      SmartInsightSeverity.savings => 2,
      SmartInsightSeverity.info => 1,
    };
  }

  String _t(
    UserSettings settings, {
    required String en,
    required String da,
    required String de,
    required String es,
  }) {
    switch (settings.preferredLanguage.trim().toLowerCase()) {
      case 'da':
      case 'danish':
      case 'dansk':
        return sanitizeLocalizedText(da);
      case 'de':
      case 'german':
      case 'deutsch':
        return sanitizeLocalizedText(de);
      case 'es':
      case 'spanish':
      case 'espanol':
      case 'español':
        return sanitizeLocalizedText(es);
      default:
        return sanitizeLocalizedText(en);
    }
  }

  // TODO: Replace and augment these local rules with OpenAI-powered personalization,
  // anomaly detection, and predictive spending forecasts once external AI is introduced.
}
