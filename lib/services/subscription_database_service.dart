import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/recurring_payment.dart';

class SubscriptionServiceEntry {
  final String id;
  final String name;
  final String category;
  final List<String> aliases;
  final String website;
  final String? cancelUrl;
  final String cancelUrlType;
  final String icon;
  final String color;
  final String commonBilling;
  final double averageMonthlyCost;
  final List<String> tags;

  const SubscriptionServiceEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.aliases,
    required this.website,
    required this.cancelUrl,
    required this.cancelUrlType,
    required this.icon,
    required this.color,
    required this.commonBilling,
    required this.averageMonthlyCost,
    required this.tags,
  });

  factory SubscriptionServiceEntry.fromJson(Map<String, dynamic> json) {
    final service = SubscriptionServiceEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      website: json['website'] as String? ?? '',
      cancelUrl: ((json['cancelUrl'] ??
                  json['cancel_url'] ??
                  json['cancellationUrl'] ??
                  json['cancellation_url'] ??
                  json['cancelLink'] ??
                  json['billingUrl'] ??
                  json['accountUrl']) as String?)
              ?.trim(),
      cancelUrlType: (json['cancelUrlType'] ?? json['cancel_url_type']) as String? ?? 'direct',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '#7C4DFF',
      commonBilling: (json['commonBilling'] ?? json['common_billing'] ?? json['frequency']) as String? ?? 'monthly',
      averageMonthlyCost:
          ((json['averageMonthlyCost'] ?? json['average_monthly_cost'] ?? json['price']) as num?)?.toDouble() ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
    );

    debugPrint('Loaded service: ${service.name} URL: ${service.cancelUrl}');
    return service;
  }

  factory SubscriptionServiceEntry.fromProviderRegistryJson(Map<String, dynamic> json) {
    final logo = (json['logo'] as String? ?? '').trim();
    final iconSlug = logo.isEmpty ? (json['id'] as String? ?? '') : logo.replaceAll(RegExp(r'\.(png|svg)$', caseSensitive: false), '');
    return SubscriptionServiceEntry(
      id: json['id'] as String? ?? '',
      name: (json['displayName'] ?? json['name']) as String? ?? '',
      category: json['category'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      website: json['website'] as String? ?? '',
      cancelUrl: (json['cancellationUrl'] as String?)?.trim(),
      cancelUrlType: 'direct',
      icon: iconSlug,
      color: '#7C4DFF',
      commonBilling: ((json['defaultFrequency'] ?? json['frequency']) as String? ?? 'monthly').toLowerCase(),
      averageMonthlyCost: ((json['averageMonthlyCost'] ?? json['price']) as num?)?.toDouble() ?? 0,
      tags: const [],
    );
  }
}

class SubscriptionDatabaseService {
  SubscriptionDatabaseService._();

  static final SubscriptionDatabaseService instance = SubscriptionDatabaseService._();

  static const _assetPath = 'assets/data/subscription_services.json';
  static const _providerRegistryAssetPath = 'assets/data/bizoot_top_100_provider_registry.json';

  List<SubscriptionServiceEntry> _services = const [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<SubscriptionServiceEntry> get allServices => _services;

  Future<void> initialize() async {
    if (_loaded) return;
    await loadServices();
  }

  Future<List<SubscriptionServiceEntry>> loadServices() async {
    if (_loaded) return _services;
    final merged = <SubscriptionServiceEntry>[];
    final seen = <String>{};

    final primaryRaw = await rootBundle.loadString(_assetPath);
    final primaryDecoded = jsonDecode(primaryRaw) as List<dynamic>;
    for (final item in primaryDecoded) {
      final entry = SubscriptionServiceEntry.fromJson(item as Map<String, dynamic>);
      if (entry.name.isEmpty) continue;
      if (seen.add(normalize(entry.id.isNotEmpty ? entry.id : entry.name))) {
        merged.add(entry);
      }
    }

    try {
      final registryRaw = await rootBundle.loadString(_providerRegistryAssetPath);
      final registryDecoded = jsonDecode(registryRaw) as Map<String, dynamic>;
      final providers = (registryDecoded['providers'] as List<dynamic>? ?? const []);
      for (final item in providers) {
        final entry = SubscriptionServiceEntry.fromProviderRegistryJson(item as Map<String, dynamic>);
        if (entry.name.isEmpty) continue;
        if (seen.add(normalize(entry.id.isNotEmpty ? entry.id : entry.name))) {
          merged.add(entry);
        }
      }
    } catch (error) {
      debugPrint('Provider registry not loaded: $error');
    }

    _services = merged.toList(growable: false);
    _loaded = true;
    final withUrls = _services.where((service) => (service.cancelUrl ?? '').trim().isNotEmpty).toList(growable: false);
    final missingUrls = _services.where((service) => (service.cancelUrl ?? '').trim().isEmpty).toList(growable: false);
    debugPrint('Loaded services: ${_services.length}');
    debugPrint('Services with cancelUrl: ${withUrls.length}');
    debugPrint('Services missing cancelUrl: ${missingUrls.length}');
    debugPrint('Missing cancelUrl examples: ${missingUrls.take(20).map((service) => service.name).join(', ')}');
    return _services;
  }

  Future<List<SubscriptionServiceEntry>> loadDatabase() => loadServices();

  SubscriptionServiceEntry? findExactMatch(String input) {
    final normalizedInput = normalize(input);
    if (normalizedInput.isEmpty) return null;

    for (final service in _services) {
      if (_normalizedCandidates(service).contains(normalizedInput)) {
        return service;
      }
    }
    return null;
  }

  SubscriptionServiceEntry? findServiceByName(String input) => findExactMatch(input);

  SubscriptionServiceEntry? fuzzyMatchService(String input) {
    final normalizedInput = normalize(input);
    if (normalizedInput.length < 3) return null;

    SubscriptionServiceEntry? bestMatch;
    int bestScore = 0;

    for (final service in _services) {
      final score = _scoreService(service, normalizedInput);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = service;
      }
    }

    if (bestScore >= 45 && bestMatch != null) {
      return bestMatch;
    }

    return null;
  }

  SubscriptionServiceEntry? findBestMatch(String input) {
    return findExactMatch(input) ?? fuzzyMatchService(input);
  }

  List<SubscriptionServiceEntry> searchServices(String input, {int limit = 8}) {
    final normalizedInput = normalize(input.trim());
    if (normalizedInput.length < 2) return const [];

    final ranked = <({SubscriptionServiceEntry service, int score})>[];

    for (final service in _services) {
      final score = _searchScore(service, normalizedInput);
      if (score > 0) {
        ranked.add((service: service, score: score));
      }
    }

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.service.name.compareTo(b.service.name);
    });

    final unique = <SubscriptionServiceEntry>[];
    final seenIds = <String>{};
    for (final item in ranked) {
      if (seenIds.add(item.service.id)) {
        unique.add(item.service);
      }
      if (unique.length >= limit) break;
    }

    return unique;
  }

  String? getCancelUrl(String input) => findBestMatch(input)?.cancelUrl;

  String? getCategory(String input) => findBestMatch(input)?.category;

  String getSuggestedIcon(SubscriptionServiceEntry service) {
    final normalizedCategory = service.category.toLowerCase();
    final tags = service.tags.map((item) => item.toLowerCase()).toList();

    if (service.icon.contains('spotify') || tags.contains('music') || tags.contains('audio') || tags.contains('podcast')) {
      return 'music';
    }
    if (tags.contains('video') || tags.contains('streaming') || normalizedCategory.contains('video')) {
      return 'movie';
    }
    if (normalizedCategory.contains('cloud') || tags.contains('storage')) {
      return 'cloud';
    }
    if (normalizedCategory.contains('fitness') || tags.contains('fitness') || tags.contains('health')) {
      return 'fitness';
    }
    if (normalizedCategory.contains('gaming') || tags.contains('gaming')) {
      return 'gamepad';
    }
    if (normalizedCategory.contains('vpn') || normalizedCategory.contains('security') || tags.contains('security')) {
      return 'shield';
    }
    if (normalizedCategory.contains('shopping') || normalizedCategory.contains('delivery') || tags.contains('delivery')) {
      return 'cart';
    }
    if (normalizedCategory.contains('finance') || normalizedCategory.contains('business') || tags.contains('finance')) {
      return 'money';
    }
    if (normalizedCategory.contains('learning') || normalizedCategory.contains('education') || tags.contains('learning')) {
      return 'book';
    }
    if (normalizedCategory.contains('ai') || tags.contains('ai')) {
      return 'robot';
    }
    if (normalizedCategory.contains('news') || normalizedCategory.contains('media')) {
      return 'news';
    }
    if (normalizedCategory.contains('productivity') || normalizedCategory.contains('software') || normalizedCategory.contains('developer')) {
      return 'briefcase';
    }
    if (normalizedCategory.contains('utility') || service.name.toLowerCase().contains('internet')) {
      return 'wifi';
    }
    if (service.name.toLowerCase().contains('phone')) {
      return 'phone';
    }
    if (normalizedCategory.contains('rent')) {
      return 'home';
    }
    return 'credit_card';
  }

  PaymentCategory getSuggestedPaymentCategory(SubscriptionServiceEntry service) {
    final category = service.category.toLowerCase();

    if (category.contains('rent')) return PaymentCategory.rent;
    if (category.contains('utility')) return PaymentCategory.utilities;
    if (category.contains('insurance')) return PaymentCategory.insurance;
    if (category.contains('internet')) return PaymentCategory.internet;
    if (category.contains('phone') || category.contains('mobile')) return PaymentCategory.phone;
    if (category.contains('fitness') || category.contains('health')) return PaymentCategory.gym;
    if (category.contains('loan') || category.contains('finance')) return PaymentCategory.loan;
    if (category.contains('contract')) return PaymentCategory.contract;
    if (category.contains('business') || category.contains('membership')) return PaymentCategory.membership;
    return PaymentCategory.subscription;
  }

  PaymentFrequency getSuggestedFrequency(SubscriptionServiceEntry service) {
    switch (service.commonBilling.toLowerCase()) {
      case 'weekly':
        return PaymentFrequency.weekly;
      case 'quarterly':
        return PaymentFrequency.quarterly;
      case 'yearly':
      case 'annual':
        return PaymentFrequency.yearly;
      default:
        return PaymentFrequency.monthly;
    }
  }

  String normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Iterable<String> _normalizedCandidates(SubscriptionServiceEntry service) sync* {
    yield normalize(service.id);
    yield normalize(service.name);
    for (final alias in service.aliases) {
      yield normalize(alias);
    }
    for (final tag in service.tags) {
      yield normalize(tag);
    }
  }

  int _scoreService(SubscriptionServiceEntry service, String normalizedInput) {
    int score = 0;
    final name = normalize(service.name);
    final id = normalize(service.id);

    if (name == normalizedInput || id == normalizedInput) return 100;
    if (name.startsWith(normalizedInput) || normalizedInput.startsWith(name)) score += 65;
    if (name.contains(normalizedInput) || normalizedInput.contains(name)) score += 55;

    for (final alias in service.aliases) {
      final normalizedAlias = normalize(alias);
      if (normalizedAlias == normalizedInput) return 95;
      if (normalizedAlias.startsWith(normalizedInput) || normalizedInput.startsWith(normalizedAlias)) score = score < 60 ? 60 : score;
      if (normalizedAlias.contains(normalizedInput) || normalizedInput.contains(normalizedAlias)) score = score < 52 ? 52 : score;
    }

    for (final tag in service.tags) {
      final normalizedTag = normalize(tag);
      if (normalizedTag == normalizedInput) score = score < 40 ? 40 : score;
    }

    return score;
  }

  int _searchScore(SubscriptionServiceEntry service, String normalizedInput) {
    final normalizedName = normalize(service.name);
    final normalizedId = normalize(service.id);
    final normalizedAliases = service.aliases.map(normalize).toList(growable: false);
    final normalizedTags = service.tags.map(normalize).toList(growable: false);
    final queryTokens = _tokenize(normalizedInput);
    final nameTokens = _tokenize(normalizedName);

    if (normalizedName == normalizedInput || normalizedId == normalizedInput) {
      return 1000;
    }

    for (final alias in normalizedAliases) {
      if (alias == normalizedInput) {
        return 960;
      }
    }

    var score = 0;

    if (normalizedName.startsWith(normalizedInput)) score = score < 900 ? 900 : score;
    if (normalizedId.startsWith(normalizedInput)) score = score < 880 ? 880 : score;

    for (final alias in normalizedAliases) {
      if (alias.startsWith(normalizedInput)) {
        score = score < 860 ? 860 : score;
      }
    }

    if (normalizedName.contains(normalizedInput)) score = score < 760 ? 760 : score;
    if (normalizedId.contains(normalizedInput)) score = score < 740 ? 740 : score;

    for (final alias in normalizedAliases) {
      if (alias.contains(normalizedInput)) {
        score = score < 720 ? 720 : score;
      }
    }

    for (final tag in normalizedTags) {
      if (tag.startsWith(normalizedInput) || tag.contains(normalizedInput)) {
        score = score < 620 ? 620 : score;
      }
    }

    final initials = nameTokens.where((token) => token.isNotEmpty).map((token) => token[0]).join();
    if (initials.startsWith(normalizedInput)) {
      score = score < 610 ? 610 : score;
    }

    for (final token in nameTokens) {
      if (token.startsWith(normalizedInput)) {
        score = score < 700 ? 700 : score;
      }
    }

    for (final token in queryTokens) {
      if (token.isEmpty) continue;
      if (normalizedName.contains(token)) score += 4;
      for (final alias in normalizedAliases) {
        if (alias.contains(token)) {
          score += 3;
          break;
        }
      }
      for (final tag in normalizedTags) {
        if (tag.contains(token)) {
          score += 2;
          break;
        }
      }
    }

    return score;
  }

  List<String> _tokenize(String input) {
    return input
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }
}
