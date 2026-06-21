import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProfileService {
  UserProfileService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKeyPrefix = 'flutter_user_profile_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<UserProfile> loadProfile(String userId) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await loadRemoteProfile(userId);
        if (remote != null) {
          await saveLocalProfile(remote);
          return remote;
        }
      } catch (_) {
        // Fall back to local cache if cloud sync is unavailable.
      }
    }

    return loadLocalProfile(userId);
  }

  Future<UserProfile?> loadRemoteProfile(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('profile')
        .get();
    final data = snapshot.data();
    if (data == null) return null;
    return UserProfile.fromMap(data, fallbackUserId: userId);
  }

  Future<UserProfile> loadLocalProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null) {
      return UserProfile.defaults(userId: userId);
    }
    return UserProfile.fromMap(
      jsonDecode(raw) as Map<String, dynamic>,
      fallbackUserId: userId,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final nextProfile = profile.copyWith(updatedAt: DateTime.now());
    await saveLocalProfile(nextProfile);
    if (cloudSyncEnabled) {
      try {
        await saveRemoteProfile(nextProfile);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
  }

  Future<void> saveRemoteProfile(UserProfile profile) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(profile.userId)
        .collection('private')
        .doc('profile')
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> saveLocalProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(profile.userId),
      jsonEncode(profile.toMap()),
    );
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_localKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }
}
