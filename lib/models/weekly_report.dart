class WeeklyReport {
  final DateTime generatedAt;
  final double totalThisWeek;
  final double totalNextWeek;
  final double potentialSavings;
  final int newSubscriptions;
  final int cancelledSubscriptions;
  final int healthScore;
  final int previousHealthScore;
  final String biggestUpcomingPaymentName;
  final double biggestUpcomingPaymentAmount;
  final double recurringBurdenPercentage;
  final String riskLabel;
  final String optimizationSummary;
  final String topCategoryLabel;

  const WeeklyReport({
    required this.generatedAt,
    required this.totalThisWeek,
    required this.totalNextWeek,
    required this.potentialSavings,
    required this.newSubscriptions,
    required this.cancelledSubscriptions,
    required this.healthScore,
    required this.previousHealthScore,
    required this.biggestUpcomingPaymentName,
    required this.biggestUpcomingPaymentAmount,
    this.recurringBurdenPercentage = 0,
    this.riskLabel = 'Low risk',
    this.optimizationSummary = '',
    this.topCategoryLabel = 'No category leader yet',
  });
}
