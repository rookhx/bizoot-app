class AiForecast {
  final String summary;
  final double projectedMonthlySpend;
  final double projectedYearlySpend;
  final double confidence;

  const AiForecast({
    required this.summary,
    required this.projectedMonthlySpend,
    required this.projectedYearlySpend,
    required this.confidence,
  });
}
