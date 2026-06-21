import 'dart:math' as math;

import '../l10n/app_locale.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../models/user_settings.dart';
import '../utils/formatters.dart';
import '../utils/payment_math.dart';
import 'financial_intelligence_service.dart';

enum SmartControlSeverity { info, warning, savings, urgent }

class SmartControlInsight {
  final String id;
  final String title;
  final String body;
  final SmartControlSeverity severity;
  final String actionLabel;
  final String? impactLabel;
  final String? relatedPaymentId;
  final bool premiumLocked;

  const SmartControlInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.actionLabel,
    this.impactLabel,
    this.relatedPaymentId,
    this.premiumLocked = false,
  });
}

class PriceIncreaseSignal {
  final RecurringPayment payment;
  final double deltaAmount;
  final double percentageChange;

  const PriceIncreaseSignal({
    required this.payment,
    required this.deltaAmount,
    required this.percentageChange,
  });

  bool get shouldUsePercentCopy =>
      percentageChange.isFinite &&
      percentageChange >= 0 &&
      percentageChange <= 100;

  double get displayPercentage => percentageChange.clamp(0, 100).toDouble();
}

class RenewalRiskSignal {
  final RecurringPayment payment;
  final int daysRemaining;
  final bool missingManagementLink;
  final String label;

  const RenewalRiskSignal({
    required this.payment,
    required this.daysRemaining,
    required this.missingManagementLink,
    required this.label,
  });
}

class EssentialBurdenSnapshot {
  final double essentialMonthlySpend;
  final double nonEssentialMonthlySpend;
  final double essentialBurdenPercentage;
  final double recurringLifeBurdenPercentage;
  final double nonEssentialSharePercentage;

  const EssentialBurdenSnapshot({
    required this.essentialMonthlySpend,
    required this.nonEssentialMonthlySpend,
    required this.essentialBurdenPercentage,
    required this.recurringLifeBurdenPercentage,
    required this.nonEssentialSharePercentage,
  });
}

class SmartControlHealthScore {
  final int score;
  final String status;
  final int delta;
  final List<String> topReasons;
  final List<String> improvements;

  const SmartControlHealthScore({
    required this.score,
    required this.status,
    required this.delta,
    required this.topReasons,
    required this.improvements,
  });
}

class SmartControlSnapshot {
  final SmartControlHealthScore healthScore;
  final EssentialBurdenSnapshot essentialBurden;
  final List<PriceIncreaseSignal> priceIncreaseSignals;
  final List<RenewalRiskSignal> renewalRisks;
  final List<SmartControlInsight> insights;
  final double projectedYearlySavings;

  const SmartControlSnapshot({
    required this.healthScore,
    required this.essentialBurden,
    required this.priceIncreaseSignals,
    required this.renewalRisks,
    required this.insights,
    required this.projectedYearlySavings,
  });

  SmartControlInsight? get topUrgentRecommendation => insights.isEmpty
      ? null
      : (insights.toList()
              ..sort((a, b) => _rank(b.severity).compareTo(_rank(a.severity))))
            .first;

  static int _rank(SmartControlSeverity severity) {
    return switch (severity) {
      SmartControlSeverity.urgent => 4,
      SmartControlSeverity.warning => 3,
      SmartControlSeverity.savings => 2,
      SmartControlSeverity.info => 1,
    };
  }
}

class SmartControlService {
  const SmartControlService({
    this.financialIntelligenceService = const FinancialIntelligenceService(),
  });

  final FinancialIntelligenceService financialIntelligenceService;

  String _t(
    UserSettings settings, {
    required String en,
    required String da,
    required String de,
    required String es,
  }) {
    return switch (AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    )) {
      'da' => da,
      'de' => de,
      'es' => es,
      _ => en,
    };
  }

  String _pluralDays(UserSettings settings, int days) {
    return switch (AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    )) {
      'da' => days == 1 ? 'dag' : 'dage',
      'de' => days == 1 ? 'Tag' : 'Tage',
      'es' => days == 1 ? 'dia' : 'dias',
      'spanish' => days == 1 ? 'día' : 'días',
      _ => days == 1 ? 'day' : 'days',
    };
  }

  SmartControlSnapshot buildSnapshot(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool hasPremiumAccess,
    List<UserDocument> documents = const [],
  }) {
    final active = payments
        .where((item) => item.isActive)
        .toList(growable: false);
    final intelligence = financialIntelligenceService.buildSnapshot(
      settings,
      active,
      isPremiumUser: hasPremiumAccess,
    );
    final essentialBurden = _buildEssentialBurden(settings, active);
    final priceIncreaseSignals = _buildPriceIncreaseSignals(active);
    final renewalRisks = _buildRenewalRisks(settings, active);
    final previousScore = _calculateScore(
      settings,
      _paymentsUsingPreviousAmounts(active),
      essentialBurden: _buildEssentialBurden(
        settings,
        _paymentsUsingPreviousAmounts(active),
      ),
      priceIncreaseSignals: const [],
      renewalRisks: _buildRenewalRisks(
        settings,
        _paymentsUsingPreviousAmounts(active),
      ),
      intelligence: financialIntelligenceService.buildSnapshot(
        settings,
        _paymentsUsingPreviousAmounts(active),
        isPremiumUser: hasPremiumAccess,
      ),
    );
    final currentScore = _calculateScore(
      settings,
      active,
      essentialBurden: essentialBurden,
      priceIncreaseSignals: priceIncreaseSignals,
      renewalRisks: renewalRisks,
      intelligence: intelligence,
    );
    final healthScore = _buildHealthScore(
      settings,
      active,
      intelligence: intelligence,
      essentialBurden: essentialBurden,
      priceIncreaseSignals: priceIncreaseSignals,
      renewalRisks: renewalRisks,
      currentScore: currentScore,
      previousScore: previousScore,
    );
    final insights = _buildInsights(
      settings,
      active,
      intelligence: intelligence,
      essentialBurden: essentialBurden,
      priceIncreaseSignals: priceIncreaseSignals,
      renewalRisks: renewalRisks,
      healthScore: healthScore,
      hasPremiumAccess: hasPremiumAccess,
      documents: documents,
    );
    final projectedYearlySavings = _projectedYearlySavings(
      intelligence,
      priceIncreaseSignals,
    );

    return SmartControlSnapshot(
      healthScore: healthScore,
      essentialBurden: essentialBurden,
      priceIncreaseSignals: priceIncreaseSignals,
      renewalRisks: renewalRisks,
      insights: insights,
      projectedYearlySavings: projectedYearlySavings,
    );
  }

  EssentialBurdenSnapshot _buildEssentialBurden(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) {
    final essential = payments
        .where((item) => item.isEssential)
        .toList(growable: false);
    final nonEssential = payments
        .where((item) => !item.isEssential)
        .toList(growable: false);
    final essentialMonthly = essential.fold<double>(
      0,
      (sum, item) => sum + monthlyEquivalent(item),
    );
    final nonEssentialMonthly = nonEssential.fold<double>(
      0,
      (sum, item) => sum + monthlyEquivalent(item),
    );
    final totalMonthly = essentialMonthly + nonEssentialMonthly;

    return EssentialBurdenSnapshot(
      essentialMonthlySpend: essentialMonthly,
      nonEssentialMonthlySpend: nonEssentialMonthly,
      essentialBurdenPercentage: settings.monthlyIncome <= 0
          ? 0
          : (essentialMonthly / settings.monthlyIncome) * 100,
      recurringLifeBurdenPercentage: settings.monthlyIncome <= 0
          ? 0
          : (totalMonthly / settings.monthlyIncome) * 100,
      nonEssentialSharePercentage: totalMonthly <= 0
          ? 0
          : (nonEssentialMonthly / totalMonthly) * 100,
    );
  }

  List<PriceIncreaseSignal> _buildPriceIncreaseSignals(
    List<RecurringPayment> payments,
  ) {
    return payments
        .where(
          (item) =>
              item.latestPriceHistory != null && item.percentageChange >= 5,
        )
        .map(
          (item) => PriceIncreaseSignal(
            payment: item,
            deltaAmount: item.latestPriceHistory!.monthlyDelta,
            percentageChange: item.percentageChange,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
  }

  List<RenewalRiskSignal> _buildRenewalRisks(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) {
    final now = DateTime.now();
    final risks = <RenewalRiskSignal>[];

    for (final payment in payments) {
      if (payment.isTrial && payment.trialEndDate != null) {
        final days = payment.trialEndDate!.difference(now).inDays;
        if (days >= 0 && days <= 7) {
          risks.add(
            RenewalRiskSignal(
              payment: payment,
              daysRemaining: days,
              missingManagementLink: payment.effectiveManagementUrl.isEmpty,
              label: _t(
                settings,
                en: 'Trial ending soon',
                da: 'Prøveperiode slutter snart',
                de: 'Testphase endet bald',
                es: 'La prueba termina pronto',
              ),
            ),
          );
        }
      }

      final target = payment.contractEndDate ?? payment.renewalDate;
      if (target == null) continue;
      final daysRemaining = target.difference(now).inDays;
      if (daysRemaining >= 0 && daysRemaining <= 30) {
        risks.add(
          RenewalRiskSignal(
            payment: payment,
            daysRemaining: daysRemaining,
            missingManagementLink: payment.effectiveManagementUrl.isEmpty,
            label: payment.contractEndDate != null
                ? _t(
                    settings,
                    en: 'Contract ending soon',
                    da: 'Kontrakt slutter snart',
                    de: 'Vertrag endet bald',
                    es: 'El contrato termina pronto',
                  )
                : _t(
                    settings,
                    en: 'Renewal coming up',
                    da: 'Fornyelse nærmer sig',
                    de: 'Verlängerung steht an',
                    es: 'La renovación se acerca',
                  ),
          ),
        );
      }
    }

    risks.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return risks;
  }

  List<RecurringPayment> _paymentsUsingPreviousAmounts(
    List<RecurringPayment> payments,
  ) {
    return payments
        .map(
          (item) => item.previousAmount == null
              ? item
              : item.copyWith(amount: item.previousAmount),
        )
        .toList(growable: false);
  }

  int _calculateScore(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required EssentialBurdenSnapshot essentialBurden,
    required List<PriceIncreaseSignal> priceIncreaseSignals,
    required List<RenewalRiskSignal> renewalRisks,
    required FinancialIntelligenceSnapshot intelligence,
  }) {
    var score = 100.0;

    final activeCount = payments.length;
    final overdueCount = payments
        .where((item) => !_isFutureDate(item.nextDueDate))
        .length;
    final missingLinks = payments
        .where((item) => item.effectiveManagementUrl.isEmpty)
        .length;
    final topCategoryShare = intelligence.categoryBreakdown.isEmpty
        ? 0.0
        : (intelligence.categoryBreakdown.first.monthlySpend /
                  math.max(intelligence.monthlyRecurringSpend, 1)) *
              100;

    score -= _burdenPenalty(intelligence.recurringBurdenPercentage);
    score -= _essentialPenalty(essentialBurden.essentialBurdenPercentage);
    score -= math.min(activeCount * 1.2, 10);
    score -= math.min(priceIncreaseSignals.length * 4.0, 12);
    score -= math.min(intelligence.duplicateGroups.length * 6.0, 18);
    score -= math.min(renewalRisks.length * 3.0, 12);
    score -= math.min(overdueCount * 6.0, 18);
    score -= math.min(missingLinks * 2.5, 10);
    if (topCategoryShare >= 45) {
      score -= 7;
    }

    return score.clamp(0, 100).round();
  }

  SmartControlHealthScore _buildHealthScore(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required FinancialIntelligenceSnapshot intelligence,
    required EssentialBurdenSnapshot essentialBurden,
    required List<PriceIncreaseSignal> priceIncreaseSignals,
    required List<RenewalRiskSignal> renewalRisks,
    required int currentScore,
    required int previousScore,
  }) {
    final reasons = <String>[];
    final improvements = <String>[];

    if (intelligence.duplicateGroups.isNotEmpty) {
      reasons.add('Duplicate services are increasing recurring overlap.');
      improvements.add(
        'Review overlapping subscriptions and keep only the highest-value plan.',
      );
    }
    if (essentialBurden.essentialBurdenPercentage >= 35) {
      reasons.add(
        'Essential recurring costs are using a large share of monthly income.',
      );
      improvements.add(
        'Review insurance, internet, phone, and rent-linked commitments first.',
      );
    }
    if (priceIncreaseSignals.isNotEmpty) {
      reasons.add(
        _t(
          settings,
          en: 'Recent price increases are putting extra pressure on your monthly budget.',
          da: 'Nylige prisstigninger laegger ekstra pres paa dit maanedlige budget.',
          de: 'Juengste Preiserhoehungen setzen dein Monatsbudget zusaetzlich unter Druck.',
          es: 'Los aumentos recientes de precio estan ejerciendo mas presion sobre tu presupuesto mensual.',
        ),
      );
      improvements.add(
        _t(
          settings,
          en: 'Review recent price increases before the next billing cycle.',
          da: 'Gennemgaa nylige prisstigninger foer naeste faktureringsperiode.',
          de: 'Pruefe aktuelle Preiserhoehungen vor dem naechsten Abrechnungszeitraum.',
          es: 'Revisa los aumentos recientes de precio antes del siguiente ciclo de facturacion.',
        ),
      );
    }
    if (renewalRisks.isNotEmpty) {
      reasons.add(
        _t(
          settings,
          en: 'Upcoming renewals could lock in higher recurring costs.',
          da: 'Kommende fornyelser kan laase hoejere tilbagevendende udgifter fast.',
          de: 'Anstehende Verlaengerungen koennten hoehere laufende Kosten festschreiben.',
          es: 'Las proximas renovaciones podrian consolidar costes recurrentes mas altos.',
        ),
      );
      improvements.add(
        _t(
          settings,
          en: 'Check renewals and contracts before they roll over automatically.',
          da: 'Tjek fornyelser og kontrakter, foer de forlaenges automatisk.',
          de: 'Pruefe Verlaengerungen und Vertraege, bevor sie sich automatisch verlaengern.',
          es: 'Revisa renovaciones y contratos antes de que se renueven automaticamente.',
        ),
      );
    }
    if (payments.any((item) => item.effectiveManagementUrl.isEmpty)) {
      reasons.add(
        _t(
          settings,
          en: 'Some recurring items are missing management or cancellation links.',
          da: 'Nogle tilbagevendende poster mangler administrations- eller opsigelseslinks.',
          de: 'Einigen wiederkehrenden Posten fehlen Verwaltungs- oder Kuendigungslinks.',
          es: 'A algunos elementos recurrentes les faltan enlaces de gestion o cancelacion.',
        ),
      );
      improvements.add(
        _t(
          settings,
          en: 'Add management links so Bizoot can help you act faster.',
          da: 'Tilfoej administrationslinks, saa Bizoot kan hjaelpe dig hurtigere.',
          de: 'Fuege Verwaltungslinks hinzu, damit Bizoot dir schneller helfen kann.',
          es: 'Anade enlaces de gestion para que Bizoot pueda ayudarte mas rapido.',
        ),
      );
    }

    if (reasons.isEmpty) {
      reasons.add(
        _t(
          settings,
          en: 'Your recurring setup looks balanced right now.',
          da: 'Din tilbagevendende opsaetning ser afbalanceret ud lige nu.',
          de: 'Deine wiederkehrende Aufstellung wirkt derzeit ausgewogen.',
          es: 'Tu configuracion recurrente parece equilibrada en este momento.',
        ),
      );
      improvements.add(
        _t(
          settings,
          en: 'Keep tracking changes so Bizoot can catch savings opportunities early.',
          da: 'Bliv ved med at spore aendringer, saa Bizoot kan opdage besparelsesmuligheder tidligt.',
          de: 'Verfolge weiter die Aenderungen, damit Bizoot Einsparmoeglichkeiten frueh erkennen kann.',
          es: 'Sigue controlando los cambios para que Bizoot pueda detectar oportunidades de ahorro pronto.',
        ),
      );
    }

    final delta = currentScore - previousScore;
    final status = switch (currentScore) {
      >= 85 => _t(
        settings,
        en: 'Excellent',
        da: 'Fremragende',
        de: 'Ausgezeichnet',
        es: 'Excelente',
      ),
      >= 70 => _t(settings, en: 'Good', da: 'God', de: 'Gut', es: 'Buena'),
      >= 55 => _t(
        settings,
        en: 'Watch',
        da: 'Hold oje',
        de: 'Beobachten',
        es: 'Vigilar',
      ),
      _ => _t(settings, en: 'Risk', da: 'Risiko', de: 'Risiko', es: 'Riesgo'),
    };

    return SmartControlHealthScore(
      score: currentScore.clamp(0, 100),
      status: status,
      delta: delta,
      topReasons: reasons.take(3).toList(growable: false),
      improvements: improvements.take(3).toList(growable: false),
    );
  }

  List<SmartControlInsight> _buildInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required FinancialIntelligenceSnapshot intelligence,
    required EssentialBurdenSnapshot essentialBurden,
    required List<PriceIncreaseSignal> priceIncreaseSignals,
    required List<RenewalRiskSignal> renewalRisks,
    required SmartControlHealthScore healthScore,
    required bool hasPremiumAccess,
    required List<UserDocument> documents,
  }) {
    final insights = <SmartControlInsight>[];

    for (final signal in priceIncreaseSignals.take(3)) {
      insights.add(
        SmartControlInsight(
          id: 'price-${signal.payment.id}',
          title: _t(
            settings,
            en: 'Price increase detected',
            da: 'Prisforhøjelse registreret',
            de: 'Preiserhöhung erkannt',
            es: 'Aumento de precio detectado',
          ),
          body: _t(
            settings,
            en: '${signal.payment.name} increased by ${signal.percentageChange.toStringAsFixed(0)}% since the last update.',
            da: '${signal.payment.name} er steget med ${signal.percentageChange.toStringAsFixed(0)}% siden sidste opdatering.',
            de: '${signal.payment.name} ist seit der letzten Aktualisierung um ${signal.percentageChange.toStringAsFixed(0)}% gestiegen.',
            es: '${signal.payment.name} aumentó un ${signal.percentageChange.toStringAsFixed(0)}% desde la última actualización.',
          ),
          severity: signal.percentageChange >= 12
              ? SmartControlSeverity.warning
              : SmartControlSeverity.info,
          actionLabel: _t(
            settings,
            en: 'Review payment',
            da: 'Gennemgå betaling',
            de: 'Zahlung prüfen',
            es: 'Revisar pago',
          ),
          impactLabel:
              '${formatCurrency(signal.deltaAmount, settings.currency)}/month',
          relatedPaymentId: signal.payment.id,
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    if (intelligence.duplicateGroups.isNotEmpty) {
      final group = intelligence.duplicateGroups.first;
      insights.add(
        SmartControlInsight(
          id: 'overlap-${group.label}',
          title: _t(
            settings,
            en: 'Savings opportunity',
            da: 'Sparemulighed',
            de: 'Sparmöglichkeit',
            es: 'Oportunidad de ahorro',
          ),
          body: _t(
            settings,
            en: 'You have ${group.payments.length} ${group.label.toLowerCase()} services. Reviewing one could reduce costs.',
            da: 'Du har ${group.payments.length} ${group.label.toLowerCase()} tjenester. En gennemgang af én af dem kan sænke omkostningerne.',
            de: 'Du hast ${group.payments.length} ${group.label.toLowerCase()}-Dienste. Wenn du einen prüfst, könntest du Kosten senken.',
            es: 'Tienes ${group.payments.length} servicios de ${group.label.toLowerCase()}. Revisar uno podría reducir costes.',
          ),
          severity: SmartControlSeverity.savings,
          actionLabel: _t(
            settings,
            en: 'Review subscriptions',
            da: 'Gennemgå abonnementer',
            de: 'Abos prüfen',
            es: 'Revisar suscripciones',
          ),
          impactLabel:
              '${formatCurrency(group.yearlyImpact, settings.currency)}/year',
          relatedPaymentId: group.payments.first.id,
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    if (essentialBurden.essentialBurdenPercentage >= 35) {
      insights.add(
        SmartControlInsight(
          id: 'essential-burden',
          title: _t(
            settings,
            en: 'Essential burden',
            da: 'Essentiel belastning',
            de: 'Belastung durch Grundkosten',
            es: 'Carga esencial',
          ),
          body: _t(
            settings,
            en: 'Your essential recurring costs use ${essentialBurden.essentialBurdenPercentage.toStringAsFixed(1)}% of monthly income.',
            da: 'Dine essentielle tilbagevendende udgifter bruger ${essentialBurden.essentialBurdenPercentage.toStringAsFixed(1)}% af din månedlige indkomst.',
            de: 'Deine essenziellen wiederkehrenden Kosten verbrauchen ${essentialBurden.essentialBurdenPercentage.toStringAsFixed(1)}% deines Monatseinkommens.',
            es: 'Tus costes esenciales recurrentes consumen el ${essentialBurden.essentialBurdenPercentage.toStringAsFixed(1)}% de tus ingresos mensuales.',
          ),
          severity: essentialBurden.essentialBurdenPercentage >= 45
              ? SmartControlSeverity.urgent
              : SmartControlSeverity.warning,
          actionLabel: _t(
            settings,
            en: 'Review burden',
            da: 'Gennemgå belastning',
            de: 'Belastung prüfen',
            es: 'Revisar carga',
          ),
          impactLabel:
              '${formatCurrency(essentialBurden.essentialMonthlySpend, settings.currency)}/month',
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    for (final risk in renewalRisks.take(3)) {
      insights.add(
        SmartControlInsight(
          id: 'renewal-${risk.payment.id}-${risk.label}',
          title: _t(
            settings,
            en: 'Renewal risk',
            da: 'Fornyelsesrisiko',
            de: 'Verlängerungsrisiko',
            es: 'Riesgo de renovación',
          ),
          body: _t(
            settings,
            en: '${risk.payment.name} ${risk.label.toLowerCase()} in ${math.max(risk.daysRemaining, 0)} ${_pluralDays(settings, math.max(risk.daysRemaining, 0))}.',
            da: '${risk.payment.name} ${risk.label.toLowerCase()} om ${math.max(risk.daysRemaining, 0)} ${_pluralDays(settings, math.max(risk.daysRemaining, 0))}.',
            de: '${risk.payment.name} ${risk.label.toLowerCase()} in ${math.max(risk.daysRemaining, 0)} ${_pluralDays(settings, math.max(risk.daysRemaining, 0))}.',
            es: '${risk.payment.name} ${risk.label.toLowerCase()} en ${math.max(risk.daysRemaining, 0)} ${_pluralDays(settings, math.max(risk.daysRemaining, 0))}.',
          ),
          severity: risk.daysRemaining <= 7
              ? SmartControlSeverity.urgent
              : SmartControlSeverity.warning,
          actionLabel: _t(
            settings,
            en: 'Review renewal',
            da: 'Gennemgå fornyelse',
            de: 'Verlängerung prüfen',
            es: 'Revisar renovación',
          ),
          impactLabel: risk.missingManagementLink
              ? _t(
                  settings,
                  en: 'Link missing',
                  da: 'Link mangler',
                  de: 'Link fehlt',
                  es: 'Falta enlace',
                )
              : null,
          relatedPaymentId: risk.payment.id,
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    if (intelligence.mostExpensiveCategory != null &&
        intelligence.mostExpensiveCategory!.paymentCount >= 3) {
      final category = intelligence.mostExpensiveCategory!;
      insights.add(
        SmartControlInsight(
          id: 'category-overload-${category.id}',
          title: _t(
            settings,
            en: 'Category overload',
            da: 'Kategori-overbelastning',
            de: 'Kategorie überlastet',
            es: 'Sobrecarga de categoría',
          ),
          body: _t(
            settings,
            en: '${category.label} now leads your recurring spend mix. Reviewing one plan may improve control.',
            da: '${category.label} fylder nu mest i dine tilbagevendende udgifter. En gennemgang af en plan kan give bedre kontrol.',
            de: '${category.label} dominiert jetzt deine wiederkehrenden Ausgaben. Die Pruefung eines Tarifs kann mehr Kontrolle schaffen.',
            es: '${category.label} lidera ahora tu mezcla de gasto recurrente. Revisar un plan puede mejorar el control.',
          ),
          severity: SmartControlSeverity.info,
          actionLabel: _t(
            settings,
            en: 'View breakdown',
            da: 'Se opdeling',
            de: 'Aufschlüsselung ansehen',
            es: 'Ver desglose',
          ),
          impactLabel:
              '${formatCurrency(category.monthlySpend, settings.currency)}/month',
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    if (payments.any((item) => item.effectiveManagementUrl.isEmpty)) {
      insights.add(
        SmartControlInsight(
          id: 'missing-links',
          title: _t(
            settings,
            en: 'Action setup',
            da: 'Handling mangler',
            de: 'Aktionen einrichten',
            es: 'Configurar acciones',
          ),
          body:
              'Some recurring items are missing management links, which makes fast action harder when renewal time comes.',
          severity: SmartControlSeverity.info,
          actionLabel: _t(
            settings,
            en: 'Complete details',
            da: 'Udfyld detaljer',
            de: 'Details ergänzen',
            es: 'Completar datos',
          ),
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    final missingDocumentTargets = payments
        .where((item) {
          if (!(item.category == PaymentCategory.insurance ||
              item.category == PaymentCategory.rent ||
              item.category == PaymentCategory.loan)) {
            return false;
          }
          return !documents.any((doc) => doc.linkedItemId == item.id);
        })
        .take(3);

    for (final payment in missingDocumentTargets) {
      insights.add(
        SmartControlInsight(
          id: 'missing-document-${payment.id}',
          title: _t(
            settings,
            en: 'Keep key details accessible',
            da: 'Hold vigtige detaljer tilgængelige',
            de: 'Wichtige Details griffbereit halten',
            es: 'Mantén los detalles importantes accesibles',
          ),
          body: switch (payment.category) {
            PaymentCategory.insurance =>
              'Add your insurance policy so renewal details stay easy to review.',
            PaymentCategory.rent =>
              'Attach your lease agreement for faster reference when payment timing changes.',
            PaymentCategory.loan =>
              'Attach your loan agreement so key repayment details stay close at hand.',
            _ => 'Attach a related document for easier reference.',
          },
          severity: SmartControlSeverity.info,
          actionLabel: _t(
            settings,
            en: 'Attach document',
            da: 'Vedhæft dokument',
            de: 'Dokument anhängen',
            es: 'Adjuntar documento',
          ),
          relatedPaymentId: payment.id,
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    if (healthScore.delta < 0) {
      insights.add(
        SmartControlInsight(
          id: 'score-drop',
          title: _t(
            settings,
            en: 'Health score dropped',
            da: 'Helbredsscoren faldt',
            de: 'Gesundheitswert gesunken',
            es: 'La puntuación de salud bajó',
          ),
          body: _t(
            settings,
            en: 'Your Smart Control Score dropped by ${healthScore.delta.abs()} point${healthScore.delta.abs() == 1 ? '' : 's'}.',
            da: 'Din Smart Control-score faldt med ${healthScore.delta.abs()} point.',
            de: 'Dein Smart-Control-Wert ist um ${healthScore.delta.abs()} Punkte gesunken.',
            es: 'Tu puntuación de Smart Control bajó ${healthScore.delta.abs()} puntos.',
          ),
          severity: SmartControlSeverity.warning,
          actionLabel: _t(
            settings,
            en: 'Improve score',
            da: 'Forbedr score',
            de: 'Wert verbessern',
            es: 'Mejorar puntuación',
          ),
          premiumLocked: !hasPremiumAccess,
        ),
      );
    }

    insights.sort(
      (a, b) => _severityRank(b.severity).compareTo(_severityRank(a.severity)),
    );
    if (hasPremiumAccess) {
      return insights;
    }
    if (insights.isEmpty) {
      return const [];
    }
    return [
      insights.first.copyWith(premiumLocked: false),
      ...insights
          .skip(1)
          .take(3)
          .map((item) => item.copyWith(premiumLocked: true)),
    ];
  }

  double _projectedYearlySavings(
    FinancialIntelligenceSnapshot intelligence,
    List<PriceIncreaseSignal> priceIncreaseSignals,
  ) {
    final duplicateSavings = intelligence.duplicateGroups.fold<double>(
      0,
      (sum, item) => sum + item.yearlyImpact,
    );
    final dormantSavings = intelligence.dormantSubscriptions.fold<double>(
      0,
      (sum, item) => sum + item.yearlyCost,
    );
    final priceNegotiationPotential = priceIncreaseSignals.fold<double>(
      0,
      (sum, item) => sum + math.max(item.deltaAmount, 0) * 6,
    );
    return duplicateSavings + dormantSavings + priceNegotiationPotential;
  }

  int _severityRank(SmartControlSeverity severity) {
    return switch (severity) {
      SmartControlSeverity.urgent => 4,
      SmartControlSeverity.warning => 3,
      SmartControlSeverity.savings => 2,
      SmartControlSeverity.info => 1,
    };
  }

  double _burdenPenalty(double burden) {
    if (burden >= 50) return 28;
    if (burden >= 40) return 20;
    if (burden >= 30) return 14;
    if (burden >= 20) return 8;
    return 0;
  }

  double _essentialPenalty(double burden) {
    if (burden >= 50) return 16;
    if (burden >= 40) return 12;
    if (burden >= 30) return 8;
    return 0;
  }

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.isAfter(today);
  }
}

extension on SmartControlInsight {
  SmartControlInsight copyWith({
    String? id,
    String? title,
    String? body,
    SmartControlSeverity? severity,
    String? actionLabel,
    String? impactLabel,
    String? relatedPaymentId,
    bool? premiumLocked,
  }) {
    return SmartControlInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      severity: severity ?? this.severity,
      actionLabel: actionLabel ?? this.actionLabel,
      impactLabel: impactLabel ?? this.impactLabel,
      relatedPaymentId: relatedPaymentId ?? this.relatedPaymentId,
      premiumLocked: premiumLocked ?? this.premiumLocked,
    );
  }
}
