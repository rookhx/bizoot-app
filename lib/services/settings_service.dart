import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

class SettingsService {
  SettingsService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKey = 'flutter_user_settings';
  static const _localKeyPrefix = 'flutter_user_settings_';
  static const _preferredLanguageKey = 'flutter_preferred_language';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<UserSettings> loadSettings(String userId) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await loadRemoteSettings(userId);
        if (remote != null) {
          await saveLocalSettings(remote);
          return remote;
        }
      } catch (_) {
        // Fall back to the last local snapshot if cloud sync is unavailable.
      }
    }

    return loadLocalSettings(userId);
  }

  Future<UserSettings?> loadRemoteSettings(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('settings')
        .get();
    final data = snapshot.data();
    if (data == null) return null;
    return _fromMap(data, userId);
  }

  Future<UserSettings> loadLocalSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null) {
      return UserSettings.defaults().copyWith(
        userId: userId,
        onboardingCompleted: false,
      );
    }
    return _fromMap(jsonDecode(raw) as Map<String, dynamic>, userId);
  }

  Future<void> saveSettings(UserSettings settings) async {
    final nextSettings = settings.copyWith(updatedAt: DateTime.now());
    await saveLocalSettings(nextSettings);
    if (cloudSyncEnabled) {
      try {
        await saveRemoteSettings(nextSettings);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
  }

  Future<void> saveRemoteSettings(UserSettings settings) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(settings.userId)
        .collection('private')
        .doc('settings')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Future<void> saveLocalSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(settings.userId),
      jsonEncode(settings.toMap()),
    );
  }

  Future<String?> loadPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredLanguageKey);
  }

  Future<void> savePreferredLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredLanguageKey, languageCode);
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    await prefs.remove(_preferredLanguageKey);
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_localKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }

  UserSettings _fromMap(Map<String, dynamic> map, String fallbackUserId) {
    return UserSettings(
      userId: map['user_id'] as String? ?? fallbackUserId,
      monthlyIncome: (map['monthly_income'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      country: map['country'] as String? ?? 'United States',
      preferredLanguage: map['preferred_language'] as String? ?? 'English',
      financialGoal: map['financial_goal'] as String? ?? 'Save money',
      estimatedSubscriptions: map['estimated_subscriptions'] as int? ?? 0,
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
      defaultReminderTiming:
          map['default_reminder_timing'] as String? ?? 'oneDayBefore',
      dateFormat: map['date_format'] as String? ?? 'MMM d, yyyy',
      firstDayOfWeek: map['first_day_of_week'] as String? ?? 'Monday',
      compactModeEnabled: map['compact_mode_enabled'] as bool? ?? false,
      pushRemindersEnabled: map['push_reminders_enabled'] as bool? ?? true,
      weeklySummaryEnabled: map['weekly_summary_enabled'] as bool? ?? true,
      stillUsingAlertsEnabled:
          map['still_using_alerts_enabled'] as bool? ?? true,
      smartSavingsAlertsEnabled:
          map['smart_savings_alerts_enabled'] as bool? ?? true,
      aiInsightsEnabled: map['ai_insights_enabled'] as bool? ?? true,
      aiLocalOnlyEnabled: map['ai_local_only_enabled'] as bool? ?? true,
      aiCloudProcessingEnabled:
          map['ai_cloud_processing_enabled'] as bool? ?? false,
      darkMode: map['dark_mode'] as bool? ?? false,
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
