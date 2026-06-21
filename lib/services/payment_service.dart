import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recurring_payment.dart';
import '../utils/mock_data.dart';

class PaymentService {
  PaymentService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKey = 'flutter_recurring_payments';
  static const _localKeyPrefix = 'flutter_recurring_payments_';
  static const _deletedKeyPrefix = 'flutter_deleted_recurring_payments_';

  String _keyForUser(String userId) => '$_localKeyPrefix$userId';
  String _deletedKeyForUser(String userId) => '$_deletedKeyPrefix$userId';
  CollectionReference<Map<String, dynamic>> _paymentsCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('payments');
  }

  Future<List<RecurringPayment>> fetchPayments(String userId) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await fetchRemotePayments(userId);
        await saveLocalPayments(userId, remote);
        return remote;
      } catch (_) {
        // Fall back to the local snapshot if cloud sync is unavailable.
      }
    }

    return fetchLocalPayments(userId);
  }

  Future<List<RecurringPayment>> fetchRemotePayments(String userId) async {
    final snapshot = await _paymentsCollection(
      userId,
    ).orderBy('next_due_date').get();
    return snapshot.docs
        .map((doc) => _fromMap({...doc.data(), 'id': doc.id}))
        .toList(growable: false);
  }

  Future<List<RecurringPayment>> fetchLocalPayments(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null) {
      return userId == 'mock-user' ? mockPayments : const [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => _fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<RecurringPayment> createPayment(RecurringPayment payment) async {
    await _upsertLocalPayment(payment);
    if (cloudSyncEnabled) {
      try {
        await upsertRemotePayments([payment]);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
    return payment;
  }

  Future<RecurringPayment> updatePayment(
    RecurringPayment original,
    RecurringPayment updated,
  ) async {
    final nextPayment = updated.amount != original.amount
        ? updated.copyWith(
            priceHistory: [
              PriceHistoryEntry(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                paymentId: updated.id,
                oldAmount: original.amount,
                newAmount: updated.amount,
                changedAt: DateTime.now(),
                changeReason: null,
              ),
              ...original.priceHistory,
            ],
          )
        : updated;

    await _upsertLocalPayment(nextPayment);
    if (cloudSyncEnabled) {
      try {
        await upsertRemotePayments([nextPayment]);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
    return nextPayment;
  }

  Future<void> deletePayment(String userId, String paymentId) async {
    final items = await fetchLocalPayments(userId);
    final next = items
        .where((item) => item.id != paymentId)
        .toList(growable: false);
    await saveLocalPayments(userId, next);
    await recordDeletedPaymentId(userId, paymentId);
    if (cloudSyncEnabled) {
      try {
        await deleteRemotePayment(paymentId);
        await clearDeletedPaymentIds(userId, {paymentId});
      } catch (_) {
        // Keep the tombstone and let SyncService retry later.
      }
    }
  }

  Future<void> upsertRemotePayments(List<RecurringPayment> payments) async {
    if (payments.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final payment in payments) {
      batch.set(
        _paymentsCollection(payment.userId).doc(payment.id),
        payment.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> deleteRemotePayment(String paymentId) async {
    final paymentsByUser = await FirebaseFirestore.instance
        .collectionGroup('payments')
        .where(FieldPath.documentId, isEqualTo: paymentId)
        .limit(1)
        .get();
    if (paymentsByUser.docs.isEmpty) return;
    await paymentsByUser.docs.first.reference.delete();
  }

  Future<void> deleteAllRemotePayments(String userId) async {
    final snapshot = await _paymentsCollection(userId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> saveLocalPayments(
    String userId,
    List<RecurringPayment> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(userId),
      jsonEncode(items.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> recordDeletedPaymentId(String userId, String paymentId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds =
        prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[];
    final next = {...deletedIds, paymentId}.toList(growable: false);
    await prefs.setStringList(_deletedKeyForUser(userId), next);
  }

  Future<Set<String>> listDeletedPaymentIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[])
        .toSet();
  }

  Future<void> clearDeletedPaymentIds(String userId, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[];
    final next = existing
        .where((id) => !ids.contains(id))
        .toList(growable: false);
    if (next.isEmpty) {
      await prefs.remove(_deletedKeyForUser(userId));
      return;
    }
    await prefs.setStringList(_deletedKeyForUser(userId), next);
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    for (final key in prefs.getKeys().where(
      (key) =>
          key.startsWith(_localKeyPrefix) || key.startsWith(_deletedKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }

  Future<void> _upsertLocalPayment(RecurringPayment payment) async {
    final items = await fetchLocalPayments(payment.userId);
    final index = items.indexWhere((item) => item.id == payment.id);
    final next = [...items];
    if (index == -1) {
      next.add(payment);
    } else {
      next[index] = payment;
    }
    await saveLocalPayments(payment.userId, next);
  }

  RecurringPayment _fromMap(Map<String, dynamic> map) {
    return RecurringPayment(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'mock-user',
      name: map['name'] as String? ?? '',
      providerName: map['provider_name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      category: RecurringPayment.categoryFromString(
        map['category'] as String? ?? 'other',
      ),
      frequency: RecurringPayment.frequencyFromString(
        map['frequency'] as String? ?? 'monthly',
      ),
      nextDueDate:
          DateTime.tryParse(map['next_due_date'] as String? ?? '') ??
          DateTime.now(),
      renewalDate: map['renewal_date'] == null
          ? null
          : DateTime.tryParse(map['renewal_date'] as String),
      contractEndDate: map['contract_end_date'] == null
          ? null
          : DateTime.tryParse(map['contract_end_date'] as String),
      reminderEnabled: map['reminder_enabled'] as bool? ?? true,
      reminderTiming: RecurringPayment.reminderTimingFromString(
        map['reminder_timing'] as String? ?? 'oneDayBefore',
      ),
      status: RecurringPayment.statusFromString(
        map['status'] as String? ?? 'active',
      ),
      isTrial: map['is_trial'] as bool? ?? false,
      trialEndDate: map['trial_end_date'] == null
          ? null
          : DateTime.tryParse(map['trial_end_date'] as String),
      trialReminderEnabled: map['trial_reminder_enabled'] as bool? ?? false,
      convertsToPaidAmount: (map['converts_to_paid_amount'] as num?)
          ?.toDouble(),
      trialNotes: map['trial_notes'] as String? ?? '',
      cancellationUrl: map['cancellation_url'] as String? ?? '',
      managementUrl: map['management_url'] as String? ?? '',
      cancellationNotes: map['cancellation_notes'] as String? ?? '',
      loginEmail: map['login_email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      signInMethod: RecurringPayment.signInMethodFromString(
        map['sign_in_method'] as String? ?? 'email',
      ),
      passwordHint: map['password_hint'] as String? ?? '',
      recoveryEmail: map['recovery_email'] as String? ?? '',
      accountNotes: map['account_notes'] as String? ?? '',
      policyNumber: map['policy_number'] as String? ?? '',
      documentLabel: map['document_label'] as String? ?? '',
      isEssential: map['is_essential'] as bool? ?? false,
      isCancellable: map['is_cancellable'] as bool? ?? true,
      cancellationStatus: RecurringPayment.cancellationStatusFromString(
        map['cancellation_status'] as String? ?? 'active',
      ),
      cancelledAt: map['cancelled_at'] == null
          ? null
          : DateTime.tryParse(map['cancelled_at'] as String),
      iconKey: map['icon_key'] as String? ?? 'credit_card',
      priceHistory:
          ((map['price_history'] as List<dynamic>?) ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (item) =>
                    PriceHistoryEntry.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false),
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
