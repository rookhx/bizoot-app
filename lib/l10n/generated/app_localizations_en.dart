// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bizoot';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get calendar => 'Calendar';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccount => 'Create your Bizoot account';

  @override
  String get authWelcomeSubtitle =>
      'Log in to see what your fixed costs are really doing to your month.';

  @override
  String get authCreateSubtitle =>
      'Create your account and bring every recurring charge into one premium control center.';

  @override
  String get authHero => 'Stop wasting money on forgotten subscriptions.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get logIn => 'Log in';

  @override
  String get createAccount => 'Create account';

  @override
  String get enterEmailPassword =>
      'Enter both your email and password to continue.';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get needAccount => 'Need an account? Sign up';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get finishingSetup => 'Finishing setup...';

  @override
  String get fullNameAndCountryRequired =>
      'Full name and country are required.';

  @override
  String get validCountryRequired =>
      'Please select a valid country from the list.';

  @override
  String get profileSetup => 'Profile setup';

  @override
  String get profileSetupSubtitle =>
      'Let\'s personalize Bizoot before we start tracking your recurring spending.';

  @override
  String get tapChooseProfilePicture => 'Tap to choose a profile picture';

  @override
  String get profilePictureSelected => 'Profile picture selected';

  @override
  String get opensPhoneGallery => 'Opens your phone gallery';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumberOptional => 'Phone number (optional)';

  @override
  String get country => 'Country';

  @override
  String get financialSetup => 'Financial setup';

  @override
  String get financialSetupSubtitle =>
      'Choose the money settings Bizoot should use across your dashboard, insights, and reminders.';

  @override
  String get currency => 'Currency';

  @override
  String get currencyAutoSelected =>
      'Automatically selected from your chosen country.';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get monthlyIncomeHelper =>
      'Optional but recommended for Health Score and safe-to-spend.';

  @override
  String get mainFinancialGoal => 'Main financial goal';

  @override
  String get estimatedSubscriptions => 'Estimated subscriptions';

  @override
  String estimatedSubscriptionsLabel(int count) {
    return '$count subscriptions';
  }

  @override
  String get goalSaveMoney => 'Save money';

  @override
  String get goalTrackBills => 'Track bills';

  @override
  String get goalAvoidSurpriseCharges => 'Avoid surprise charges';

  @override
  String get goalCancelUnusedSubscriptions => 'Cancel unused subscriptions';

  @override
  String get settingsSyncing => 'Saving your latest Bizoot changes...';

  @override
  String get settingsOffline =>
      'Offline mode active. Your changes stay safe and will continue when you are back online.';

  @override
  String get settingsPendingChanges =>
      'A few recent changes are still being saved.';

  @override
  String get settingsReady =>
      'Your account, reminders, privacy, and support settings live here.';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Choose the language Bizoot should use across the app.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageUpdated => 'Language updated.';

  @override
  String get notificationPreferencesUpdated =>
      'Notification preferences updated.';

  @override
  String get notificationPreferencesFailed =>
      'We could not update your notification preferences right now.';

  @override
  String get signOutQuestion => 'Sign out of Bizoot?';

  @override
  String get signOutBody =>
      'You will return to the login screen, and your synced account data will remain attached to your account.';

  @override
  String get staySignedIn => 'Stay signed in';

  @override
  String get signOut => 'Sign out';

  @override
  String get openPhoneNotificationSettings =>
      'Open phone notification settings';

  @override
  String get paymentReminders => 'Payment reminders';

  @override
  String get paymentRemindersSubtitle =>
      'Due tomorrow and due soon reminders for your active subscriptions.';

  @override
  String get weeklySummaries => 'Weekly summaries';

  @override
  String get weeklySummariesSubtitle =>
      'Sunday evening summaries for next week\'s renewals and totals.';

  @override
  String get trialAlerts => 'Trial alerts';

  @override
  String get trialAlertsSubtitle =>
      'Warnings before a free trial turns into a paid subscription.';

  @override
  String get smartInsights => 'Smart insights';

  @override
  String get smartInsightsSubtitle =>
      'Savings nudges, cancellation follow-ups, and recurring-spend warnings.';

  @override
  String get promotionalNotifications => 'Promotional notifications';

  @override
  String get promotionalNotificationsSubtitle =>
      'Optional product updates, launch news, and feature announcements.';

  @override
  String premiumRequiredSuffix(Object text) {
    return '$text Premium required.';
  }

  @override
  String get subscriptionPremium => 'Subscription & Premium';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get trialStatus => 'Trial status';

  @override
  String get subscriptionUsage => 'Subscription usage';

  @override
  String get whatHappensNow => 'What happens now';

  @override
  String get planPremium => 'Premium';

  @override
  String get planTrial => '7-day trial';

  @override
  String get planFree => 'Free';

  @override
  String get premiumUnlocked => 'Premium unlocked';

  @override
  String trialDaysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get trialEnded => 'Trial ended';

  @override
  String subscriptionsTrackedUnlimited(int count) {
    return '$count subscriptions tracked • unlimited plan';
  }

  @override
  String subscriptionsUsed(int count, int limit) {
    return '$count / $limit subscriptions used';
  }

  @override
  String get premiumActiveDescription =>
      'You have unlimited subscription tracking and all premium features unlocked.';

  @override
  String get trialPremiumDescription =>
      'You have full premium features during trial, with a 5-subscription trial limit.';

  @override
  String freePlanDescription(int limit) {
    return 'You can keep tracking up to $limit active subscriptions on this plan.';
  }

  @override
  String get limitReachedDescription =>
      'Limit reached - upgrade for unlimited tracking.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumFeatureComparison => 'Premium feature comparison';

  @override
  String get premiumCompareFree =>
      'Free: up to 5 active subscriptions, basic reminders, core tracking';

  @override
  String get premiumCompareOne =>
      'Premium: unlimited subscriptions, advanced reports, smart insights';

  @override
  String get premiumCompareTwo =>
      'Premium: richer cancellation intelligence, weekly summaries, and deeper insights';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacyAiSettings => 'Privacy & AI Settings';

  @override
  String get privacyAiSubtitle =>
      'Control AI insights and review how Bizoot protects sensitive information.';

  @override
  String get support => 'Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get contactSupportSubtitle =>
      'Get help, report an issue, or share feedback with the Bizoot team.';

  @override
  String get legal => 'Legal';

  @override
  String get savedServices => 'Saved Services';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get savedServicesEmptyTitle => 'No custom services yet';

  @override
  String get savedServicesEmptyBody =>
      'When you create a custom subscription with your own cancellation link, Bizoot will remember it here for faster autofill next time.';

  @override
  String get savedServiceUpdated => 'Saved service updated.';

  @override
  String get savedServiceUpdatedFailed =>
      'We could not update that saved service right now.';

  @override
  String get editSavedService => 'Edit saved service';

  @override
  String get deleteSavedService => 'Delete saved service';

  @override
  String get cancellationUrl => 'Cancellation URL';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteSavedServiceQuestion => 'Delete saved service?';

  @override
  String deleteSavedServiceBody(Object serviceName) {
    return 'Bizoot will forget $serviceName and stop suggesting it from your custom list.';
  }

  @override
  String get savedServiceDeleted => 'Saved service deleted.';

  @override
  String get savedServiceDeletedFailed =>
      'We could not delete that saved service right now.';

  @override
  String get noSavedCancellationUrl => 'No saved cancellation URL yet.';

  @override
  String usedTimes(int count) {
    return 'Used $count times';
  }

  @override
  String get debugLocalization => 'Localization Debug';

  @override
  String get currentLocale => 'Current locale';

  @override
  String get supportedLocalesLabel => 'Supported locales';

  @override
  String get fallbackBehavior => 'Fallback behavior';

  @override
  String get fallbackBehaviorValue =>
      'Unsupported device locales fall back to English.';

  @override
  String get missingTranslationFallbackCount =>
      'Missing translation fallback count';

  @override
  String get premiumTooltip => 'Premium';
}
