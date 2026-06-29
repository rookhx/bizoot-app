import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_subscription_app/screens/dashboard_screen.dart';
import 'package:flutter_subscription_app/screens/weekly_report_screen.dart';

import 'config/app_config.dart';
import 'l10n/app_locale.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/connected_email_account_service.dart';
import 'services/custom_subscription_database_service.dart';
import 'services/document_storage_service.dart';
import 'services/email_import_service.dart';
import 'services/entitlement_service.dart';
import 'services/gmail_import_service.dart';
import 'services/gmail_oauth_backend_service.dart';
import 'services/intelligence_service.dart';
import 'services/notification_service.dart';
import 'services/notification_preferences_service.dart';
import 'services/outlook_import_service.dart';
import 'services/outlook_oauth_backend_service.dart';
import 'services/payment_service.dart';
import 'services/push_notification_service.dart';
import 'services/settings_service.dart';
import 'services/subscription_service.dart';
import 'services/sync_service.dart';
import 'services/user_profile_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/premium_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await PushNotificationService.ensureFirebaseInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  const cloudSyncEnabled = true;
  const emailImportDeviceOnly = true;

  final notificationService = NotificationService();
  final pushNotificationService = PushNotificationService(
    cloudSyncEnabled: cloudSyncEnabled,
    localNotificationService: notificationService,
  );
  await pushNotificationService.initialize();
  final userProfileService = UserProfileService(
    cloudSyncEnabled: cloudSyncEnabled,
  );
  final settingsService = SettingsService(cloudSyncEnabled: cloudSyncEnabled);
  final notificationPreferencesService = NotificationPreferencesService(
    cloudSyncEnabled: cloudSyncEnabled,
  );
  final paymentService = PaymentService(cloudSyncEnabled: cloudSyncEnabled);
  final documentStorageService = DocumentStorageService(
    cloudSyncEnabled: cloudSyncEnabled,
  );
  final customSubscriptionDatabaseService = CustomSubscriptionDatabaseService(
    cloudSyncEnabled: cloudSyncEnabled,
  );
  final connectedEmailAccountService = ConnectedEmailAccountService(
    cloudSyncEnabled: !emailImportDeviceOnly,
  );
  final gmailOAuthBackendService = GmailOAuthBackendService(
    cloudSyncEnabled: !emailImportDeviceOnly,
  );
  final outlookOAuthBackendService = OutlookOAuthBackendService(
    cloudSyncEnabled: !emailImportDeviceOnly,
  );

  final appState = AppState(
    authService: const AuthService(),
    paymentService: paymentService,
    settingsService: settingsService,
    notificationPreferencesService: notificationPreferencesService,
    subscriptionService: SubscriptionService(),
    notificationService: notificationService,
    pushNotificationService: pushNotificationService,
    intelligenceService: IntelligenceService(),
    customSubscriptionDatabaseService: customSubscriptionDatabaseService,
    userProfileService: userProfileService,
    entitlementService: const EntitlementService(),
    documentStorageService: documentStorageService,
    emailImportService: EmailImportService(
      gmailImportService: GmailImportService(
        accountService: connectedEmailAccountService,
        backendService: gmailOAuthBackendService,
      ),
      outlookImportService: OutlookImportService(
        accountService: connectedEmailAccountService,
        backendService: outlookOAuthBackendService,
      ),
    ),
    syncService: SyncService(
      cloudSyncEnabled: cloudSyncEnabled,
      userProfileService: userProfileService,
      settingsService: settingsService,
      notificationPreferencesService: notificationPreferencesService,
      paymentService: paymentService,
      documentStorageService: documentStorageService,
      customSubscriptionDatabaseService: customSubscriptionDatabaseService,
    ),
  );
  await appState.bootstrap();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const SubscriptionControlFlutterApp(),
    ),
  );
}

class SubscriptionControlFlutterApp extends StatelessWidget {
  const SubscriptionControlFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final locale = appState.currentLocale;
        Intl.defaultLocale = locale.toLanguageTag();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: appState.settings.darkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocale.supportedLocales,
          home: _RootView(appState: appState),
        );
      },
    );
  }
}

class _RootView extends StatelessWidget {
  final AppState appState;

  const _RootView({required this.appState});

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (appState.isBootstrapping) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (!appState.isAuthenticated) {
      child = const AuthScreen(key: ValueKey('auth'));
    } else if (!appState.userProfile.onboardingCompleted) {
      child = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      child = const _MainShell(key: ValueKey('main-shell'));
    }

    return AnimatedSwitcher(
      duration: BizootDurations.medium,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({super.key});

  AppLocalizations _l10n(BuildContext context) {
    return AppLocalizations.of(context) ??
        AppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n(context);
    final appState = context.watch<AppState>();
    final screens = const [
      DashboardScreen(),
      CalendarScreen(),
      SubscriptionsScreen(),
      WeeklyReportScreen(embedded: true),
      SettingsScreen(),
    ];
    final titles = [
      l10n.dashboard,
      l10n.calendar,
      l10n.subscriptions,
      l10n.reports,
      l10n.settings,
    ];

    return AppScaffold(
      title: titles[appState.selectedTab],
      useSafeArea: false,
      actions: [
        IconButton(
          tooltip: l10n.premiumTooltip,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
          icon: const Icon(Icons.workspace_premium_outlined),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: screens[appState.selectedTab],
            ),
          ),
          PremiumBottomNav(
            selectedIndex: appState.selectedTab,
            onTap: appState.setSelectedTab,
            items: [
              PremiumNavItem(
                icon: Icons.dashboard_outlined,
                label: l10n.dashboard,
              ),
              PremiumNavItem(
                icon: Icons.calendar_month_outlined,
                label: l10n.calendar,
              ),
              PremiumNavItem(
                icon: Icons.payments_outlined,
                label: l10n.subscriptions,
              ),
              PremiumNavItem(
                icon: Icons.stacked_line_chart_outlined,
                label: l10n.reports,
              ),
              PremiumNavItem(
                icon: Icons.settings_outlined,
                label: l10n.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
