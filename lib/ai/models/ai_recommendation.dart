class AiRecommendation {
  final String id;
  final String title;
  final String explanation;
  final String actionLabel;
  final String? relatedPaymentId;
  final double confidence;

  const AiRecommendation({
    required this.id,
    required this.title,
    required this.explanation,
    required this.actionLabel,
    required this.confidence,
    this.relatedPaymentId,
  });
}
