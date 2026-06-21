enum AiInsightType {
  savingsOpportunity,
  cancellationRecommendation,
  trialRisk,
  spendingForecast,
  categoryOverload,
  healthScoreExplanation,
  unusualIncrease,
  duplicateServices,
  renewalRisk,
}

enum AiInsightSeverity {
  info,
  warning,
  savings,
  urgent,
}

class AiInsight {
  final String id;
  final AiInsightType type;
  final String title;
  final String explanation;
  final String? financialImpactLabel;
  final double confidence;
  final AiInsightSeverity severity;
  final String actionLabel;
  final String? relatedPaymentId;
  final bool premiumLocked;
  final bool previewOnly;

  const AiInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.explanation,
    required this.confidence,
    required this.severity,
    required this.actionLabel,
    this.financialImpactLabel,
    this.relatedPaymentId,
    this.premiumLocked = false,
    this.previewOnly = false,
  });
}
