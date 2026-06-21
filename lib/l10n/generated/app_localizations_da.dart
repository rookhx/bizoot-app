// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appName => 'Bizoot';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get calendar => 'Kalender';

  @override
  String get subscriptions => 'Abonnementer';

  @override
  String get reports => 'Rapporter';

  @override
  String get settings => 'Indstillinger';

  @override
  String get premium => 'Premium';

  @override
  String get authWelcomeBack => 'Velkommen tilbage';

  @override
  String get authCreateAccount => 'Opret din Bizoot-konto';

  @override
  String get authWelcomeSubtitle =>
      'Log ind for at se, hvad dine faste udgifter virkelig gør ved din måned.';

  @override
  String get authCreateSubtitle =>
      'Opret din konto og saml alle tilbagevendende betalinger i ét premium kontrolcenter.';

  @override
  String get authHero => 'Stop med at spilde penge på glemte abonnementer.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Adgangskode';

  @override
  String get logIn => 'Log ind';

  @override
  String get createAccount => 'Opret konto';

  @override
  String get enterEmailPassword =>
      'Indtast både e-mail og adgangskode for at fortsætte.';

  @override
  String get alreadyHaveAccount => 'Har du allerede en konto? Log ind';

  @override
  String get needAccount => 'Har du brug for en konto? Tilmeld dig';

  @override
  String onboardingStep(int current, int total) {
    return 'Trin $current af $total';
  }

  @override
  String get back => 'Tilbage';

  @override
  String get continueLabel => 'Fortsæt';

  @override
  String get finishSetup => 'Fuldfør opsætning';

  @override
  String get finishingSetup => 'Fuldfører opsætning...';

  @override
  String get fullNameAndCountryRequired => 'Fulde navn og land er påkrævet.';

  @override
  String get validCountryRequired => 'Vælg et gyldigt land fra listen.';

  @override
  String get profileSetup => 'Profilopsætning';

  @override
  String get profileSetupSubtitle =>
      'Lad os tilpasse Bizoot, før vi begynder at spore dine tilbagevendende udgifter.';

  @override
  String get tapChooseProfilePicture => 'Tryk for at vælge et profilbillede';

  @override
  String get profilePictureSelected => 'Profilbillede valgt';

  @override
  String get opensPhoneGallery => 'Åbner dit telefongalleri';

  @override
  String get fullName => 'Fulde navn';

  @override
  String get phoneNumberOptional => 'Telefonnummer (valgfrit)';

  @override
  String get country => 'Land';

  @override
  String get financialSetup => 'Finansiel opsætning';

  @override
  String get financialSetupSubtitle =>
      'Vælg de pengeindstillinger, Bizoot skal bruge på tværs af dashboard, indsigter og påmindelser.';

  @override
  String get currency => 'Valuta';

  @override
  String get currencyAutoSelected =>
      'Vælges automatisk ud fra dit valgte land.';

  @override
  String get monthlyIncome => 'Månedlig indkomst';

  @override
  String get monthlyIncomeHelper =>
      'Valgfrit, men anbefalet for Health Score og sikkert forbrug.';

  @override
  String get mainFinancialGoal => 'Primært økonomisk mål';

  @override
  String get estimatedSubscriptions => 'Estimerede abonnementer';

  @override
  String estimatedSubscriptionsLabel(int count) {
    return '$count abonnementer';
  }

  @override
  String get goalSaveMoney => 'Spar penge';

  @override
  String get goalTrackBills => 'Spor regninger';

  @override
  String get goalAvoidSurpriseCharges => 'Undgå overraskende opkrævninger';

  @override
  String get goalCancelUnusedSubscriptions => 'Opsig ubrugte abonnementer';

  @override
  String get settingsSyncing => 'Gemmer dine seneste Bizoot-ændringer...';

  @override
  String get settingsOffline =>
      'Offline-tilstand er aktiv. Dine ændringer er sikre og fortsætter, når du er online igen.';

  @override
  String get settingsPendingChanges =>
      'Nogle nylige ændringer bliver stadig gemt.';

  @override
  String get settingsReady =>
      'Dine konto-, påmindelses-, privatlivs- og supportindstillinger findes her.';

  @override
  String get notifications => 'Notifikationer';

  @override
  String get language => 'Sprog';

  @override
  String get languageDescription =>
      'Vælg det sprog Bizoot skal bruge i hele appen.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageUpdated => 'Sprog opdateret.';

  @override
  String get notificationPreferencesUpdated =>
      'Notifikationsindstillinger opdateret.';

  @override
  String get notificationPreferencesFailed =>
      'Vi kunne ikke opdatere dine notifikationsindstillinger lige nu.';

  @override
  String get signOutQuestion => 'Log ud af Bizoot?';

  @override
  String get signOutBody =>
      'Du vender tilbage til login-skærmen, og dine synkroniserede kontodata forbliver knyttet til din konto.';

  @override
  String get staySignedIn => 'Forbliv logget ind';

  @override
  String get signOut => 'Log ud';

  @override
  String get openPhoneNotificationSettings =>
      'Åbn telefonens notifikationsindstillinger';

  @override
  String get paymentReminders => 'Betalingspåmindelser';

  @override
  String get paymentRemindersSubtitle =>
      'Påmindelser om betaling i morgen og snart for dine aktive abonnementer.';

  @override
  String get weeklySummaries => 'Ugentlige oversigter';

  @override
  String get weeklySummariesSubtitle =>
      'Søndag aften-oversigter over næste uges fornyelser og totaler.';

  @override
  String get trialAlerts => 'Prøveperiode-advarsler';

  @override
  String get trialAlertsSubtitle =>
      'Advarsler før en gratis prøveperiode bliver til et betalt abonnement.';

  @override
  String get smartInsights => 'Smarte indsigter';

  @override
  String get smartInsightsSubtitle =>
      'Sparenudges, opsigelsesopfølgninger og advarsler om tilbagevendende forbrug.';

  @override
  String get promotionalNotifications => 'Promotionsnotifikationer';

  @override
  String get promotionalNotificationsSubtitle =>
      'Valgfrie produktopdateringer, lanceringsnyt og funktionsannonceringer.';

  @override
  String premiumRequiredSuffix(Object text) {
    return '$text Premium kræves.';
  }

  @override
  String get subscriptionPremium => 'Abonnement & Premium';

  @override
  String get currentPlan => 'Nuværende plan';

  @override
  String get trialStatus => 'Prøvestatus';

  @override
  String get subscriptionUsage => 'Abonnementsforbrug';

  @override
  String get whatHappensNow => 'Hvad sker der nu';

  @override
  String get planPremium => 'Premium';

  @override
  String get planTrial => '7-dages prøveperiode';

  @override
  String get planFree => 'Gratis';

  @override
  String get premiumUnlocked => 'Premium låst op';

  @override
  String trialDaysRemaining(int days) {
    return '$days dage tilbage';
  }

  @override
  String get trialEnded => 'Prøveperiode slut';

  @override
  String subscriptionsTrackedUnlimited(int count) {
    return '$count abonnementer sporet • ubegrænset plan';
  }

  @override
  String subscriptionsUsed(int count, int limit) {
    return '$count / $limit abonnementer brugt';
  }

  @override
  String get premiumActiveDescription =>
      'Du har ubegrænset abonnementssporing og alle premiumfunktioner låst op.';

  @override
  String get trialPremiumDescription =>
      'Du har fulde premiumfunktioner under prøveperioden med en grænse på 5 abonnementer.';

  @override
  String freePlanDescription(int limit) {
    return 'Du kan fortsætte med at spore op til $limit aktive abonnementer på denne plan.';
  }

  @override
  String get limitReachedDescription =>
      'Grænse nået - opgrader for ubegrænset sporing.';

  @override
  String get upgradeToPremium => 'Opgrader til Premium';

  @override
  String get premiumFeatureComparison => 'Sammenligning af premiumfunktioner';

  @override
  String get premiumCompareFree =>
      'Gratis: op til 5 aktive abonnementer, grundlæggende påmindelser, kernesporing';

  @override
  String get premiumCompareOne =>
      'Premium: ubegrænsede abonnementer, avancerede rapporter, smarte indsigter';

  @override
  String get premiumCompareTwo =>
      'Premium: rigere opsigelsesintelligens, ugentlige oversigter og dybere indsigter';

  @override
  String get privacySecurity => 'Privatliv & sikkerhed';

  @override
  String get privacyAiSettings => 'Privatlivs- & AI-indstillinger';

  @override
  String get privacyAiSubtitle =>
      'Styr AI-indsigter og se, hvordan Bizoot beskytter følsomme oplysninger.';

  @override
  String get support => 'Support';

  @override
  String get contactSupport => 'Kontakt support';

  @override
  String get contactSupportSubtitle =>
      'Få hjælp, rapportér et problem, eller del feedback med Bizoot-teamet.';

  @override
  String get legal => 'Juridisk';

  @override
  String get savedServices => 'Gemte tjenester';

  @override
  String get dangerZone => 'Farezone';

  @override
  String get logout => 'Log ud';

  @override
  String get deleteAccount => 'Slet konto';

  @override
  String get savedServicesEmptyTitle =>
      'Ingen brugerdefinerede tjenester endnu';

  @override
  String get savedServicesEmptyBody =>
      'Når du opretter et brugerdefineret abonnement med dit eget opsigelseslink, husker Bizoot det her for hurtigere autofyld næste gang.';

  @override
  String get savedServiceUpdated => 'Gemt tjeneste opdateret.';

  @override
  String get savedServiceUpdatedFailed =>
      'Vi kunne ikke opdatere den gemte tjeneste lige nu.';

  @override
  String get editSavedService => 'Rediger gemt tjeneste';

  @override
  String get deleteSavedService => 'Slet gemt tjeneste';

  @override
  String get cancellationUrl => 'Opsigelses-URL';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get deleteSavedServiceQuestion => 'Slet gemt tjeneste?';

  @override
  String deleteSavedServiceBody(Object serviceName) {
    return 'Bizoot vil glemme $serviceName og stoppe med at foreslå den fra din brugerdefinerede liste.';
  }

  @override
  String get savedServiceDeleted => 'Gemt tjeneste slettet.';

  @override
  String get savedServiceDeletedFailed =>
      'Vi kunne ikke slette den gemte tjeneste lige nu.';

  @override
  String get noSavedCancellationUrl => 'Ingen gemt opsigelses-URL endnu.';

  @override
  String usedTimes(int count) {
    return 'Brugt $count gange';
  }

  @override
  String get debugLocalization => 'Lokaliseringsdebug';

  @override
  String get currentLocale => 'Aktuelt sprog';

  @override
  String get supportedLocalesLabel => 'Understøttede sprog';

  @override
  String get fallbackBehavior => 'Fallback-adfærd';

  @override
  String get fallbackBehaviorValue =>
      'Ikke-understøttede enhedssprog falder tilbage til engelsk.';

  @override
  String get missingTranslationFallbackCount =>
      'Antal fallback for manglende oversættelser';

  @override
  String get premiumTooltip => 'Premium';
}
