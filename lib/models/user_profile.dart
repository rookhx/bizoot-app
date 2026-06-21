class UserProfile {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final String country;
  final String preferredLanguage;
  final String preferredCurrency;
  final double monthlyIncome;
  final String financialGoal;
  final int estimatedSubscriptions;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final bool isPremiumOverride;
  final int subscriptionLimit;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.country,
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.monthlyIncome,
    required this.financialGoal,
    required this.estimatedSubscriptions,
    required this.trialStartedAt,
    required this.trialEndsAt,
    required this.isPremiumOverride,
    required this.subscriptionLimit,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.defaults({String userId = 'mock-user'}) {
    final now = DateTime.now();
    return UserProfile(
      id: userId,
      userId: userId,
      fullName: '',
      phone: '',
      avatarUrl: null,
      country: 'United States',
      preferredLanguage: 'English',
      preferredCurrency: 'USD',
      monthlyIncome: 4200,
      financialGoal: 'Save money',
      estimatedSubscriptions: 5,
      trialStartedAt: null,
      trialEndsAt: null,
      isPremiumOverride: false,
      subscriptionLimit: 5,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? country,
    String? preferredLanguage,
    String? preferredCurrency,
    double? monthlyIncome,
    String? financialGoal,
    int? estimatedSubscriptions,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    bool clearTrialDates = false,
    bool? isPremiumOverride,
    int? subscriptionLimit,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      country: country ?? this.country,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      financialGoal: financialGoal ?? this.financialGoal,
      estimatedSubscriptions: estimatedSubscriptions ?? this.estimatedSubscriptions,
      trialStartedAt: clearTrialDates ? null : (trialStartedAt ?? this.trialStartedAt),
      trialEndsAt: clearTrialDates ? null : (trialEndsAt ?? this.trialEndsAt),
      isPremiumOverride: isPremiumOverride ?? this.isPremiumOverride,
      subscriptionLimit: subscriptionLimit ?? this.subscriptionLimit,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'country': country,
      'preferred_language': preferredLanguage,
      'preferred_currency': preferredCurrency,
      'monthly_income': monthlyIncome,
      'financial_goal': financialGoal,
      'estimated_subscriptions': estimatedSubscriptions,
      'trial_started_at': trialStartedAt?.toIso8601String(),
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'is_premium_override': isPremiumOverride,
      'subscription_limit': subscriptionLimit,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {required String fallbackUserId}) {
    final now = DateTime.now();
    return UserProfile(
      id: map['id'] as String? ?? fallbackUserId,
      userId: map['user_id'] as String? ?? fallbackUserId,
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      country: map['country'] as String? ?? 'United States',
      preferredLanguage: map['preferred_language'] as String? ?? 'English',
      preferredCurrency: map['preferred_currency'] as String? ?? 'USD',
      monthlyIncome: (map['monthly_income'] as num?)?.toDouble() ?? 0,
      financialGoal: map['financial_goal'] as String? ?? 'Save money',
      estimatedSubscriptions: map['estimated_subscriptions'] as int? ?? 0,
      trialStartedAt: DateTime.tryParse(map['trial_started_at'] as String? ?? ''),
      trialEndsAt: DateTime.tryParse(map['trial_ends_at'] as String? ?? ''),
      isPremiumOverride: map['is_premium_override'] as bool? ?? false,
      subscriptionLimit: map['subscription_limit'] as int? ?? 5,
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? now,
    );
  }
}
