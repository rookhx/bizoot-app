import '../models/custom_subscription_service.dart';
import '../models/detected_subscription_candidate.dart';
import '../models/recurring_payment.dart';
import '../services/brand_icon_service.dart';
import 'subscription_database_service.dart';

class SubscriptionCandidateMatcher {
  const SubscriptionCandidateMatcher();

  Future<List<DetectedSubscriptionCandidate>> matchCandidates({
    required List<DetectedSubscriptionCandidate> candidates,
    required List<RecurringPayment> existingPayments,
    required List<CustomSubscriptionService> customServices,
  }) async {
    await SubscriptionDatabaseService.instance.initialize();

    return candidates
        .map((candidate) {
          final databaseMatch = _findDatabaseMatch(candidate);
          final customMatch = _findCustomMatch(candidate, customServices);
          final brandMatch = BrandIconService.instance.resolve(
            serviceId: candidate.providerSlugHint,
            serviceName: candidate.serviceName,
            iconKey: candidate.iconHint,
          );
          final duplicate = _findDuplicate(
            candidate: candidate,
            existingPayments: existingPayments,
            databaseMatch: databaseMatch,
            customMatch: customMatch,
            brandMatch: brandMatch,
          );

          final matchedCanonicalName =
              databaseMatch?.name ??
              customMatch?.name ??
              _canonicalNameFromBrand(candidate, brandMatch);
          final matchedServiceId =
              databaseMatch?.id ??
              customMatch?.id ??
              _matchedServiceIdFromBrand(brandMatch);
          final matchedCategory = databaseMatch != null
              ? SubscriptionDatabaseService.instance
                    .getSuggestedPaymentCategory(databaseMatch)
              : customMatch?.category;
          final matchedFrequency =
              customMatch?.frequency ??
              candidate.billingFrequency ??
              (databaseMatch != null
                  ? SubscriptionDatabaseService.instance.getSuggestedFrequency(
                      databaseMatch,
                    )
                  : null);
          final resolvedIconHint =
              candidate.iconHint ??
              databaseMatch?.icon ??
              customMatch?.icon ??
              (brandMatch.canonicalSlug.isNotEmpty
                  ? brandMatch.canonicalSlug
                  : null);
          final resolvedProviderSlug = brandMatch.canonicalSlug.isNotEmpty
              ? brandMatch.canonicalSlug
              : (candidate.providerSlugHint ?? databaseMatch?.id);

          return candidate.copyWith(
            serviceName: matchedCanonicalName ?? candidate.serviceName,
            normalizedServiceName: SubscriptionDatabaseService.instance
                .normalize(matchedCanonicalName ?? candidate.serviceName),
            merchantLabel: candidate.merchantLabel ?? matchedCanonicalName,
            category: matchedCategory ?? candidate.category,
            billingFrequency: matchedFrequency,
            website:
                candidate.website ??
                databaseMatch?.website ??
                customMatch?.website,
            cancellationUrl:
                candidate.cancellationUrl ??
                databaseMatch?.cancelUrl ??
                customMatch?.cancellationUrl,
            iconHint: resolvedIconHint,
            providerSlugHint: resolvedProviderSlug,
            matchedServiceId: matchedServiceId,
            matchedCanonicalName: matchedCanonicalName,
            duplicatePaymentId: duplicate?.payment.id,
            duplicateReason: duplicate?.reason,
          );
        })
        .toList(growable: false);
  }

  SubscriptionServiceEntry? _findDatabaseMatch(
    DetectedSubscriptionCandidate candidate,
  ) {
    final database = SubscriptionDatabaseService.instance;
    final inputs = _candidateInputs(candidate);

    SubscriptionServiceEntry? bestMatch;
    var bestScore = 0;

    for (final service in database.allServices) {
      final score = _scoreDatabaseMatch(
        candidate: candidate,
        service: service,
        inputs: inputs,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMatch = service;
      }
    }

    if (bestScore >= 65) {
      return bestMatch;
    }

    for (final input in inputs) {
      final direct = database.findBestMatch(input);
      if (direct != null) {
        return direct;
      }
    }

    return null;
  }

  CustomSubscriptionService? _findCustomMatch(
    DetectedSubscriptionCandidate candidate,
    List<CustomSubscriptionService> customServices,
  ) {
    CustomSubscriptionService? bestMatch;
    var bestScore = 0;

    for (final service in customServices) {
      final score = _scoreCustomMatch(candidate, service);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = service;
      }
    }

    return bestScore >= 70 ? bestMatch : null;
  }

  _DuplicateMatch? _findDuplicate({
    required DetectedSubscriptionCandidate candidate,
    required List<RecurringPayment> existingPayments,
    required SubscriptionServiceEntry? databaseMatch,
    required CustomSubscriptionService? customMatch,
    required BrandIconMatch brandMatch,
  }) {
    _DuplicateMatch? bestMatch;
    var bestScore = 0;

    final canonicalName =
        databaseMatch?.name ??
        customMatch?.name ??
        _canonicalNameFromBrand(candidate, brandMatch) ??
        candidate.serviceName;
    final normalizedCandidateName = SubscriptionDatabaseService.instance
        .normalize(canonicalName);

    for (final payment in existingPayments) {
      final score = _scoreDuplicate(
        candidate: candidate,
        payment: payment,
        normalizedCandidateName: normalizedCandidateName,
        databaseMatch: databaseMatch,
        customMatch: customMatch,
        brandMatch: brandMatch,
      );
      if (score.score > bestScore) {
        bestScore = score.score;
        bestMatch = _DuplicateMatch(payment: payment, reason: score.reason);
      }
    }

    return bestScore >= 75 ? bestMatch : null;
  }

  int _scoreDatabaseMatch({
    required DetectedSubscriptionCandidate candidate,
    required SubscriptionServiceEntry service,
    required List<String> inputs,
  }) {
    final normalizedServiceId = SubscriptionDatabaseService.instance.normalize(
      service.id,
    );
    final normalizedServiceName = SubscriptionDatabaseService.instance
        .normalize(service.name);
    final normalizedAliases = [
      ...service.aliases,
      ...service.tags,
      service.icon,
    ].map(SubscriptionDatabaseService.instance.normalize).toSet();

    var score = 0;
    for (final input in inputs) {
      final normalizedInput = SubscriptionDatabaseService.instance.normalize(
        input,
      );
      if (normalizedInput.isEmpty) {
        continue;
      }

      if (normalizedInput == normalizedServiceId) {
        score = score < 100 ? 100 : score;
      }
      if (normalizedInput == normalizedServiceName) {
        score = score < 96 ? 96 : score;
      }
      if (normalizedAliases.contains(normalizedInput)) {
        score = score < 92 ? 92 : score;
      }
      if (normalizedServiceName.startsWith(normalizedInput) ||
          normalizedInput.startsWith(normalizedServiceName)) {
        score = score < 82 ? 82 : score;
      }
      if (normalizedServiceName.contains(normalizedInput) ||
          normalizedInput.contains(normalizedServiceName)) {
        score = score < 74 ? 74 : score;
      }
      for (final alias in normalizedAliases) {
        if (alias.startsWith(normalizedInput) ||
            normalizedInput.startsWith(alias)) {
          score = score < 78 ? 78 : score;
        } else if (alias.contains(normalizedInput) ||
            normalizedInput.contains(alias)) {
          score = score < 71 ? 71 : score;
        }
      }
    }

    if (candidate.providerSlugHint != null &&
        candidate.providerSlugHint!.isNotEmpty &&
        candidate.providerSlugHint == service.id) {
      score = score < 97 ? 97 : score;
    }

    return score;
  }

  int _scoreCustomMatch(
    DetectedSubscriptionCandidate candidate,
    CustomSubscriptionService service,
  ) {
    final normalizedServiceName = service.normalizedName;
    final normalizedAliases = service.aliases
        .map(SubscriptionDatabaseService.instance.normalize)
        .toSet();
    final inputs = _candidateInputs(candidate)
        .map(SubscriptionDatabaseService.instance.normalize)
        .where((item) => item.isNotEmpty)
        .toSet();

    var score = 0;
    if (inputs.contains(normalizedServiceName)) {
      score = 100;
    }
    if (inputs.any(
      (input) =>
          normalizedServiceName.startsWith(input) ||
          input.startsWith(normalizedServiceName),
    )) {
      score = score < 84 ? 84 : score;
    }
    if (inputs.any(
      (input) =>
          normalizedServiceName.contains(input) ||
          input.contains(normalizedServiceName),
    )) {
      score = score < 76 ? 76 : score;
    }
    if (inputs.any(normalizedAliases.contains)) {
      score = score < 92 ? 92 : score;
    }

    return score;
  }

  _ScoredDuplicate _scoreDuplicate({
    required DetectedSubscriptionCandidate candidate,
    required RecurringPayment payment,
    required String normalizedCandidateName,
    required SubscriptionServiceEntry? databaseMatch,
    required CustomSubscriptionService? customMatch,
    required BrandIconMatch brandMatch,
  }) {
    var score = 0;
    final reasons = <String>[];

    final normalizedPaymentName = SubscriptionDatabaseService.instance
        .normalize(payment.name);
    final normalizedPaymentProvider = SubscriptionDatabaseService.instance
        .normalize(payment.providerName);
    final normalizedPaymentIcon = SubscriptionDatabaseService.instance
        .normalize(payment.iconKey);
    final normalizedCandidateProvider = SubscriptionDatabaseService.instance
        .normalize(candidate.merchantLabel ?? '');

    if (normalizedPaymentName == normalizedCandidateName ||
        normalizedPaymentProvider == normalizedCandidateName ||
        normalizedPaymentName == candidate.normalizedServiceName ||
        normalizedPaymentProvider == candidate.normalizedServiceName) {
      score += 55;
      reasons.add('matching service name');
    } else if (normalizedCandidateProvider.isNotEmpty &&
        (normalizedPaymentName == normalizedCandidateProvider ||
            normalizedPaymentProvider == normalizedCandidateProvider)) {
      score += 44;
      reasons.add('matching merchant label');
    }

    if (brandMatch.canonicalSlug.isNotEmpty &&
        (normalizedPaymentIcon == brandMatch.canonicalSlug ||
            normalizedPaymentProvider == brandMatch.canonicalSlug)) {
      score += 18;
      reasons.add('matching provider logo');
    }

    if (databaseMatch != null) {
      final normalizedServiceId = SubscriptionDatabaseService.instance
          .normalize(databaseMatch.id);
      if (normalizedPaymentProvider == normalizedServiceId ||
          normalizedPaymentIcon == normalizedServiceId) {
        score += 22;
        reasons.add('matching provider record');
      }
    }

    if (customMatch != null &&
        normalizedPaymentName == customMatch.normalizedName) {
      score += 20;
      reasons.add('matching custom service');
    }

    if (candidate.amount != null) {
      final difference = (payment.amount - candidate.amount!).abs();
      if (difference < 0.01) {
        score += 20;
        reasons.add('same amount');
      } else if (difference <= 1.0) {
        score += 12;
        reasons.add('nearly same amount');
      }
    }

    if (candidate.billingFrequency != null &&
        payment.frequency == candidate.billingFrequency) {
      score += 12;
      reasons.add('same billing cadence');
    }

    if (candidate.category != null && payment.category == candidate.category) {
      score += 8;
      reasons.add('same category');
    }

    final candidateDate =
        candidate.nextPaymentDate ??
        candidate.renewalDate ??
        candidate.trialEndDate ??
        candidate.evidenceDate;
    if (candidateDate != null) {
      final comparedDate = payment.nextDueDate == candidateDate
          ? payment.nextDueDate
          : (payment.renewalDate ?? payment.nextDueDate);
      final dayDelta = comparedDate.difference(candidateDate).inDays.abs();
      if (dayDelta <= 3) {
        score += 18;
        reasons.add('very close billing date');
      } else if (dayDelta <= 10) {
        score += 10;
        reasons.add('close billing date');
      } else if (dayDelta <= 31) {
        score += 4;
      }
    }

    final reason = reasons.isEmpty
        ? 'Possible existing Bizoot item'
        : 'Possible duplicate: ${reasons.join(', ')}';
    return _ScoredDuplicate(score: score, reason: reason);
  }

  List<String> _candidateInputs(DetectedSubscriptionCandidate candidate) {
    return [
      candidate.serviceName,
      candidate.normalizedServiceName,
      candidate.merchantLabel ?? '',
      candidate.providerSlugHint ?? '',
      candidate.iconHint ?? '',
    ].where((value) => value.trim().isNotEmpty).toList(growable: false);
  }

  String? _canonicalNameFromBrand(
    DetectedSubscriptionCandidate candidate,
    BrandIconMatch brandMatch,
  ) {
    if (brandMatch.canonicalSlug.isEmpty) {
      return null;
    }
    return BrandIconService.instance.canonicalDisplayName(
      candidate.serviceName,
      serviceId: candidate.providerSlugHint,
      iconKey: candidate.iconHint,
    );
  }

  String? _matchedServiceIdFromBrand(BrandIconMatch brandMatch) {
    return brandMatch.canonicalSlug.isEmpty ? null : brandMatch.canonicalSlug;
  }
}

class _DuplicateMatch {
  const _DuplicateMatch({required this.payment, required this.reason});

  final RecurringPayment payment;
  final String reason;
}

class _ScoredDuplicate {
  const _ScoredDuplicate({required this.score, required this.reason});

  final int score;
  final String reason;
}
