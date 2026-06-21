import '../../models/recurring_payment.dart';
import '../../models/user_settings.dart';
import '../models/ai_forecast.dart';
import '../models/ai_insight.dart';
import '../models/ai_recommendation.dart';
import '../models/ai_user_context.dart';
import 'ai_insight_provider.dart';

class ExternalAiProvider implements AiInsightProvider {
  const ExternalAiProvider();

  @override
  String get providerName => 'External placeholder';

  @override
  Future<List<AiInsight>> generatePersonalizedInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
  }) async {
    // TODO: Route sanitized context to a consent-gated cloud AI provider such
    // as an OpenAI-backed Firebase cloud endpoint with rate limiting, audit
    // logging, moderation, and localization support.
    return const [];
  }

  @override
  Future<List<AiRecommendation>> generateSavingsRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    return const [];
  }

  @override
  Future<List<AiRecommendation>> generateCancellationRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    return const [];
  }

  @override
  Future<AiForecast> generateSpendingForecast(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    return const AiForecast(
      summary: 'Cloud AI forecast is not enabled in this build.',
      projectedMonthlySpend: 0,
      projectedYearlySpend: 0,
      confidence: 0,
    );
  }

  @override
  Future<String> explainHealthScore(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    return 'Cloud AI health-score explanations are not enabled in this build.';
  }

  @override
  Future<List<AiInsight>> detectSubscriptionAnomalies(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) async {
    return const [];
  }

  @override
  AiUserContext buildSanitizedUserContext(
    UserSettings settings,
    List<RecurringPayment> payments,
  ) {
    throw UnimplementedError(
      'TODO: Build sanitized cloud-ready AI context before enabling external processing.',
    );
  }
}
