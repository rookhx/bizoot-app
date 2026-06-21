class InsightEvent {
  final String id;
  final String title;
  final String body;
  final String tone;
  final String category;
  final String severity;
  final String priority;
  final bool premiumLocked;
  final String? metricLabel;

  const InsightEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.tone,
    this.category = 'general',
    this.severity = 'low',
    this.priority = 'low',
    this.premiumLocked = false,
    this.metricLabel,
  });
}
