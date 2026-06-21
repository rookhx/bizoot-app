import '../models/insight_event.dart';
import '../models/recurring_payment.dart';
import '../models/user_settings.dart';
import '../models/weekly_report.dart';
import '../utils/payment_math.dart';
import 'financial_intelligence_service.dart';

class HealthScoreResult {
  final int score;
  final String label;
  final int delta;
  final String explanation;
  final List<HealthScoreBreakdownItem> breakdown;

  const HealthScoreResult({
    required this.score,
    required this.label,
    this.delta = 0,
    this.explanation = '',
    this.breakdown = const [],
  });
}

class IntelligenceService {
  IntelligenceService({
    FinancialIntelligenceService? financialIntelligenceService,
  }) : financialIntelligenceService = financialIntelligenceService ?? const FinancialIntelligenceService();

  final FinancialIntelligenceService financialIntelligenceService;

  FinancialIntelligenceSnapshot buildSnapshot(
    UserSettings settings,
    List<RecurringPayment> payments, {
    bool isPremiumUser = false,
  }) {
    return financialIntelligenceService.buildSnapshot(
      settings,
      payments,
      isPremiumUser: isPremiumUser,
    );
  }

  double monthlySpend(List<RecurringPayment> payments) {
    return payments.fold(0, (sum, item) => sum + monthlyEquivalent(item));
  }

  double yearlySpend(List<RecurringPayment> payments) {
    return payments.fold(0, (sum, item) => sum + yearlyEquivalent(item));
  }

  double safeToSpend(UserSettings settings, List<RecurringPayment> payments) {
    return settings.monthlyIncome - monthlySpend(payments);
  }

  double incomeCommitment(UserSettings settings, List<RecurringPayment> payments) {
    if (settings.monthlyIncome <= 0) return 0;
    return (monthlySpend(payments) / settings.monthlyIncome) * 100;
  }

  HealthScoreResult buildHealthScore(UserSettings settings, List<RecurringPayment> payments) {
    final snapshot = buildSnapshot(settings, payments, isPremiumUser: true);
    return HealthScoreResult(
      score: snapshot.healthScore.score,
      label: snapshot.healthScore.label,
      delta: snapshot.healthScore.delta,
      explanation: snapshot.healthScore.explanation,
      breakdown: snapshot.healthScore.breakdown,
    );
  }

  List<InsightEvent> buildInsights(UserSettings settings, List<RecurringPayment> payments) {
    final snapshot = buildSnapshot(settings, payments, isPremiumUser: true);
    return snapshot.insights
        .map(
          (item) => InsightEvent(
            id: item.id,
            title: item.title,
            body: item.body,
            tone: switch (item.severity) {
              InsightSeverity.high => 'warning',
              InsightSeverity.medium => 'neutral',
              InsightSeverity.low => 'positive',
            },
            category: item.category,
            severity: item.severity.name,
            priority: item.priority.name,
            premiumLocked: item.isPremium,
            metricLabel: item.metricLabel,
          ),
        )
        .toList(growable: false);
  }

  WeeklyReport buildWeeklyReport(UserSettings settings, List<RecurringPayment> payments) {
    final snapshot = buildSnapshot(settings, payments, isPremiumUser: true);
    final now = DateTime.now();
    final thisWeekEnd = now.add(const Duration(days: 7));
    final nextWeekEnd = now.add(const Duration(days: 14));
    final thisWeek = payments.where((item) => item.nextDueDate.isAfter(now) && item.nextDueDate.isBefore(thisWeekEnd)).toList();
    final nextWeek = payments.where((item) => item.nextDueDate.isAfter(thisWeekEnd) && item.nextDueDate.isBefore(nextWeekEnd)).toList();
    final biggest = _maxBy(thisWeek, (item) => item.amount);

    return WeeklyReport(
      generatedAt: now,
      totalThisWeek: thisWeek.fold(0, (sum, item) => sum + item.amount),
      totalNextWeek: nextWeek.fold(0, (sum, item) => sum + item.amount),
      potentialSavings: potentialSavings(payments),
      newSubscriptions: payments.where((item) => item.createdAt.isAfter(now.subtract(const Duration(days: 7)))).length,
      cancelledSubscriptions: payments.where((item) => item.cancelledAt != null && item.cancelledAt!.isAfter(now.subtract(const Duration(days: 7)))).length,
      healthScore: snapshot.healthScore.score,
      previousHealthScore: (snapshot.healthScore.score - snapshot.healthScore.delta).clamp(0, 100),
      biggestUpcomingPaymentName: biggest?.name ?? 'No upcoming payments',
      biggestUpcomingPaymentAmount: biggest?.amount ?? 0,
      recurringBurdenPercentage: snapshot.recurringBurdenPercentage,
      riskLabel: snapshot.riskReport.label,
      optimizationSummary: snapshot.report.optimizationSummary,
      topCategoryLabel: snapshot.mostExpensiveCategory?.label ?? 'No category leader yet',
    );
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
