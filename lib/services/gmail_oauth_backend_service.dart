import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gmail_oauth_backend_state.dart';

class GmailOAuthBackendService {
  GmailOAuthBackendService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKeyPrefix = 'bizoot_gmail_oauth_state_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<GmailOAuthBackendState?> loadState(String userId) async {
    if (userId.isEmpty) return null;
    if (cloudSyncEnabled) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return GmailOAuthBackendState.fromMap(data);
  }

  Future<void> saveState(GmailOAuthBackendState state) async {
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
