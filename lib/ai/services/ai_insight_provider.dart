import '../../models/recurring_payment.dart';
import '../../models/user_settings.dart';
import '../models/ai_forecast.dart';
import '../models/ai_insight.dart';
import '../models/ai_recommendation.dart';
import '../models/ai_user_context.dart';

abstract class AiInsightProvider {
  String get providerName;

  Future<List<AiInsight>> generatePersonalizedInsights(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
  });

  Future<List<AiRecommendation>> generateSavingsRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  );

  Future<List<AiRecommendation>> generateCancellationRecommendations(
    UserSettings settings,
    List<RecurringPayment> payments,
  );

  Future<AiForecast> generateSpendingForecast(
    UserSettings settings,
    List<RecurringPayment> payments,
  );

  Future<String> explainHealthScore(
    UserSettings settings,
    List<RecurringPayment> payments,
  );

  Future<List<AiInsight>> detectSubscriptionAnomalies(
    UserSettings settings,
    List<RecurringPayment> payments,
  );

  AiUserContext buildSanitizedUserContext(
    UserSettings settings,
    List<RecurringPayment> payments,
  );
}
