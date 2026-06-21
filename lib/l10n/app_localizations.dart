import 'package:flutter/material.dart';

import 'localized_text_sanitizer.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _strings = {
    'en': {
      'dashboard': 'Dashboard',
      'calendar': 'Calendar',
      'subscriptions': 'Subscriptions',
      'reports': 'Reports',
      'settings': 'Settings',
      'premiumTooltip': 'Premium',
      'authWelcomeBack': 'Welcome back',
      'authCreateAccount': 'Create your Bizoot account',
      'authWelcomeSubtitle':
          'Log in to see what your fixed costs are really doing to your month.',
      'authCreateSubtitle':
          'Create your account and bring every recurring charge into one premium control center.',
      'authHero': 'Stop wasting money on forgotten subscriptions.',
      'email': 'Email',
      'password': 'Password',
      'logIn': 'Log in',
      'createAccount': 'Create account',
      'enterEmailPassword': 'Enter both your email and password to continue.',
      'alreadyHaveAccount': 'Already have an account? Log in',
      'needAccount': 'Need an account? Sign up',
      'back': 'Back',
      'continueLabel': 'Continue',
      'finishSetup': 'Finish setup',
      'finishingSetup': 'Finishing setup...',
      'fullNameAndCountryRequired': 'Full name and country are required.',
      'validCountryRequired': 'Please select a valid country from the list.',
      'profileSetup': 'Profile setup',
      'profileSetupSubtitle':
          "Let's personalize Bizoot before we start tracking your recurring spending.",
      'tapChooseProfilePicture': 'Tap to choose a profile picture',
      'profilePictureSelected': 'Profile picture selected',
      'opensPhoneGallery': 'Opens your phone gallery',
      'fullName': 'Full name',
      'phoneNumberOptional': 'Phone number (optional)',
      'country': 'Country',
      'financialSetup': 'Financial setup',
      'financialSetupSubtitle':
          'Choose the money settings Bizoot should use across your dashboard, insights, and reminders.',
      'currency': 'Currency',
      'currencyAutoSelected':
          'Automatically selected from your chosen country.',
      'monthlyIncome': 'Monthly income',
      'monthlyIncomeHelper':
          'Optional but recommended for Health Score and safe-to-spend.',
      'mainFinancialGoal': 'Main financial goal',
      'estimatedSubscriptions': 'Estimated subscriptions',
      'estimatedSubscriptionsLabel': '{count} subscriptions',
      'goalSaveMoney': 'Save money',
      'goalTrackBills': 'Track bills',
      'goalAvoidSurpriseCharges': 'Avoid surprise charges',
      'goalCancelUnusedSubscriptions': 'Cancel unused subscriptions',
      'settingsSyncing': 'Saving your latest Bizoot changes...',
      'settingsOffline':
          'Offline mode active. Your changes stay safe and will continue when you are back online.',
      'settingsPendingChanges': 'A few recent changes are still being saved.',
      'settingsReady':
          'Your account, reminders, privacy, and support settings live here.',
      'notifications': 'Notifications',
      'language': 'Language',
      'languageDescription':
          'Choose the language Bizoot should use across the app.',
      'languageEnglish': 'English',
      'languageDanish': 'Dansk',
      'languageGerman': 'Deutsch',
      'languageSpanish': 'Español',
      'languageUpdated': 'Language updated.',
      'notificationPreferencesUpdated': 'Notification preferences updated.',
      'notificationPreferencesFailed':
          'We could not update your notification preferences right now.',
      'signOutQuestion': 'Sign out of Bizoot?',
      'signOutBody':
          'You will return to the login screen, and your synced account data will remain attached to your account.',
      'staySignedIn': 'Stay signed in',
      'signOut': 'Sign out',
      'openPhoneNotificationSettings': 'Open phone notification settings',
      'paymentReminders': 'Payment reminders',
      'paymentRemindersSubtitle':
          'Due tomorrow and due soon reminders for your active subscriptions.',
      'weeklySummaries': 'Weekly summaries',
      'weeklySummariesSubtitle':
          "Sunday evening summaries for next week's renewals and totals.",
      'trialAlerts': 'Trial alerts',
      'trialAlertsSubtitle':
          'Warnings before a free trial turns into a paid subscription.',
      'smartInsights': 'Smart insights',
      'smartInsightsSubtitle':
          'Savings nudges, cancellation follow-ups, and recurring-spend warnings.',
      'promotionalNotifications': 'Promotional notifications',
      'promotionalNotificationsSubtitle':
          'Optional product updates, launch news, and feature announcements.',
      'subscriptionPremium': 'Subscription & Premium',
      'currentPlan': 'Current plan',
      'trialStatus': 'Trial status',
      'subscriptionUsage': 'Subscription usage',
      'whatHappensNow': 'What happens now',
      'planPremium': 'Premium',
      'planTrial': '7-day trial',
      'planFree': 'Free',
      'premiumUnlocked': 'Premium unlocked',
      'trialEnded': 'Trial ended',
      'trialDaysRemaining': '{days} days remaining',
      'subscriptionsTrackedUnlimited': '{count} subscriptions tracked',
      'subscriptionsUsed': '{count} / {limit} subscriptions used',
      'freePlanDescription':
          'Free plan active with room for up to {limit} active subscriptions.',
      'premiumActiveDescription':
          'You have unlimited subscription tracking and all premium features unlocked.',
      'trialPremiumDescription':
          'You have full premium features during trial, with a 5-subscription trial limit.',
      'limitReachedDescription':
          'Limit reached - upgrade for unlimited tracking.',
      'upgradeToPremium': 'Upgrade to Premium',
      'premiumFeatureComparison': 'Premium feature comparison',
      'premiumCompareFree':
          'Free: up to 5 active subscriptions, basic reminders, core tracking',
      'premiumCompareOne':
          'Premium: unlimited subscriptions, advanced reports, smart insights',
      'premiumCompareTwo':
          'Premium: richer cancellation intelligence, weekly summaries, and deeper insights',
      'privacySecurity': 'Privacy & Security',
      'privacyAiSettings': 'Privacy & AI Settings',
      'privacyAiSubtitle':
          'Control AI insights and review how Bizoot protects sensitive information.',
      'support': 'Support',
      'contactSupport': 'Contact Support',
      'contactSupportSubtitle':
          'Get help, report an issue, or share feedback with the Bizoot team.',
      'legal': 'Legal',
      'savedServices': 'Saved Services',
      'dangerZone': 'Danger Zone',
      'logout': 'Logout',
      'deleteAccount': 'Delete Account',
      'savedServicesEmptyTitle': 'No custom services yet',
      'savedServicesEmptyBody':
          'When you create a custom subscription with your own cancellation link, Bizoot will remember it here for faster autofill next time.',
      'savedServiceUpdated': 'Saved service updated.',
      'savedServiceUpdatedFailed':
          'We could not update that saved service right now.',
      'editSavedService': 'Edit saved service',
      'deleteSavedService': 'Delete saved service',
      'cancellationUrl': 'Cancellation URL',
      'cancel': 'Cancel',
      'save': 'Save',
      'deleteSavedServiceQuestion': 'Delete saved service?',
      'savedServiceDeleted': 'Saved service deleted.',
      'savedServiceDeletedFailed':
          'We could not delete that saved service right now.',
      'noSavedCancellationUrl': 'No saved cancellation URL yet.',
      'debugLocalization': 'Localization Debug',
      'currentLocale': 'Current locale',
      'supportedLocalesLabel': 'Supported locales',
      'fallbackBehavior': 'Fallback behavior',
      'fallbackBehaviorValue':
          'Unsupported device locales fall back to English.',
      'missingTranslationFallbackCount': 'Missing translation fallback count',
    },
    'da': {
      'dashboard': 'Dashboard',
      'calendar': 'Kalender',
      'subscriptions': 'Abonnementer',
      'reports': 'Rapporter',
      'settings': 'Indstillinger',
      'premiumTooltip': 'Premium',
      'authWelcomeBack': 'Velkommen tilbage',
      'authCreateAccount': 'Opret din Bizoot-konto',
      'authWelcomeSubtitle':
          'Log ind for at se, hvad dine faste udgifter faktisk gør ved din måned.',
      'authCreateSubtitle':
          'Opret din konto, og saml alle tilbagevendende udgifter i ét premium kontrolcenter.',
      'authHero': 'Stop med at spilde penge på glemte abonnementer.',
      'email': 'E-mail',
      'password': 'Adgangskode',
      'logIn': 'Log ind',
      'createAccount': 'Opret konto',
      'enterEmailPassword':
          'Indtast både e-mail og adgangskode for at fortsætte.',
      'alreadyHaveAccount': 'Har du allerede en konto? Log ind',
      'needAccount': 'Har du brug for en konto? Tilmeld dig',
      'back': 'Tilbage',
      'continueLabel': 'Fortsæt',
      'finishSetup': 'Afslut opsætning',
      'finishingSetup': 'Afslutter opsætning...',
      'fullNameAndCountryRequired': 'Fulde navn og land er påkrævet.',
      'validCountryRequired': 'Vælg venligst et gyldigt land fra listen.',
      'profileSetup': 'Profilopsætning',
      'profileSetupSubtitle':
          'Lad os tilpasse Bizoot, før vi begynder at spore dine tilbagevendende udgifter.',
      'tapChooseProfilePicture': 'Tryk for at vælge et profilbillede',
      'profilePictureSelected': 'Profilbillede valgt',
      'opensPhoneGallery': 'Åbner dit telefongalleri',
      'fullName': 'Fulde navn',
      'phoneNumberOptional': 'Telefonnummer (valgfrit)',
      'country': 'Land',
      'financialSetup': 'Økonomisk opsætning',
      'financialSetupSubtitle':
          'Vælg de pengeindstillinger, som Bizoot skal bruge på tværs af dit dashboard, indsigt og påmindelser.',
      'currency': 'Valuta',
      'currencyAutoSelected': 'Vælges automatisk ud fra dit valgte land.',
      'monthlyIncome': 'Månedlig indkomst',
      'monthlyIncomeHelper':
          'Valgfrit, men anbefalet til Health Score og sikkert forbrug.',
      'mainFinancialGoal': 'Vigtigste økonomiske mål',
      'estimatedSubscriptions': 'Forventede abonnementer',
      'estimatedSubscriptionsLabel': '{count} abonnementer',
      'goalSaveMoney': 'Spar penge',
      'goalTrackBills': 'Hold styr på regninger',
      'goalAvoidSurpriseCharges': 'Undgå overraskende gebyrer',
      'goalCancelUnusedSubscriptions': 'Opsig ubrugte abonnementer',
      'settingsSyncing': 'Gemmer dine seneste Bizoot-ændringer...',
      'settingsOffline':
          'Offline-tilstand er aktiv. Dine ændringer er sikre og fortsætter, når du er online igen.',
      'settingsPendingChanges': 'Nogle nylige ændringer gemmes stadig.',
      'settingsReady':
          'Dine konto-, påmindelses-, privatlivs- og supportindstillinger er her.',
      'notifications': 'Notifikationer',
      'language': 'Sprog',
      'languageDescription': 'Vælg det sprog, Bizoot skal bruge i hele appen.',
      'languageEnglish': 'English',
      'languageDanish': 'Dansk',
      'languageGerman': 'Deutsch',
      'languageSpanish': 'Español',
      'languageUpdated': 'Sprog opdateret.',
      'notificationPreferencesUpdated': 'Notifikationsindstillinger opdateret.',
      'notificationPreferencesFailed':
          'Vi kunne ikke opdatere dine notifikationsindstillinger lige nu.',
      'signOutQuestion': 'Log ud af Bizoot?',
      'signOutBody':
          'Du vender tilbage til loginskærmen, og dine synkroniserede kontodata forbliver knyttet til din konto.',
      'staySignedIn': 'Forbliv logget ind',
      'signOut': 'Log ud',
      'openPhoneNotificationSettings':
          'Åbn telefonens notifikationsindstillinger',
      'paymentReminders': 'Betalingspåmindelser',
      'paymentRemindersSubtitle':
          'Påmindelser om aktive abonnementer, der forfalder i morgen eller snart.',
      'weeklySummaries': 'Ugentlige oversigter',
      'weeklySummariesSubtitle':
          'Søndag aften-oversigter over næste uges fornyelser og totaler.',
      'trialAlerts': 'Prøveperiode-advarsler',
      'trialAlertsSubtitle':
          'Advarsler før en gratis prøveperiode bliver til et betalt abonnement.',
      'smartInsights': 'Smart indsigt',
      'smartInsightsSubtitle':
          'Sparsomhedstips, opfølgningsforslag til opsigelse og advarsler om tilbagevendende udgifter.',
      'promotionalNotifications': 'Promoverende notifikationer',
      'promotionalNotificationsSubtitle':
          'Valgfrie produktopdateringer, nyheder og funktionsannonceringer.',
      'subscriptionPremium': 'Abonnement & Premium',
      'currentPlan': 'Nuværende plan',
      'trialStatus': 'Prøvestatus',
      'subscriptionUsage': 'Abonnementsforbrug',
      'whatHappensNow': 'Hvad sker der nu',
      'planPremium': 'Premium',
      'planTrial': '7-dages prøveperiode',
      'planFree': 'Gratis',
      'premiumUnlocked': 'Premium låst op',
      'trialEnded': 'Prøveperioden er slut',
      'premiumActiveDescription':
          'Du har ubegrænset abonnementssporing og alle premium-funktioner låst op.',
      'trialPremiumDescription':
          'Du har alle premium-funktioner under prøveperioden med en grænse på 5 abonnementer.',
      'limitReachedDescription':
          'Grænse nået – opgrader for ubegrænset sporing.',
      'upgradeToPremium': 'Opgrader til Premium',
      'premiumFeatureComparison': 'Sammenligning af premium-funktioner',
      'premiumCompareFree':
          'Gratis: op til 5 aktive abonnementer, grundlæggende påmindelser og kernesporing',
      'premiumCompareOne':
          'Premium: ubegrænsede abonnementer, avancerede rapporter og smart indsigt',
      'premiumCompareTwo':
          'Premium: bedre opsigelsesintelligens, ugentlige oversigter og dybere indsigt',
      'privacySecurity': 'Privatliv & sikkerhed',
      'privacyAiSettings': 'Privatlivs- og AI-indstillinger',
      'privacyAiSubtitle':
          'Styr AI-indsigt og se, hvordan Bizoot beskytter følsomme oplysninger.',
      'support': 'Support',
      'contactSupport': 'Kontakt support',
      'contactSupportSubtitle':
          'Få hjælp, rapportér et problem eller del feedback med Bizoot-teamet.',
      'legal': 'Juridisk',
      'savedServices': 'Gemte tjenester',
      'dangerZone': 'Farezone',
      'logout': 'Log ud',
      'deleteAccount': 'Slet konto',
      'savedServicesEmptyTitle': 'Ingen brugerdefinerede tjenester endnu',
      'savedServicesEmptyBody':
          'Når du opretter et brugerdefineret abonnement med dit eget opsigelseslink, vil Bizoot huske det her for hurtigere autofuldførelse næste gang.',
      'savedServiceUpdated': 'Gemt tjeneste opdateret.',
      'savedServiceUpdatedFailed':
          'Vi kunne ikke opdatere den gemte tjeneste lige nu.',
      'editSavedService': 'Rediger gemt tjeneste',
      'deleteSavedService': 'Slet gemt tjeneste',
      'cancellationUrl': 'Opsigelses-URL',
      'cancel': 'Annuller',
      'save': 'Gem',
      'deleteSavedServiceQuestion': 'Slet gemt tjeneste?',
      'savedServiceDeleted': 'Gemt tjeneste slettet.',
      'savedServiceDeletedFailed':
          'Vi kunne ikke slette den gemte tjeneste lige nu.',
      'noSavedCancellationUrl': 'Ingen gemt opsigelses-URL endnu.',
      'debugLocalization': 'Lokaliseringsdebug',
      'currentLocale': 'Nuværende lokalitet',
      'supportedLocalesLabel': 'Understøttede lokaliteter',
      'fallbackBehavior': 'Fallback-adfærd',
      'fallbackBehaviorValue':
          'Ikke-understøttede enhedslokaliteter falder tilbage til engelsk.',
      'missingTranslationFallbackCount':
          'Antal fallback for manglende oversættelser',
    },
    'de': {
      'dashboard': 'Dashboard',
      'calendar': 'Kalender',
      'subscriptions': 'Abonnements',
      'reports': 'Berichte',
      'settings': 'Einstellungen',
      'premiumTooltip': 'Premium',
      'authWelcomeBack': 'Willkommen zurück',
      'authCreateAccount': 'Erstelle dein Bizoot-Konto',
      'authWelcomeSubtitle':
          'Melde dich an, um zu sehen, was deine Fixkosten wirklich mit deinem Monat machen.',
      'authCreateSubtitle':
          'Erstelle dein Konto und bringe jede wiederkehrende Zahlung in ein Premium-Kontrollzentrum.',
      'authHero': 'Verschwende kein Geld mehr für vergessene Abonnements.',
      'email': 'E-Mail',
      'password': 'Passwort',
      'logIn': 'Anmelden',
      'createAccount': 'Konto erstellen',
      'enterEmailPassword':
          'Gib sowohl deine E-Mail als auch dein Passwort ein, um fortzufahren.',
      'alreadyHaveAccount': 'Du hast bereits ein Konto? Anmelden',
      'needAccount': 'Du brauchst ein Konto? Registrieren',
      'back': 'Zurück',
      'continueLabel': 'Weiter',
      'finishSetup': 'Einrichtung abschließen',
      'finishingSetup': 'Einrichtung wird abgeschlossen...',
      'fullNameAndCountryRequired':
          'Vollständiger Name und Land sind erforderlich.',
      'validCountryRequired': 'Bitte wähle ein gültiges Land aus der Liste.',
      'profileSetup': 'Profileinrichtung',
      'profileSetupSubtitle':
          'Lass uns Bizoot personalisieren, bevor wir deine wiederkehrenden Ausgaben verfolgen.',
      'tapChooseProfilePicture': 'Tippe, um ein Profilbild auszuwählen',
      'profilePictureSelected': 'Profilbild ausgewählt',
      'opensPhoneGallery': 'Öffnet deine Handy-Galerie',
      'fullName': 'Vollständiger Name',
      'phoneNumberOptional': 'Telefonnummer (optional)',
      'country': 'Land',
      'financialSetup': 'Finanzeinrichtung',
      'financialSetupSubtitle':
          'Wähle die Geldeinstellungen, die Bizoot für dein Dashboard, deine Insights und Erinnerungen verwenden soll.',
      'currency': 'Währung',
      'currencyAutoSelected':
          'Wird automatisch basierend auf deinem gewählten Land ausgewählt.',
      'monthlyIncome': 'Monatliches Einkommen',
      'monthlyIncomeHelper':
          'Optional, aber empfohlen für Health Score und sicher auszugeben.',
      'mainFinancialGoal': 'Wichtigstes Finanzziel',
      'estimatedSubscriptions': 'Geschätzte Abonnements',
      'goalSaveMoney': 'Geld sparen',
      'goalTrackBills': 'Rechnungen verfolgen',
      'goalAvoidSurpriseCharges': 'Überraschende Gebühren vermeiden',
      'goalCancelUnusedSubscriptions': 'Ungenutzte Abonnements kündigen',
      'settingsSyncing':
          'Deine neuesten Bizoot-Änderungen werden gespeichert...',
      'settingsOffline':
          'Offline-Modus aktiv. Deine Änderungen bleiben sicher und werden fortgesetzt, sobald du wieder online bist.',
      'settingsPendingChanges':
          'Einige aktuelle Änderungen werden noch gespeichert.',
      'settingsReady':
          'Deine Konto-, Erinnerungs-, Datenschutz- und Support-Einstellungen findest du hier.',
      'notifications': 'Benachrichtigungen',
      'language': 'Sprache',
      'languageDescription':
          'Wähle die Sprache, die Bizoot in der gesamten App verwenden soll.',
      'languageEnglish': 'English',
      'languageDanish': 'Dansk',
      'languageGerman': 'Deutsch',
      'languageSpanish': 'Español',
      'languageUpdated': 'Sprache aktualisiert.',
      'notificationPreferencesUpdated':
          'Benachrichtigungseinstellungen aktualisiert.',
      'notificationPreferencesFailed':
          'Wir konnten deine Benachrichtigungseinstellungen gerade nicht aktualisieren.',
      'signOutQuestion': 'Von Bizoot abmelden?',
      'signOutBody':
          'Du kehrst zum Anmeldebildschirm zurück, und deine synchronisierten Kontodaten bleiben mit deinem Konto verknüpft.',
      'staySignedIn': 'Angemeldet bleiben',
      'signOut': 'Abmelden',
      'openPhoneNotificationSettings':
          'Benachrichtigungseinstellungen des Telefons öffnen',
      'paymentReminders': 'Zahlungserinnerungen',
      'paymentRemindersSubtitle':
          'Erinnerungen für aktive Abonnements, die morgen oder bald fällig sind.',
      'weeklySummaries': 'Wöchentliche Zusammenfassungen',
      'weeklySummariesSubtitle':
          'Zusammenfassungen am Sonntagabend für Verlängerungen und Summen der nächsten Woche.',
      'trialAlerts': 'Testphasen-Warnungen',
      'trialAlertsSubtitle':
          'Warnungen, bevor aus einer kostenlosen Testphase ein bezahltes Abonnement wird.',
      'smartInsights': 'Smart Insights',
      'smartInsightsSubtitle':
          'Spartipps, Kündigungs-Follow-ups und Warnungen zu wiederkehrenden Ausgaben.',
      'promotionalNotifications': 'Werbliche Benachrichtigungen',
      'promotionalNotificationsSubtitle':
          'Optionale Produktupdates, Launch-News und Funktionsankündigungen.',
      'subscriptionPremium': 'Abo & Premium',
      'currentPlan': 'Aktueller Plan',
      'trialStatus': 'Teststatus',
      'subscriptionUsage': 'Abo-Nutzung',
      'whatHappensNow': 'Was jetzt passiert',
      'planPremium': 'Premium',
      'planTrial': '7-Tage-Testversion',
      'planFree': 'Kostenlos',
      'premiumUnlocked': 'Premium freigeschaltet',
      'trialEnded': 'Testphase beendet',
      'premiumActiveDescription':
          'Du hast unbegrenztes Abo-Tracking und alle Premium-Funktionen freigeschaltet.',
      'trialPremiumDescription':
          'Während der Testphase stehen dir alle Premium-Funktionen mit einem Limit von 5 Abonnements zur Verfügung.',
      'limitReachedDescription':
          'Limit erreicht – Upgrade für unbegrenztes Tracking.',
      'upgradeToPremium': 'Auf Premium upgraden',
      'premiumFeatureComparison': 'Premium-Funktionsvergleich',
      'premiumCompareFree':
          'Kostenlos: bis zu 5 aktive Abonnements, grundlegende Erinnerungen und Kern-Tracking',
      'premiumCompareOne':
          'Premium: unbegrenzte Abonnements, erweiterte Berichte und Smart Insights',
      'premiumCompareTwo':
          'Premium: bessere Kündigungs-Intelligenz, wöchentliche Zusammenfassungen und tiefere Insights',
      'privacySecurity': 'Datenschutz & Sicherheit',
      'privacyAiSettings': 'Datenschutz- & KI-Einstellungen',
      'privacyAiSubtitle':
          'Steuere KI-Insights und überprüfe, wie Bizoot sensible Informationen schützt.',
      'support': 'Support',
      'contactSupport': 'Support kontaktieren',
      'contactSupportSubtitle':
          'Hole dir Hilfe, melde ein Problem oder teile Feedback mit dem Bizoot-Team.',
      'legal': 'Rechtliches',
      'savedServices': 'Gespeicherte Dienste',
      'dangerZone': 'Gefahrenzone',
      'logout': 'Abmelden',
      'deleteAccount': 'Konto löschen',
      'savedServicesEmptyTitle': 'Noch keine benutzerdefinierten Dienste',
      'savedServicesEmptyBody':
          'Wenn du ein benutzerdefiniertes Abonnement mit deinem eigenen Kündigungslink erstellst, merkt sich Bizoot es hier für schnelleres Autofill beim nächsten Mal.',
      'savedServiceUpdated': 'Gespeicherter Dienst aktualisiert.',
      'savedServiceUpdatedFailed':
          'Wir konnten den gespeicherten Dienst gerade nicht aktualisieren.',
      'editSavedService': 'Gespeicherten Dienst bearbeiten',
      'deleteSavedService': 'Gespeicherten Dienst löschen',
      'cancellationUrl': 'Kündigungs-URL',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'deleteSavedServiceQuestion': 'Gespeicherten Dienst löschen?',
      'savedServiceDeleted': 'Gespeicherter Dienst gelöscht.',
      'savedServiceDeletedFailed':
          'Wir konnten den gespeicherten Dienst gerade nicht löschen.',
      'noSavedCancellationUrl': 'Noch keine gespeicherte Kündigungs-URL.',
      'debugLocalization': 'Lokalisierungs-Debug',
      'currentLocale': 'Aktuelle Locale',
      'supportedLocalesLabel': 'Unterstützte Locales',
      'fallbackBehavior': 'Fallback-Verhalten',
      'fallbackBehaviorValue':
          'Nicht unterstützte Gerätesprachen fallen auf Englisch zurück.',
      'missingTranslationFallbackCount':
          'Fallback-Anzahl für fehlende Übersetzungen',
    },
    'es': {
      'dashboard': 'Panel',
      'calendar': 'Calendario',
      'subscriptions': 'Suscripciones',
      'reports': 'Informes',
      'settings': 'Configuración',
      'premiumTooltip': 'Premium',
      'authWelcomeBack': 'Bienvenido de nuevo',
      'authCreateAccount': 'Crea tu cuenta de Bizoot',
      'authWelcomeSubtitle':
          'Inicia sesión para ver lo que tus gastos fijos realmente le hacen a tu mes.',
      'authCreateSubtitle':
          'Crea tu cuenta y reúne cada cargo recurrente en un centro de control premium.',
      'authHero': 'Deja de perder dinero en suscripciones olvidadas.',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'logIn': 'Iniciar sesión',
      'createAccount': 'Crear cuenta',
      'enterEmailPassword':
          'Introduce tu correo y tu contraseña para continuar.',
      'alreadyHaveAccount': '¿Ya tienes una cuenta? Inicia sesión',
      'needAccount': '¿Necesitas una cuenta? Regístrate',
      'back': 'Atrás',
      'continueLabel': 'Continuar',
      'finishSetup': 'Finalizar configuración',
      'finishingSetup': 'Finalizando configuración...',
      'fullNameAndCountryRequired':
          'El nombre completo y el país son obligatorios.',
      'validCountryRequired': 'Selecciona un país válido de la lista.',
      'profileSetup': 'Configuración del perfil',
      'profileSetupSubtitle':
          'Vamos a personalizar Bizoot antes de empezar a seguir tus gastos recurrentes.',
      'tapChooseProfilePicture': 'Toca para elegir una foto de perfil',
      'profilePictureSelected': 'Foto de perfil seleccionada',
      'opensPhoneGallery': 'Abre la galería de tu teléfono',
      'fullName': 'Nombre completo',
      'phoneNumberOptional': 'Número de teléfono (opcional)',
      'country': 'País',
      'financialSetup': 'Configuración financiera',
      'financialSetupSubtitle':
          'Elige la configuración monetaria que Bizoot debe usar en tu panel, insights y recordatorios.',
      'currency': 'Moneda',
      'currencyAutoSelected':
          'Se selecciona automáticamente según el país que elijas.',
      'monthlyIncome': 'Ingresos mensuales',
      'monthlyIncomeHelper':
          'Opcional, pero recomendable para Health Score y gasto seguro.',
      'mainFinancialGoal': 'Objetivo financiero principal',
      'estimatedSubscriptions': 'Suscripciones estimadas',
      'goalSaveMoney': 'Ahorrar dinero',
      'goalTrackBills': 'Controlar facturas',
      'goalAvoidSurpriseCharges': 'Evitar cargos sorpresa',
      'goalCancelUnusedSubscriptions': 'Cancelar suscripciones no usadas',
      'settingsSyncing': 'Guardando tus últimos cambios de Bizoot...',
      'settingsOffline':
          'Modo sin conexión activo. Tus cambios están seguros y continuarán cuando vuelvas a conectarte.',
      'settingsPendingChanges':
          'Algunos cambios recientes aún se están guardando.',
      'settingsReady':
          'Aquí viven tus ajustes de cuenta, recordatorios, privacidad y soporte.',
      'notifications': 'Notificaciones',
      'language': 'Idioma',
      'languageDescription':
          'Elige el idioma que Bizoot debe usar en toda la app.',
      'languageEnglish': 'English',
      'languageDanish': 'Dansk',
      'languageGerman': 'Deutsch',
      'languageSpanish': 'Español',
      'languageUpdated': 'Idioma actualizado.',
      'notificationPreferencesUpdated':
          'Preferencias de notificaciones actualizadas.',
      'notificationPreferencesFailed':
          'No pudimos actualizar tus preferencias de notificaciones ahora mismo.',
      'signOutQuestion': '¿Cerrar sesión en Bizoot?',
      'signOutBody':
          'Volverás a la pantalla de inicio de sesión y tus datos sincronizados seguirán vinculados a tu cuenta.',
      'staySignedIn': 'Seguir conectado',
      'signOut': 'Cerrar sesión',
      'openPhoneNotificationSettings':
          'Abrir ajustes de notificaciones del teléfono',
      'paymentReminders': 'Recordatorios de pago',
      'paymentRemindersSubtitle':
          'Recordatorios para tus suscripciones activas que vencen mañana o pronto.',
      'weeklySummaries': 'Resúmenes semanales',
      'weeklySummariesSubtitle':
          'Resúmenes del domingo por la noche con renovaciones y totales de la próxima semana.',
      'trialAlerts': 'Alertas de prueba',
      'trialAlertsSubtitle':
          'Avisos antes de que una prueba gratuita se convierta en una suscripción de pago.',
      'smartInsights': 'Smart insights',
      'smartInsightsSubtitle':
          'Sugerencias de ahorro, seguimientos de cancelación y avisos sobre gasto recurrente.',
      'promotionalNotifications': 'Notificaciones promocionales',
      'promotionalNotificationsSubtitle':
          'Actualizaciones opcionales del producto, noticias de lanzamientos y anuncios de funciones.',
      'subscriptionPremium': 'Suscripción y Premium',
      'currentPlan': 'Plan actual',
      'trialStatus': 'Estado de prueba',
      'subscriptionUsage': 'Uso de suscripción',
      'whatHappensNow': 'Qué ocurre ahora',
      'planPremium': 'Premium',
      'planTrial': 'Prueba de 7 días',
      'planFree': 'Gratis',
      'premiumUnlocked': 'Premium desbloqueado',
      'trialEnded': 'Prueba finalizada',
      'premiumActiveDescription':
          'Tienes seguimiento ilimitado de suscripciones y todas las funciones premium desbloqueadas.',
      'trialPremiumDescription':
          'Tienes todas las funciones premium durante la prueba, con un límite de 5 suscripciones.',
      'limitReachedDescription':
          'Límite alcanzado: actualiza para seguimiento ilimitado.',
      'upgradeToPremium': 'Actualizar a Premium',
      'premiumFeatureComparison': 'Comparación de funciones premium',
      'premiumCompareFree':
          'Gratis: hasta 5 suscripciones activas, recordatorios básicos y seguimiento esencial',
      'premiumCompareOne':
          'Premium: suscripciones ilimitadas, informes avanzados y smart insights',
      'premiumCompareTwo':
          'Premium: mejor inteligencia de cancelación, resúmenes semanales e insights más profundos',
      'privacySecurity': 'Privacidad y seguridad',
      'privacyAiSettings': 'Privacidad y ajustes de IA',
      'privacyAiSubtitle':
          'Controla los insights de IA y revisa cómo Bizoot protege la información sensible.',
      'support': 'Soporte',
      'contactSupport': 'Contactar con soporte',
      'contactSupportSubtitle':
          'Obtén ayuda, informa de un problema o comparte comentarios con el equipo de Bizoot.',
      'legal': 'Legal',
      'savedServices': 'Servicios guardados',
      'dangerZone': 'Zona de riesgo',
      'logout': 'Cerrar sesión',
      'deleteAccount': 'Eliminar cuenta',
      'savedServicesEmptyTitle': 'Aún no hay servicios personalizados',
      'savedServicesEmptyBody':
          'Cuando crees una suscripción personalizada con tu propio enlace de cancelación, Bizoot la recordará aquí para un autocompletado más rápido la próxima vez.',
      'savedServiceUpdated': 'Servicio guardado actualizado.',
      'savedServiceUpdatedFailed':
          'No pudimos actualizar ese servicio guardado ahora mismo.',
      'editSavedService': 'Editar servicio guardado',
      'deleteSavedService': 'Eliminar servicio guardado',
      'cancellationUrl': 'URL de cancelación',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'deleteSavedServiceQuestion': '¿Eliminar servicio guardado?',
      'savedServiceDeleted': 'Servicio guardado eliminado.',
      'savedServiceDeletedFailed':
          'No pudimos eliminar ese servicio guardado ahora mismo.',
      'noSavedCancellationUrl': 'Aún no hay URL de cancelación guardada.',
      'debugLocalization': 'Depuración de localización',
      'currentLocale': 'Configuración regional actual',
      'supportedLocalesLabel': 'Configuraciones regionales compatibles',
      'fallbackBehavior': 'Comportamiento de reserva',
      'fallbackBehaviorValue':
          'Los idiomas del dispositivo no compatibles vuelven al inglés.',
      'missingTranslationFallbackCount':
          'Conteo de reserva por traducciones faltantes',
    },
  };

  String get _code =>
      _strings.containsKey(locale.languageCode) ? locale.languageCode : 'en';

  String _text(String key) {
    return sanitizeLocalizedText(
      _strings[_code]?[key] ?? _strings['en']?[key] ?? key,
    );
  }

  String get dashboard => _text('dashboard');
  String get calendar => _text('calendar');
  String get subscriptions => _text('subscriptions');
  String get reports => _text('reports');
  String get settings => _text('settings');
  String get premiumTooltip => _text('premiumTooltip');
  String get authWelcomeBack => _text('authWelcomeBack');
  String get authCreateAccount => _text('authCreateAccount');
  String get authWelcomeSubtitle => _text('authWelcomeSubtitle');
  String get authCreateSubtitle => _text('authCreateSubtitle');
  String get authHero => _text('authHero');
  String get email => _text('email');
  String get password => _text('password');
  String get logIn => _text('logIn');
  String get createAccount => _text('createAccount');
  String get enterEmailPassword => _text('enterEmailPassword');
  String get alreadyHaveAccount => _text('alreadyHaveAccount');
  String get needAccount => _text('needAccount');
  String get back => _text('back');
  String get continueLabel => _text('continueLabel');
  String get finishSetup => _text('finishSetup');
  String get finishingSetup => _text('finishingSetup');
  String get fullNameAndCountryRequired => _text('fullNameAndCountryRequired');
  String get validCountryRequired => _text('validCountryRequired');
  String get profileSetup => _text('profileSetup');
  String get profileSetupSubtitle => _text('profileSetupSubtitle');
  String get tapChooseProfilePicture => _text('tapChooseProfilePicture');
  String get profilePictureSelected => _text('profilePictureSelected');
  String get opensPhoneGallery => _text('opensPhoneGallery');
  String get fullName => _text('fullName');
  String get phoneNumberOptional => _text('phoneNumberOptional');
  String get country => _text('country');
  String get financialSetup => _text('financialSetup');
  String get financialSetupSubtitle => _text('financialSetupSubtitle');
  String get currency => _text('currency');
  String get currencyAutoSelected => _text('currencyAutoSelected');
  String get monthlyIncome => _text('monthlyIncome');
  String get monthlyIncomeHelper => _text('monthlyIncomeHelper');
  String get mainFinancialGoal => _text('mainFinancialGoal');
  String get estimatedSubscriptions => _text('estimatedSubscriptions');
  String get goalSaveMoney => _text('goalSaveMoney');
  String get goalTrackBills => _text('goalTrackBills');
  String get goalAvoidSurpriseCharges => _text('goalAvoidSurpriseCharges');
  String get goalCancelUnusedSubscriptions =>
      _text('goalCancelUnusedSubscriptions');
  String get settingsSyncing => _text('settingsSyncing');
  String get settingsOffline => _text('settingsOffline');
  String get settingsPendingChanges => _text('settingsPendingChanges');
  String get settingsReady => _text('settingsReady');
  String get notifications => _text('notifications');
  String get language => _text('language');
  String get languageDescription => _text('languageDescription');
  String get languageEnglish => _text('languageEnglish');
  String get languageDanish => _text('languageDanish');
  String get languageGerman => _text('languageGerman');
  String get languageSpanish => _text('languageSpanish');
  String get languageUpdated => _text('languageUpdated');
  String get notificationPreferencesUpdated =>
      _text('notificationPreferencesUpdated');
  String get notificationPreferencesFailed =>
      _text('notificationPreferencesFailed');
  String get signOutQuestion => _text('signOutQuestion');
  String get signOutBody => _text('signOutBody');
  String get staySignedIn => _text('staySignedIn');
  String get signOut => _text('signOut');
  String get openPhoneNotificationSettings =>
      _text('openPhoneNotificationSettings');
  String get paymentReminders => _text('paymentReminders');
  String get paymentRemindersSubtitle => _text('paymentRemindersSubtitle');
  String get weeklySummaries => _text('weeklySummaries');
  String get weeklySummariesSubtitle => _text('weeklySummariesSubtitle');
  String get trialAlerts => _text('trialAlerts');
  String get trialAlertsSubtitle => _text('trialAlertsSubtitle');
  String get smartInsights => _text('smartInsights');
  String get smartInsightsSubtitle => _text('smartInsightsSubtitle');
  String get promotionalNotifications => _text('promotionalNotifications');
  String get promotionalNotificationsSubtitle =>
      _text('promotionalNotificationsSubtitle');
  String get subscriptionPremium => _text('subscriptionPremium');
  String get currentPlan => _text('currentPlan');
  String get trialStatus => _text('trialStatus');
  String get subscriptionUsage => _text('subscriptionUsage');
  String get whatHappensNow => _text('whatHappensNow');
  String get planPremium => _text('planPremium');
  String get planTrial => _text('planTrial');
  String get planFree => _text('planFree');
  String get premiumUnlocked => _text('premiumUnlocked');
  String get trialEnded => _text('trialEnded');
  String get premiumActiveDescription => _text('premiumActiveDescription');
  String get trialPremiumDescription => _text('trialPremiumDescription');
  String get limitReachedDescription => _text('limitReachedDescription');
  String get upgradeToPremium => _text('upgradeToPremium');
  String get premiumFeatureComparison => _text('premiumFeatureComparison');
  String get premiumCompareFree => _text('premiumCompareFree');
  String get premiumCompareOne => _text('premiumCompareOne');
  String get premiumCompareTwo => _text('premiumCompareTwo');
  String get privacySecurity => _text('privacySecurity');
  String get privacyAiSettings => _text('privacyAiSettings');
  String get privacyAiSubtitle => _text('privacyAiSubtitle');
  String get support => _text('support');
  String get contactSupport => _text('contactSupport');
  String get contactSupportSubtitle => _text('contactSupportSubtitle');
  String get legal => _text('legal');
  String get savedServices => _text('savedServices');
  String get dangerZone => _text('dangerZone');
  String get logout => _text('logout');
  String get deleteAccount => _text('deleteAccount');
  String get savedServicesEmptyTitle => _text('savedServicesEmptyTitle');
  String get savedServicesEmptyBody => _text('savedServicesEmptyBody');
  String get savedServiceUpdated => _text('savedServiceUpdated');
  String get savedServiceUpdatedFailed => _text('savedServiceUpdatedFailed');
  String get editSavedService => _text('editSavedService');
  String get deleteSavedService => _text('deleteSavedService');
  String get cancellationUrl => _text('cancellationUrl');
  String get cancel => _text('cancel');
  String get save => _text('save');
  String get deleteSavedServiceQuestion => _text('deleteSavedServiceQuestion');
  String get savedServiceDeleted => _text('savedServiceDeleted');
  String get savedServiceDeletedFailed => _text('savedServiceDeletedFailed');
  String get noSavedCancellationUrl => _text('noSavedCancellationUrl');
  String get debugLocalization => _text('debugLocalization');
  String get currentLocale => _text('currentLocale');
  String get supportedLocalesLabel => _text('supportedLocalesLabel');
  String get fallbackBehavior => _text('fallbackBehavior');
  String get fallbackBehaviorValue => _text('fallbackBehaviorValue');
  String get missingTranslationFallbackCount =>
      _text('missingTranslationFallbackCount');

  String onboardingStep(int current, int total) => _text(
    'onboardingStep',
  ).replaceFirst('{current}', '$current').replaceFirst('{total}', '$total');

  String estimatedSubscriptionsLabel(int count) =>
      _text('estimatedSubscriptionsLabel').replaceFirst('{count}', '$count');

  String trialDaysRemaining(int days) {
    switch (locale.languageCode) {
      case 'da':
        return '$days dage tilbage';
      case 'de':
        return '$days Tage verbleibend';
      case 'es':
        return '$days dias restantes';
      default:
        return '$days days remaining';
    }
  }

  String subscriptionsTrackedUnlimited(int count) {
    switch (locale.languageCode) {
      case 'da':
        return '$count aktive poster sporet';
      case 'de':
        return '$count aktive Eintraege verfolgt';
      case 'es':
        return '$count elementos activos registrados';
      default:
        return '$count active items tracked';
    }
  }

  String subscriptionsUsed(int count, int limit) {
    switch (locale.languageCode) {
      case 'da':
        return '$count / $limit aktive poster brugt';
      case 'de':
        return '$count / $limit aktive Eintraege verwendet';
      case 'es':
        return '$count / $limit elementos activos usados';
      default:
        return '$count / $limit active items used';
    }
  }

  String freePlanDescription(int limit) {
    switch (locale.languageCode) {
      case 'da':
        return 'Gratis plan aktiv med plads til op til $limit aktive poster.';
      case 'de':
        return 'Kostenloser Plan aktiv mit Platz fuer bis zu $limit aktive Eintraege.';
      case 'es':
        return 'Plan gratuito activo con espacio para hasta $limit elementos activos.';
      default:
        return 'Free plan active with room for up to $limit active items.';
    }
  }

  String deleteSavedServiceBody(String serviceName) => _text(
    'deleteSavedServiceBody',
  ).replaceFirst('{serviceName}', serviceName);

  String usedTimes(int count) =>
      _text('usedTimes').replaceFirst('{count}', '$count');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'da', 'de', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
