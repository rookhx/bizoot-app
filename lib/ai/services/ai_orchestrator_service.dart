import '../../config/app_config.dart';
import '../../models/recurring_payment.dart';
import '../../models/user_settings.dart';
import '../models/ai_forecast.dart';
import '../models/ai_insight.dart';
import '../models/ai_privacy_consent.dart';
import '../models/ai_user_context.dart';
import 'ai_insight_provider.dart';
import 'external_ai_provider.dart';
import 'local_rule_based_ai_provider.dart';

class AiOrchestratorResult {
  final List<AiInsight> insights;
  final AiForecast forecast;
  final String providerName;
  final AiUserContext sanitizedContext;

  const AiOrchestratorResult({
    required this.insights,
    required this.forecast,
    required this.providerName,
    required this.sanitizedContext,
  });
}

class AiOrchestratorService {
  const AiOrchestratorService({
    this.localProvider = const LocalRuleBasedAiProvider(),
    this.externalProvider = const ExternalAiProvider(),
  });

  final AiInsightProvider localProvider;
  final AiInsightProvider externalProvider;

  Future<AiOrchestratorResult> buildInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
    required AiPrivacyConsent consent,
  }) async {
    final useExternal =
        consent.enableAiInsights &&
        !consent.useLocalOnlyInsights &&
        consent.allowCloudAiProcessingLater &&
        AppConfig.isFirebaseConfigured;

    final provider = useExternal ? externalProvider : localProvider;

    try {
      final insights = await provider.generatePersonalizedInsights(
        settings,
        payments,
        isPremiumUser: isPremiumUser,
      );
      final anomalies = await provider.detectSubscriptionAnomalies(
        settings,
        payments,
      );
      final forecast = await provider.generateSpendingForecast(
        settings,
        payments,
      );
      final merged = _dedupeAndRank([...insights, ...anomalies]);
      return AiOrchestratorResult(
        insights: merged,
        forecast: forecast,
        providerName: provider.providerName,
        sanitizedContext: localProvider.buildSanitizedUserContext(
          settings,
          payments,
        ),
      );
    } catch (_) {
      final fallbackInsights = await localProvider.generatePersonalizedInsights(
        settings,
        payments,
        isPremiumUser: isPremiumUser,
      );
      final fallbackForecast = await localProvider.generateSpendingForecast(
        settings,
        payments,
      );
      return AiOrchestratorResult(
        insights: _dedupeAndRank(fallbackInsights),
        forecast: fallbackForecast,
        providerName: localProvider.providerName,
        sanitizedContext: localProvider.buildSanitizedUserContext(
          settings,
          payments,
        ),
      );
    }
  }

  List<AiInsight> _dedupeAndRank(List<AiInsight> items) {
    final seen = <String>{};
    final deduped = <AiInsight>[];
    for (final item in items) {
      final dedupeKey =
          '${item.type.name}:${item.relatedPaymentId ?? ''}:${item.title}';
      if (seen.add(dedupeKey)) {
        deduped.add(item);
      }
    }
    deduped.sort((a, b) {
      final severityCompare = _severityRank(
        b.severity,
      ).compareTo(_severityRank(a.severity));
      if (severityCompare != 0) return severityCompare;
      return b.confidence.compareTo(a.confidence);
    });
    return deduped;
  }

  int _severityRank(AiInsightSeverity severity) {
    return switch (severity) {
      AiInsightSeverity.urgent => 4,
      AiInsightSeverity.warning => 3,
      AiInsightSeverity.savings => 2,
      AiInsightSeverity.info => 1,
    };
  }

  // TODO: When cloud AI is enabled later, record consent logs, apply rate
  // limits, route through a Firebase-backed cloud endpoint, and preserve audit
  // trails for outputs.
}
