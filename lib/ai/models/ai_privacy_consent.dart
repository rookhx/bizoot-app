class AiPrivacyConsent {
  final bool enableAiInsights;
  final bool useLocalOnlyInsights;
  final bool allowCloudAiProcessingLater;

  const AiPrivacyConsent({
    required this.enableAiInsights,
    required this.useLocalOnlyInsights,
    required this.allowCloudAiProcessingLater,
  });

  factory AiPrivacyConsent.defaults() {
    return const AiPrivacyConsent(
      enableAiInsights: true,
      useLocalOnlyInsights: true,
      allowCloudAiProcessingLater: false,
    );
  }
}
