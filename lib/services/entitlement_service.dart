import '../models/user_profile.dart';

class EntitlementService {
  const EntitlementService();

  static const int defaultSubscriptionLimit = 5;
  static const Duration defaultTrialLength = Duration(days: 7);

  bool isPremiumUser(UserProfile profile) {
    // TODO: Replace this temporary local premium override with RevenueCat's
    // "premium" entitlement once billing goes live.
    return profile.isPremiumOverride;
  }

  bool hasPremiumFeatureAccess(UserProfile profile, {DateTime? now}) {
    return isPremiumUser(profile) || isTrialActive(profile, now: now);
  }

  bool isTrialActive(UserProfile profile, {DateTime? now}) {
    final trialEndsAt = profile.trialEndsAt;
    if (trialEndsAt == null || isPremiumUser(profile)) return false;
    return trialEndsAt.isAfter(now ?? DateTime.now());
  }

  int getTrialDaysRemaining(UserProfile profile, {DateTime? now}) {
    if (!isTrialActive(profile, now: now)) return 0;
    final current = now ?? DateTime.now();
    final difference = profile.trialEndsAt!.difference(current);
    final days = difference.inDays + (difference.inHours % 24 > 0 || difference.inMinutes % 60 > 0 ? 1 : 0);
    return days < 0 ? 0 : days;
  }

  int getSubscriptionLimit(UserProfile profile) {
    if (isPremiumUser(profile)) return -1;
    return profile.subscriptionLimit <= 0 ? defaultSubscriptionLimit : profile.subscriptionLimit;
  }

  bool canAddSubscription(UserProfile profile, int currentActiveCount) {
    if (isPremiumUser(profile)) return true;
    return currentActiveCount < defaultSubscriptionLimit;
  }

  bool shouldShowUpgradeWall(UserProfile profile, int currentActiveCount) {
    return !canAddSubscription(profile, currentActiveCount);
  }

  bool canUseAdvancedInsights(UserProfile profile) => hasPremiumFeatureAccess(profile);

  bool canUseSmartNotifications(UserProfile profile) => hasPremiumFeatureAccess(profile);

  bool canUseAdvancedReports(UserProfile profile) => hasPremiumFeatureAccess(profile);

  bool canUseCancellationAssistant(UserProfile profile) => hasPremiumFeatureAccess(profile);

  bool shouldLockAdvancedInsights(UserProfile profile) => !hasPremiumFeatureAccess(profile);

  bool shouldLockReports(UserProfile profile) => !hasPremiumFeatureAccess(profile);

  bool shouldLockSmartNotifications(UserProfile profile) => !hasPremiumFeatureAccess(profile);

  bool shouldLockCancellationAssistant(UserProfile profile) => !hasPremiumFeatureAccess(profile);

  UserProfile ensureTrialStarted(UserProfile profile, {DateTime? now}) {
    if (profile.trialStartedAt != null && profile.trialEndsAt != null) {
      return profile;
    }
    final startedAt = now ?? DateTime.now();
    return profile.copyWith(
      trialStartedAt: startedAt,
      trialEndsAt: startedAt.add(defaultTrialLength),
      subscriptionLimit: defaultSubscriptionLimit,
    );
  }
}
