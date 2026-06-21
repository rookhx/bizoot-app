// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Bizoot';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get calendar => 'Kalender';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String get reports => 'Berichte';

  @override
  String get settings => 'Einstellungen';

  @override
  String get premium => 'Premium';

  @override
  String get authWelcomeBack => 'Willkommen zurück';

  @override
  String get authCreateAccount => 'Erstelle dein Bizoot-Konto';

  @override
  String get authWelcomeSubtitle =>
      'Melde dich an, um zu sehen, was deine Fixkosten wirklich mit deinem Monat machen.';

  @override
  String get authCreateSubtitle =>
      'Erstelle dein Konto und bringe jede wiederkehrende Zahlung in ein Premium-Kontrollzentrum.';

  @override
  String get authHero =>
      'Verschwende kein Geld mehr für vergessene Abonnements.';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get logIn => 'Anmelden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get enterEmailPassword =>
      'Gib sowohl deine E-Mail als auch dein Passwort ein, um fortzufahren.';

  @override
  String get alreadyHaveAccount => 'Du hast bereits ein Konto? Anmelden';

  @override
  String get needAccount => 'Du brauchst ein Konto? Registrieren';

  @override
  String onboardingStep(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get back => 'Zurück';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get finishSetup => 'Einrichtung abschließen';

  @override
  String get finishingSetup => 'Einrichtung wird abgeschlossen...';

  @override
  String get fullNameAndCountryRequired =>
      'Vollständiger Name und Land sind erforderlich.';

  @override
  String get validCountryRequired =>
      'Bitte wähle ein gültiges Land aus der Liste.';

  @override
  String get profileSetup => 'Profileinrichtung';

  @override
  String get profileSetupSubtitle =>
      'Lass uns Bizoot personalisieren, bevor wir deine wiederkehrenden Ausgaben verfolgen.';

  @override
  String get tapChooseProfilePicture => 'Tippe, um ein Profilbild auszuwählen';

  @override
  String get profilePictureSelected => 'Profilbild ausgewählt';

  @override
  String get opensPhoneGallery => 'Öffnet deine Handy-Galerie';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get phoneNumberOptional => 'Telefonnummer (optional)';

  @override
  String get country => 'Land';

  @override
  String get financialSetup => 'Finanzeinrichtung';

  @override
  String get financialSetupSubtitle =>
      'Wähle die Geldeinstellungen, die Bizoot für dein Dashboard, deine Insights und Erinnerungen verwenden soll.';

  @override
  String get currency => 'Währung';

  @override
  String get currencyAutoSelected =>
      'Wird automatisch basierend auf deinem gewählten Land ausgewählt.';

  @override
  String get monthlyIncome => 'Monatliches Einkommen';

  @override
  String get monthlyIncomeHelper =>
      'Optional, aber empfohlen für Health Score und sicher auszugeben.';

  @override
  String get mainFinancialGoal => 'Wichtigstes Finanzziel';

  @override
  String get estimatedSubscriptions => 'Geschätzte Abonnements';

  @override
  String estimatedSubscriptionsLabel(int count) {
    return '$count Abonnements';
  }

  @override
  String get goalSaveMoney => 'Geld sparen';

  @override
  String get goalTrackBills => 'Rechnungen verfolgen';

  @override
  String get goalAvoidSurpriseCharges => 'Überraschende Gebühren vermeiden';

  @override
  String get goalCancelUnusedSubscriptions => 'Ungenutzte Abonnements kündigen';

  @override
  String get settingsSyncing =>
      'Deine neuesten Bizoot-Änderungen werden gespeichert...';

  @override
  String get settingsOffline =>
      'Offline-Modus aktiv. Deine Änderungen bleiben sicher und werden fortgesetzt, sobald du wieder online bist.';

  @override
  String get settingsPendingChanges =>
      'Einige aktuelle Änderungen werden noch gespeichert.';

  @override
  String get settingsReady =>
      'Deine Konto-, Erinnerungs-, Datenschutz- und Support-Einstellungen findest du hier.';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageDescription =>
      'Wähle die Sprache, die Bizoot in der gesamten App verwenden soll.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageUpdated => 'Sprache aktualisiert.';

  @override
  String get notificationPreferencesUpdated =>
      'Benachrichtigungseinstellungen aktualisiert.';

  @override
  String get notificationPreferencesFailed =>
      'Wir konnten deine Benachrichtigungseinstellungen gerade nicht aktualisieren.';

  @override
  String get signOutQuestion => 'Von Bizoot abmelden?';

  @override
  String get signOutBody =>
      'Du kehrst zum Anmeldebildschirm zurück, und deine synchronisierten Kontodaten bleiben mit deinem Konto verknüpft.';

  @override
  String get staySignedIn => 'Angemeldet bleiben';

  @override
  String get signOut => 'Abmelden';

  @override
  String get openPhoneNotificationSettings =>
      'Benachrichtigungseinstellungen des Telefons öffnen';

  @override
  String get paymentReminders => 'Zahlungserinnerungen';

  @override
  String get paymentRemindersSubtitle =>
      'Erinnerungen für aktive Abonnements, die morgen oder bald fällig sind.';

  @override
  String get weeklySummaries => 'Wöchentliche Zusammenfassungen';

  @override
  String get weeklySummariesSubtitle =>
      'Zusammenfassungen am Sonntagabend für Verlängerungen und Summen der nächsten Woche.';

  @override
  String get trialAlerts => 'Testphasen-Warnungen';

  @override
  String get trialAlertsSubtitle =>
      'Warnungen, bevor aus einer kostenlosen Testphase ein bezahltes Abonnement wird.';

  @override
  String get smartInsights => 'Smart Insights';

  @override
  String get smartInsightsSubtitle =>
      'Spartipps, Kündigungs-Follow-ups und Warnungen zu wiederkehrenden Ausgaben.';

  @override
  String get promotionalNotifications => 'Werbliche Benachrichtigungen';

  @override
  String get promotionalNotificationsSubtitle =>
      'Optionale Produktupdates, Launch-News und Funktionsankündigungen.';

  @override
  String premiumRequiredSuffix(Object text) {
    return '$text Premium erforderlich.';
  }

  @override
  String get subscriptionPremium => 'Abo & Premium';

  @override
  String get currentPlan => 'Aktueller Plan';

  @override
  String get trialStatus => 'Teststatus';

  @override
  String get subscriptionUsage => 'Abo-Nutzung';

  @override
  String get whatHappensNow => 'Was jetzt passiert';

  @override
  String get planPremium => 'Premium';

  @override
  String get planTrial => '7-Tage-Testversion';

  @override
  String get planFree => 'Kostenlos';

  @override
  String get premiumUnlocked => 'Premium freigeschaltet';

  @override
  String trialDaysRemaining(int days) {
    return '$days Tage verbleibend';
  }

  @override
  String get trialEnded => 'Testphase beendet';

  @override
  String subscriptionsTrackedUnlimited(int count) {
    return '$count Abonnements verfolgt • unbegrenzter Plan';
  }

  @override
  String subscriptionsUsed(int count, int limit) {
    return '$count / $limit Abonnements verwendet';
  }

  @override
  String get premiumActiveDescription =>
      'Du hast unbegrenztes Abo-Tracking und alle Premium-Funktionen freigeschaltet.';

  @override
  String get trialPremiumDescription =>
      'Während der Testphase stehen dir alle Premium-Funktionen mit einem Limit von 5 Abonnements zur Verfügung.';

  @override
  String freePlanDescription(int limit) {
    return 'Du kannst in diesem Tarif bis zu $limit aktive Abonnements verfolgen.';
  }

  @override
  String get limitReachedDescription =>
      'Limit erreicht – Upgrade für unbegrenztes Tracking.';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get premiumFeatureComparison => 'Premium-Funktionsvergleich';

  @override
  String get premiumCompareFree =>
      'Kostenlos: bis zu 5 aktive Abonnements, grundlegende Erinnerungen und Kern-Tracking';

  @override
  String get premiumCompareOne =>
      'Premium: unbegrenzte Abonnements, erweiterte Berichte und Smart Insights';

  @override
  String get premiumCompareTwo =>
      'Premium: bessere Kündigungs-Intelligenz, wöchentliche Zusammenfassungen und tiefere Insights';

  @override
  String get privacySecurity => 'Datenschutz & Sicherheit';

  @override
  String get privacyAiSettings => 'Datenschutz- & KI-Einstellungen';

  @override
  String get privacyAiSubtitle =>
      'Steuere KI-Insights und überprüfe, wie Bizoot sensible Informationen schützt.';

  @override
  String get support => 'Support';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get contactSupportSubtitle =>
      'Hole dir Hilfe, melde ein Problem oder teile Feedback mit dem Bizoot-Team.';

  @override
  String get legal => 'Rechtliches';

  @override
  String get savedServices => 'Gespeicherte Dienste';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get logout => 'Abmelden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get savedServicesEmptyTitle =>
      'Noch keine benutzerdefinierten Dienste';

  @override
  String get savedServicesEmptyBody =>
      'Wenn du ein benutzerdefiniertes Abonnement mit deinem eigenen Kündigungslink erstellst, merkt sich Bizoot es hier für schnelleres Autofill beim nächsten Mal.';

  @override
  String get savedServiceUpdated => 'Gespeicherter Dienst aktualisiert.';

  @override
  String get savedServiceUpdatedFailed =>
      'Wir konnten den gespeicherten Dienst gerade nicht aktualisieren.';

  @override
  String get editSavedService => 'Gespeicherten Dienst bearbeiten';

  @override
  String get deleteSavedService => 'Gespeicherten Dienst löschen';

  @override
  String get cancellationUrl => 'Kündigungs-URL';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get deleteSavedServiceQuestion => 'Gespeicherten Dienst löschen?';

  @override
  String deleteSavedServiceBody(Object serviceName) {
    return 'Bizoot wird $serviceName vergessen und den Dienst nicht mehr aus deiner benutzerdefinierten Liste vorschlagen.';
  }

  @override
  String get savedServiceDeleted => 'Gespeicherter Dienst gelöscht.';

  @override
  String get savedServiceDeletedFailed =>
      'Wir konnten den gespeicherten Dienst gerade nicht löschen.';

  @override
  String get noSavedCancellationUrl =>
      'Noch keine gespeicherte Kündigungs-URL.';

  @override
  String usedTimes(int count) {
    return '$count Mal verwendet';
  }

  @override
  String get debugLocalization => 'Lokalisierungs-Debug';

  @override
  String get currentLocale => 'Aktuelle Locale';

  @override
  String get supportedLocalesLabel => 'Unterstützte Locales';

  @override
  String get fallbackBehavior => 'Fallback-Verhalten';

  @override
  String get fallbackBehaviorValue =>
      'Nicht unterstützte Gerätesprachen fallen auf Englisch zurück.';

  @override
  String get missingTranslationFallbackCount =>
      'Fallback-Anzahl für fehlende Übersetzungen';

  @override
  String get premiumTooltip => 'Premium';
}
