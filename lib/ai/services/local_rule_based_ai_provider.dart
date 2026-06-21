import '../../models/recurring_payment.dart';
import '../../models/user_settings.dart';
import '../../utils/formatters.dart';
import '../../services/financial_intelligence_service.dart';
import '../../services/smart_insights_service.dart';
import '../models/ai_forecast.dart';
import '../models/ai_insight.dart';
import '../models/ai_recommendation.dart';
import '../models/ai_user_context.dart';
import 'ai_insight_provider.dart';

class LocalRuleBasedAiProvider implements AiInsightProvider {
  const LocalRuleBasedAiProvider({
    this.smartInsightsService = const SmartInsightsService(),
    this.financialIntelligenceService = const FinancialIntelligenceService(),
  });

  final SmartInsightsService smartInsightsService;
  final FinancialIntelligenceService financialIntelligenceService;

  @override
  String get providerName => 'Local';

  @override
  Future<List<AiInsight>> generatePersonalizedInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
  }) async {
    final ruleInsights = smartInsightsService.buildInsights(
      settings,
      payments,
      isPremiumUser: isPremiumUser,
    );

    return ruleInsights
        .map(
          (item) => AiInsight(
            id: item.id,
            type: _mapType(item.id),
            title: item.title,
            explanation: item.explanation,
            financialImpactLabel: item.impactLabel,
            confidence: item.premiumLocked ? 0.74 : 0.86,
            severity: _mapSeverity(item.severity),
            actionLabel: item.actionLabel,
            relatedPaymentId: item.relatedPaymentId,
            premiumLocked: item.premiumLocked,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<AiRecommendation>> generateSavingsRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    final snapshot = financialIntelligenceService.buildSnapshot(settings, payments, isPremiumUser: true);
    final recommendations = <AiRecommendation>[];

    if (snapshot.dormantSubscriptions.isNotEmpty) {
      recommendations.add(
        AiRecommendation(
          id: 'save-dormant',
          title: _t(
            settings,
            en: 'Review dormant subscriptions',
            da: 'Gennemgå inaktive abonnementer',
            de: 'Inaktive Abos prüfen',
            es: 'Revisar suscripciones inactivas',
          ),
          explanation: _t(
            settings,
            en: 'Cancelling ${snapshot.dormantSubscriptions.length} low-engagement subscription${snapshot.dormantSubscriptions.length == 1 ? '' : 's'} could reduce recurring spend.',
            da: 'Opsigelse af ${snapshot.dormantSubscriptions.length} abonnement${snapshot.dormantSubscriptions.length == 1 ? '' : 'er'} med lav aktivitet kan reducere dine faste udgifter.',
            de: 'Die Kündigung von ${snapshot.dormantSubscriptions.length} wenig genutztem Abonnement${snapshot.dormantSubscriptions.length == 1 ? '' : 's'} könnte deine wiederkehrenden Ausgaben senken.',
            es: 'Cancelar ${snapshot.dormantSubscriptions.length} suscripción${snapshot.dormantSubscriptions.length == 1 ? '' : 'es'} con poco uso podría reducir tu gasto recurrente.',
          ),
          actionLabel: _t(
            settings,
            en: 'Review',
            da: 'Gennemgå',
            de: 'Prüfen',
            es: 'Revisar',
          ),
          relatedPaymentId: snapshot.dormantSubscriptions.first.payment.id,
          confidence: 0.84,
        ),
      );
    }

    if (snapshot.duplicateGroups.isNotEmpty) {
      recommendations.add(
        AiRecommendation(
          id: 'save-duplicates',
          title: _t(
            settings,
            en: 'Reduce overlapping services',
            da: 'Reducer overlappende tjenester',
            de: 'Überschneidende Dienste reduzieren',
            es: 'Reducir servicios superpuestos',
          ),
          explanation: _t(
            settings,
            en: 'Bizoot found overlapping category spend that may be safe to reduce.',
            da: 'Bizoot fandt overlap i dine kategoriudgifter, som muligvis kan reduceres.',
            de: 'Bizoot hat überschneidende Kategorieausgaben gefunden, die sich möglicherweise reduzieren lassen.',
            es: 'Bizoot encontró gasto superpuesto por categoría que podría reducirse.',
          ),
          actionLabel: _t(
            settings,
            en: 'View overlap',
            da: 'Se overlap',
            de: 'Überschneidung ansehen',
            es: 'Ver solapamiento',
          ),
          relatedPaymentId: snapshot.duplicateGroups.first.payments.first.id,
          confidence: 0.81,
        ),
      );
    }

    return recommendations;
  }

  @override
  Future<List<AiRecommendation>> generateCancellationRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    final considering = payments.where(
      (item) => item.isActive && item.cancellationStatus == CancellationStatus.considering,
    );
    return considering
        .map(
          (payment) => AiRecommendation(
            id: 'cancel-${payment.id}',
            title: _t(
              settings,
              en: 'Cancel before the next billing cycle',
              da: 'Opsig før næste betalingsperiode',
              de: 'Vor dem nächsten Abrechnungszyklus kündigen',
              es: 'Cancelar antes del próximo ciclo de cobro',
            ),
            explanation: _t(
              settings,
              en: 'You already marked ${payment.name} as considering cancellation. Acting before ${formatShortDate(payment.nextDueDate)} avoids the next charge.',
              da: 'Du har allerede markeret ${payment.name} som mulig opsigelse. Handler du før ${formatShortDate(payment.nextDueDate)}, undgår du næste opkrævning.',
              de: 'Du hast ${payment.name} bereits als möglichen Kündigungskandidaten markiert. Wenn du vor dem ${formatShortDate(payment.nextDueDate)} handelst, vermeidest du die nächste Belastung.',
              es: 'Ya marcaste ${payment.name} como posible cancelación. Si actúas antes del ${formatShortDate(payment.nextDueDate)}, evitarás el próximo cargo.',
            ),
            actionLabel: _t(
              settings,
              en: 'View subscription',
              da: 'Se abonnement',
              de: 'Abo ansehen',
              es: 'Ver suscripción',
            ),
            relatedPaymentId: payment.id,
            confidence: 0.9,
          ),
        )
        .take(4)
        .toList(growable: false);
  }

  @override
  Future<AiForecast> generateSpendingForecast(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    final snapshot = financialIntelligenceService.buildSnapshot(settings, payments, isPremiumUser: true);
    return AiForecast(
      summary: _t(
        settings,
        en: 'Based on your current recurring commitments, Bizoot expects your monthly run rate to stay near ${formatCurrency(snapshot.monthlyRecurringSpend, settings.currency)}.',
        da: 'Baseret på dine nuværende faste forpligtelser forventer Bizoot, at dit månedlige niveau forbliver omkring ${formatCurrency(snapshot.monthlyRecurringSpend, settings.currency)}.',
        de: 'Basierend auf deinen aktuellen wiederkehrenden Verpflichtungen erwartet Bizoot, dass dein monatliches Niveau bei etwa ${formatCurrency(snapshot.monthlyRecurringSpend, settings.currency)} bleibt.',
        es: 'Según tus compromisos recurrentes actuales, Bizoot espera que tu nivel mensual se mantenga cerca de ${formatCurrency(snapshot.monthlyRecurringSpend, settings.currency)}.',
      ),
      projectedMonthlySpend: snapshot.monthlyRecurringSpend,
      projectedYearlySpend: snapshot.yearlyRecurringProjection,
      confidence: snapshot.monthlyTrend.where((item) => item.hasTrackedData).length >= 2 ? 0.8 : 0.62,
    );
  }

  @override
  Future<String> explainHealthScore(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    final snapshot = financialIntelligenceService.buildSnapshot(settings, payments, isPremiumUser: true);
    return snapshot.healthScore.explanation;
  }

  @override
  Future<List<AiInsight>> detectSubscriptionAnomalies(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    final snapshot = financialIntelligenceService.buildSnapshot(settings, payments, isPremiumUser: true);
    final anomalies = <AiInsight>[];
    final comparable = snapshot.monthlyTrend.where((item) => item.hasComparison).toList(growable: false);
    if (comparable.isNotEmpty) {
      final latest = comparable.last;
      if (latest.changePercentage.abs() >= 8) {
        anomalies.add(
          AiInsight(
            id: 'anomaly-trend',
            type: AiInsightType.unusualIncrease,
            title: latest.changePercentage >= 0
                ? _t(
                    settings,
                    en: 'Unusual increase detected',
                    da: 'Usædvanlig stigning registreret',
                    de: 'Ungewöhnlicher Anstieg erkannt',
                    es: 'Aumento inusual detectado',
                  )
                : _t(
                    settings,
                    en: 'Unusual decrease detected',
                    da: 'Usædvanligt fald registreret',
                    de: 'Ungewöhnlicher Rückgang erkannt',
                    es: 'Descenso inusual detectado',
                  ),
            explanation: _t(
              settings,
              en: 'Your recurring spend changed by ${latest.changePercentage.toStringAsFixed(1)}% versus the previous month.',
              da: 'Dine faste udgifter ændrede sig med ${latest.changePercentage.toStringAsFixed(1)}% i forhold til måneden før.',
              de: 'Deine wiederkehrenden Ausgaben haben sich im Vergleich zum Vormonat um ${latest.changePercentage.toStringAsFixed(1)}% verändert.',
              es: 'Tu gasto recurrente cambió un ${latest.changePercentage.toStringAsFixed(1)}% frente al mes anterior.',
            ),
            financialImpactLabel: '${formatCurrency(latest.amount, settings.currency)}/month',
            confidence: 0.79,
            severity: latest.changePercentage >= 0 ? AiInsightSeverity.warning : AiInsightSeverity.info,
            actionLabel: _t(
              settings,
              en: 'View trend',
              da: 'Se udvikling',
              de: 'Trend ansehen',
              es: 'Ver tendencia',
            ),
          ),
        );
      }
    }
    return anomalies;
  }

  @override
  AiUserContext buildSanitizedUserContext(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) {
    return AiUserContext(
      currency: settings.currency,
      monthlyIncome: settings.monthlyIncome,
      subscriptions: payments
          .map(
            (item) => AiSubscriptionContextItem(
              serviceName: item.name,
              amount: item.amount,
              currency: item.currency,
              category: item.category.displayLabel,
              billingFrequency: item.frequency.displayLabel,
              nextDueDate: item.nextDueDate,
              isTrial: item.isTrial,
              trialEndDate: item.trialEndDate,
              consideringCancellation: item.cancellationStatus == CancellationStatus.considering,
            ),
          )
          .toList(growable: false),
    );
  }

  AiInsightType _mapType(String id) {
    if (id.contains('savings')) return AiInsightType.savingsOpportunity;
    if (id.contains('duplicate')) return AiInsightType.duplicateServices;
    if (id.contains('trial')) return AiInsightType.trialRisk;
    if (id.contains('cancellation')) return AiInsightType.cancellationRecommendation;
    if (id.contains('monthly')) return AiInsightType.unusualIncrease;
    if (id.contains('category')) return AiInsightType.categoryOverload;
    return AiInsightType.healthScoreExplanation;
  }

  AiInsightSeverity _mapSeverity(SmartInsightSeverity severity) {
    return switch (severity) {
      SmartInsightSeverity.info => AiInsightSeverity.info,
      SmartInsightSeverity.warning => AiInsightSeverity.warning,
      SmartInsightSeverity.savings => AiInsightSeverity.savings,
      SmartInsightSeverity.urgent => AiInsightSeverity.urgent,
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
        return da;
      case 'de':
      case 'german':
      case 'deutsch':
        return de;
      case 'es':
      case 'spanish':
      case 'espanol':
      case 'español':
        return es;
      default:
        return en;
    }
  }
}
