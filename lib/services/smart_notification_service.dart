import '../models/recurring_payment.dart';
import '../models/user_settings.dart';
import 'financial_intelligence_service.dart';

class SmartNotificationService {
  const SmartNotificationService({
    this.intelligenceService = const FinancialIntelligenceService(),
  });

  final FinancialIntelligenceService intelligenceService;

  List<SmartNotificationOpportunity> buildSmartNotifications(
    UserSettings settings,
    List<RecurringPayment> payments, {
    required bool isPremiumUser,
  }) {
    return intelligenceService.buildNotificationOpportunities(
      settings,
      payments,
      isPremiumUser: isPremiumUser,
    );
  }
}
