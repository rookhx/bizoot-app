import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../l10n/app_locale.dart';
import '../l10n/localized_text_sanitizer.dart';
import '../models/recurring_payment.dart';
import '../models/user_settings.dart';
import '../utils/payment_math.dart';

enum InsightSeverity { low, medium, high }

enum InsightPriority { low, medium, high, critical }

enum RiskLevel { low, medium, high }

enum SmartNotificationCategory { critical, savings, reminders, insights }

class CategorySpendBreakdown {
  final String id;
  final String label;
  final double monthlySpend;
  final double yearlyProjection;
  final int paymentCount;
  final String percentileMessage;

  const CategorySpendBreakdown({
    required this.id,
    required this.label,
    required this.monthlySpend,
    required this.yearlyProjection,
    required this.paymentCount,
    required this.percentileMessage,
  });
}

class SpendingTrendPoint {
  final String label;
  final double amount;
  final double changePercentage;
  final bool hasComparison;
  final bool hasTrackedData;

  const SpendingTrendPoint({
    required this.label,
    required this.amount,
    required this.changePercentage,
    required this.hasComparison,
    required this.hasTrackedData,
  });

  bool get isIncrease => hasComparison && changePercentage > 0.5;
  bool get isDecrease => hasComparison && changePercentage < -0.5;
  bool get isStable => hasComparison && !isIncrease && !isDecrease;
}

class DuplicateSubscriptionGroup {
  final String label;
  final List<RecurringPayment> payments;
  final double monthlyImpact;
  final double yearlyImpact;

  const DuplicateSubscriptionGroup({
    required this.label,
    required this.payments,
    required this.monthlyImpact,
    required this.yearlyImpact,
  });
}

class DormantSubscriptionSignal {
  final RecurringPayment payment;
  final int dormantDays;
  final double yearlyCost;

  const DormantSubscriptionSignal({
    required this.payment,
    required this.dormantDays,
    required this.yearlyCost,
  });
}

class PaymentClusterAnalysis {
  final String label;
  final DateTime anchorDate;
  final double totalAmount;
  final int paymentCount;
  final List<String> services;

  const PaymentClusterAnalysis({
    required this.label,
    required this.anchorDate,
    required this.totalAmount,
    required this.paymentCount,
    required this.services,
  });
}

class SubscriptionRiskReport {
  final RiskLevel level;
  final String label;
  final double recurringBurdenPercentage;
  final List<String> reasons;
  final int overlapCount;
  final int trialCount;

  const SubscriptionRiskReport({
    required this.level,
    required this.label,
    required this.recurringBurdenPercentage,
    required this.reasons,
    required this.overlapCount,
    required this.trialCount,
  });
}

class HealthScoreBreakdownItem {
  final String title;
  final int impact;
  final String description;

  const HealthScoreBreakdownItem({
    required this.title,
    required this.impact,
    required this.description,
  });
}

class HealthScoreSnapshot {
  final int score;
  final String label;
  final int delta;
  final String explanation;
  final List<HealthScoreBreakdownItem> breakdown;

  const HealthScoreSnapshot({
    required this.score,
    required this.label,
    required this.delta,
    required this.explanation,
    required this.breakdown,
  });
}

class PremiumInsightCardData {
  final String id;
  final String title;
  final String body;
  final String category;
  final String metricLabel;
  final bool isPremium;
  final InsightSeverity severity;
  final InsightPriority priority;

  const PremiumInsightCardData({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.metricLabel,
    required this.isPremium,
    required this.severity,
    required this.priority,
  });
}

class EngagementBadge {
  final String title;
  final String body;
  final String iconKey;

  const EngagementBadge({
    required this.title,
    required this.body,
    required this.iconKey,
  });
}

class EngagementSummary {
  final int streakDays;
  final int monthlySummariesUnlocked;
  final int optimizedSubscriptions;
  final List<EngagementBadge> badges;

  const EngagementSummary({
    required this.streakDays,
    required this.monthlySummariesUnlocked,
    required this.optimizedSubscriptions,
    required this.badges,
  });
}

class AdvancedReportSnapshot {
  final double monthlyRecurringSpend;
  final double yearlyProjection;
  final String topCategorySummary;
  final String optimizationSummary;
  final List<String> reportHighlights;

  const AdvancedReportSnapshot({
    required this.monthlyRecurringSpend,
    required this.yearlyProjection,
    required this.topCategorySummary,
    required this.optimizationSummary,
    required this.reportHighlights,
  });
}

class FutureAiOpportunity {
  final String title;
  final String description;

  const FutureAiOpportunity({required this.title, required this.description});
}

class SmartNotificationOpportunity {
  final String id;
  final SmartNotificationCategory category;
  final InsightPriority priority;
  final String title;
  final String body;

  const SmartNotificationOpportunity({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.body,
  });
}

class FinancialIntelligenceSnapshot {
  final double monthlyRecurringSpend;
  final double yearlyRecurringProjection;
  final double safeToSpend;
  final double recurringBurdenPercentage;
  final List<CategorySpendBreakdown> categoryBreakdown;
  final RecurringPayment? largestSubscription;
  final CategorySpendBreakdown? mostExpensiveCategory;
  final List<SpendingTrendPoint> monthlyTrend;
  final List<DuplicateSubscriptionGroup> duplicateGroups;
  final List<DormantSubscriptionSignal> dormantSubscriptions;
  final List<PaymentClusterAnalysis> paymentClusters;
  final SubscriptionRiskReport riskReport;
  final HealthScoreSnapshot healthScore;
  final List<PremiumInsightCardData> insights;
  final EngagementSummary engagement;
  final AdvancedReportSnapshot report;
  final List<FutureAiOpportunity> futureAiOpportunities;

  const FinancialIntelligenceSnapshot({
    required this.monthlyRecurringSpend,
    required this.yearlyRecurringProjection,
    required this.safeToSpend,
    required this.recurringBurdenPercentage,
    required this.categoryBreakdown,
    required this.largestSubscription,
    required this.mostExpensiveCategory,
    required this.monthlyTrend,
    required this.duplicateGroups,
    required this.dormantSubscriptions,
    required this.paymentClusters,
    required this.riskReport,
    required this.healthScore,
    required this.insights,
    required this.engagement,
    required this.report,
    required this.futureAiOpportunities,
  });
}

class FinancialIntelligenceService {
  const FinancialIntelligenceService();

  String _t(
    UserSettings settings, {
    required String en,
    required String da,
    required String de,
    required String es,
  }) {
    return sanitizeLocalizedText(switch (AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    )) {
      'da' => da,
      'de' => de,
      'es' => es,
      _ => en,
    });
  }

  FinancialIntelligenceSnapshot buildSnapshot(
    UserSettings settings,
    List<RecurringPayment> payments, {
    bool isPremiumUser = false,
  }) {
    final active = payments
        .where((item) => item.isActive)
        .toList(growable: false);
    final monthlyRecurringSpend = active.fold<double>(
      0,
      (sum, item) => sum + monthlyEquivalent(item),
    );
    final yearlyRecurringProjection = active.fold<double>(
      0,
      (sum, item) => sum + yearlyEquivalent(item),
    );
    final recurringBurdenPercentage = settings.monthlyIncome <= 0
        ? 0.0
        : (monthlyRecurringSpend / settings.monthlyIncome) * 100;
    final safeToSpend = settings.monthlyIncome - monthlyRecurringSpend;
    final categoryBreakdown = _buildCategoryBreakdown(active, settings);
    final largestSubscription = _maxBy(
      active,
      (item) => monthlyEquivalent(item),
    );
    final mostExpensiveCategory = categoryBreakdown.isEmpty
        ? null
        : categoryBreakdown.reduce(
            (best, next) => next.monthlySpend > best.monthlySpend ? next : best,
          );
    final monthlyTrend = _buildMonthlyTrend(payments, settings);
    final duplicateGroups = _findDuplicateGroups(active, settings);
    final dormantSubscriptions = _findDormantSubscriptions(active);
    final paymentClusters = _buildPaymentClusters(active, settings);
    final riskReport = _buildRiskReport(
      settings: settings,
      recurringBurdenPercentage: recurringBurdenPercentage,
      duplicates: duplicateGroups,
      activePayments: active,
      paymentClusters: paymentClusters,
    );
    final healthScore = _buildHealthScore(
      settings: settings,
      recurringBurdenPercentage: recurringBurdenPercentage,
      activePayments: active,
      monthlyTrend: monthlyTrend,
      duplicates: duplicateGroups,
      dormantSubscriptions: dormantSubscriptions,
      categoryBreakdown: categoryBreakdown,
      riskReport: riskReport,
    );
    final insights = _buildInsights(
      settings: settings,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
      duplicates: duplicateGroups,
      dormantSubscriptions: dormantSubscriptions,
      riskReport: riskReport,
      healthScore: healthScore,
      largestSubscription: largestSubscription,
      isPremiumUser: isPremiumUser,
    );
    final engagement = _buildEngagement(
      settings,
      active,
      duplicateGroups,
      dormantSubscriptions,
    );
    final report = _buildAdvancedReport(
      monthlyRecurringSpend: monthlyRecurringSpend,
      yearlyRecurringProjection: yearlyRecurringProjection,
      settings: settings,
      categoryBreakdown: categoryBreakdown,
      duplicates: duplicateGroups,
      riskReport: riskReport,
    );

    return FinancialIntelligenceSnapshot(
      monthlyRecurringSpend: monthlyRecurringSpend,
      yearlyRecurringProjection: yearlyRecurringProjection,
      safeToSpend: safeToSpend,
      recurringBurdenPercentage: recurringBurdenPercentage,
      categoryBreakdown: categoryBreakdown,
      largestSubscription: largestSubscription,
      mostExpensiveCategory: mostExpensiveCategory,
      monthlyTrend: monthlyTrend,
      duplicateGroups: duplicateGroups,
      dormantSubscriptions: dormantSubscriptions,
      paymentClusters: paymentClusters,
      riskReport: riskReport,
      healthScore: healthScore,
      insights: insights,
      engagement: engagement,
      report: report,
      futureAiOpportunities: _futureAiOpportunities(settings),
    );
  }

  List<SmartNotificationOpportunity> buildNotificationOpportunities(
    UserSettings settings,
    List<RecurringPayment> payments, {
    bool isPremiumUser = false,
  }) {
    final snapshot = buildSnapshot(
      settings,
      payments,
      isPremiumUser: isPremiumUser,
    );
    final upcoming = payments
        .where((item) {
          final diff = item.nextDueDate.difference(DateTime.now()).inHours;
          return item.isActive && diff >= 0 && diff <= 30;
        })
        .toList(growable: false);
    final opportunities = <SmartNotificationOpportunity>[];

    for (final payment in upcoming) {
      opportunities.add(
        SmartNotificationOpportunity(
          id: 'payment-${payment.id}',
          category: SmartNotificationCategory.reminders,
          priority: InsightPriority.high,
          title: _t(
            settings,
            en: 'Upcoming payment',
            da: 'Kommende betaling',
            de: 'Bevorstehende Zahlung',
            es: 'PrÃ³ximo pago',
          ),
          body: _t(
            settings,
            en: 'You will be charged ${payment.currency} ${payment.amount.toStringAsFixed(2)} for ${payment.name} soon.',
            da: 'Du bliver snart opkrÃ¦vet ${payment.currency} ${payment.amount.toStringAsFixed(2)} for ${payment.name}.',
            de: 'Du wirst bald ${payment.currency} ${payment.amount.toStringAsFixed(2)} fÃ¼r ${payment.name} zahlen.',
            es: 'Pronto se te cobrarÃ¡ ${payment.currency} ${payment.amount.toStringAsFixed(2)} por ${payment.name}.',
          ),
        ),
      );
    }

    if (!isPremiumUser) {
      return opportunities.take(4).toList(growable: false);
    }

    for (final trial in payments.where(
      (item) => item.isTrial && item.trialEndDate != null,
    )) {
      final days = trial.trialEndDate!.difference(DateTime.now()).inDays;
      if (days >= 1 && days <= 3) {
        opportunities.add(
          SmartNotificationOpportunity(
            id: 'trial-${trial.id}',
            category: SmartNotificationCategory.critical,
            priority: InsightPriority.critical,
            title: _t(
              settings,
              en: 'Trial ending soon',
              da: 'PrÃ¸veperiode slutter snart',
              de: 'Testphase endet bald',
              es: 'La prueba termina pronto',
            ),
            body: _t(
              settings,
              en: '${trial.name} may convert into ${trial.currency} ${(trial.convertsToPaidAmount ?? trial.amount).toStringAsFixed(2)} soon.',
              da: '${trial.name} kan snart blive til ${trial.currency} ${(trial.convertsToPaidAmount ?? trial.amount).toStringAsFixed(2)}.',
              de: '${trial.name} kÃ¶nnte bald in ${trial.currency} ${(trial.convertsToPaidAmount ?? trial.amount).toStringAsFixed(2)} umgewandelt werden.',
              es: '${trial.name} puede convertirse pronto en ${trial.currency} ${(trial.convertsToPaidAmount ?? trial.amount).toStringAsFixed(2)}.',
            ),
          ),
        );
      }
    }

    if (snapshot.recurringBurdenPercentage >= 22) {
      opportunities.add(
        SmartNotificationOpportunity(
          id: 'burden-warning',
          category: SmartNotificationCategory.critical,
          priority: InsightPriority.high,
          title: _t(
            settings,
            en: 'Recurring burden is climbing',
            da: 'Den tilbagevendende belastning stiger',
            de: 'Die laufende Belastung steigt',
            es: 'La carga recurrente estÃ¡ subiendo',
          ),
          body: _t(
            settings,
            en: 'Your recurring payments now exceed ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% of monthly income.',
            da: 'Dine tilbagevendende betalinger overstiger nu ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% af din mÃ¥nedlige indkomst.',
            de: 'Deine wiederkehrenden Zahlungen Ã¼bersteigen jetzt ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% deines Monatseinkommens.',
            es: 'Tus pagos recurrentes ya superan el ${snapshot.recurringBurdenPercentage.toStringAsFixed(1)}% de tus ingresos mensuales.',
          ),
        ),
      );
    }

    if (snapshot.duplicateGroups.isNotEmpty) {
      final group = snapshot.duplicateGroups.first;
      opportunities.add(
        SmartNotificationOpportunity(
          id: 'duplicate-${group.label}',
          category: SmartNotificationCategory.savings,
          priority: InsightPriority.medium,
          title: _t(
            settings,
            en: 'Duplicate services detected',
            da: 'Dublerede tjenester fundet',
            de: 'Doppelte Dienste erkannt',
            es: 'Servicios duplicados detectados',
          ),
          body: _t(
            settings,
            en: 'You have ${group.payments.length} overlapping ${group.label.toLowerCase()} subscriptions.',
            da: 'Du har ${group.payments.length} overlappende ${group.label.toLowerCase()} abonnementer.',
            de: 'Du hast ${group.payments.length} Ã¼berschneidende ${group.label.toLowerCase()}-Abos.',
            es: 'Tienes ${group.payments.length} suscripciones superpuestas de ${group.label.toLowerCase()}.',
          ),
        ),
      );
    }

    if (snapshot.dormantSubscriptions.isNotEmpty) {
      final dormant = snapshot.dormantSubscriptions.first;
      opportunities.add(
        SmartNotificationOpportunity(
          id: 'dormant-${dormant.payment.id}',
          category: SmartNotificationCategory.savings,
          priority: InsightPriority.medium,
          title: _t(
            settings,
            en: 'Inactive subscription reminder',
            da: 'PÃ¥mindelse om inaktivt abonnement',
            de: 'Erinnerung an inaktives Abo',
            es: 'Recordatorio de suscripciÃ³n inactiva',
          ),
          body: _t(
            settings,
            en: '${dormant.payment.name} looks dormant and still costs ${dormant.payment.currency} ${dormant.payment.amount.toStringAsFixed(2)}.',
            da: '${dormant.payment.name} virker inaktiv og koster stadig ${dormant.payment.currency} ${dormant.payment.amount.toStringAsFixed(2)}.',
            de: '${dormant.payment.name} wirkt inaktiv und kostet weiterhin ${dormant.payment.currency} ${dormant.payment.amount.toStringAsFixed(2)}.',
            es: '${dormant.payment.name} parece inactiva y aÃºn cuesta ${dormant.payment.currency} ${dormant.payment.amount.toStringAsFixed(2)}.',
          ),
        ),
      );
    }

    if (snapshot.monthlyTrend.length >= 2) {
      final latest = snapshot.monthlyTrend.last;
      if (latest.changePercentage >= 8) {
        opportunities.add(
          SmartNotificationOpportunity(
            id: 'growth-${latest.label}',
            category: SmartNotificationCategory.insights,
            priority: InsightPriority.medium,
            title: _t(
              settings,
              en: 'Recurring spending milestone',
              da: 'MilepÃ¦l for tilbagevendende forbrug',
              de: 'Meilenstein bei wiederkehrenden Ausgaben',
              es: 'Hito de gasto recurrente',
            ),
            body: _t(
              settings,
              en: 'Recurring costs rose ${latest.changePercentage.toStringAsFixed(0)}% this month.',
              da: 'Tilbagevendende udgifter steg ${latest.changePercentage.toStringAsFixed(0)}% denne mÃ¥ned.',
              de: 'Die wiederkehrenden Ausgaben sind diesen Monat um ${latest.changePercentage.toStringAsFixed(0)}% gestiegen.',
              es: 'Los costes recurrentes subieron un ${latest.changePercentage.toStringAsFixed(0)}% este mes.',
            ),
          ),
        );
      }
    }

    return opportunities;
  }

  List<CategorySpendBreakdown> _buildCategoryBreakdown(
    List<RecurringPayment> payments,
    UserSettings settings,
  ) {
    final grouped = <String, List<RecurringPayment>>{};
    for (final payment in payments) {
      final key = _categoryClusterKey(payment);
      grouped.putIfAbsent(key, () => <RecurringPayment>[]).add(payment);
    }

    final breakdown = grouped.entries
        .map((entry) {
          final monthly = entry.value.fold<double>(
            0,
            (sum, item) => sum + monthlyEquivalent(item),
          );
          return CategorySpendBreakdown(
            id: entry.key,
            label: _prettyCategory(entry.key, settings),
            monthlySpend: monthly,
            yearlyProjection: monthly * 12,
            paymentCount: entry.value.length,
            percentileMessage: _percentileHint(entry.key, monthly, settings),
          );
        })
        .toList(growable: false);

    breakdown.sort((a, b) => b.monthlySpend.compareTo(a.monthlySpend));
    return breakdown;
  }

  List<SpendingTrendPoint> _buildMonthlyTrend(
    List<RecurringPayment> payments,
    UserSettings settings,
  ) {
    final now = DateTime.now();
    final buckets = List<DateTime>.generate(
      4,
      (index) => DateTime(now.year, now.month - 3 + index, 1),
      growable: false,
    );
    if (payments.isEmpty) {
      return buckets
          .map(
            (bucket) => SpendingTrendPoint(
              label: _monthLabel(bucket.month, settings),
              amount: 0,
              changePercentage: 0,
              hasComparison: false,
              hasTrackedData: false,
            ),
          )
          .toList(growable: false);
    }

    final firstTrackedMonth = payments
        .map(
          (payment) =>
              DateTime(payment.createdAt.year, payment.createdAt.month, 1),
        )
        .reduce((earliest, next) => next.isBefore(earliest) ? next : earliest);
    final points = <SpendingTrendPoint>[];
    double? previousAmount;
    var previousHadTrackedData = false;

    for (final bucket in buckets) {
      final start = DateTime(bucket.year, bucket.month, 1);
      final end = DateTime(bucket.year, bucket.month + 1, 0, 23, 59, 59, 999);
      final hasTrackedData = !start.isBefore(firstTrackedMonth);
      final amount = hasTrackedData
          ? payments.fold<double>(
              0,
              (sum, item) => sum + _monthlyAmountForMonth(item, start, end),
            )
          : 0.0;
      final hasComparison =
          hasTrackedData && previousHadTrackedData && previousAmount != null;
      final previousForChange = previousAmount;
      final reliableComparison =
          hasComparison &&
          _isReliableTrendComparison(previousForChange!, amount);
      final change = reliableComparison
          ? _safePercentageChange(previousForChange, amount)
          : 0.0;
      points.add(
        SpendingTrendPoint(
          label: _monthLabel(bucket.month, settings),
          amount: amount,
          changePercentage: change,
          hasComparison: reliableComparison,
          hasTrackedData: hasTrackedData,
        ),
      );
      previousAmount = amount;
      previousHadTrackedData = hasTrackedData;
    }
    return points;
  }

  double _monthlyAmountForMonth(
    RecurringPayment payment,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    if (!_isActiveDuringMonth(payment, monthStart, monthEnd)) {
      return 0.0;
    }
    final amount = _amountAtDate(payment, monthEnd);
    return _monthlyEquivalentForAmount(amount, payment.frequency);
  }

  bool _isActiveDuringMonth(
    RecurringPayment payment,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    if (payment.createdAt.isAfter(monthEnd)) {
      return false;
    }

    final endedAt =
        payment.cancelledAt ??
        (payment.status == PaymentStatus.active ? null : payment.updatedAt);
    if (endedAt != null && endedAt.isBefore(monthStart)) {
      return false;
    }

    return true;
  }

  double _amountAtDate(RecurringPayment payment, DateTime date) {
    var amount = payment.amount;
    final history = [...payment.priceHistory]
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));
    for (final entry in history.reversed) {
      if (entry.changedAt.isAfter(date)) {
        amount = entry.oldAmount;
      } else {
        break;
      }
    }
    return amount;
  }

  double _monthlyEquivalentForAmount(
    double amount,
    PaymentFrequency frequency,
  ) {
    switch (frequency) {
      case PaymentFrequency.weekly:
        return amount * 4.33;
      case PaymentFrequency.monthly:
        return amount;
      case PaymentFrequency.quarterly:
        return amount / 3;
      case PaymentFrequency.yearly:
        return amount / 12;
    }
  }

  double _safePercentageChange(double previous, double current) {
    if (previous <= 0 && current <= 0) {
      return 0.0;
    }
    if (previous <= 0) {
      return 100.0;
    }
    final rawChange = ((current - previous) / previous) * 100;
    return rawChange.clamp(-250.0, 250.0);
  }

  bool _isReliableTrendComparison(double previous, double current) {
    if (previous <= 0) return false;
    final absoluteShift = (current - previous).abs();
    if (previous < 250 && absoluteShift > 500) {
      return false;
    }
    if (previous < (current * 0.15) && absoluteShift > 500) {
      return false;
    }
    return true;
  }

  List<DuplicateSubscriptionGroup> _findDuplicateGroups(
    List<RecurringPayment> payments,
    UserSettings settings,
  ) {
    final grouped = <String, List<RecurringPayment>>{};
    for (final payment in payments.where(
      (item) => item.category.isSubscriptionLike,
    )) {
      final key = _categoryClusterKey(payment);
      grouped.putIfAbsent(key, () => <RecurringPayment>[]).add(payment);
    }

    return grouped.entries
        .where((entry) => entry.value.length > 1)
        .map(
          (entry) => DuplicateSubscriptionGroup(
            label: _prettyCategory(entry.key, settings),
            payments: entry.value,
            monthlyImpact: entry.value.fold<double>(
              0,
              (sum, item) => sum + monthlyEquivalent(item),
            ),
            yearlyImpact: entry.value.fold<double>(
              0,
              (sum, item) => sum + yearlyEquivalent(item),
            ),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.yearlyImpact.compareTo(a.yearlyImpact));
  }

  List<DormantSubscriptionSignal> _findDormantSubscriptions(
    List<RecurringPayment> payments,
  ) {
    final now = DateTime.now();
    final dormant = <DormantSubscriptionSignal>[];
    for (final payment in payments) {
      final dormantDays = now.difference(payment.updatedAt).inDays;
      final yearly = yearlyEquivalent(payment);
      if ((payment.status == PaymentStatus.inactive ||
              payment.cancellationStatus == CancellationStatus.considering ||
              dormantDays >= 45) &&
          yearly >= 60) {
        dormant.add(
          DormantSubscriptionSignal(
            payment: payment,
            dormantDays: dormantDays,
            yearlyCost: yearly,
          ),
        );
      }
    }
    dormant.sort((a, b) => b.yearlyCost.compareTo(a.yearlyCost));
    return dormant;
  }

  List<PaymentClusterAnalysis> _buildPaymentClusters(
    List<RecurringPayment> payments,
    UserSettings settings,
  ) {
    final upcoming = [...payments]
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final clusters = <PaymentClusterAnalysis>[];
    for (final payment in upcoming) {
      final monthKey = DateTime(
        payment.nextDueDate.year,
        payment.nextDueDate.month,
        payment.nextDueDate.day,
      );
      final existingIndex = clusters.indexWhere(
        (cluster) => cluster.anchorDate.difference(monthKey).inDays.abs() <= 2,
      );
      if (existingIndex == -1) {
        clusters.add(
          PaymentClusterAnalysis(
            label: '${_monthLabel(monthKey.month, settings)} ${monthKey.day}',
            anchorDate: monthKey,
            totalAmount: payment.amount,
            paymentCount: 1,
            services: [payment.name],
          ),
        );
      } else {
        final cluster = clusters[existingIndex];
        clusters[existingIndex] = PaymentClusterAnalysis(
          label: cluster.label,
          anchorDate: cluster.anchorDate,
          totalAmount: cluster.totalAmount + payment.amount,
          paymentCount: cluster.paymentCount + 1,
          services: [...cluster.services, payment.name],
        );
      }
    }
    clusters.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return clusters.take(4).toList(growable: false);
  }

  SubscriptionRiskReport _buildRiskReport({
    required UserSettings settings,
    required double recurringBurdenPercentage,
    required List<DuplicateSubscriptionGroup> duplicates,
    required List<RecurringPayment> activePayments,
    required List<PaymentClusterAnalysis> paymentClusters,
  }) {
    final reasons = <String>[];
    final aiOverlap = activePayments
        .where((item) => _categoryClusterKey(item) == 'ai_tools')
        .length;
    final streamingOverlap = activePayments
        .where((item) => _categoryClusterKey(item) == 'streaming')
        .length;
    final trials = activePayments.where((item) => item.isTrial).length;
    if (recurringBurdenPercentage >= 25) {
      reasons.add(
        _t(
          settings,
          en: 'Recurring burden is above 25% of income.',
          da: 'Den tilbagevendende belastning er over 25% af indkomsten.',
          de: 'Die laufende Belastung liegt Ã¼ber 25% des Einkommens.',
          es: 'La carga recurrente supera el 25% de los ingresos.',
        ),
      );
    }
    if (duplicates.isNotEmpty) {
      reasons.add(
        _t(
          settings,
          en: 'Overlapping subscriptions are active in the same category.',
          da: 'Overlappende abonnementer er aktive i samme kategori.',
          de: 'Ãœberlappende Abonnements sind in derselben Kategorie aktiv.',
          es: 'Hay suscripciones superpuestas activas en la misma categorÃ­a.',
        ),
      );
    }
    if (streamingOverlap >= 4) {
      reasons.add(
        _t(
          settings,
          en: 'Streaming overlap is unusually high.',
          da: 'Overlappet i streaming er usÃ¦dvanligt hÃ¸jt.',
          de: 'Die Ãœberschneidung bei Streaming ist ungewÃ¶hnlich hoch.',
          es: 'La superposiciÃ³n de streaming es inusualmente alta.',
        ),
      );
    }
    if (aiOverlap >= 3) {
      reasons.add(
        _t(
          settings,
          en: 'AI tool overlap may be overspending.',
          da: 'Overlap i AI-vÃ¦rktÃ¸jer kan betyde overforbrug.',
          de: 'Ãœberschneidungen bei KI-Tools kÃ¶nnten zu hohen Ausgaben fÃ¼hren.',
          es: 'La superposiciÃ³n de herramientas de IA puede estar generando gasto excesivo.',
        ),
      );
    }
    if (trials >= 3) {
      reasons.add(
        _t(
          settings,
          en: 'Multiple trials are active at the same time.',
          da: 'Flere prÃ¸veperioder er aktive samtidig.',
          de: 'Mehrere Testphasen sind gleichzeitig aktiv.',
          es: 'Hay varias pruebas activas al mismo tiempo.',
        ),
      );
    }
    if (paymentClusters.isNotEmpty &&
        paymentClusters.first.totalAmount >= 250) {
      reasons.add(
        _t(
          settings,
          en: 'Too many charges are concentrated in a narrow payment window.',
          da: 'For mange betalinger ligger samlet i et snÃ¦vert betalingsvindue.',
          de: 'Zu viele Abbuchungen liegen in einem engen Zahlungsfenster.',
          es: 'Demasiados cargos se concentran en una ventana de pago muy estrecha.',
        ),
      );
    }

    RiskLevel level;
    if (recurringBurdenPercentage >= 25 || reasons.length >= 4) {
      level = RiskLevel.high;
    } else if (recurringBurdenPercentage >= 15 || reasons.length >= 2) {
      level = RiskLevel.medium;
    } else {
      level = RiskLevel.low;
    }

    return SubscriptionRiskReport(
      level: level,
      label: switch (level) {
        RiskLevel.low => _t(
          settings,
          en: 'Low risk',
          da: 'Lav risiko',
          de: 'Niedriges Risiko',
          es: 'Riesgo bajo',
        ),
        RiskLevel.medium => _t(
          settings,
          en: 'Medium risk',
          da: 'Mellem risiko',
          de: 'Mittleres Risiko',
          es: 'Riesgo medio',
        ),
        RiskLevel.high => _t(
          settings,
          en: 'High risk',
          da: 'HÃ¸j risiko',
          de: 'Hohes Risiko',
          es: 'Riesgo alto',
        ),
      },
      recurringBurdenPercentage: recurringBurdenPercentage,
      reasons: reasons,
      overlapCount: duplicates.fold<int>(
        0,
        (sum, item) => sum + item.payments.length,
      ),
      trialCount: trials,
    );
  }

  HealthScoreSnapshot _buildHealthScore({
    required UserSettings settings,
    required double recurringBurdenPercentage,
    required List<RecurringPayment> activePayments,
    required List<SpendingTrendPoint> monthlyTrend,
    required List<DuplicateSubscriptionGroup> duplicates,
    required List<DormantSubscriptionSignal> dormantSubscriptions,
    required List<CategorySpendBreakdown> categoryBreakdown,
    required SubscriptionRiskReport riskReport,
  }) {
    var score = 100;
    final breakdown = <HealthScoreBreakdownItem>[];

    if (recurringBurdenPercentage >= 25) {
      score -= 22;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'High recurring burden',
            da: 'HÃ¸j tilbagevendende belastning',
            de: 'Hohe laufende Belastung',
            es: 'Alta carga recurrente',
          ),
          impact: -22,
          description: _t(
            settings,
            en: 'Too much of your monthly income is already committed.',
            da: 'For meget af din mÃ¥nedlige indkomst er allerede bundet.',
            de: 'Zu viel deines Monatseinkommens ist bereits gebunden.',
            es: 'Demasiada parte de tus ingresos mensuales ya estÃ¡ comprometida.',
          ),
        ),
      );
    } else if (recurringBurdenPercentage >= 15) {
      score -= 12;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Moderate recurring burden',
            da: 'Moderat tilbagevendende belastning',
            de: 'MÃ¤ÃŸige laufende Belastung',
            es: 'Carga recurrente moderada',
          ),
          impact: -12,
          description: _t(
            settings,
            en: 'Recurring payments are starting to crowd your budget.',
            da: 'Tilbagevendende betalinger begynder at presse dit budget.',
            de: 'Wiederkehrende Zahlungen beginnen, dein Budget zu belasten.',
            es: 'Los pagos recurrentes estÃ¡n empezando a presionar tu presupuesto.',
          ),
        ),
      );
    }

    if (duplicates.isNotEmpty) {
      final impact = math.min(18, duplicates.length * 6);
      score -= impact;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Duplicate services',
            da: 'Dublerede tjenester',
            de: 'Doppelte Dienste',
            es: 'Servicios duplicados',
          ),
          impact: -impact,
          description: _t(
            settings,
            en: 'You are paying for overlapping categories at the same time.',
            da: 'Du betaler for overlappende kategorier paa samme tid.',
            de: 'Du zahlst gleichzeitig fuer sich ueberschneidende Kategorien.',
            es: 'Estas pagando por categorias superpuestas al mismo tiempo.',
          ),
        ),
      );
    }

    if (dormantSubscriptions.isNotEmpty) {
      final impact = math.min(16, dormantSubscriptions.length * 4);
      score -= impact;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Dormant subscriptions',
            da: 'Inaktive abonnementer',
            de: 'Inaktive Abos',
            es: 'Suscripciones inactivas',
          ),
          impact: -impact,
          description: _t(
            settings,
            en: 'Subscriptions may be active without enough value coming back.',
            da: 'Abonnementer kan vaere aktive uden at give nok vaerdi tilbage.',
            de: 'Abos koennen aktiv sein, ohne ausreichend Wert zurueckzugeben.',
            es: 'Las suscripciones pueden seguir activas sin aportar suficiente valor.',
          ),
        ),
      );
    }

    final growth = monthlyTrend.isNotEmpty
        ? monthlyTrend.last.changePercentage
        : 0;
    if (growth >= 12) {
      score -= 12;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Spending growth',
            da: 'Stigende udgifter',
            de: 'Ausgabenanstieg',
            es: 'Aumento del gasto',
          ),
          impact: -12,
          description: _t(
            settings,
            en: 'Recurring spending rose sharply in the latest trend window.',
            da: 'De tilbagevendende udgifter steg markant i det seneste trendvindue.',
            de: 'Die wiederkehrenden Ausgaben sind im letzten Trendfenster deutlich gestiegen.',
            es: 'El gasto recurrente subio con fuerza en la ultima ventana de tendencia.',
          ),
        ),
      );
    } else if (growth <= -5) {
      score += 4;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Spending discipline',
            da: 'Udgiftsdisciplin',
            de: 'Ausgabendisziplin',
            es: 'Disciplina del gasto',
          ),
          impact: 4,
          description: _t(
            settings,
            en: 'Recurring spending eased recently.',
            da: 'De tilbagevendende udgifter er faldet for nylig.',
            de: 'Die wiederkehrenden Ausgaben haben sich zuletzt entspannt.',
            es: 'El gasto recurrente se ha moderado recientemente.',
          ),
        ),
      );
    }

    final topCategory = categoryBreakdown.isEmpty
        ? null
        : categoryBreakdown.first;
    if (topCategory != null && topCategory.monthlySpend >= 120) {
      score -= 8;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Category overload',
            da: 'Kategori-overbelastning',
            de: 'Kategorie ueberlastet',
            es: 'Sobrecarga de categoria',
          ),
          impact: -8,
          description: _t(
            settings,
            en: '${topCategory.label} is taking a large share of your recurring budget.',
            da: '${topCategory.label} fylder en stor del af dit tilbagevendende budget.',
            de: '${topCategory.label} beansprucht einen grossen Teil deines wiederkehrenden Budgets.',
            es: '${topCategory.label} ocupa una gran parte de tu presupuesto recurrente.',
          ),
        ),
      );
    }

    final activeTrials = activePayments.where((item) => item.isTrial).length;
    if (activeTrials >= 2) {
      final impact = math.min(10, activeTrials * 4);
      score -= impact;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Trial risk',
            da: 'Proeverisiko',
            de: 'Testrisiko',
            es: 'Riesgo de prueba',
          ),
          impact: -impact,
          description: _t(
            settings,
            en: 'Multiple trials may convert into paid charges soon.',
            da: 'Flere proeveperioder kan snart blive til betalte opkraevninger.',
            de: 'Mehrere Testphasen koennten sich bald in kostenpflichtige Abbuchungen verwandeln.',
            es: 'Varias pruebas pueden convertirse pronto en cargos de pago.',
          ),
        ),
      );
    }

    if (riskReport.level == RiskLevel.low) {
      score += 4;
      breakdown.add(
        HealthScoreBreakdownItem(
          title: _t(
            settings,
            en: 'Stable payment mix',
            da: 'Stabil betalingsprofil',
            de: 'Stabiler Zahlungsmix',
            es: 'Mezcla de pagos estable',
          ),
          impact: 4,
          description: _t(
            settings,
            en: 'Your recurring profile looks relatively stable right now.',
            da: 'Din tilbagevendende profil ser forholdsvis stabil ud lige nu.',
            de: 'Dein wiederkehrendes Profil wirkt derzeit relativ stabil.',
            es: 'Tu perfil recurrente parece relativamente estable en este momento.',
          ),
        ),
      );
    }

    score = score.clamp(0, 100);
    final explanation = breakdown.isEmpty
        ? _t(
            settings,
            en: 'Your recurring setup looks stable.',
            da: 'Dine tilbagevendende udgifter ser stabile ud.',
            de: 'Deine laufenden Ausgaben wirken stabil.',
            es: 'Tu configuraciÃ³n recurrente parece estable.',
          )
        : _t(
            settings,
            en: '${breakdown.first.title} is the biggest driver of your current score.',
            da: '${breakdown.first.title} er den stÃ¸rste Ã¥rsag til din nuvÃ¦rende score.',
            de: '${breakdown.first.title} ist der grÃ¶ÃŸte Treiber deines aktuellen Werts.',
            es: '${breakdown.first.title} es el principal factor de tu puntuaciÃ³n actual.',
          );

    return HealthScoreSnapshot(
      score: score,
      label: score >= 85
          ? _t(
              settings,
              en: 'Excellent',
              da: 'Fremragende',
              de: 'Ausgezeichnet',
              es: 'Excelente',
            )
          : score >= 70
          ? _t(
              settings,
              en: 'Healthy',
              da: 'Sund',
              de: 'Gesund',
              es: 'Saludable',
            )
          : score >= 55
          ? _t(
              settings,
              en: 'Watchlist',
              da: 'Hold Ã¸je',
              de: 'Beobachten',
              es: 'En observaciÃ³n',
            )
          : score >= 40
          ? _t(
              settings,
              en: 'Risky',
              da: 'Risikabel',
              de: 'Riskant',
              es: 'Riesgoso',
            )
          : _t(
              settings,
              en: 'Critical',
              da: 'Kritisk',
              de: 'Kritisch',
              es: 'CrÃ­tico',
            ),
      delta: 0,
      explanation: explanation,
      breakdown: breakdown,
    );
  }

  List<PremiumInsightCardData> _buildInsights({
    required UserSettings settings,
    required List<CategorySpendBreakdown> categoryBreakdown,
    required List<SpendingTrendPoint> monthlyTrend,
    required List<DuplicateSubscriptionGroup> duplicates,
    required List<DormantSubscriptionSignal> dormantSubscriptions,
    required SubscriptionRiskReport riskReport,
    required HealthScoreSnapshot healthScore,
    required RecurringPayment? largestSubscription,
    required bool isPremiumUser,
  }) {
    final insights = <PremiumInsightCardData>[];
    final topCategory = categoryBreakdown.isEmpty
        ? null
        : categoryBreakdown.first;

    if (topCategory != null) {
      insights.add(
        PremiumInsightCardData(
          id: 'category-${topCategory.id}',
          title: _t(
            settings,
            en: '${topCategory.label} projection',
            da: '${topCategory.label}-prognose',
            de: '${topCategory.label}-Prognose',
            es: 'ProyecciÃ³n de ${topCategory.label}',
          ),
          body: _t(
            settings,
            en: 'You are projected to spend ${topCategory.yearlyProjection.toStringAsFixed(0)} per year on ${topCategory.label.toLowerCase()}.',
            da: 'Du forventes at bruge ${topCategory.yearlyProjection.toStringAsFixed(0)} om aaret paa ${topCategory.label.toLowerCase()}.',
            de: 'Du wirst voraussichtlich ${topCategory.yearlyProjection.toStringAsFixed(0)} pro Jahr fuer ${topCategory.label.toLowerCase()} ausgeben.',
            es: 'Se preve que gastes ${topCategory.yearlyProjection.toStringAsFixed(0)} al ano en ${topCategory.label.toLowerCase()}.',
          ),
          category: _t(
            settings,
            en: 'trends',
            da: 'trends',
            de: 'trends',
            es: 'tendencias',
          ),
          metricLabel: _t(
            settings,
            en: '${topCategory.paymentCount} active',
            da: '${topCategory.paymentCount} aktive',
            de: '${topCategory.paymentCount} aktiv',
            es: '${topCategory.paymentCount} activas',
          ),
          isPremium: true,
          severity: InsightSeverity.medium,
          priority: InsightPriority.medium,
        ),
      );
    }

    if (duplicates.isNotEmpty) {
      final group = duplicates.first;
      insights.add(
        PremiumInsightCardData(
          id: 'duplicate-${group.label}',
          title: _t(
            settings,
            en: 'Overlap detected',
            da: 'Overlap registreret',
            de: 'Ueberschneidung erkannt',
            es: 'Solapamiento detectado',
          ),
          body: _t(
            settings,
            en: 'Cancelling one ${group.label.toLowerCase()} subscription could save ${group.yearlyImpact.toStringAsFixed(0)}/year.',
            da: 'Hvis du opsiger et ${group.label.toLowerCase()}-abonnement, kan du spare ${group.yearlyImpact.toStringAsFixed(0)}/aar.',
            de: 'Wenn du ein ${group.label.toLowerCase()}-Abo kuendigst, koenntest du ${group.yearlyImpact.toStringAsFixed(0)}/Jahr sparen.',
            es: 'Cancelar una suscripcion de ${group.label.toLowerCase()} podria ahorrarte ${group.yearlyImpact.toStringAsFixed(0)}/ano.',
          ),
          category: _t(
            settings,
            en: 'duplicate services',
            da: 'dublerede tjenester',
            de: 'doppelte Dienste',
            es: 'servicios duplicados',
          ),
          metricLabel: _t(
            settings,
            en: '${group.payments.length} overlapping',
            da: '${group.payments.length} overlapper',
            de: '${group.payments.length} ueberlappen',
            es: '${group.payments.length} superpuestas',
          ),
          isPremium: true,
          severity: InsightSeverity.high,
          priority: InsightPriority.high,
        ),
      );
    }

    if (dormantSubscriptions.isNotEmpty) {
      final dormant = dormantSubscriptions.first;
      insights.add(
        PremiumInsightCardData(
          id: 'dormant-${dormant.payment.id}',
          title: _t(
            settings,
            en: 'Dormant subscription',
            da: 'Inaktivt abonnement',
            de: 'Inaktives Abo',
            es: 'Suscripcion inactiva',
          ),
          body: _t(
            settings,
            en: '${dormant.payment.name} has been quiet for ${dormant.dormantDays} days and still costs ${dormant.yearlyCost.toStringAsFixed(0)}/year.',
            da: '${dormant.payment.name} har vaeret stille i ${dormant.dormantDays} dage og koster stadig ${dormant.yearlyCost.toStringAsFixed(0)}/aar.',
            de: '${dormant.payment.name} war ${dormant.dormantDays} Tage ruhig und kostet weiterhin ${dormant.yearlyCost.toStringAsFixed(0)}/Jahr.',
            es: '${dormant.payment.name} lleva ${dormant.dormantDays} dias inactiva y todavia cuesta ${dormant.yearlyCost.toStringAsFixed(0)}/ano.',
          ),
          category: _t(
            settings,
            en: 'savings',
            da: 'besparelser',
            de: 'ersparnisse',
            es: 'ahorros',
          ),
          metricLabel: _t(
            settings,
            en: '${dormant.dormantDays} days',
            da: '${dormant.dormantDays} dage',
            de: '${dormant.dormantDays} Tage',
            es: '${dormant.dormantDays} dias',
          ),
          isPremium: true,
          severity: InsightSeverity.high,
          priority: InsightPriority.high,
        ),
      );
    }

    if (monthlyTrend.length >= 2) {
      final latest = monthlyTrend.last;
      insights.add(
        PremiumInsightCardData(
          id: 'trend-${latest.label}',
          title: _t(
            settings,
            en: 'Monthly trend',
            da: 'Maanedlig trend',
            de: 'Monatstrend',
            es: 'Tendencia mensual',
          ),
          body: _t(
            settings,
            en: 'Your recurring payments changed ${latest.changePercentage.toStringAsFixed(0)}% in ${latest.label}.',
            da: 'Dine tilbagevendende betalinger aendrede sig ${latest.changePercentage.toStringAsFixed(0)}% i ${latest.label}.',
            de: 'Deine wiederkehrenden Zahlungen haben sich im ${latest.label} um ${latest.changePercentage.toStringAsFixed(0)}% veraendert.',
            es: 'Tus pagos recurrentes cambiaron ${latest.changePercentage.toStringAsFixed(0)}% en ${latest.label}.',
          ),
          category: _t(
            settings,
            en: 'trends',
            da: 'trends',
            de: 'trends',
            es: 'tendencias',
          ),
          metricLabel: latest.label,
          isPremium: true,
          severity: latest.changePercentage >= 8
              ? InsightSeverity.high
              : InsightSeverity.low,
          priority: latest.changePercentage >= 8
              ? InsightPriority.medium
              : InsightPriority.low,
        ),
      );
    }

    if (largestSubscription != null) {
      insights.add(
        PremiumInsightCardData(
          id: 'largest-${largestSubscription.id}',
          title: _t(
            settings,
            en: 'Largest subscription',
            da: 'Stoerste abonnement',
            de: 'Groesstes Abo',
            es: 'Suscripcion mas grande',
          ),
          body: _t(
            settings,
            en: '${largestSubscription.name} is your biggest single recurring line item right now.',
            da: '${largestSubscription.name} er din stoerste enkeltpost blandt tilbagevendende udgifter lige nu.',
            de: '${largestSubscription.name} ist derzeit dein groesster einzelner wiederkehrender Posten.',
            es: '${largestSubscription.name} es en este momento tu mayor gasto recurrente individual.',
          ),
          category: _t(
            settings,
            en: 'optimization',
            da: 'optimering',
            de: 'optimierung',
            es: 'optimizacion',
          ),
          metricLabel:
              '${largestSubscription.currency} ${largestSubscription.amount.toStringAsFixed(2)}',
          isPremium: false,
          severity: InsightSeverity.low,
          priority: InsightPriority.low,
        ),
      );
    }

    if (riskReport.level != RiskLevel.low) {
      insights.add(
        PremiumInsightCardData(
          id: 'risk-${riskReport.level.name}',
          title: _t(
            settings,
            en: 'Recurring burden warning',
            da: 'Advarsel om tilbagevendende belastning',
            de: 'Warnung zur laufenden Belastung',
            es: 'Advertencia de carga recurrente',
          ),
          body: _t(
            settings,
            en: 'Your recurring payments now exceed ${riskReport.recurringBurdenPercentage.toStringAsFixed(1)}% of monthly income.',
            da: 'Dine tilbagevendende betalinger overstiger nu ${riskReport.recurringBurdenPercentage.toStringAsFixed(1)}% af din maanedlige indkomst.',
            de: 'Deine wiederkehrenden Zahlungen uebersteigen jetzt ${riskReport.recurringBurdenPercentage.toStringAsFixed(1)}% deines Monatseinkommens.',
            es: 'Tus pagos recurrentes ya superan el ${riskReport.recurringBurdenPercentage.toStringAsFixed(1)}% de tus ingresos mensuales.',
          ),
          category: _t(
            settings,
            en: 'warnings',
            da: 'advarsler',
            de: 'warnungen',
            es: 'alertas',
          ),
          metricLabel:
              '${riskReport.recurringBurdenPercentage.toStringAsFixed(1)}%',
          isPremium: true,
          severity: InsightSeverity.high,
          priority: InsightPriority.critical,
        ),
      );
    }

    if (healthScore.delta < 0) {
      insights.add(
        PremiumInsightCardData(
          id: 'health-drop',
          title: _t(
            settings,
            en: 'Health Score changed',
            da: 'Sundhedsscoren har aendret sig',
            de: 'Gesundheitswert geaendert',
            es: 'La puntuacion de salud cambio',
          ),
          body: _t(
            settings,
            en: 'Your Health Score softened because recurring spending and overlap risk increased.',
            da: 'Din sundhedsscore faldt, fordi tilbagevendende udgifter og overlapningsrisiko steg.',
            de: 'Dein Gesundheitswert ist gesunken, weil die wiederkehrenden Ausgaben und das Ueberschneidungsrisiko gestiegen sind.',
            es: 'Tu puntuacion de salud bajo porque aumentaron el gasto recurrente y el riesgo de solapamiento.',
          ),
          category: _t(
            settings,
            en: 'health',
            da: 'sundhed',
            de: 'gesundheit',
            es: 'salud',
          ),
          metricLabel: '${healthScore.score}',
          isPremium: true,
          severity: InsightSeverity.medium,
          priority: InsightPriority.medium,
        ),
      );
    }

    insights.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return insights
        .map(
          (item) => item.isPremium && !isPremiumUser
              ? PremiumInsightCardData(
                  id: item.id,
                  title: item.title,
                  body: item.body,
                  category: item.category,
                  metricLabel: item.metricLabel,
                  isPremium: true,
                  severity: item.severity,
                  priority: item.priority,
                )
              : item,
        )
        .toList(growable: false);
  }

  EngagementSummary _buildEngagement(
    UserSettings settings,
    List<RecurringPayment> activePayments,
    List<DuplicateSubscriptionGroup> duplicates,
    List<DormantSubscriptionSignal> dormantSubscriptions,
  ) {
    final streakDays = math.max(3, 30 - duplicates.length * 2);
    final optimized = dormantSubscriptions
        .where(
          (item) =>
              item.payment.cancellationStatus == CancellationStatus.considering,
        )
        .length;
    return EngagementSummary(
      streakDays: streakDays,
      monthlySummariesUnlocked: math.max(1, activePayments.length ~/ 2),
      optimizedSubscriptions: optimized,
      badges: [
        EngagementBadge(
          title: '$streakDays-day clarity streak',
          body: _t(
            settings,
            en: 'You have kept your recurring picture updated for $streakDays straight days.',
            da: 'Du har holdt dit overblik over tilbagevendende udgifter opdateret i $streakDays dage i trÃ¦k.',
            de: 'Du hast deinen Ãœberblick Ã¼ber wiederkehrende Ausgaben $streakDays Tage in Folge aktuell gehalten.',
            es: 'Has mantenido actualizada tu visiÃ³n de gastos recurrentes durante $streakDays dÃ­as seguidos.',
          ),
          iconKey: 'bolt',
        ),
        EngagementBadge(
          title: '${math.max(1, duplicates.length)} savings signals',
          body: _t(
            settings,
            en: 'Bizoot found areas where small changes could create meaningful savings.',
            da: 'Bizoot har fundet omrÃ¥der, hvor smÃ¥ Ã¦ndringer kan skabe meningsfulde besparelser.',
            de: 'Bizoot hat Bereiche gefunden, in denen kleine Ã„nderungen spÃ¼rbare Einsparungen bringen kÃ¶nnen.',
            es: 'Bizoot encontrÃ³ Ã¡reas donde pequeÃ±os cambios pueden generar ahorros importantes.',
          ),
          iconKey: 'savings',
        ),
      ],
    );
  }

  AdvancedReportSnapshot _buildAdvancedReport({
    required UserSettings settings,
    required double monthlyRecurringSpend,
    required double yearlyRecurringProjection,
    required List<CategorySpendBreakdown> categoryBreakdown,
    required List<DuplicateSubscriptionGroup> duplicates,
    required SubscriptionRiskReport riskReport,
  }) {
    final topCategory = categoryBreakdown.isEmpty
        ? _t(
            settings,
            en: 'No dominant category yet.',
            da: 'Ingen dominerende kategori endnu.',
            de: 'Noch keine dominante Kategorie.',
            es: 'AÃºn no hay una categorÃ­a dominante.',
          )
        : _t(
            settings,
            en: '${categoryBreakdown.first.label} leads your recurring mix.',
            da: '${categoryBreakdown.first.label} fylder mest i dine tilbagevendende udgifter.',
            de: '${categoryBreakdown.first.label} dominiert deine wiederkehrenden Ausgaben.',
            es: '${categoryBreakdown.first.label} lidera tu mezcla de gastos recurrentes.',
          );
    final optimizationSummary = duplicates.isEmpty
        ? _t(
            settings,
            en: 'No major overlap issues detected right now.',
            da: 'Ingen stÃ¸rre overlap-problemer registreret lige nu.',
            de: 'Derzeit wurden keine grÃ¶ÃŸeren Ãœberschneidungen erkannt.',
            es: 'Ahora mismo no se detectan grandes problemas de solapamiento.',
          )
        : _t(
            settings,
            en: 'You have ${duplicates.length} optimization opportunities across overlapping services.',
            da: 'Du har ${duplicates.length} optimeringsmuligheder pÃ¥ tvÃ¦rs af overlappende tjenester.',
            de: 'Du hast ${duplicates.length} OptimierungsmÃ¶glichkeiten bei Ã¼berschneidenden Diensten.',
            es: 'Tienes ${duplicates.length} oportunidades de optimizaciÃ³n entre servicios solapados.',
          );

    return AdvancedReportSnapshot(
      monthlyRecurringSpend: monthlyRecurringSpend,
      yearlyProjection: yearlyRecurringProjection,
      topCategorySummary: topCategory,
      optimizationSummary: optimizationSummary,
      reportHighlights: [
        _t(
          settings,
          en: 'Recurring spend is projected at ${yearlyRecurringProjection.toStringAsFixed(0)} per year.',
          da: 'De tilbagevendende udgifter forventes at blive ${yearlyRecurringProjection.toStringAsFixed(0)} om Ã¥ret.',
          de: 'Die wiederkehrenden Ausgaben werden auf ${yearlyRecurringProjection.toStringAsFixed(0)} pro Jahr geschÃ¤tzt.',
          es: 'Se proyecta que el gasto recurrente sea de ${yearlyRecurringProjection.toStringAsFixed(0)} al aÃ±o.',
        ),
        _t(
          settings,
          en: 'Risk level is currently ${riskReport.label.toLowerCase()}.',
          da: 'Risikoniveauet er i Ã¸jeblikket ${riskReport.label.toLowerCase()}.',
          de: 'Das Risikoniveau ist derzeit ${riskReport.label.toLowerCase()}.',
          es: 'El nivel de riesgo actualmente es ${riskReport.label.toLowerCase()}.',
        ),
        if (categoryBreakdown.isNotEmpty)
          categoryBreakdown.first.percentileMessage,
      ],
    );
  }

  List<FutureAiOpportunity> _futureAiOpportunities(UserSettings settings) {
    return [
      FutureAiOpportunity(
        title: _t(
          settings,
          en: 'Recommendation engine',
          da: 'Anbefalingsmotor',
          de: 'Empfehlungs-Engine',
          es: 'Motor de recomendaciones',
        ),
        description: _t(
          settings,
          en: 'Rank the best cancellation, downgrade, or bundling moves for each user.',
          da: 'RangÃ©r de bedste opsigelses-, nedgraderings- eller bundlingsmuligheder for hver bruger.',
          de: 'Ordne die besten KÃ¼ndigungs-, Downgrade- oder BÃ¼ndelungsoptionen fÃ¼r jeden Nutzer.',
          es: 'Clasifica las mejores opciones de cancelaciÃ³n, degradaciÃ³n o agrupaciÃ³n para cada usuario.',
        ),
      ),
      FutureAiOpportunity(
        title: _t(
          settings,
          en: 'Predictive insights',
          da: 'Forudsigende indsigter',
          de: 'PrÃ¤diktive Einblicke',
          es: 'Insights predictivos',
        ),
        description: _t(
          settings,
          en: 'Forecast renewal pressure and likely overspend moments before they happen.',
          da: 'Forudsig fornyelsespres og sandsynlige overforbrugsmomenter, fÃ¸r de opstÃ¥r.',
          de: 'Prognostiziere VerlÃ¤ngerungsdruck und wahrscheinliche Ausgabenspitzen, bevor sie eintreten.',
          es: 'Predice la presiÃ³n de renovaciones y los posibles excesos de gasto antes de que ocurran.',
        ),
      ),
      FutureAiOpportunity(
        title: _t(
          settings,
          en: 'Anomaly detection',
          da: 'Anomalidetektion',
          de: 'Anomalieerkennung',
          es: 'DetecciÃ³n de anomalÃ­as',
        ),
        description: _t(
          settings,
          en: 'Flag surprising price shifts or unusual recurring spending growth automatically.',
          da: 'MarkÃ©r automatisk overraskende prisÃ¦ndringer eller usÃ¦dvanlig vÃ¦kst i tilbagevendende udgifter.',
          de: 'Markiere automatisch Ã¼berraschende PreisÃ¤nderungen oder ungewÃ¶hnliches Wachstum bei wiederkehrenden Ausgaben.',
          es: 'Marca automÃ¡ticamente cambios de precio inesperados o un crecimiento inusual del gasto recurrente.',
        ),
      ),
    ];
  }

  String _categoryClusterKey(RecurringPayment payment) {
    final name = payment.name.toLowerCase();
    if (name.contains('netflix') ||
        name.contains('disney') ||
        name.contains('hulu') ||
        name.contains('max') ||
        name.contains('youtube premium') ||
        name.contains('prime video') ||
        name.contains('spotify') ||
        name.contains('apple music')) {
      return name.contains('spotify') || name.contains('music')
          ? 'music_audio'
          : 'streaming';
    }
    if (name.contains('chatgpt') ||
        name.contains('claude') ||
        name.contains('gemini') ||
        name.contains('midjourney') ||
        name.contains('copilot') ||
        name.contains('cursor') ||
        name.contains('perplexity')) {
      return 'ai_tools';
    }
    if (name.contains('dropbox') ||
        name.contains('google one') ||
        name.contains('icloud') ||
        name.contains('onedrive') ||
        name.contains('mega')) {
      return 'cloud_storage';
    }
    if (name.contains('gym') ||
        name.contains('peloton') ||
        name.contains('fitbit') ||
        name.contains('strava')) {
      return 'fitness';
    }
    if (name.contains('notion') ||
        name.contains('slack') ||
        name.contains('zoom') ||
        name.contains('canva') ||
        name.contains('figma') ||
        name.contains('microsoft 365')) {
      return 'productivity';
    }
    return payment.category.name;
  }

  String _prettyCategory(String key, UserSettings settings) {
    switch (key) {
      case 'ai_tools':
        return _t(
          settings,
          en: 'AI tools',
          da: 'AI-vÃ¦rktÃ¸jer',
          de: 'KI-Tools',
          es: 'Herramientas de IA',
        );
      case 'cloud_storage':
        return _t(
          settings,
          en: 'Cloud storage',
          da: 'Cloudlager',
          de: 'Cloud-Speicher',
          es: 'Almacenamiento en la nube',
        );
      case 'music_audio':
        return _t(
          settings,
          en: 'Music & audio',
          da: 'Musik og lyd',
          de: 'Musik und Audio',
          es: 'MÃºsica y audio',
        );
      case 'streaming':
        return _t(
          settings,
          en: 'Streaming',
          da: 'Streaming',
          de: 'Streaming',
          es: 'Streaming',
        );
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (part) => part.isEmpty
                  ? part
                  : '${part[0].toUpperCase()}${part.substring(1)}',
            )
            .join(' ');
    }
  }

  String _percentileHint(String key, double monthly, UserSettings settings) {
    final percentile = switch (key) {
      'ai_tools' =>
        monthly >= 60
            ? 82
            : monthly >= 35
            ? 68
            : 44,
      'streaming' =>
        monthly >= 70
            ? 79
            : monthly >= 40
            ? 63
            : 41,
      'cloud_storage' => monthly >= 20 ? 74 : 48,
      'fitness' => monthly >= 45 ? 71 : 43,
      'productivity' => monthly >= 35 ? 77 : 51,
      _ => monthly >= 50 ? 69 : 46,
    };
    return _t(
      settings,
      en: 'You spend more on ${_prettyCategory(key, settings).toLowerCase()} than about $percentile% of similar Bizoot users.',
      da: 'Du bruger mere pÃ¥ ${_prettyCategory(key, settings).toLowerCase()} end omkring $percentile% af brugerne i Bizoots nuvÃ¦rende benchmarkmodel.',
      de: 'Du gibst mehr fÃ¼r ${_prettyCategory(key, settings).toLowerCase()} aus als etwa $percentile% der Nutzer im aktuellen Bizoot-Benchmarkmodell.',
      es: 'Gastas mÃ¡s en ${_prettyCategory(key, settings).toLowerCase()} que aproximadamente el $percentile% de los usuarios del modelo de referencia actual de Bizoot.',
    );
  }

  String _monthLabel(int month, UserSettings settings) {
    final locale = switch (AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    )) {
      'da' => 'da',
      'de' => 'de',
      'es' => 'es',
      _ => 'en',
    };
    return DateFormat.MMM(locale).format(DateTime(2026, month, 1));
  }

  T? _maxBy<T>(List<T> items, num Function(T item) selector) {
    if (items.isEmpty) return null;
    var best = items.first;
    var bestValue = selector(best);
    for (final item in items.skip(1)) {
      final value = selector(item);
      if (value > bestValue) {
        best = item;
        bestValue = value;
      }
    }
    return best;
  }
}
