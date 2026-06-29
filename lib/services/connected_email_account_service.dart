import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/connected_email_account.dart';

class ConnectedEmailAccountService {
  ConnectedEmailAccountService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKeyPrefix = 'bizoot_connected_email_accounts_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';

  Future<List<ConnectedEmailAccount>> loadAccounts(String userId) async {
    return loadLocalAccounts(userId);
  }

  Future<List<ConnectedEmailAccount>> loadRemoteAccounts(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('connected_email_accounts')
        .get();
    final data = snapshot.data();
    if (data == null) return const [];

    final rawAccounts = (data['accounts'] as List<dynamic>? ?? const []);
    return rawAccounts
        .whereType<Map<String, dynamic>>()
        .map(ConnectedEmailAccount.fromMap)
        .toList(growable: false);
  }

  Future<List<ConnectedEmailAccount>> loadLocalAccounts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ConnectedEmailAccount.fromMap)
        .toList(growable: false);
  }

  Future<void> saveAccounts(
    String userId,
    List<ConnectedEmailAccount> accounts,
  ) async {
    await saveLocalAccounts(userId, accounts);
  }

  Future<void> saveRemoteAccounts(
    String userId,
    List<ConnectedEmailAccount> accounts,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('connected_email_accounts')
        .set({
          'accounts': accounts
              .map((item) => item.toMap())
              .toList(growable: false),
          'updated_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
  }

  Future<void> saveLocalAccounts(
    String userId,
    List<ConnectedEmailAccount> accounts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(userId),
      jsonEncode(accounts.map((item) => item.toMap()).toList(growable: false)),
    );
  }

  Future<void> clearLocalCache([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null && userId.isNotEmpty) {
      await prefs.remove(_keyForUser(userId));
      return;
    }
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_localKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }
}
