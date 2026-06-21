import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_subscription_service.dart';
import '../models/recurring_payment.dart';
import 'subscription_database_service.dart';

class SubscriptionSuggestionItem {
  final String id;
  final String name;
  final String category;
  final String cancellationUrl;
  final String website;
  final String icon;
  final String commonBilling;
  final double? amount;
  final List<String> aliases;
  final bool isCustom;

  const SubscriptionSuggestionItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cancellationUrl,
    required this.website,
    required this.icon,
    required this.commonBilling,
    required this.amount,
    required this.aliases,
    required this.isCustom,
  });

  String get badgeLabel => isCustom ? 'Your saved service' : 'Bizoot database';
}

class MergedSubscriptionSearchResults {
  final List<SubscriptionSuggestionItem> knownServices;
  final List<SubscriptionSuggestionItem> customServices;

  const MergedSubscriptionSearchResults({
    required this.knownServices,
    required this.customServices,
  });
}

class CustomSubscriptionDatabaseService {
  CustomSubscriptionDatabaseService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;
  static const _localKeyPrefix = 'custom_subscription_services_';
  static const _deletedKeyPrefix = 'deleted_custom_subscription_services_';
  CollectionReference<Map<String, dynamic>> _customServicesCollection(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('custom_services');
  }

  String normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<List<CustomSubscriptionService>> listCustomServices(
    String userId,
  ) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await listRemoteCustomServices(userId);
        await _saveLocal(userId, remote);
        return remote;
      } catch (_) {
        // Fall back to the last local snapshot if cloud sync is unavailable.
      }
    }

    return listLocalCustomServices(userId);
  }

  Future<List<CustomSubscriptionService>> listRemoteCustomServices(
    String userId,
  ) async {
    final snapshot = await _customServicesCollection(
      userId,
    ).orderBy('usage_count', descending: true).orderBy('name').get();
    return snapshot.docs
        .map(
          (doc) =>
              CustomSubscriptionService.fromMap({...doc.data(), 'id': doc.id}),
        )
        .toList(growable: false);
  }

  Future<List<CustomSubscriptionService>> listLocalCustomServices(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_localKeyPrefix$userId');
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (item) =>
              CustomSubscriptionService.fromMap(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<List<CustomSubscriptionService>> searchCustomServices(
    String userId,
    String query,
  ) async {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.length < 2) return const [];
    final services = await listCustomServices(userId);
    final ranked = <({CustomSubscriptionService service, int score})>[];

    for (final service in services) {
      final score = _scoreCustomService(service, normalizedQuery);
      if (score > 0) {
        ranked.add((service: service, score: score));
      }
    }

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.service.usageCount.compareTo(a.service.usageCount);
    });

    return ranked.map((item) => item.service).take(8).toList(growable: false);
  }

  Future<CustomSubscriptionService> upsertCustomServiceFromPayment(
    String userId,
    RecurringPayment payment,
  ) async {
    final normalizedName = normalize(payment.name);
    final services = await listCustomServices(userId);
    CustomSubscriptionService? existing;
    for (final service in services) {
      if (service.normalizedName == normalizedName) {
        existing = service;
        break;
      }
    }
    final now = DateTime.now();

    final nextService =
        (existing ??
                CustomSubscriptionService(
                  id:
                      existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  userId: userId,
                  name: payment.name.trim(),
                  normalizedName: normalizedName,
                  category: payment.category,
                  frequency: payment.frequency,
                  amount: payment.amount > 0 ? payment.amount : null,
                  cancellationUrl: payment.cancellationUrl.trim(),
                  website: '',
                  icon: payment.iconKey,
                  aliases: const [],
                  createdAt: now,
                  updatedAt: now,
                  usageCount: 0,
                  isUserCreated: true,
                ))
            .copyWith(
              name: payment.name.trim().isNotEmpty
                  ? payment.name.trim()
                  : existing?.name,
              category: payment.category,
              frequency: payment.frequency,
              amount: payment.amount > 0 ? payment.amount : existing?.amount,
              cancellationUrl: payment.cancellationUrl.trim().isNotEmpty
                  ? payment.cancellationUrl.trim()
                  : (existing?.cancellationUrl ?? ''),
              icon: payment.iconKey.isNotEmpty
                  ? payment.iconKey
                  : (existing?.icon ?? 'credit_card'),
              updatedAt: now,
              usageCount: (existing?.usageCount ?? 0) + 1,
            );

    final local = [
      ...services.where((service) => service.normalizedName != normalizedName),
      nextService,
    ];
    await _saveLocal(userId, local);
    if (cloudSyncEnabled) {
      try {
        await upsertRemoteCustomServices([nextService]);
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
    return nextService;
  }

  Future<void> incrementUsageCount(String userId, String serviceId) async {
    final services = await listCustomServices(userId);
    final index = services.indexWhere((service) => service.id == serviceId);
    if (index == -1) return;
    final updated = services[index].copyWith(
      usageCount: services[index].usageCount + 1,
      updatedAt: DateTime.now(),
    );
    services[index] = updated;
    if (cloudSyncEnabled) {
      try {
        await _customServicesCollection(userId).doc(serviceId).set({
          'usage_count': updated.usageCount,
          'updated_at': updated.updatedAt.toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
    await _saveLocal(userId, services);
  }

  Future<MergedSubscriptionSearchResults> mergeWithMainDatabaseResults(
    String query, {
    required String userId,
    required List<SubscriptionServiceEntry> mainServices,
    required List<CustomSubscriptionService> customServices,
  }) async {
    final mainResults = _searchMainServices(mainServices, query)
        .map(
          (service) => SubscriptionSuggestionItem(
            id: service.id,
            name: service.name,
            category: service.category,
            cancellationUrl: service.cancelUrl ?? '',
            website: service.website,
            icon: service.icon,
            commonBilling: service.commonBilling,
            amount: service.averageMonthlyCost > 0
                ? service.averageMonthlyCost
                : null,
            aliases: service.aliases,
            isCustom: false,
          ),
        )
        .toList(growable: false);

    final customResults = _searchCustomServicesFromList(customServices, query)
        .map(
          (service) => SubscriptionSuggestionItem(
            id: service.id,
            name: service.name,
            category: service.category.displayLabel,
            cancellationUrl: service.cancellationUrl,
            website: service.website,
            icon: service.icon,
            commonBilling: service.frequency.name,
            amount: service.amount,
            aliases: service.aliases,
            isCustom: true,
          ),
        )
        .toList(growable: false);

    return MergedSubscriptionSearchResults(
      knownServices: mainResults,
      customServices: customResults,
    );
  }

  List<CustomSubscriptionService> _searchCustomServicesFromList(
    List<CustomSubscriptionService> services,
    String query,
  ) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.length < 2) return const [];
    final ranked = <({CustomSubscriptionService service, int score})>[];
    for (final service in services) {
      final score = _scoreCustomService(service, normalizedQuery);
      if (score > 0) {
        ranked.add((service: service, score: score));
      }
    }
    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.service.usageCount.compareTo(a.service.usageCount);
    });
    return ranked.map((item) => item.service).take(8).toList(growable: false);
  }

  Future<void> updateCustomService(CustomSubscriptionService service) async {
    final services = await listCustomServices(service.userId);
    final updatedService = service.copyWith(updatedAt: DateTime.now());
    final next = services
        .map((item) => item.id == service.id ? updatedService : item)
        .toList();
    if (cloudSyncEnabled) {
      try {
        await _customServicesCollection(
          service.userId,
        ).doc(service.id).set(updatedService.toMap(), SetOptions(merge: true));
      } catch (_) {
        // Keep the local snapshot and let SyncService retry later.
      }
    }
    await _saveLocal(service.userId, next);
  }

  Future<void> deleteCustomService(String userId, String serviceId) async {
    final services = await listCustomServices(userId);
    final next = services
        .where((service) => service.id != serviceId)
        .toList(growable: false);
    await _saveLocal(userId, next);
    await recordDeletedCustomServiceId(userId, serviceId);
    if (cloudSyncEnabled) {
      try {
        await deleteRemoteCustomService(serviceId);
        await clearDeletedCustomServiceIds(userId, {serviceId});
      } catch (_) {
        // Keep the tombstone and let SyncService retry later.
      }
    }
  }

  Future<void> clearLocalCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_localKeyPrefix$userId');
    await prefs.remove('$_deletedKeyPrefix$userId');
  }

  Future<void> submitServiceSuggestion({
    required String? userId,
    required String name,
    required String category,
    required String cancellationUrl,
    required String website,
  }) async {
    if (!cloudSyncEnabled) return;
    await FirebaseFirestore.instance.collection('service_suggestions').add({
      'user_id': userId,
      'name': name,
      'normalized_name': normalize(name),
      'category': category,
      'cancellation_url': cancellationUrl,
      'website': website,
      'source': 'user_submission',
      'status': 'pending',
    });
  }

  List<SubscriptionServiceEntry> _searchMainServices(
    List<SubscriptionServiceEntry> services,
    String query,
  ) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.length < 2) return const [];
    final ranked = <({SubscriptionServiceEntry service, int score})>[];
    for (final service in services) {
      final score = _scoreMainService(service, normalizedQuery);
      if (score > 0) {
        ranked.add((service: service, score: score));
      }
    }
    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.service.name.compareTo(b.service.name);
    });
    return ranked.map((item) => item.service).take(8).toList(growable: false);
  }

  int _scoreMainService(
    SubscriptionServiceEntry service,
    String normalizedQuery,
  ) {
    final name = normalize(service.name);
    final id = normalize(service.id);
    final aliases = service.aliases.map(normalize).toList(growable: false);
    final tags = service.tags.map(normalize).toList(growable: false);

    if (name == normalizedQuery || id == normalizedQuery) {
      return 1000;
    }
    if (aliases.contains(normalizedQuery)) {
      return 950;
    }

    var score = 0;
    if (name.startsWith(normalizedQuery)) {
      score = score < 900 ? 900 : score;
    }
    if (aliases.any((alias) => alias.startsWith(normalizedQuery))) {
      score = score < 860 ? 860 : score;
    }
    if (name.contains(normalizedQuery)) {
      score = score < 760 ? 760 : score;
    }
    if (aliases.any((alias) => alias.contains(normalizedQuery))) {
      score = score < 720 ? 720 : score;
    }
    if (tags.any((tag) => tag.contains(normalizedQuery))) {
      score = score < 620 ? 620 : score;
    }
    return score;
  }

  int _scoreCustomService(
    CustomSubscriptionService service,
    String normalizedQuery,
  ) {
    if (service.normalizedName == normalizedQuery) {
      return 1000;
    }
    if (service.normalizedName.startsWith(normalizedQuery)) {
      return 900;
    }
    if (service.aliases
        .map(normalize)
        .any((alias) => alias.startsWith(normalizedQuery))) {
      return 860;
    }
    if (service.normalizedName.contains(normalizedQuery)) {
      return 760;
    }
    if (service.aliases
        .map(normalize)
        .any((alias) => alias.contains(normalizedQuery))) {
      return 720;
    }
    return 0;
  }

  Future<void> _saveLocal(
    String userId,
    List<CustomSubscriptionService> services,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_localKeyPrefix$userId',
      jsonEncode(services.map((service) => service.toMap()).toList()),
    );
  }

  Future<void> saveLocalServices(
    String userId,
    List<CustomSubscriptionService> services,
  ) {
    return _saveLocal(userId, services);
  }

  Future<void> upsertRemoteCustomServices(
    List<CustomSubscriptionService> services,
  ) async {
    if (services.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final service in services) {
      batch.set(
        _customServicesCollection(service.userId).doc(service.id),
        service.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> deleteRemoteCustomService(String serviceId) async {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('custom_services')
        .where(FieldPath.documentId, isEqualTo: serviceId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.delete();
  }

  Future<void> deleteAllRemoteCustomServices(String userId) async {
    final snapshot = await _customServicesCollection(userId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> recordDeletedCustomServiceId(
    String userId,
    String serviceId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList('$_deletedKeyPrefix$userId') ?? const <String>[];
    final next = {...existing, serviceId}.toList(growable: false);
    await prefs.setStringList('$_deletedKeyPrefix$userId', next);
  }

  Future<Set<String>> listDeletedCustomServiceIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('$_deletedKeyPrefix$userId') ??
            const <String>[])
        .toSet();
  }

  Future<void> clearDeletedCustomServiceIds(
    String userId,
    Set<String> ids,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList('$_deletedKeyPrefix$userId') ?? const <String>[];
    final next = existing
        .where((id) => !ids.contains(id))
        .toList(growable: false);
    if (next.isEmpty) {
      await prefs.remove('$_deletedKeyPrefix$userId');
      return;
    }
    await prefs.setStringList('$_deletedKeyPrefix$userId', next);
  }
}
