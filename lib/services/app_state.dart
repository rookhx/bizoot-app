import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../ai/models/ai_insight.dart';
import '../ai/models/ai_privacy_consent.dart';
import '../ai/models/ai_user_context.dart';
import '../ai/services/ai_orchestrator_service.dart';
import '../models/custom_subscription_service.dart';
import '../models/calendar_event.dart';
import '../models/insight_event.dart';
import '../models/notification_preferences.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';
import '../models/weekly_report.dart';
import '../utils/payment_math.dart';
import 'auth_service.dart';
import 'custom_subscription_database_service.dart';
import 'document_storage_service.dart';
import 'entitlement_service.dart';
import 'financial_intelligence_service.dart';
import 'intelligence_service.dart';
import 'notification_service.dart';
import 'notification_preferences_service.dart';
import 'payment_service.dart';
import 'push_notification_service.dart';
import 'settings_service.dart';
import 'recurring_life_calendar_service.dart';
import 'smart_notification_service.dart';
import 'smart_insights_service.dart';
import 'smart_control_service.dart';
import 'subscription_service.dart';
import 'sync_service.dart';
import 'user_profile_service.dart';
import 'brand_icon_service.dart';

class QuickPreset {
  final String name;
  final PaymentCategory category;
  final PaymentFrequency frequency;
  final ReminderTiming reminderTiming;
  final String iconKey;
  final double suggestedAmount;

  const QuickPreset({
    required this.name,
    required this.category,
    required this.frequency,
    required this.reminderTiming,
    required this.iconKey,
    required this.suggestedAmount,
  });
}

class AppState extends ChangeNotifier {
  AppState({
    required this.authService,
    required this.paymentService,
    required this.settingsService,
    required this.notificationPreferencesService,
    required this.subscriptionService,
    required this.notificationService,
    required this.pushNotificationService,
    required this.intelligenceService,
    required this.customSubscriptionDatabaseService,
    required this.userProfileService,
    required this.entitlementService,
    required this.documentStorageService,
    required this.syncService,
  });

  final AuthService authService;
  final PaymentService paymentService;
  final SettingsService settingsService;
  final NotificationPreferencesService notificationPreferencesService;
  final SubscriptionService subscriptionService;
  final NotificationService notificationService;
  final PushNotificationService pushNotificationService;
  final IntelligenceService intelligenceService;
  final CustomSubscriptionDatabaseService customSubscriptionDatabaseService;
  final UserProfileService userProfileService;
  final EntitlementService entitlementService;
  final DocumentStorageService documentStorageService;
  final SyncService syncService;
  final SmartNotificationService smartNotificationService =
      const SmartNotificationService();
  final SmartInsightsService smartInsightsService =
      const SmartInsightsService();
  final SmartControlService smartControlService = const SmartControlService();
  final RecurringLifeCalendarService recurringLifeCalendarService =
      const RecurringLifeCalendarService();
  final AiOrchestratorService aiOrchestratorService =
      const AiOrchestratorService();

  bool isBootstrapping = true;
  bool isAuthenticated = false;
  bool hasPremium = false;
  bool isAuthLoading = false;
  bool isPurchaseInProgress = false;
  bool isRestoreInProgress = false;
  bool isSavingSettings = false;
  bool isSavingPayment = false;
  bool isDeletingPayment = false;
  bool isUploadingDocument = false;
  bool isDeletingDocument = false;
  bool isSyncingData = false;
  bool notificationsAllowed = false;
  bool isOfflineMode = false;
  bool hasPendingSyncChanges = false;
  int selectedTab = 0;
  String? errorMessage;
  String? subscriptionMessage;
  String? syncErrorMessage;
  DateTime? lastSyncedAt;
  late UserProfile userProfile;
  late UserSettings settings;
  NotificationPreferences notificationPreferences =
      NotificationPreferences.defaults();
  List<RecurringPayment> payments = [];
  List<UserDocument> documents = [];
  List<CustomSubscriptionService> customServices = [];
  String _aiProviderName = 'Local';
  List<AiInsight> _aiInsights = const [];
  AiUserContext _aiContextPreview = const AiUserContext(
    currency: 'USD',
    monthlyIncome: 0,
    subscriptions: [],
  );

  final presets = const [
    QuickPreset(
      name: 'Netflix',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'movie',
      suggestedAmount: 19.99,
    ),
    QuickPreset(
      name: 'Spotify',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'music',
      suggestedAmount: 11.99,
    ),
    QuickPreset(
      name: 'YouTube Premium',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'play',
      suggestedAmount: 13.99,
    ),
    QuickPreset(
      name: 'Amazon Prime',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.threeDaysBefore,
      iconKey: 'cart',
      suggestedAmount: 14.99,
    ),
    QuickPreset(
      name: 'Disney+',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'tv',
      suggestedAmount: 13.99,
    ),
    QuickPreset(
      name: 'Apple iCloud',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'cloud',
      suggestedAmount: 9.99,
    ),
    QuickPreset(
      name: 'Google One',
      category: PaymentCategory.subscription,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'storage',
      suggestedAmount: 9.99,
    ),
    QuickPreset(
      name: 'Gym',
      category: PaymentCategory.gym,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.threeDaysBefore,
      iconKey: 'fitness',
      suggestedAmount: 49.99,
    ),
    QuickPreset(
      name: 'Rent',
      category: PaymentCategory.rent,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.sameDay,
      iconKey: 'home',
      suggestedAmount: 1450,
    ),
    QuickPreset(
      name: 'Internet',
      category: PaymentCategory.internet,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'wifi',
      suggestedAmount: 79.99,
    ),
    QuickPreset(
      name: 'Phone',
      category: PaymentCategory.phone,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.oneDayBefore,
      iconKey: 'phone',
      suggestedAmount: 65,
    ),
    QuickPreset(
      name: 'Insurance',
      category: PaymentCategory.insurance,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.threeDaysBefore,
      iconKey: 'shield',
      suggestedAmount: 120,
    ),
    QuickPreset(
      name: 'Utilities',
      category: PaymentCategory.utilities,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.threeDaysBefore,
      iconKey: 'flash',
      suggestedAmount: 140,
    ),
    QuickPreset(
      name: 'Loan',
      category: PaymentCategory.loan,
      frequency: PaymentFrequency.monthly,
      reminderTiming: ReminderTiming.threeDaysBefore,
      iconKey: 'payments',
      suggestedAmount: 300,
    ),
    QuickPreset(
      name: 'Contract',
      category: PaymentCategory.contract,
      frequency: PaymentFrequency.yearly,
      reminderTiming: ReminderTiming.sevenDaysBefore,
      iconKey: 'description',
      suggestedAmount: 0,
    ),
  ];

  Future<void> bootstrap() async {
    await notificationService.initialize();
    final user = authService.currentUser;
    if (user != null) {
      isAuthenticated = true;
      _applySyncBundle(await syncService.syncOnAppStart(user.id));
      if (userProfile.onboardingCompleted) {
        userProfile = entitlementService.ensureTrialStarted(userProfile);
        await userProfileService.saveProfile(userProfile);
      }
      settings = _mergeProfileIntoSettings(settings, userProfile);
      await _normalizePreferredLanguage();
      await subscriptionService.initializeRevenueCat(user.id);
      await _syncPremiumAccessFromBilling();
      _refreshEntitlements();
      notificationPreferences = notificationPreferences.copyWith(
        userId: user.id,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await _normalizePaymentDisplayNames();
      await _normalizePaymentCategories();
      await _normalizePaymentCurrencies();
      await _enforceActiveItemLimitIfNeeded();
      _applyPreferencesToSettings();
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      await _initializePushNotifications(user.id);
      await _syncSmartNotifications();
    } else {
      final savedLanguagePreference = await settingsService
          .loadPreferredLanguage();
      final savedLanguage = AppLocale.normalizeLanguageCode(
        savedLanguagePreference,
      );
      userProfile = UserProfile.defaults();
      settings = UserSettings.defaults().copyWith(
        preferredLanguage: savedLanguagePreference == null
            ? AppLocale.preferenceFromDeviceLocale(
                WidgetsBinding.instance.platformDispatcher.locale,
              )
            : savedLanguage,
      );
      notificationPreferences = NotificationPreferences.defaults();
      payments = [];
      documents = const [];
      customServices = const [];
      isOfflineMode = false;
      hasPendingSyncChanges = false;
      syncErrorMessage = null;
      lastSyncedAt = null;
      await pushNotificationService.initialize(
        onNotificationTap: _handlePushNotificationTap,
      );
      notificationsAllowed = await notificationService
          .areNotificationsEnabled();
    }
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> signIn(
    String email,
    String password, {
    bool signUp = false,
  }) async {
    errorMessage = null;
    isAuthLoading = true;
    notifyListeners();
    try {
      if (signUp) {
        await authService.signUp(email, password);
      } else {
        await authService.signIn(email, password);
      }
      final user = authService.currentUser!;
      if (signUp) {
        userProfile = UserProfile.defaults(userId: user.id).copyWith(
          subscriptionLimit: EntitlementService.defaultSubscriptionLimit,
          preferredLanguage: AppLocale.normalizeLanguageCode(
            settings.preferredLanguage,
          ),
        );
        settings = UserSettings.defaults().copyWith(
          userId: user.id,
          onboardingCompleted: false,
          preferredLanguage: userProfile.preferredLanguage,
        );
        notificationPreferences = NotificationPreferences.defaults(
          userId: user.id,
        );
        payments = const [];
        documents = const [];
        customServices = const [];
        await userProfileService.saveProfile(userProfile);
        await settingsService.saveSettings(settings);
        await settingsService.savePreferredLanguage(settings.preferredLanguage);
        await notificationPreferencesService.savePreferences(
          notificationPreferences,
        );
      } else {
        _applySyncBundle(await syncService.syncOnLogin(user.id));
        if (userProfile.onboardingCompleted) {
          userProfile = entitlementService.ensureTrialStarted(userProfile);
          await userProfileService.saveProfile(userProfile);
        }
        settings = _mergeProfileIntoSettings(settings, userProfile);
        await _normalizePreferredLanguage();
      }
      await subscriptionService.initializeRevenueCat(user.id);
      await _syncPremiumAccessFromBilling();
      _refreshEntitlements();
      notificationPreferences = notificationPreferences.copyWith(
        userId: user.id,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await _normalizePaymentDisplayNames();
      await _normalizePaymentCategories();
      await _normalizePaymentCurrencies();
      await _enforceActiveItemLimitIfNeeded();
      selectedTab = 0;
      _applyPreferencesToSettings();
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      await _initializePushNotifications(user.id);
      await _syncSmartNotifications();
      isAuthenticated = true;
    } catch (error) {
      errorMessage = error.toString();
      isAuthenticated = false;
    } finally {
      isAuthLoading = false;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    final preservedLanguage = AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    );
    final userId = authService.currentUser?.id;
    if (userId != null) {
      await pushNotificationService.deleteTokenOnLogout(userId);
      await syncService.clearLocalCacheOnLogout(userId);
    }
    await subscriptionService.logout();
    await authService.signOut();
    await notificationService.cancelAll();
    isAuthenticated = false;
    userProfile = UserProfile.defaults();
    settings = UserSettings.defaults().copyWith(
      preferredLanguage: preservedLanguage,
    );
    notificationPreferences = NotificationPreferences.defaults();
    payments = [];
    documents = const [];
    customServices = const [];
    notificationsAllowed = false;
    isOfflineMode = false;
    hasPendingSyncChanges = false;
    syncErrorMessage = null;
    lastSyncedAt = null;
    selectedTab = 0;
    await settingsService.savePreferredLanguage(preservedLanguage);
    notifyListeners();
  }

  Future<void> deleteAccountPlaceholder() async {
    final userId = settings.userId;
    await notificationService.cancelAll();
    await pushNotificationService.deleteTokenOnLogout(userId);
    if (userId.isNotEmpty) {
      await syncService.deleteRemoteAccountData(userId);
      await syncService.clearLocalCacheOnLogout(userId);
    }
    await paymentService.clearLocalCache();
    await documentStorageService.deleteAllForUser(userId);
    await userProfileService.clearLocalCache();
    await settingsService.clearLocalCache();
    await notificationPreferencesService.clearLocalCache();
    await customSubscriptionDatabaseService.clearLocalCache(userId);
    payments = [];
    documents = const [];
    customServices = const [];
    errorMessage = null;
    subscriptionMessage = null;
    await signOut();
  }

  Future<void> clearLocalCacheOnly() async {
    final userId = settings.userId;
    await paymentService.clearLocalCache();
    await documentStorageService.clearLocalCache();
    await userProfileService.clearLocalCache();
    await settingsService.clearLocalCache();
    await notificationPreferencesService.clearLocalCache();
    await customSubscriptionDatabaseService.clearLocalCache(userId);
    if (userId.isNotEmpty) {
      await syncService.clearLocalCacheOnLogout(userId);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile nextProfile) async {
    isSavingSettings = true;
    notifyListeners();
    try {
      userProfile = entitlementService.ensureTrialStarted(
        nextProfile.copyWith(
          onboardingCompleted: true,
          updatedAt: DateTime.now(),
          subscriptionLimit: entitlementService.getSubscriptionLimit(
            nextProfile,
          ),
        ),
      );
      _refreshEntitlements();
      await userProfileService.saveProfile(userProfile);
      settings = settings.copyWith(
        userId: userProfile.userId,
        monthlyIncome: userProfile.monthlyIncome,
        currency: userProfile.preferredCurrency,
        country: userProfile.country,
        preferredLanguage: userProfile.preferredLanguage,
        financialGoal: userProfile.financialGoal,
        estimatedSubscriptions: userProfile.estimatedSubscriptions,
        onboardingCompleted: true,
      );
      await settingsService.saveSettings(settings);
      await _normalizePaymentCurrencies();
      notificationPreferences = notificationPreferences.copyWith(
        userId: settings.userId,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<void> saveSettings(UserSettings nextSettings) async {
    isSavingSettings = true;
    notifyListeners();
    try {
      final previousCurrency = settings.currency.trim().toUpperCase();
      settings = nextSettings;
      notificationPreferences = notificationPreferences.copyWith(
        userId: settings.userId,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await settingsService.saveSettings(settings);
      if (settings.currency.trim().toUpperCase() != previousCurrency) {
        await _normalizePaymentCurrencies();
      }
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      if (isAuthenticated) {
        await pushNotificationService.syncDeviceToken(
          userId: settings.userId,
          notificationsEnabled: notificationPreferences.paymentRemindersEnabled,
        );
      }
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<void> saveProfileAndSettings(
    UserProfile nextProfile,
    UserSettings nextSettings,
  ) async {
    isSavingSettings = true;
    notifyListeners();
    try {
      final previousCurrency = settings.currency.trim().toUpperCase();
      userProfile = entitlementService.ensureTrialStarted(
        nextProfile.copyWith(
          updatedAt: DateTime.now(),
          subscriptionLimit: entitlementService.getSubscriptionLimit(
            nextProfile,
          ),
        ),
      );
      _refreshEntitlements();
      settings = nextSettings.copyWith(
        userId: userProfile.userId,
        monthlyIncome: userProfile.monthlyIncome,
        currency: userProfile.preferredCurrency,
        country: userProfile.country,
        preferredLanguage: userProfile.preferredLanguage,
        financialGoal: userProfile.financialGoal,
        estimatedSubscriptions: userProfile.estimatedSubscriptions,
        onboardingCompleted: userProfile.onboardingCompleted,
      );
      notifyListeners();
      await userProfileService.saveProfile(userProfile);
      await settingsService.saveSettings(settings);
      if (settings.currency.trim().toUpperCase() != previousCurrency) {
        await _normalizePaymentCurrencies();
      }
      notificationPreferences = notificationPreferences.copyWith(
        userId: settings.userId,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<void> setPreferredLanguage(String languageCode) async {
    final normalized = AppLocale.normalizeLanguageCode(languageCode);
    if (normalized == settings.preferredLanguage &&
        normalized == userProfile.preferredLanguage) {
      return;
    }

    isSavingSettings = true;
    notifyListeners();
    try {
      settings = settings.copyWith(
        preferredLanguage: normalized,
        updatedAt: DateTime.now(),
      );
      await settingsService.saveSettings(settings);
      await settingsService.savePreferredLanguage(normalized);
      if (isAuthenticated) {
        userProfile = userProfile.copyWith(
          preferredLanguage: normalized,
          updatedAt: DateTime.now(),
        );
        await userProfileService.saveProfile(userProfile);
        _refreshSyncStatus(
          await syncService.syncAfterSettingsChange(settings.userId),
        );
      }
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<void> saveNotificationPreferences(
    NotificationPreferences nextPreferences,
  ) async {
    isSavingSettings = true;
    notifyListeners();
    try {
      notificationPreferences = nextPreferences.copyWith(
        userId: settings.userId,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      _applyPreferencesToSettings();
      await settingsService.saveSettings(settings);
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      if (isAuthenticated) {
        await pushNotificationService.syncDeviceToken(
          userId: settings.userId,
          notificationsEnabled: notificationPreferences.paymentRemindersEnabled,
        );
      }
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<void> savePayment(
    RecurringPayment payment, {
    RecurringPayment? original,
    bool rememberAsCustom = false,
  }) async {
    isSavingPayment = true;
    notifyListeners();
    try {
      final normalizedCategory = _normalizedCategoryForPayment(payment);
      final normalizedPayment = payment.copyWith(
        name: BrandIconService.instance.canonicalDisplayName(
          payment.name,
          serviceId: payment.iconKey,
          iconKey: payment.iconKey,
        ),
        category: normalizedCategory,
        isEssential: normalizedCategory.isEssential,
        currency: settings.currency.trim().toUpperCase(),
      );
      final wasCountingTowardLimit = original?.isActive ?? false;
      final willCountTowardLimit = normalizedPayment.isActive;
      final increasesActiveItemCount =
          willCountTowardLimit && !wasCountingTowardLimit;
      if (increasesActiveItemCount && !canAddSubscription) {
        throw StateError('subscription_limit_reached');
      }
      if (original == null) {
        final saved = await paymentService.createPayment(normalizedPayment);
        payments = [...payments, saved];
      } else {
        final saved = await paymentService.updatePayment(
          original,
          normalizedPayment,
        );
        payments = payments
            .map((item) => item.id == normalizedPayment.id ? saved : item)
            .toList();
      }
      if (rememberAsCustom) {
        await customSubscriptionDatabaseService.upsertCustomServiceFromPayment(
          normalizedPayment.userId,
          normalizedPayment,
        );
        customServices = await customSubscriptionDatabaseService
            .listCustomServices(normalizedPayment.userId);
      }
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(normalizedPayment.userId),
      );
    } finally {
      isSavingPayment = false;
    }
    notifyListeners();
  }

  Future<void> deletePayment(RecurringPayment payment) async {
    isDeletingPayment = true;
    notifyListeners();
    try {
      await documentStorageService.unlinkDocumentsForItem(
        payment.userId,
        payment.id,
      );
      documents = documents
          .map(
            (item) => item.linkedItemId == payment.id
                ? item.copyWith(
                    clearLinkedItemId: true,
                    clearLinkedItemType: true,
                    updatedAt: DateTime.now(),
                  )
                : item,
          )
          .toList(growable: false);
      await paymentService.deletePayment(payment.userId, payment.id);
      payments = payments.where((item) => item.id != payment.id).toList();
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(payment.userId),
      );
    } finally {
      isDeletingPayment = false;
    }
    notifyListeners();
  }

  Future<void> refreshDocuments() async {
    if (settings.userId.isEmpty) return;
    documents = await documentStorageService.fetchDocuments(settings.userId);
    notifyListeners();
  }

  Future<UserDocument> uploadDocumentForItem({
    required String linkedItemId,
    required String title,
    required UserDocumentCategory category,
    String notes = '',
  }) async {
    if (!canStoreMoreDocuments) {
      throw StateError('document_limit_reached');
    }
    isUploadingDocument = true;
    notifyListeners();
    try {
      final asset = await documentStorageService.pickDocument();
      if (asset == null) {
        throw StateError('document_pick_cancelled');
      }
      final document = await documentStorageService.uploadDocument(
        userId: settings.userId,
        asset: asset,
        title: title,
        category: category,
        linkedItemId: linkedItemId,
        linkedItemType: LinkedItemType.recurringPayment,
        notes: notes,
      );
      documents = [document, ...documents];
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(settings.userId),
      );
      return document;
    } finally {
      isUploadingDocument = false;
      notifyListeners();
    }
  }

  Future<UserDocument> replaceDocument(UserDocument document) async {
    isUploadingDocument = true;
    notifyListeners();
    try {
      final asset = await documentStorageService.pickDocument();
      if (asset == null) {
        throw StateError('document_pick_cancelled');
      }
      final updated = await documentStorageService.replaceDocument(
        existing: document,
        asset: asset,
      );
      documents = documents
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(settings.userId),
      );
      return updated;
    } finally {
      isUploadingDocument = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(UserDocument document) async {
    isDeletingDocument = true;
    notifyListeners();
    try {
      await documentStorageService.deleteDocument(document);
      documents = documents
          .where((item) => item.id != document.id)
          .toList(growable: false);
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(settings.userId),
      );
    } finally {
      isDeletingDocument = false;
      notifyListeners();
    }
  }

  Future<UserDocument> linkDocumentToPayment(
    UserDocument document,
    RecurringPayment payment,
  ) async {
    isUploadingDocument = true;
    notifyListeners();
    try {
      final updated = await documentStorageService.linkDocumentToItem(
        document: document,
        linkedItemId: payment.id,
        linkedItemType: LinkedItemType.recurringPayment,
      );
      documents = documents
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(settings.userId),
      );
      return updated;
    } finally {
      isUploadingDocument = false;
      notifyListeners();
    }
  }

  Future<String> getSignedDocumentUrl(UserDocument document) async {
    return documentStorageService.getSignedUrl(document);
  }

  Future<void> uploadPendingDocumentsForItem(
    String linkedItemId,
    List<PickedDocumentAsset> assets, {
    required UserDocumentCategory category,
  }) async {
    if (assets.isEmpty) return;
    isUploadingDocument = true;
    notifyListeners();
    try {
      final uploaded = <UserDocument>[];
      var availableSlots = hasPremiumFeatureAccess
          ? assets.length
          : (documentLimit - documents.length).clamp(0, assets.length);
      for (final asset in assets) {
        if (!hasPremiumFeatureAccess && availableSlots <= 0) {
          throw StateError('document_limit_reached');
        }
        final document = await documentStorageService.uploadDocument(
          userId: settings.userId,
          asset: asset,
          title: _documentTitleFromAsset(asset),
          category: category,
          linkedItemId: linkedItemId,
          linkedItemType: LinkedItemType.recurringPayment,
        );
        uploaded.add(document);
        if (!hasPremiumFeatureAccess) {
          availableSlots -= 1;
        }
      }
      documents = [...uploaded, ...documents];
      _refreshSyncStatus(
        await syncService.syncAfterPaymentChange(settings.userId),
      );
    } finally {
      isUploadingDocument = false;
      notifyListeners();
    }
  }

  Future<DateTime> markPaymentAsPaid(RecurringPayment payment) async {
    final nextDueDate = nextScheduledDueDate(
      payment.nextDueDate,
      payment.frequency,
    );
    final updated = payment.copyWith(
      nextDueDate: nextDueDate,
      status: PaymentStatus.active,
      updatedAt: DateTime.now(),
    );
    await savePayment(updated, original: payment);
    return nextDueDate;
  }

  Future<void> restorePremium() async {
    subscriptionMessage = null;
    isRestoreInProgress = true;
    notifyListeners();
    try {
      final result = await subscriptionService.restorePurchases();
      await _syncPremiumAccessFromBilling();
      _refreshEntitlements();
      notificationPreferences = notificationPreferences.copyWith(
        premiumAccess: hasPremium,
      );
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      subscriptionMessage = result.message;
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isRestoreInProgress = false;
    }
    notifyListeners();
  }

  Future<void> setPremiumOverride(bool enabled) async {
    isSavingSettings = true;
    notifyListeners();
    try {
      userProfile = userProfile.copyWith(
        isPremiumOverride: enabled,
        updatedAt: DateTime.now(),
      );
      _refreshEntitlements();
      await userProfileService.saveProfile(userProfile);
      notificationPreferences = notificationPreferences.copyWith(
        userId: settings.userId,
        defaultReminderTiming: settings.defaultReminderTiming,
        premiumAccess: hasPremium,
      );
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
    } finally {
      isSavingSettings = false;
    }
    notifyListeners();
  }

  Future<SubscriptionActionResult> purchasePremium() async {
    debugPrint('[purchasePremium] Starting purchase flow');
    subscriptionMessage = null;
    isPurchaseInProgress = true;
    notifyListeners();
    late final SubscriptionActionResult result;
    try {
      debugPrint('[purchasePremium] Calling purchaseMonthlySubscription');
      result = await subscriptionService.purchaseMonthlySubscription();
      debugPrint(
        '[purchasePremium] Result — success:${result.success} cancelled:${result.cancelled} premiumActive:${result.premiumActive} message:${result.message}',
      );

      debugPrint('[purchasePremium] Syncing premium access from billing');
      await _syncPremiumAccessFromBilling();
      _refreshEntitlements();
      debugPrint('[purchasePremium] hasPremium after sync: $hasPremium');

      notificationPreferences = notificationPreferences.copyWith(
        premiumAccess: hasPremium,
      );
      await notificationPreferencesService.savePreferences(
        notificationPreferences,
      );
      subscriptionMessage = result.cancelled ? null : result.message;

      debugPrint('[purchasePremium] Syncing smart notifications');
      await _syncSmartNotifications();
      _refreshSyncStatus(
        await syncService.syncAfterSettingsChange(settings.userId),
      );
      debugPrint('[purchasePremium] Purchase flow completed successfully');
    } catch (e, stack) {
      debugPrint('[purchasePremium] ERROR: $e');
      debugPrint('[purchasePremium] Stack: $stack');
      rethrow;
    } finally {
      isPurchaseInProgress = false;
      debugPrint('[purchasePremium] isPurchaseInProgress reset to false');
    }
    notifyListeners();
    return result;
  }

  Future<void> openManageSubscription() async {
    await subscriptionService.openManageSubscriptions();
  }

  Future<void> refreshNotificationPermissionStatus() async {
    notificationsAllowed = await notificationService.areNotificationsEnabled();
    notifyListeners();
  }

  Future<void> openNotificationSettings() async {
    await notificationService.openNotificationSettings();
    notificationsAllowed = await notificationService.areNotificationsEnabled();
    notifyListeners();
  }

  Future<void> sendTestNotification() async {
    await notificationService.showTestNotification();
    notificationsAllowed = notificationService.permissionsGranted;
    notifyListeners();
  }

  Future<void> scheduleDebugNotification() async {
    await notificationService.scheduleDebugNotification();
    notificationsAllowed = notificationService.permissionsGranted;
    notifyListeners();
  }

  Future<void> remindMeAboutCalendarEvent(CalendarEvent event) async {
    await notificationService.scheduleCalendarEventReminder(event);
    notificationsAllowed = notificationService.permissionsGranted;
    notifyListeners();
  }

  Future<void> _syncSmartNotifications() async {
    notificationsAllowed = await notificationService.resyncAllReminders(
      payments: payments,
      settings: settings,
      preferences: notificationPreferences,
      hasPremiumAccess: hasPremium,
      intelligenceService: intelligenceService,
    );
    await _refreshAiInsights();
  }

  Future<void> _refreshAiInsights() async {
    final consent = AiPrivacyConsent(
      enableAiInsights: settings.aiInsightsEnabled,
      useLocalOnlyInsights: settings.aiLocalOnlyEnabled,
      allowCloudAiProcessingLater: settings.aiCloudProcessingEnabled,
    );
    final result = await aiOrchestratorService.buildInsights(
      settings,
      payments,
      isPremiumUser: hasPremiumFeatureAccess,
      consent: consent,
    );
    _aiInsights = result.insights;
    _aiProviderName = result.providerName;
    _aiContextPreview = result.sanitizedContext;
  }

  Future<void> _initializePushNotifications(String userId) async {
    await pushNotificationService.initialize(
      userId: userId,
      onNotificationTap: _handlePushNotificationTap,
    );
    await pushNotificationService.syncDeviceToken(
      userId: userId,
      notificationsEnabled: notificationPreferences.paymentRemindersEnabled,
    );
  }

  Future<void> _handlePushNotificationTap(Map<String, dynamic> data) async {
    final type = data['notification_type']?.toString() ?? '';
    if (type == 'weekly_summary') {
      selectedTab = 3;
    } else if (type == 'calendar') {
      selectedTab = 1;
    } else {
      selectedTab = 0;
    }
    notifyListeners();
  }

  void _applyPreferencesToSettings() {
    settings = settings.copyWith(
      pushRemindersEnabled: notificationPreferences.paymentRemindersEnabled,
      weeklySummaryEnabled: notificationPreferences.weeklySummaryEnabled,
      stillUsingAlertsEnabled: notificationPreferences.stillUsingAlertsEnabled,
      smartSavingsAlertsEnabled: notificationPreferences.savingsInsightsEnabled,
      defaultReminderTiming: notificationPreferences.defaultReminderTiming,
    );
  }

  String get notificationStatusMessage {
    if (!notificationPreferences.paymentRemindersEnabled) {
      return 'Notifications are turned off in Bizoot.';
    }
    if (!notificationsAllowed) {
      return 'Notifications are disabled. Enable them in phone settings to receive savings alerts.';
    }
    return hasPremiumFeatureAccess
        ? 'Smart alerts are active for payments, trials, weekly summaries, and savings insights.'
        : 'Basic payment reminders are active. Unlock premium for trial, weekly, and savings alerts.';
  }

  String get pushPermissionStatusMessage {
    if (!pushNotificationService.isFirebaseReady) {
      return 'Firebase push is not configured yet. Local reminders still work as fallback.';
    }
    if (!pushNotificationService.permissionGranted) {
      return 'Push permission is off. Enable it in system settings to receive cloud alerts.';
    }
    return 'Push permission is enabled for this device.';
  }

  String get pushDeviceStatusMessage {
    if (!pushNotificationService.isFirebaseReady) {
      return 'Device registration is waiting for Firebase setup.';
    }
    if (!pushNotificationService.deviceRegistered) {
      return 'This device is not registered for cloud push yet.';
    }
    final lastSync = pushNotificationService.lastTokenSyncAt;
    return lastSync == null
        ? 'Device token is registered.'
        : 'Device token synced on ${lastSync.month}/${lastSync.day} at ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}.';
  }

  String get pushSyncMessage {
    return pushNotificationService.lastSyncError ??
        'Firebase push token is healthy.';
  }

  Future<void> sendTestPushNotification() async {
    final user = authService.currentUser;
    if (user == null) return;
    await pushNotificationService.syncDeviceToken(
      userId: user.id,
      notificationsEnabled: notificationPreferences.paymentRemindersEnabled,
    );
    await pushNotificationService.sendTestPushNotification(userId: user.id);
    notifyListeners();
  }

  Future<void> syncPushDeviceToken() async {
    final user = authService.currentUser;
    if (user == null) return;
    await pushNotificationService.syncDeviceToken(
      userId: user.id,
      notificationsEnabled: notificationPreferences.paymentRemindersEnabled,
    );
    notifyListeners();
  }

  Future<void> refreshCustomServices() async {
    if (settings.userId.isEmpty) return;
    customServices = await customSubscriptionDatabaseService.listCustomServices(
      settings.userId,
    );
    _refreshSyncStatus(await syncService.syncCustomServices(settings.userId));
    notifyListeners();
  }

  Future<void> updateCustomService(CustomSubscriptionService service) async {
    await customSubscriptionDatabaseService.updateCustomService(service);
    await refreshCustomServices();
  }

  Future<void> deleteCustomService(String serviceId) async {
    await customSubscriptionDatabaseService.deleteCustomService(
      settings.userId,
      serviceId,
    );
    await refreshCustomServices();
  }

  Future<void> submitServiceSuggestionForPayment(
    RecurringPayment payment,
  ) async {
    await customSubscriptionDatabaseService.submitServiceSuggestion(
      userId: authService.currentUser?.id,
      name: payment.name,
      category: payment.category.displayLabel,
      cancellationUrl: payment.cancellationUrl,
      website: '',
    );
  }

  double get monthlySpend => intelligenceService.monthlySpend(payments);
  double get yearlySpend => intelligenceService.yearlySpend(payments);
  int get activeSubscriptionCount =>
      payments.where((item) => item.isActive).length;
  List<RecurringPayment> get activeEssentials => payments
      .where(
        (item) =>
            item.isActive && item.category != PaymentCategory.subscription,
      )
      .toList(growable: false);
  List<RecurringPayment> get activeSubscriptionsOnly => payments
      .where(
        (item) =>
            item.isActive && item.category == PaymentCategory.subscription,
      )
      .toList(growable: false);
  double get monthlyEssentialsSpend =>
      intelligenceService.monthlySpend(activeEssentials);
  double get monthlySubscriptionOnlySpend =>
      intelligenceService.monthlySpend(activeSubscriptionsOnly);
  List<RecurringPayment> get renewalsThisMonth {
    final now = DateTime.now();
    return payments
        .where(
          (item) =>
              item.isActive &&
              ((item.renewalDate != null &&
                      item.renewalDate!.year == now.year &&
                      item.renewalDate!.month == now.month) ||
                  (item.contractEndDate != null &&
                      item.contractEndDate!.year == now.year &&
                      item.contractEndDate!.month == now.month)),
        )
        .toList(growable: false);
  }

  List<RecurringPayment> get itemsMissingManagementLinks => payments
      .where((item) => item.isActive && item.effectiveManagementUrl.isEmpty)
      .toList(growable: false);
  List<UserDocument> linkedDocumentsForItem(String itemId) => documents
      .where((item) => item.linkedItemId == itemId)
      .toList(growable: false);
  List<UserDocument> get unlinkedDocuments => documents
      .where((item) => item.linkedItemId == null)
      .toList(growable: false);
  List<RecurringPayment> get itemsWithSavedLoginDetails => payments
      .where(
        (item) =>
            item.isActive &&
            (item.loginEmail.trim().isNotEmpty ||
                item.username.trim().isNotEmpty),
      )
      .toList(growable: false);
  bool get isPremiumUser => entitlementService.isPremiumUser(userProfile);
  bool get hasPremiumFeatureAccess =>
      entitlementService.hasPremiumFeatureAccess(userProfile);
  int get subscriptionLimit =>
      entitlementService.getSubscriptionLimit(userProfile);
  bool get isTrialActive => entitlementService.isTrialActive(userProfile);
  int get trialDaysRemaining =>
      entitlementService.getTrialDaysRemaining(userProfile);
  bool get canAddSubscription => entitlementService.canAddSubscription(
    userProfile,
    activeSubscriptionCount,
  );
  bool get shouldShowUpgradeWall => entitlementService.shouldShowUpgradeWall(
    userProfile,
    activeSubscriptionCount,
  );
  int get documentLimit => hasPremiumFeatureAccess ? -1 : 2;
  bool get canStoreMoreDocuments =>
      hasPremiumFeatureAccess || documents.length < documentLimit;
  bool get canUseAdvancedInsights =>
      entitlementService.canUseAdvancedInsights(userProfile);
  bool get canUseSmartNotifications =>
      entitlementService.canUseSmartNotifications(userProfile);
  bool get canUseAdvancedReports =>
      entitlementService.canUseAdvancedReports(userProfile);
  bool get canUseCancellationAssistant =>
      entitlementService.canUseCancellationAssistant(userProfile);
  bool get shouldLockAdvancedInsights =>
      entitlementService.shouldLockAdvancedInsights(userProfile);
  bool get shouldLockReports =>
      entitlementService.shouldLockReports(userProfile);
  bool get shouldLockSmartNotifications =>
      entitlementService.shouldLockSmartNotifications(userProfile);
  bool get shouldLockCancellationAssistant =>
      entitlementService.shouldLockCancellationAssistant(userProfile);
  double get safeToSpend => intelligenceService.safeToSpend(settings, payments);
  double get incomeCommitment =>
      intelligenceService.incomeCommitment(settings, payments);
  HealthScoreResult get healthScore =>
      intelligenceService.buildHealthScore(settings, payments);
  List<InsightEvent> get insights =>
      intelligenceService.buildInsights(settings, payments);
  WeeklyReport get weeklyReport =>
      intelligenceService.buildWeeklyReport(settings, payments);
  FinancialIntelligenceSnapshot get intelligenceSnapshot =>
      intelligenceService.buildSnapshot(
        settings,
        payments,
        isPremiumUser: hasPremiumFeatureAccess,
      );
  List<PremiumInsightCardData> get premiumInsights =>
      intelligenceSnapshot.insights;
  EngagementSummary get engagementSummary => intelligenceSnapshot.engagement;
  SubscriptionRiskReport get subscriptionRisk =>
      intelligenceSnapshot.riskReport;
  AdvancedReportSnapshot get advancedReport => intelligenceSnapshot.report;
  List<FutureAiOpportunity> get futureAiOpportunities =>
      intelligenceSnapshot.futureAiOpportunities;
  List<SmartNotificationOpportunity> get smartNotificationPreview =>
      smartNotificationService.buildSmartNotifications(
        settings,
        payments,
        isPremiumUser: hasPremiumFeatureAccess,
      );
  List<SmartInsightCard> get smartInsights =>
      smartInsightsService.buildInsights(
        settings,
        payments,
        isPremiumUser: hasPremiumFeatureAccess,
      );
  List<AiInsight> get aiInsights => _aiInsights;
  SmartControlSnapshot get smartControlSnapshot =>
      smartControlService.buildSnapshot(
        settings,
        payments,
        hasPremiumAccess: hasPremiumFeatureAccess,
        documents: documents,
      );
  List<CalendarEvent> get calendarEvents {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 2, 1);
    final to = DateTime(now.year, now.month + 4, 0);
    return recurringLifeCalendarService.buildEvents(
      payments,
      from: from,
      to: to,
      hasPremiumAccess: hasPremiumFeatureAccess,
    );
  }

  List<CalendarEvent> get upcomingCalendarEvents =>
      recurringLifeCalendarService.upcomingTimeline(
        payments,
        hasPremiumAccess: hasPremiumFeatureAccess,
        withinDays: 30,
      );
  String get aiProviderName => _aiProviderName;
  AiUserContext get aiContextPreview => _aiContextPreview;
  double get savings => potentialSavings(payments);
  Locale get currentLocale =>
      AppLocale.localeFromPreference(settings.preferredLanguage);

  RecurringPayment? get nextUpcoming {
    final active = payments.where((item) => item.isActive).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return active.isEmpty ? null : active.first;
  }

  RecurringPayment? get nextCriticalBill {
    final active = activeEssentials.toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return active.isEmpty ? null : active.first;
  }

  bool isDuplicate(String name, PaymentCategory category, {String? ignoreId}) {
    final normalized = name.trim().toLowerCase();
    return payments.any(
      (item) =>
          item.id != ignoreId &&
          (item.name.toLowerCase().contains(normalized) ||
              normalized.contains(item.name.toLowerCase())) &&
          item.category == category,
    );
  }

  void _refreshEntitlements() {
    hasPremium = hasPremiumFeatureAccess;
  }

  Future<void> _syncPremiumAccessFromBilling() async {
    final entitlementActive = await subscriptionService
        .checkPremiumEntitlement();
    if (userProfile.isPremiumOverride == entitlementActive) {
      return;
    }
    userProfile = userProfile.copyWith(
      isPremiumOverride: entitlementActive,
      updatedAt: DateTime.now(),
    );
    await userProfileService.saveProfile(userProfile);
  }

  void _refreshSyncStatus(SyncStatusSnapshot status) {
    isSyncingData = status.isSyncing;
    isOfflineMode = status.isOfflineMode;
    hasPendingSyncChanges = status.hasPendingChanges;
    syncErrorMessage = status.lastError;
    lastSyncedAt = status.lastSyncedAt;
  }

  void _applySyncBundle(SyncBundle bundle) {
    userProfile = bundle.userProfile;
    settings = bundle.settings;
    notificationPreferences = bundle.notificationPreferences;
    payments = bundle.payments;
    documents = bundle.documents;
    customServices = bundle.customServices;
    isSyncingData = bundle.status.isSyncing;
    isOfflineMode = bundle.status.isOfflineMode;
    hasPendingSyncChanges = bundle.status.hasPendingChanges;
    syncErrorMessage = bundle.status.lastError;
    lastSyncedAt = bundle.status.lastSyncedAt;
  }

  void setSelectedTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  UserSettings _mergeProfileIntoSettings(
    UserSettings base,
    UserProfile profile,
  ) {
    return base.copyWith(
      userId: profile.userId,
      monthlyIncome: profile.monthlyIncome,
      currency: profile.preferredCurrency,
      country: profile.country,
      preferredLanguage: profile.preferredLanguage,
      financialGoal: profile.financialGoal,
      estimatedSubscriptions: profile.estimatedSubscriptions,
      onboardingCompleted: profile.onboardingCompleted,
    );
  }

  String _documentTitleFromAsset(PickedDocumentAsset asset) {
    final name = asset.fileName.contains('.')
        ? asset.fileName.substring(0, asset.fileName.lastIndexOf('.'))
        : asset.fileName;
    return name.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }

  Future<void> _normalizePaymentCurrencies() async {
    final targetCurrency = settings.currency.trim().toUpperCase();
    if (targetCurrency.isEmpty || payments.isEmpty) return;

    final nextPayments = <RecurringPayment>[];
    var changed = false;

    for (final payment in payments) {
      final currentCurrency = payment.currency.trim().toUpperCase();
      if (currentCurrency == targetCurrency) {
        nextPayments.add(payment);
        continue;
      }

      final normalized = payment.copyWith(
        currency: targetCurrency,
        updatedAt: DateTime.now(),
      );
      final saved = await paymentService.updatePayment(payment, normalized);
      nextPayments.add(saved);
      changed = true;
    }

    if (changed) {
      payments = nextPayments;
    }
  }

  Future<void> _enforceActiveItemLimitIfNeeded() async {
    if (isPremiumUser) return;
    final limit = subscriptionLimit;
    if (limit < 0) return;

    final activeItems = payments.where((item) => item.isActive).toList()
      ..sort((a, b) {
        final createdComparison = a.createdAt.compareTo(b.createdAt);
        if (createdComparison != 0) return createdComparison;
        return a.nextDueDate.compareTo(b.nextDueDate);
      });

    if (activeItems.length <= limit) return;

    final overflowIds = activeItems.skip(limit).map((item) => item.id).toSet();
    final nextPayments = <RecurringPayment>[];
    var changed = false;

    for (final payment in payments) {
      if (!overflowIds.contains(payment.id)) {
        nextPayments.add(payment);
        continue;
      }

      final normalized = payment.copyWith(
        status: PaymentStatus.inactive,
        updatedAt: DateTime.now(),
      );
      final saved = await paymentService.updatePayment(payment, normalized);
      nextPayments.add(saved);
      changed = true;
    }

    if (changed) {
      payments = nextPayments;
    }
  }

  Future<void> _normalizePreferredLanguage() async {
    final normalizedSettingsLanguage = AppLocale.normalizeLanguageCode(
      settings.preferredLanguage,
    );
    final normalizedProfileLanguage = AppLocale.normalizeLanguageCode(
      userProfile.preferredLanguage,
    );
    var settingsChanged = false;
    var profileChanged = false;

    if (normalizedSettingsLanguage != settings.preferredLanguage) {
      settings = settings.copyWith(
        preferredLanguage: normalizedSettingsLanguage,
      );
      settingsChanged = true;
    }

    if (normalizedProfileLanguage != userProfile.preferredLanguage) {
      userProfile = userProfile.copyWith(
        preferredLanguage: normalizedProfileLanguage,
        updatedAt: DateTime.now(),
      );
      profileChanged = true;
    }

    if (settingsChanged) {
      await settingsService.saveSettings(settings);
      await settingsService.savePreferredLanguage(settings.preferredLanguage);
    }

    if (isAuthenticated && profileChanged) {
      await userProfileService.saveProfile(userProfile);
    }
  }

  Future<void> _normalizePaymentDisplayNames() async {
    if (payments.isEmpty) return;

    final nextPayments = <RecurringPayment>[];
    var changed = false;

    for (final payment in payments) {
      final normalizedName = BrandIconService.instance.canonicalDisplayName(
        payment.name,
        serviceId: payment.iconKey,
        iconKey: payment.iconKey,
      );

      if (normalizedName == payment.name) {
        nextPayments.add(payment);
        continue;
      }

      final normalized = payment.copyWith(
        name: normalizedName,
        updatedAt: DateTime.now(),
      );
      final saved = await paymentService.updatePayment(payment, normalized);
      nextPayments.add(saved);
      changed = true;
    }

    if (changed) {
      payments = nextPayments;
    }
  }

  Future<void> _normalizePaymentCategories() async {
    if (payments.isEmpty) return;

    final nextPayments = <RecurringPayment>[];
    var changed = false;

    for (final payment in payments) {
      final normalizedCategory = _normalizedCategoryForPayment(payment);
      final normalizedEssential = normalizedCategory.isEssential;

      if (normalizedCategory == payment.category &&
          normalizedEssential == payment.isEssential) {
        nextPayments.add(payment);
        continue;
      }

      final normalized = payment.copyWith(
        category: normalizedCategory,
        isEssential: normalizedEssential,
        updatedAt: DateTime.now(),
      );
      final saved = await paymentService.updatePayment(payment, normalized);
      nextPayments.add(saved);
      changed = true;
    }

    if (changed) {
      payments = nextPayments;
    }
  }

  PaymentCategory _normalizedCategoryForPayment(RecurringPayment payment) {
    final match = BrandIconService.instance.resolve(
      serviceId: payment.iconKey,
      serviceName: payment.name,
      iconKey: payment.iconKey,
    );

    switch (match.canonicalSlug) {
      case 'houserent':
      case 'apartmentrent':
      case 'rent':
        return PaymentCategory.rent;
      default:
        return payment.category;
    }
  }
}
