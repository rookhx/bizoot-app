import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_preferences.dart';

class NotificationPreferencesService {
  NotificationPreferencesService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKey = 'flutter_notification_preferences';
  static const _localKeyPrefix = 'flutter_notification_preferences_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<NotificationPreferences> loadPreferences(String userId) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await loadRemotePreferences(userId);
        if (remote != null) {
          await saveLocalPreferences(remote);
          return remote;
        }
      } catch (_) {
        // Fall back to the last local snapshot if cloud sync is unavailable.
      }
    }

    return loadLocalPreferences(userId);
  }

  Future<NotificationPreferences?> loadRemotePreferences(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('notification_preferences')
        .get();
    final data = snapshot.data();
    if (data == null) return null;
    return NotificationPreferences.fromMap(data, fallbackUserId: userId);
  }

  Future<NotificationPreferences> loadLocalPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null) {
      return NotificationPreferences.defaults(userId: userId);
    }

    return NotificationPreferences.fromMap(
      jsonDecode(raw) as Map<String, dynamic>,
      fallbackUserId: userId,
    );
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final nextPreferences = preferences.copyWith(updatedAt: DateTime.now());
    await saveLocalPreferences(nextPreferences);
    if (cloudSyncEnabled) {
      try {
        await saveRemotePreferences(nextPreferences);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
  }

  Future<void> saveRemotePreferences(
    NotificationPreferences preferences,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(preferences.userId)
        .collection('private')
        .doc('notification_preferences')
        .set(preferences.toMap(), SetOptions(merge: true));
  }

  Future<void> saveLocalPreferences(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(preferences.userId),
      jsonEncode(preferences.toMap()),
    );
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_localKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }
}
