class UserSettings {
  final String userId;
  final double monthlyIncome;
  final String currency;
  final String country;
  final String preferredLanguage;
  final String financialGoal;
  final int estimatedSubscriptions;
  final bool onboardingCompleted;
  final String defaultReminderTiming;
  final String dateFormat;
  final String firstDayOfWeek;
  final bool compactModeEnabled;
  final bool pushRemindersEnabled;
  final bool weeklySummaryEnabled;
  final bool stillUsingAlertsEnabled;
  final bool smartSavingsAlertsEnabled;
  final bool aiInsightsEnabled;
  final bool aiLocalOnlyEnabled;
  final bool aiCloudProcessingEnabled;
  final bool darkMode;
  final DateTime updatedAt;

  const UserSettings({
    required this.userId,
    required this.monthlyIncome,
    required this.currency,
    required this.country,
    required this.preferredLanguage,
    required this.financialGoal,
    required this.estimatedSubscriptions,
    required this.onboardingCompleted,
    required this.defaultReminderTiming,
    required this.dateFormat,
    required this.firstDayOfWeek,
    required this.compactModeEnabled,
    required this.pushRemindersEnabled,
    required this.weeklySummaryEnabled,
    required this.stillUsingAlertsEnabled,
    required this.smartSavingsAlertsEnabled,
    required this.aiInsightsEnabled,
    required this.aiLocalOnlyEnabled,
    required this.aiCloudProcessingEnabled,
    required this.darkMode,
    required this.updatedAt,
  });

  factory UserSettings.defaults() {
    return UserSettings(
      userId: 'mock-user',
      monthlyIncome: 4200,
      currency: 'USD',
      country: 'United States',
      preferredLanguage: 'English',
      financialGoal: 'Save money',
      estimatedSubscriptions: 5,
      onboardingCompleted: false,
      defaultReminderTiming: 'oneDayBefore',
      dateFormat: 'MMM d, yyyy',
      firstDayOfWeek: 'Monday',
      compactModeEnabled: false,
      pushRemindersEnabled: true,
      weeklySummaryEnabled: true,
      stillUsingAlertsEnabled: true,
      smartSavingsAlertsEnabled: true,
      aiInsightsEnabled: true,
      aiLocalOnlyEnabled: true,
      aiCloudProcessingEnabled: false,
      darkMode: false,
      updatedAt: DateTime.now(),
    );
  }

  UserSettings copyWith({
    String? userId,
    double? monthlyIncome,
    String? currency,
    String? country,
    String? preferredLanguage,
    String? financialGoal,
    int? estimatedSubscriptions,
    bool? onboardingCompleted,
    String? defaultReminderTiming,
    String? dateFormat,
    String? firstDayOfWeek,
    bool? compactModeEnabled,
    bool? pushRemindersEnabled,
    bool? weeklySummaryEnabled,
    bool? stillUsingAlertsEnabled,
    bool? smartSavingsAlertsEnabled,
    bool? aiInsightsEnabled,
    bool? aiLocalOnlyEnabled,
    bool? aiCloudProcessingEnabled,
    bool? darkMode,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      financialGoal: financialGoal ?? this.financialGoal,
      estimatedSubscriptions: estimatedSubscriptions ?? this.estimatedSubscriptions,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      defaultReminderTiming: defaultReminderTiming ?? this.defaultReminderTiming,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      compactModeEnabled: compactModeEnabled ?? this.compactModeEnabled,
      pushRemindersEnabled: pushRemindersEnabled ?? this.pushRemindersEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      stillUsingAlertsEnabled: stillUsingAlertsEnabled ?? this.stillUsingAlertsEnabled,
      smartSavingsAlertsEnabled: smartSavingsAlertsEnabled ?? this.smartSavingsAlertsEnabled,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      aiLocalOnlyEnabled: aiLocalOnlyEnabled ?? this.aiLocalOnlyEnabled,
      aiCloudProcessingEnabled: aiCloudProcessingEnabled ?? this.aiCloudProcessingEnabled,
      darkMode: darkMode ?? this.darkMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'monthly_income': monthlyIncome,
      'currency': currency,
      'country': country,
      'preferred_language': preferredLanguage,
      'financial_goal': financialGoal,
      'estimated_subscriptions': estimatedSubscriptions,
      'onboarding_completed': onboardingCompleted,
      'default_reminder_timing': defaultReminderTiming,
      'date_format': dateFormat,
      'first_day_of_week': firstDayOfWeek,
      'compact_mode_enabled': compactModeEnabled,
      'push_reminders_enabled': pushRemindersEnabled,
      'weekly_summary_enabled': weeklySummaryEnabled,
      'still_using_alerts_enabled': stillUsingAlertsEnabled,
      'smart_savings_alerts_enabled': smartSavingsAlertsEnabled,
      'ai_insights_enabled': aiInsightsEnabled,
      'ai_local_only_enabled': aiLocalOnlyEnabled,
      'ai_cloud_processing_enabled': aiCloudProcessingEnabled,
      'dark_mode': darkMode,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
