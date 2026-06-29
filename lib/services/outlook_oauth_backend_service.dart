import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/outlook_oauth_backend_state.dart';

class OutlookOAuthBackendService {
  OutlookOAuthBackendService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKeyPrefix = 'bizoot_outlook_oauth_state_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<OutlookOAuthBackendState?> loadState(String userId) async {
    if (userId.isEmpty) return null;
    if (cloudSyncEnabled) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return OutlookOAuthBackendState.fromMap(data);
  }

  Future<void> saveState(OutlookOAuthBackendState state) async {
    if (state.userId.isEmpty) return;
    if (cloudSyncEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(state.userId), jsonEncode(state.toMap()));
  }

  Future<void> clearState(String userId) async {
    if (userId.isEmpty) return;
    if (cloudSyncEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUser(userId));
  }
}
