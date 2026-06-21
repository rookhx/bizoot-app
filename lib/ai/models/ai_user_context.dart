class AiSubscriptionContextItem {
  final String serviceName;
  final double amount;
  final String currency;
  final String category;
  final String billingFrequency;
  final DateTime nextDueDate;
  final bool isTrial;
  final DateTime? trialEndDate;
  final bool consideringCancellation;

  const AiSubscriptionContextItem({
    required this.serviceName,
    required this.amount,
    required this.currency,
    required this.category,
    required this.billingFrequency,
    required this.nextDueDate,
    required this.isTrial,
    required this.trialEndDate,
    required this.consideringCancellation,
  });
}

class AiUserContext {
  final String currency;
  final double monthlyIncome;
  final List<AiSubscriptionContextItem> subscriptions;

  const AiUserContext({
    required this.currency,
    required this.monthlyIncome,
    required this.subscriptions,
  });

  Map<String, dynamic> toSanitizedMap() {
    return {
      'currency': currency,
      'monthly_income': monthlyIncome,
      'subscriptions': subscriptions
          .map(
            (item) => {
              'service_name': item.serviceName,
              'amount': item.amount,
              'currency': item.currency,
              'category': item.category,
              'billing_frequency': item.billingFrequency,
              'next_due_date': item.nextDueDate.toIso8601String(),
              'is_trial': item.isTrial,
              'trial_end_date': item.trialEndDate?.toIso8601String(),
              'considering_cancellation': item.consideringCancellation,
            },
          )
          .toList(growable: false),
    };
  }
}
