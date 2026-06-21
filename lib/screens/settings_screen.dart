import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_text.dart';
import '../models/custom_subscription_service.dart';
import '../models/notification_preferences.dart';
import '../screens/contact_support_screen.dart';
import '../screens/data_privacy_screen.dart';
import '../screens/delete_account_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/subscription_terms_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../services/app_state.dart';
import '../services/brand_icon_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/neon_icon_box.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppLocalizations _l10n(BuildContext context) =>
      AppLocalizations.of(context) ??
      AppLocalizations(
        Localizations.maybeLocaleOf(context) ?? const Locale('en'),
      );

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _updateNotificationPreferences(
    NotificationPreferences nextPreferences, {
    String? success,
  }) async {
    final appState = context.read<AppState>();
    final l10n = _l10n(context);
    try {
      await appState.saveNotificationPreferences(nextPreferences);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        success ?? l10n.notificationPreferencesUpdated,
      );
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, l10n.notificationPreferencesFailed);
    }
  }

  Future<void> _signOut(AppState appState) async {
    final l10n = _l10n(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.signOutQuestion),
            content: Text(l10n.signOutBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.staySignedIn),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await appState.signOut();
  }

  Future<void> _editCustomService(
    BuildContext context,
    AppState appState,
    CustomSubscriptionService service,
  ) async {
    final l10n = _l10n(context);
    final urlController = TextEditingController(text: service.cancellationUrl);
    final updated = await showDialog<CustomSubscriptionService>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(labelText: l10n.cancellationUrl),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(service.copyWith(cancellationUrl: urlController.text.trim())),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (updated == null) return;
    try {
      await appState.updateCustomService(updated);
      if (!context.mounted) return;
      showSuccessSnackBar(context, l10n.savedServiceUpdated);
    } catch (_) {
      if (!context.mounted) return;
      showErrorSnackBar(context, l10n.savedServiceUpdatedFailed);
    }
  }

  String _planLabel(AppLocalizations l10n, AppState appState) {
    if (appState.isPremiumUser) return l10n.planPremium;
    if (appState.isTrialActive) return l10n.planTrial;
    return l10n.planFree;
  }

  String _notificationStatusMessage(AppLocalizations l10n, AppState appState) {
    if (!appState.notificationPreferences.paymentRemindersEnabled) {
      return '${l10n.notifications} ${_localizedText(context, en: 'are turned off in Bizoot.', da: 'er slået fra i Bizoot.', de: 'sind in Bizoot ausgeschaltet.', es: 'están desactivadas en Bizoot.')}';
    }
    if (!appState.notificationsAllowed) {
      return '${l10n.notifications} ${_localizedText(context, en: 'are disabled on this phone.', da: 'er slået fra på denne telefon.', de: 'sind auf diesem Telefon deaktiviert.', es: 'están desactivadas en este teléfono.')}';
    }
    return appState.hasPremiumFeatureAccess
        ? _localizedText(
            context,
            en: 'Smart alerts are active for payments, trials, weekly summaries, and savings insights.',
            da: 'Smarte advarsler er aktive for betalinger, prøveperioder, ugentlige oversigter og spareindsigter.',
            de: 'Smarte Hinweise sind für Zahlungen, Testphasen, Wochenübersichten und Sparhinweise aktiv.',
            es: 'Las alertas inteligentes están activas para pagos, pruebas, resúmenes semanales y recomendaciones de ahorro.',
          )
        : _localizedText(
            context,
            en: 'Basic payment reminders are active. Unlock premium for trials, weekly summaries, and savings alerts.',
            da: 'Grundlæggende betalingspåmindelser er aktive. Lås op for Premium til prøveperioder, ugentlige oversigter og spareadvarsler.',
            de: 'Grundlegende Zahlungserinnerungen sind aktiv. Schalte Premium frei für Testphasen, Wochenübersichten und Sparhinweise.',
            es: 'Los recordatorios básicos de pago están activos. Desbloquea Premium para pruebas, resúmenes semanales y alertas de ahorro.',
          );
  }

  String _localizedText(
    BuildContext context, {
    required String en,
    required String da,
    required String de,
    required String es,
  }) {
    switch ((Localizations.maybeLocaleOf(context) ?? const Locale('en'))
        .languageCode) {
      case 'da':
        return da;
      case 'de':
        return de;
      case 'es':
        return es;
      default:
        return en;
    }
  }

  String _languageName(AppLocalizations l10n, String code) {
    switch (code) {
      case AppLocale.danish:
        return l10n.languageDanish;
      case AppLocale.german:
        return l10n.languageGerman;
      case AppLocale.spanish:
        return l10n.languageSpanish;
      default:
        return l10n.languageEnglish;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final preferences = appState.notificationPreferences;
    final l10n = _l10n(context);

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        120 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settings,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: BizootSpacing.xs),
                    Text(
                      appState.isSyncingData
                          ? l10n.settingsSyncing
                          : appState.isOfflineMode
                          ? l10n.settingsOffline
                          : appState.hasPendingSyncChanges
                          ? l10n.settingsPendingChanges
                          : l10n.settingsReady,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BizootSpacing.md),
              NeonIconBox(
                icon: appState.isOfflineMode
                    ? Icons.cloud_off_outlined
                    : Icons.settings_outlined,
                size: 48,
              ),
            ],
          ),
        ),
        if (appState.isSavingSettings || appState.isSyncingData) ...[
          const SizedBox(height: BizootSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(minHeight: 4),
          ),
        ],
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.language_outlined,
          title: l10n.language,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.languageDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.textSecondary,
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: BizootColors.border.withValues(alpha: 0.75),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: AppLocale.normalizeLanguageCode(
                    appState.settings.preferredLanguage,
                  ),
                  menuMaxHeight: 280,
                  dropdownColor: BizootColors.surface,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: BizootColors.textSecondary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  items: AppLocale.supportedLanguageCodes
                      .map(
                        (code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(
                            _languageName(l10n, code),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    await appState.setPreferredLanguage(value);
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, l10n.languageUpdated);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.notifications_active_outlined,
          title: l10n.notifications,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _notificationStatusMessage(l10n, appState),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.textSecondary,
                ),
              ),
              if (!appState.notificationsAllowed) ...[
                const SizedBox(height: BizootSpacing.md),
                AppButton(
                  label: l10n.openPhoneNotificationSettings,
                  icon: Icons.settings_applications_outlined,
                  secondary: true,
                  onPressed: appState.openNotificationSettings,
                ),
              ],
              const SizedBox(height: BizootSpacing.lg),
              _PremiumToggleRow(
                title: l10n.paymentReminders,
                subtitle: l10n.paymentRemindersSubtitle,
                value: preferences.paymentRemindersEnabled,
                enabled: true,
                onChanged: (value) => _updateNotificationPreferences(
                  preferences.copyWith(paymentRemindersEnabled: value),
                ),
              ),
              _PremiumToggleRow(
                title: l10n.weeklySummaries,
                subtitle: l10n.weeklySummariesSubtitle,
                value: preferences.weeklySummaryEnabled,
                enabled: appState.canUseSmartNotifications,
                onChanged: (value) => _updateNotificationPreferences(
                  preferences.copyWith(weeklySummaryEnabled: value),
                ),
              ),
              _PremiumToggleRow(
                title: l10n.trialAlerts,
                subtitle: l10n.trialAlertsSubtitle,
                value: preferences.trialAlertsEnabled,
                enabled: appState.canUseSmartNotifications,
                onChanged: (value) => _updateNotificationPreferences(
                  preferences.copyWith(trialAlertsEnabled: value),
                ),
              ),
              _PremiumToggleRow(
                title: l10n.smartInsights,
                subtitle: l10n.smartInsightsSubtitle,
                value: preferences.savingsInsightsEnabled,
                enabled: appState.canUseSmartNotifications,
                onChanged: (value) => _updateNotificationPreferences(
                  preferences.copyWith(savingsInsightsEnabled: value),
                ),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _PremiumToggleRow(
                title: l10n.promotionalNotifications,
                subtitle: l10n.promotionalNotificationsSubtitle,
                value: preferences.emailRemindersEnabled,
                enabled: true,
                onChanged: (value) => _updateNotificationPreferences(
                  preferences.copyWith(emailRemindersEnabled: value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.workspace_premium_outlined,
          title: l10n.subscriptionPremium,
          child: Column(
            children: [
              _StatusTile(
                label: l10n.currentPlan,
                value: _planLabel(l10n, appState),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _StatusTile(
                label: l10n.trialStatus,
                value: appState.isPremiumUser
                    ? l10n.premiumUnlocked
                    : appState.isTrialActive
                    ? l10n.trialDaysRemaining(appState.trialDaysRemaining)
                    : l10n.trialEnded,
              ),
              const SizedBox(height: BizootSpacing.sm),
              _StatusTile(
                label: l10n.subscriptionUsage,
                value: appState.isPremiumUser
                    ? l10n.subscriptionsTrackedUnlimited(
                        appState.activeSubscriptionCount,
                      )
                    : l10n.subscriptionsUsed(
                        appState.activeSubscriptionCount,
                        appState.subscriptionLimit,
                      ),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _StatusTile(
                label: l10n.whatHappensNow,
                value: appState.isPremiumUser
                    ? l10n.premiumActiveDescription
                    : appState.canAddSubscription
                    ? appState.isTrialActive
                          ? l10n.trialPremiumDescription
                          : l10n.freePlanDescription(appState.subscriptionLimit)
                    : l10n.limitReachedDescription,
              ),
              const SizedBox(height: BizootSpacing.md),
              AppButton(
                label: l10n.upgradeToPremium,
                icon: Icons.auto_awesome,
                onPressed: () => _openScreen(const PaywallScreen()),
              ),
              const SizedBox(height: BizootSpacing.md),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BizootColors.surfaceElevated.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: BizootColors.border.withValues(alpha: 0.75),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.premiumFeatureComparison,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FeatureBullet(
                      label: localeText(
                        context,
                        en: 'Free: up to 5 active recurring items, basic reminders, core tracking',
                        da: 'Gratis: op til 5 aktive poster, grundlaeggende paamindelser og kernesporing',
                        de: 'Kostenlos: bis zu 5 aktive Eintraege, grundlegende Erinnerungen und Kern-Tracking',
                        es: 'Gratis: hasta 5 elementos activos, recordatorios basicos y seguimiento principal',
                      ),
                    ),
                    _FeatureBullet(
                      label: localeText(
                        context,
                        en: 'Premium: unlimited recurring items, advanced reports, smart insights',
                        da: 'Premium: ubegrænsede poster, avancerede rapporter og smart indsigt',
                        de: 'Premium: unbegrenzte Eintraege, erweiterte Berichte und Smart Insights',
                        es: 'Premium: elementos recurrentes ilimitados, informes avanzados y smart insights',
                      ),
                    ),
                    _FeatureBullet(label: l10n.premiumCompareTwo),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.verified_user_outlined,
          title: l10n.privacySecurity,
          child: Column(
            children: [
              _SettingsNavTile(
                icon: Icons.lock_person_outlined,
                title: localeText(
                  context,
                  en: 'Privacy, AI & data',
                  da: 'Privatliv, AI og data',
                  de: 'Datenschutz, KI und Daten',
                  es: 'Privacidad, IA y datos',
                ),
                subtitle: localeText(
                  context,
                  en: 'Manage privacy choices, local AI behavior, and how Bizoot handles your data.',
                  da: 'Administrer privatlivsvalg, lokal AI-adfærd og hvordan Bizoot håndterer dine data.',
                  de: 'Verwalte Datenschutzoptionen, lokales KI-Verhalten und wie Bizoot deine Daten verarbeitet.',
                  es: 'Administra la privacidad, el comportamiento de la IA local y cómo Bizoot gestiona tus datos.',
                ),
                onTap: () => _openScreen(const DataPrivacyScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.support_agent_outlined,
          title: l10n.support,
          child: Column(
            children: [
              _SettingsNavTile(
                icon: Icons.support_agent_outlined,
                title: l10n.contactSupport,
                subtitle: l10n.contactSupportSubtitle,
                onTap: () => _openScreen(const ContactSupportScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.gavel_outlined,
          title: l10n.legal,
          child: Column(
            children: [
              _SettingsNavTile(
                icon: Icons.description_outlined,
                title: localeText(
                  context,
                  en: 'Terms of Service',
                  da: 'Brugsvilkår',
                  de: 'Nutzungsbedingungen',
                  es: 'Términos de servicio',
                ),
                subtitle: localeText(
                  context,
                  en: 'General account, usage, and product terms for Bizoot.',
                  da: 'Generelle vilkår for konto, brug og produkt i Bizoot.',
                  de: 'Allgemeine Konto-, Nutzungs- und Produktbedingungen für Bizoot.',
                  es: 'Condiciones generales de cuenta, uso y producto para Bizoot.',
                ),
                onTap: () => _openScreen(const TermsOfServiceScreen()),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _SettingsNavTile(
                icon: Icons.workspace_premium_outlined,
                title: localeText(
                  context,
                  en: 'Subscription Terms',
                  da: 'Abonnementsvilkår',
                  de: 'Abonnementbedingungen',
                  es: 'Términos de suscripción',
                ),
                subtitle: localeText(
                  context,
                  en: 'Trials, renewals, store billing, and cancellation terms.',
                  da: 'Vilkår for prøveperioder, fornyelser, butiksbetaling og opsigelse.',
                  de: 'Bedingungen zu Testphasen, Verlängerungen, Store-Abrechnung und Kündigung.',
                  es: 'Condiciones sobre pruebas, renovaciones, facturación de la tienda y cancelaciones.',
                ),
                onTap: () => _openScreen(const SubscriptionTermsScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.bookmark_added_outlined,
          title: l10n.savedServices,
          child: appState.customServices.isEmpty
              ? EmptyState(
                  title: l10n.savedServicesEmptyTitle,
                  body: l10n.savedServicesEmptyBody,
                )
              : Column(
                  children: appState.customServices
                      .map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: BizootSpacing.sm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BizootColors.surfaceElevated.withValues(
                                alpha: 0.88,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: BizootColors.border.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        BrandIconService.instance
                                            .canonicalDisplayName(service.name),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.editSavedService,
                                      onPressed: () => _editCustomService(
                                        context,
                                        appState,
                                        service,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: l10n.deleteSavedService,
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text(
                                                  l10n.deleteSavedServiceQuestion,
                                                ),
                                                content: Text(
                                                  l10n.deleteSavedServiceBody(
                                                    BrandIconService.instance
                                                        .canonicalDisplayName(
                                                          service.name,
                                                        ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text(l10n.cancel),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: Text(
                                                      l10n.deleteSavedService,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;
                                        if (!confirmed) return;
                                        try {
                                          await appState.deleteCustomService(
                                            service.id,
                                          );
                                          if (!context.mounted) return;
                                          showSuccessSnackBar(
                                            context,
                                            l10n.savedServiceDeleted,
                                          );
                                        } catch (_) {
                                          if (!context.mounted) return;
                                          showErrorSnackBar(
                                            context,
                                            l10n.savedServiceDeletedFailed,
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                                Text(
                                  service.cancellationUrl.isEmpty
                                      ? l10n.noSavedCancellationUrl
                                      : service.cancellationUrl,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: BizootColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.usedTimes(service.usageCount),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: BizootColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _SettingsSection(
          icon: Icons.warning_amber_outlined,
          title: l10n.dangerZone,
          child: Column(
            children: [
              _SettingsNavTile(
                icon: Icons.logout,
                title: l10n.logout,
                subtitle: l10n.signOutBody,
                onTap: () => _signOut(appState),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _SettingsNavTile(
                icon: Icons.person_remove_outlined,
                title: l10n.deleteAccount,
                subtitle: localeText(
                  context,
                  en: 'Permanently remove your Bizoot account data, clear the device cache, and sign out.',
                  da: 'Fjern dine Bizoot-kontodata permanent, ryd enhedens cache og log ud.',
                  de: 'Entferne deine Bizoot-Kontodaten dauerhaft, lösche den Gerätespeicher und melde dich ab.',
                  es: 'Elimina permanentemente los datos de tu cuenta de Bizoot, borra la caché del dispositivo y cierra sesión.',
                ),
                onTap: () => _openScreen(const DeleteAccountScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeonIconBox(icon: icon, size: 42),
              const SizedBox(width: BizootSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: BizootSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatusTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: BizootSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BizootColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PremiumToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.75)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          enabled
              ? subtitle
              : localeText(
                  context,
                  en: '$subtitle Premium required.',
                  da: '$subtitle Premium kræves.',
                  de: '$subtitle Premium erforderlich.',
                  es: '$subtitle Requiere Premium.',
                ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.75)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        minVerticalPadding: 12,
        leading: NeonIconBox(icon: icon, size: 38),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: BizootColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String label;

  const _FeatureBullet({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.check_circle_outline,
              size: 16,
              color: BizootColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
