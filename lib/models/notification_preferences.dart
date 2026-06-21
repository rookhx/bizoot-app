class NotificationPreferences {
  final String userId;
  final bool paymentRemindersEnabled;
  final bool emailRemindersEnabled;
  final bool trialAlertsEnabled;
  final bool weeklySummaryEnabled;
  final bool stillUsingAlertsEnabled;
  final bool savingsInsightsEnabled;
  final bool cancellationNudgesEnabled;
  final String defaultReminderTiming;
  final bool premiumAccess;
  final DateTime updatedAt;

  const NotificationPreferences({
    required this.userId,
    required this.paymentRemindersEnabled,
    required this.emailRemindersEnabled,
    required this.trialAlertsEnabled,
    required this.weeklySummaryEnabled,
    required this.stillUsingAlertsEnabled,
    required this.savingsInsightsEnabled,
    required this.cancellationNudgesEnabled,
    required this.defaultReminderTiming,
    required this.premiumAccess,
    required this.updatedAt,
  });

  factory NotificationPreferences.defaults({String userId = 'mock-user'}) {
    return NotificationPreferences(
      userId: userId,
      paymentRemindersEnabled: true,
      emailRemindersEnabled: false,
      trialAlertsEnabled: true,
      weeklySummaryEnabled: true,
      stillUsingAlertsEnabled: true,
      savingsInsightsEnabled: true,
      cancellationNudgesEnabled: true,
      defaultReminderTiming: 'oneDayBefore',
      premiumAccess: false,
      updatedAt: DateTime.now(),
    );
  }

  NotificationPreferences copyWith({
    String? userId,
    bool? paymentRemindersEnabled,
    bool? emailRemindersEnabled,
    bool? trialAlertsEnabled,
    bool? weeklySummaryEnabled,
    bool? stillUsingAlertsEnabled,
    bool? savingsInsightsEnabled,
    bool? cancellationNudgesEnabled,
    String? defaultReminderTiming,
    bool? premiumAccess,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      paymentRemindersEnabled: paymentRemindersEnabled ?? this.paymentRemindersEnabled,
      emailRemindersEnabled: emailRemindersEnabled ?? this.emailRemindersEnabled,
      trialAlertsEnabled: trialAlertsEnabled ?? this.trialAlertsEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      stillUsingAlertsEnabled: stillUsingAlertsEnabled ?? this.stillUsingAlertsEnabled,
      savingsInsightsEnabled: savingsInsightsEnabled ?? this.savingsInsightsEnabled,
      cancellationNudgesEnabled: cancellationNudgesEnabled ?? this.cancellationNudgesEnabled,
      defaultReminderTiming: defaultReminderTiming ?? this.defaultReminderTiming,
      premiumAccess: premiumAccess ?? this.premiumAccess,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'push_reminders_enabled': paymentRemindersEnabled,
      'email_reminders_enabled': emailRemindersEnabled,
      'trial_alerts_enabled': trialAlertsEnabled,
      'weekly_summary_enabled': weeklySummaryEnabled,
      'still_using_alerts_enabled': stillUsingAlertsEnabled,
      'savings_insights_enabled': savingsInsightsEnabled,
      'cancellation_nudges_enabled': cancellationNudgesEnabled,
      'default_reminder_timing': defaultReminderTiming,
      'premium_access': premiumAccess,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map, {String fallbackUserId = 'mock-user'}) {
    return NotificationPreferences(
      userId: map['user_id'] as String? ?? fallbackUserId,
      paymentRemindersEnabled: map['push_reminders_enabled'] as bool? ?? true,
      emailRemindersEnabled: map['email_reminders_enabled'] as bool? ?? false,
      trialAlertsEnabled: map['trial_alerts_enabled'] as bool? ?? true,
      weeklySummaryEnabled: map['weekly_summary_enabled'] as bool? ?? true,
      stillUsingAlertsEnabled: map['still_using_alerts_enabled'] as bool? ?? true,
      savingsInsightsEnabled: map['savings_insights_enabled'] as bool? ?? true,
      cancellationNudgesEnabled: map['cancellation_nudges_enabled'] as bool? ?? true,
      defaultReminderTiming: map['default_reminder_timing'] as String? ?? 'oneDayBefore',
      premiumAccess: map['premium_access'] as bool? ?? false,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
