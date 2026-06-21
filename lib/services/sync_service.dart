import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_subscription_service.dart';
import '../models/notification_preferences.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';
import 'custom_subscription_database_service.dart';
import 'document_storage_service.dart';
import 'notification_preferences_service.dart';
import 'payment_service.dart';
import 'settings_service.dart';
import 'user_profile_service.dart';

class SyncStatusSnapshot {
  final bool isSyncing;
  final bool isOfflineMode;
  final bool hasPendingChanges;
  final DateTime? lastSyncedAt;
  final String? lastError;

  const SyncStatusSnapshot({
    required this.isSyncing,
    required this.isOfflineMode,
    required this.hasPendingChanges,
    required this.lastSyncedAt,
    required this.lastError,
  });

  const SyncStatusSnapshot.idle()
    : isSyncing = false,
      isOfflineMode = false,
      hasPendingChanges = false,
      lastSyncedAt = null,
      lastError = null;
}

class SyncBundle {
  final UserProfile userProfile;
  final UserSettings settings;
  final NotificationPreferences notificationPreferences;
  final List<RecurringPayment> payments;
  final List<UserDocument> documents;
  final List<CustomSubscriptionService> customServices;
  final SyncStatusSnapshot status;

  const SyncBundle({
    required this.userProfile,
    required this.settings,
    required this.notificationPreferences,
    required this.payments,
    required this.documents,
    required this.customServices,
    required this.status,
  });
}

class SyncService {
  SyncService({
    required this.cloudSyncEnabled,
    required this.userProfileService,
    required this.settingsService,
    required this.notificationPreferencesService,
    required this.paymentService,
    required this.documentStorageService,
    required this.customSubscriptionDatabaseService,
  });

  final bool cloudSyncEnabled;
  final UserProfileService userProfileService;
  final SettingsService settingsService;
  final NotificationPreferencesService notificationPreferencesService;
  final PaymentService paymentService;
  final DocumentStorageService documentStorageService;
  final CustomSubscriptionDatabaseService customSubscriptionDatabaseService;
  bool get _cloudSyncEnabled => cloudSyncEnabled;

  static const _lastSyncedPrefix = 'sync_last_synced_at_';
  static const _lastErrorPrefix = 'sync_last_error_';
  static const _pendingPrefix = 'sync_pending_changes_';
  static const _offlinePrefix = 'sync_offline_mode_';

  Future<SyncBundle> syncOnLogin(String userId) async {
    return _syncAll(userId);
  }

  Future<SyncBundle> syncOnAppStart(String userId) async {
    return _syncAll(userId);
  }

  Future<SyncStatusSnapshot> syncAfterPaymentChange(String userId) async {
    final bundle = await _syncAll(userId);
    return bundle.status;
  }

  Future<SyncStatusSnapshot> syncAfterSettingsChange(String userId) async {
    final bundle = await _syncAll(userId);
    return bundle.status;
  }

  Future<SyncStatusSnapshot> syncCustomServices(String userId) async {
    final bundle = await _syncAll(userId);
    return bundle.status;
  }

  Future<SyncBundle> pullRemoteData(String userId) async {
    if (!_cloudSyncEnabled) {
      final localProfile = await userProfileService.loadLocalProfile(userId);
      final localSettings = await settingsService.loadLocalSettings(userId);
      final localPreferences = await notificationPreferencesService
          .loadLocalPreferences(userId);
      final localPayments = await paymentService.fetchLocalPayments(userId);
      final localDocuments = await documentStorageService.fetchLocalDocuments(
        userId,
      );
      final localCustom = await customSubscriptionDatabaseService
          .listLocalCustomServices(userId);
      return SyncBundle(
        userProfile: localProfile,
        settings: localSettings,
        notificationPreferences: localPreferences,
        payments: localPayments,
        documents: localDocuments,
        customServices: localCustom,
        status: await _readStatus(userId),
      );
    }

    final remoteProfile =
        await userProfileService.loadRemoteProfile(userId) ??
        UserProfile.defaults(userId: userId);
    final remoteSettings =
        await settingsService.loadRemoteSettings(userId) ??
        UserSettings.defaults().copyWith(userId: userId);
    final remotePreferences =
        await notificationPreferencesService.loadRemotePreferences(userId) ??
        NotificationPreferences.defaults(userId: userId);
    final remotePayments = await paymentService.fetchRemotePayments(userId);
    final remoteDocuments = await documentStorageService.fetchRemoteDocuments(
      userId,
    );
    final remoteCustom = await customSubscriptionDatabaseService
        .listRemoteCustomServices(userId);

    return SyncBundle(
      userProfile: remoteProfile,
      settings: remoteSettings,
      notificationPreferences: remotePreferences,
      payments: remotePayments,
      documents: remoteDocuments,
      customServices: remoteCustom,
      status: await _readStatus(userId),
    );
  }

  Future<SyncStatusSnapshot> pushLocalPendingChanges(String userId) async {
    if (!_cloudSyncEnabled) {
      return _writeStatus(
        userId,
        isSyncing: false,
        isOfflineMode: true,
        hasPendingChanges: true,
        lastError: 'Cloud sync is not available in this build.',
      );
    }

    try {
      final localProfile = await userProfileService.loadLocalProfile(userId);
      final localSettings = await settingsService.loadLocalSettings(userId);
      final localPreferences = await notificationPreferencesService
          .loadLocalPreferences(userId);
      final localPayments = await paymentService.fetchLocalPayments(userId);
      final localDocuments = await documentStorageService.fetchLocalDocuments(
        userId,
      );
      final localCustom = await customSubscriptionDatabaseService
          .listLocalCustomServices(userId);
      final deletedPayments = await paymentService.listDeletedPaymentIds(
        userId,
      );
      final deletedDocuments = await documentStorageService
          .listDeletedDocumentIds(userId);
      final deletedCustom = await customSubscriptionDatabaseService
          .listDeletedCustomServiceIds(userId);

      await userProfileService.saveRemoteProfile(localProfile);
      await settingsService.saveRemoteSettings(localSettings);
      await notificationPreferencesService.saveRemotePreferences(
        localPreferences,
      );
      await paymentService.upsertRemotePayments(
        localPayments
            .where((item) => !deletedPayments.contains(item.id))
            .toList(growable: false),
      );
      await documentStorageService.upsertRemoteDocuments(
        localDocuments
            .where((item) => !deletedDocuments.contains(item.id))
            .toList(growable: false),
      );
      for (final paymentId in deletedPayments) {
        await paymentService.deleteRemotePayment(paymentId);
      }
      for (final documentId in deletedDocuments) {
        await documentStorageService.deleteRemoteDocument(documentId);
      }
      await customSubscriptionDatabaseService.upsertRemoteCustomServices(
        localCustom
            .where((item) => !deletedCustom.contains(item.id))
            .toList(growable: false),
      );
      for (final serviceId in deletedCustom) {
        await customSubscriptionDatabaseService.deleteRemoteCustomService(
          serviceId,
        );
      }

      await paymentService.clearDeletedPaymentIds(userId, deletedPayments);
      await documentStorageService.clearDeletedDocumentIds(
        userId,
        deletedDocuments,
      );
      await customSubscriptionDatabaseService.clearDeletedCustomServiceIds(
        userId,
        deletedCustom,
      );
      return _writeStatus(
        userId,
        isSyncing: false,
        isOfflineMode: false,
        hasPendingChanges: false,
        lastError: null,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error) {
      return _writeStatus(
        userId,
        isSyncing: false,
        isOfflineMode: true,
        hasPendingChanges: true,
        lastError: error.toString(),
      );
    }
  }

  Future<SyncBundle> resolveConflicts(String userId) async {
    final localProfile = await userProfileService.loadLocalProfile(userId);
    final localSettings = await settingsService.loadLocalSettings(userId);
    final localPreferences = await notificationPreferencesService
        .loadLocalPreferences(userId);
    final localPayments = await paymentService.fetchLocalPayments(userId);
    final localDocuments = await documentStorageService.fetchLocalDocuments(
      userId,
    );
    final localCustom = await customSubscriptionDatabaseService
        .listLocalCustomServices(userId);

    UserProfile mergedProfile = localProfile;
    UserSettings mergedSettings = localSettings;
    NotificationPreferences mergedPreferences = localPreferences;
    var mergedPayments = localPayments;
    var mergedDocuments = localDocuments;
    var mergedCustomServices = localCustom;

    if (_cloudSyncEnabled) {
      try {
        final remoteProfile = await userProfileService.loadRemoteProfile(
          userId,
        );
        final remoteSettings = await settingsService.loadRemoteSettings(userId);
        final remotePreferences = await notificationPreferencesService
            .loadRemotePreferences(userId);
        final remotePayments = await paymentService.fetchRemotePayments(userId);
        final remoteDocuments = await documentStorageService
            .fetchRemoteDocuments(userId);
        final remoteCustom = await customSubscriptionDatabaseService
            .listRemoteCustomServices(userId);
        final deletedPayments = await paymentService.listDeletedPaymentIds(
          userId,
        );
        final deletedDocuments = await documentStorageService
            .listDeletedDocumentIds(userId);
        final deletedCustom = await customSubscriptionDatabaseService
            .listDeletedCustomServiceIds(userId);

        mergedProfile = _pickNewestProfile(localProfile, remoteProfile);
        mergedSettings = _pickNewestSettings(localSettings, remoteSettings);
        mergedPreferences = _pickNewestPreferences(
          localPreferences,
          remotePreferences,
        );
        mergedPayments = _mergeByUpdatedAt<RecurringPayment>(
          localPayments,
          remotePayments,
          deletedIds: deletedPayments,
          idOf: (item) => item.id,
          updatedAtOf: (item) => item.updatedAt,
        );
        mergedDocuments = _mergeByUpdatedAt<UserDocument>(
          localDocuments,
          remoteDocuments,
          deletedIds: deletedDocuments,
          idOf: (item) => item.id,
          updatedAtOf: (item) => item.updatedAt,
        );
        mergedCustomServices = _mergeByUpdatedAt<CustomSubscriptionService>(
          localCustom,
          remoteCustom,
          deletedIds: deletedCustom,
          idOf: (item) => item.id,
          updatedAtOf: (item) => item.updatedAt,
        );

        await userProfileService.saveLocalProfile(mergedProfile);
        await settingsService.saveLocalSettings(mergedSettings);
        await notificationPreferencesService.saveLocalPreferences(
          mergedPreferences,
        );
        await paymentService.saveLocalPayments(userId, mergedPayments);
        await documentStorageService.saveLocalDocuments(
          userId,
          mergedDocuments,
        );
        await customSubscriptionDatabaseService.saveLocalServices(
          userId,
          mergedCustomServices,
        );

        await userProfileService.saveRemoteProfile(mergedProfile);
        await settingsService.saveRemoteSettings(mergedSettings);
        await notificationPreferencesService.saveRemotePreferences(
          mergedPreferences,
        );
        await paymentService.upsertRemotePayments(mergedPayments);
        await documentStorageService.upsertRemoteDocuments(mergedDocuments);
        await customSubscriptionDatabaseService.upsertRemoteCustomServices(
          mergedCustomServices,
        );
        for (final paymentId in deletedPayments) {
          await paymentService.deleteRemotePayment(paymentId);
        }
        for (final documentId in deletedDocuments) {
          await documentStorageService.deleteRemoteDocument(documentId);
        }
        for (final serviceId in deletedCustom) {
          await customSubscriptionDatabaseService.deleteRemoteCustomService(
            serviceId,
          );
        }
        await paymentService.clearDeletedPaymentIds(userId, deletedPayments);
        await documentStorageService.clearDeletedDocumentIds(
          userId,
          deletedDocuments,
        );
        await customSubscriptionDatabaseService.clearDeletedCustomServiceIds(
          userId,
          deletedCustom,
        );
      } catch (error) {
        final status = await _writeStatus(
          userId,
          isSyncing: false,
          isOfflineMode: true,
          hasPendingChanges: true,
          lastError: error.toString(),
        );
        return SyncBundle(
          userProfile: mergedProfile,
          settings: mergedSettings,
          notificationPreferences: mergedPreferences,
          payments: mergedPayments,
          documents: mergedDocuments,
          customServices: mergedCustomServices,
          status: status,
        );
      }
    }

    final status = await _writeStatus(
      userId,
      isSyncing: false,
      isOfflineMode: !_cloudSyncEnabled,
      hasPendingChanges: false,
      lastError: null,
      lastSyncedAt: _cloudSyncEnabled ? DateTime.now() : null,
    );
    return SyncBundle(
      userProfile: mergedProfile,
      settings: mergedSettings,
      notificationPreferences: mergedPreferences,
      payments: mergedPayments,
      documents: mergedDocuments,
      customServices: mergedCustomServices,
      status: status,
    );
  }

  Future<void> clearLocalCacheOnLogout(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_lastSyncedPrefix$userId');
    await prefs.remove('$_lastErrorPrefix$userId');
    await prefs.remove('$_pendingPrefix$userId');
    await prefs.remove('$_offlinePrefix$userId');
  }

  Future<void> deleteRemoteAccountData(String userId) async {
    if (!_cloudSyncEnabled) return;
    await paymentService.deleteAllRemotePayments(userId);
    await documentStorageService.deleteAllRemoteDocuments(userId);
    await customSubscriptionDatabaseService.deleteAllRemoteCustomServices(
      userId,
    );
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final privateCollection = userDoc.collection('private');
    await privateCollection.doc('notification_preferences').delete().catchError(
      (_) {
        return;
      },
    );
    await privateCollection.doc('settings').delete().catchError((_) {
      return;
    });
    await privateCollection.doc('profile').delete().catchError((_) {
      return;
    });
  }

  Future<SyncBundle> _syncAll(String userId) async {
    await _writeStatus(userId, isSyncing: true);
    await pushLocalPendingChanges(userId);
    return resolveConflicts(userId);
  }

  UserProfile _pickNewestProfile(UserProfile local, UserProfile? remote) {
    if (remote == null) return local;
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }

  UserSettings _pickNewestSettings(UserSettings local, UserSettings? remote) {
    if (remote == null) return local;
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }

  NotificationPreferences _pickNewestPreferences(
    NotificationPreferences local,
    NotificationPreferences? remote,
  ) {
    if (remote == null) return local;
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }

  List<T> _mergeByUpdatedAt<T>(
    List<T> local,
    List<T> remote, {
    required Set<String> deletedIds,
    required String Function(T item) idOf,
    required DateTime Function(T item) updatedAtOf,
  }) {
    final merged = <String, T>{};
    for (final item in [...remote, ...local]) {
      final id = idOf(item);
      if (deletedIds.contains(id)) continue;
      final existing = merged[id];
      if (existing == null ||
          updatedAtOf(item).isAfter(updatedAtOf(existing))) {
        merged[id] = item;
      }
    }
    final values = merged.values.toList(growable: false);
    values.sort((a, b) => updatedAtOf(b).compareTo(updatedAtOf(a)));
    return values;
  }

  Future<SyncStatusSnapshot> _readStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return SyncStatusSnapshot(
      isSyncing: false,
      isOfflineMode: prefs.getBool('$_offlinePrefix$userId') ?? false,
      hasPendingChanges: prefs.getBool('$_pendingPrefix$userId') ?? false,
      lastSyncedAt: DateTime.tryParse(
        prefs.getString('$_lastSyncedPrefix$userId') ?? '',
      ),
      lastError: prefs.getString('$_lastErrorPrefix$userId'),
    );
  }

  Future<SyncStatusSnapshot> _writeStatus(
    String userId, {
    bool? isSyncing,
    bool? isOfflineMode,
    bool? hasPendingChanges,
    DateTime? lastSyncedAt,
    String? lastError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _readStatus(userId);
    final next = SyncStatusSnapshot(
      isSyncing: isSyncing ?? current.isSyncing,
      isOfflineMode: isOfflineMode ?? current.isOfflineMode,
      hasPendingChanges: hasPendingChanges ?? current.hasPendingChanges,
      lastSyncedAt: lastSyncedAt ?? current.lastSyncedAt,
      lastError: lastError,
    );
    await prefs.setBool('$_offlinePrefix$userId', next.isOfflineMode);
    await prefs.setBool('$_pendingPrefix$userId', next.hasPendingChanges);
    if (next.lastSyncedAt != null) {
      await prefs.setString(
        '$_lastSyncedPrefix$userId',
        next.lastSyncedAt!.toIso8601String(),
      );
    }
    if (next.lastError == null || next.lastError!.isEmpty) {
      await prefs.remove('$_lastErrorPrefix$userId');
    } else {
      await prefs.setString('$_lastErrorPrefix$userId', next.lastError!);
    }
    return next;
  }
}
