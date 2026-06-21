import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Bizoot'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your Bizoot account'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to see what your fixed costs are really doing to your month.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account and bring every recurring charge into one premium control center.'**
  String get authCreateSubtitle;

  /// No description provided for @authHero.
  ///
  /// In en, this message translates to:
  /// **'Stop wasting money on forgotten subscriptions.'**
  String get authHero;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter both your email and password to continue.'**
  String get enterEmailPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get needAccount;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @finishingSetup.
  ///
  /// In en, this message translates to:
  /// **'Finishing setup...'**
  String get finishingSetup;

  /// No description provided for @fullNameAndCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name and country are required.'**
  String get fullNameAndCountryRequired;

  /// No description provided for @validCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid country from the list.'**
  String get validCountryRequired;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Profile setup'**
  String get profileSetup;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize Bizoot before we start tracking your recurring spending.'**
  String get profileSetupSubtitle;

  /// No description provided for @tapChooseProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a profile picture'**
  String get tapChooseProfilePicture;

  /// No description provided for @profilePictureSelected.
  ///
  /// In en, this message translates to:
  /// **'Profile picture selected'**
  String get profilePictureSelected;

  /// No description provided for @opensPhoneGallery.
  ///
  /// In en, this message translates to:
  /// **'Opens your phone gallery'**
  String get opensPhoneGallery;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneNumberOptional;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @financialSetup.
  ///
  /// In en, this message translates to:
  /// **'Financial setup'**
  String get financialSetup;

  /// No description provided for @financialSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the money settings Bizoot should use across your dashboard, insights, and reminders.'**
  String get financialSetupSubtitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyAutoSelected.
  ///
  /// In en, this message translates to:
  /// **'Automatically selected from your chosen country.'**
  String get currencyAutoSelected;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get monthlyIncome;

  /// No description provided for @monthlyIncomeHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional but recommended for Health Score and safe-to-spend.'**
  String get monthlyIncomeHelper;

  /// No description provided for @mainFinancialGoal.
  ///
  /// In en, this message translates to:
  /// **'Main financial goal'**
  String get mainFinancialGoal;

  /// No description provided for @estimatedSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Estimated subscriptions'**
  String get estimatedSubscriptions;

  /// No description provided for @estimatedSubscriptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} subscriptions'**
  String estimatedSubscriptionsLabel(int count);

  /// No description provided for @goalSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save money'**
  String get goalSaveMoney;

  /// No description provided for @goalTrackBills.
  ///
  /// In en, this message translates to:
  /// **'Track bills'**
  String get goalTrackBills;

  /// No description provided for @goalAvoidSurpriseCharges.
  ///
  /// In en, this message translates to:
  /// **'Avoid surprise charges'**
  String get goalAvoidSurpriseCharges;

  /// No description provided for @goalCancelUnusedSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Cancel unused subscriptions'**
  String get goalCancelUnusedSubscriptions;

  /// No description provided for @settingsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Saving your latest Bizoot changes...'**
  String get settingsSyncing;

  /// No description provided for @settingsOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Your changes stay safe and will continue when you are back online.'**
  String get settingsOffline;

  /// No description provided for @settingsPendingChanges.
  ///
  /// In en, this message translates to:
  /// **'A few recent changes are still being saved.'**
  String get settingsPendingChanges;

  /// No description provided for @settingsReady.
  ///
  /// In en, this message translates to:
  /// **'Your account, reminders, privacy, and support settings live here.'**
  String get settingsReady;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language Bizoot should use across the app.'**
  String get languageDescription;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageDanish.
  ///
  /// In en, this message translates to:
  /// **'Dansk'**
  String get languageDanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated.'**
  String get languageUpdated;

  /// No description provided for @notificationPreferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences updated.'**
  String get notificationPreferencesUpdated;

  /// No description provided for @notificationPreferencesFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not update your notification preferences right now.'**
  String get notificationPreferencesFailed;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Bizoot?'**
  String get signOutQuestion;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will return to the login screen, and your synced account data will remain attached to your account.'**
  String get signOutBody;

  /// No description provided for @staySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in'**
  String get staySignedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @openPhoneNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone notification settings'**
  String get openPhoneNotificationSettings;

  /// No description provided for @paymentReminders.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get paymentReminders;

  /// No description provided for @paymentRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow and due soon reminders for your active subscriptions.'**
  String get paymentRemindersSubtitle;

  /// No description provided for @weeklySummaries.
  ///
  /// In en, this message translates to:
  /// **'Weekly summaries'**
  String get weeklySummaries;

  /// No description provided for @weeklySummariesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sunday evening summaries for next week\'s renewals and totals.'**
  String get weeklySummariesSubtitle;

  /// No description provided for @trialAlerts.
  ///
  /// In en, this message translates to:
  /// **'Trial alerts'**
  String get trialAlerts;

  /// No description provided for @trialAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warnings before a free trial turns into a paid subscription.'**
  String get trialAlertsSubtitle;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart insights'**
  String get smartInsights;

  /// No description provided for @smartInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Savings nudges, cancellation follow-ups, and recurring-spend warnings.'**
  String get smartInsightsSubtitle;

  /// No description provided for @promotionalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Promotional notifications'**
  String get promotionalNotifications;

  /// No description provided for @promotionalNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional product updates, launch news, and feature announcements.'**
  String get promotionalNotificationsSubtitle;

  /// No description provided for @premiumRequiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'{text} Premium required.'**
  String premiumRequiredSuffix(Object text);

  /// No description provided for @subscriptionPremium.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Premium'**
  String get subscriptionPremium;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlan;

  /// No description provided for @trialStatus.
  ///
  /// In en, this message translates to:
  /// **'Trial status'**
  String get trialStatus;

  /// No description provided for @subscriptionUsage.
  ///
  /// In en, this message translates to:
  /// **'Subscription usage'**
  String get subscriptionUsage;

  /// No description provided for @whatHappensNow.
  ///
  /// In en, this message translates to:
  /// **'What happens now'**
  String get whatHappensNow;

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @planTrial.
  ///
  /// In en, this message translates to:
  /// **'7-day trial'**
  String get planTrial;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @premiumUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Premium unlocked'**
  String get premiumUnlocked;

  /// No description provided for @trialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String trialDaysRemaining(int days);

  /// No description provided for @trialEnded.
  ///
  /// In en, this message translates to:
  /// **'Trial ended'**
  String get trialEnded;

  /// No description provided for @subscriptionsTrackedUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{count} subscriptions tracked • unlimited plan'**
  String subscriptionsTrackedUnlimited(int count);

  /// No description provided for @subscriptionsUsed.
  ///
  /// In en, this message translates to:
  /// **'{count} / {limit} subscriptions used'**
  String subscriptionsUsed(int count, int limit);

  /// No description provided for @premiumActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'You have unlimited subscription tracking and all premium features unlocked.'**
  String get premiumActiveDescription;

  /// No description provided for @trialPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'You have full premium features during trial, with a 5-subscription trial limit.'**
  String get trialPremiumDescription;

  /// No description provided for @freePlanDescription.
  ///
  /// In en, this message translates to:
  /// **'You can keep tracking up to {limit} active subscriptions on this plan.'**
  String freePlanDescription(int limit);

  /// No description provided for @limitReachedDescription.
  ///
  /// In en, this message translates to:
  /// **'Limit reached - upgrade for unlimited tracking.'**
  String get limitReachedDescription;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumFeatureComparison.
  ///
  /// In en, this message translates to:
  /// **'Premium feature comparison'**
  String get premiumFeatureComparison;

  /// No description provided for @premiumCompareFree.
  ///
  /// In en, this message translates to:
  /// **'Free: up to 5 active subscriptions, basic reminders, core tracking'**
  String get premiumCompareFree;

  /// No description provided for @premiumCompareOne.
  ///
  /// In en, this message translates to:
  /// **'Premium: unlimited subscriptions, advanced reports, smart insights'**
  String get premiumCompareOne;

  /// No description provided for @premiumCompareTwo.
  ///
  /// In en, this message translates to:
  /// **'Premium: richer cancellation intelligence, weekly summaries, and deeper insights'**
  String get premiumCompareTwo;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacyAiSettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy & AI Settings'**
  String get privacyAiSettings;

  /// No description provided for @privacyAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control AI insights and review how Bizoot protects sensitive information.'**
  String get privacyAiSubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help, report an issue, or share feedback with the Bizoot team.'**
  String get contactSupportSubtitle;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @savedServices.
  ///
  /// In en, this message translates to:
  /// **'Saved Services'**
  String get savedServices;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @savedServicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No custom services yet'**
  String get savedServicesEmptyTitle;

  /// No description provided for @savedServicesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you create a custom subscription with your own cancellation link, Bizoot will remember it here for faster autofill next time.'**
  String get savedServicesEmptyBody;

  /// No description provided for @savedServiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Saved service updated.'**
  String get savedServiceUpdated;

  /// No description provided for @savedServiceUpdatedFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not update that saved service right now.'**
  String get savedServiceUpdatedFailed;

  /// No description provided for @editSavedService.
  ///
  /// In en, this message translates to:
  /// **'Edit saved service'**
  String get editSavedService;

  /// No description provided for @deleteSavedService.
  ///
  /// In en, this message translates to:
  /// **'Delete saved service'**
  String get deleteSavedService;

  /// No description provided for @cancellationUrl.
  ///
  /// In en, this message translates to:
  /// **'Cancellation URL'**
  String get cancellationUrl;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteSavedServiceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete saved service?'**
  String get deleteSavedServiceQuestion;

  /// No description provided for @deleteSavedServiceBody.
  ///
  /// In en, this message translates to:
  /// **'Bizoot will forget {serviceName} and stop suggesting it from your custom list.'**
  String deleteSavedServiceBody(Object serviceName);

  /// No description provided for @savedServiceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Saved service deleted.'**
  String get savedServiceDeleted;

  /// No description provided for @savedServiceDeletedFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not delete that saved service right now.'**
  String get savedServiceDeletedFailed;

  /// No description provided for @noSavedCancellationUrl.
  ///
  /// In en, this message translates to:
  /// **'No saved cancellation URL yet.'**
  String get noSavedCancellationUrl;

  /// No description provided for @usedTimes.
  ///
  /// In en, this message translates to:
  /// **'Used {count} times'**
  String usedTimes(int count);

  /// No description provided for @debugLocalization.
  ///
  /// In en, this message translates to:
  /// **'Localization Debug'**
  String get debugLocalization;

  /// No description provided for @currentLocale.
  ///
  /// In en, this message translates to:
  /// **'Current locale'**
  String get currentLocale;

  /// No description provided for @supportedLocalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Supported locales'**
  String get supportedLocalesLabel;

  /// No description provided for @fallbackBehavior.
  ///
  /// In en, this message translates to:
  /// **'Fallback behavior'**
  String get fallbackBehavior;

  /// No description provided for @fallbackBehaviorValue.
  ///
  /// In en, this message translates to:
  /// **'Unsupported device locales fall back to English.'**
  String get fallbackBehaviorValue;

  /// No description provided for @missingTranslationFallbackCount.
  ///
  /// In en, this message translates to:
  /// **'Missing translation fallback count'**
  String get missingTranslationFallbackCount;

  /// No description provided for @premiumTooltip.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
