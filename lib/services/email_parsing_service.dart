import '../models/connected_email_account.dart';
import '../models/detected_subscription_candidate.dart';
import '../models/recurring_payment.dart';
import 'email_import_service.dart';

class EmailParsingService {
  const EmailParsingService();

  static const double _minimumConfidence = 0.34;

  static const List<String> _billingKeywords = [
    'invoice',
    'receipt',
    'subscription',
    'renewal',
    'trial',
    'payment',
    'charged',
    'billing',
    'plan',
    'membership',
    'due',
    'autopay',
    'recurring',
    'monthly',
    'yearly',
  ];

  static const List<String> _renewalKeywords = [
    'renew',
    'renewal',
    'renews',
    'renews on',
    'next billing',
    'next payment',
    'upcoming charge',
    'your plan renews',
  ];

  static const List<String> _trialKeywords = [
    'trial',
    'free trial',
    'trial ends',
    'trial ending',
    'trial expires',
    'trial will end',
  ];

  static const List<String> _cancellationKeywords = [
    'cancel',
    'cancel anytime',
    'cancel subscription',
    'manage subscription',
    'manage membership',
    'billing settings',
    'account settings',
  ];

  List<DetectedSubscriptionCandidate> parseMessages({
    required ConnectedEmailAccount account,
    required List<EmailImportMessageSource> messages,
  }) {
    final candidates = <DetectedSubscriptionCandidate>[];

    for (final message in messages) {
      final body = _combinedBody(message);
      final normalizedBody = _normalize(body);
      if (!_looksSubscriptionRelated(normalizedBody)) {
        continue;
      }

      final serviceName = _extractServiceName(message, body);
      if (serviceName.isEmpty) {
        continue;
      }

      final amount = _extractAmount(body);
      final currency = _extractCurrency(body) ?? 'USD';
      final frequency =
          _extractFrequency(normalizedBody) ??
          _frequencyFromAmountContext(normalizedBody);
      final nextPaymentDate = _extractNextPaymentDate(body, message.receivedAt);
      final renewalDate = _extractRenewalDate(body, message.receivedAt);
      final trialEndDate = _extractTrialEndDate(body, message.receivedAt);
      final website = _extractWebsite(body, message.senderEmail);
      final cancellationUrl = _extractCancellationUrl(body);
      final category = _inferCategory(serviceName, message, normalizedBody);
      final providerHint = _providerHint(serviceName, message.senderEmail);
      final confidence = _confidenceFor(
        message: message,
        normalizedBody: normalizedBody,
        serviceName: serviceName,
        amount: amount,
        frequency: frequency,
        nextPaymentDate: nextPaymentDate,
        renewalDate: renewalDate,
        trialEndDate: trialEndDate,
        cancellationUrl: cancellationUrl,
      );

      if (confidence < _minimumConfidence &&
          amount == null &&
          trialEndDate == null &&
          renewalDate == null &&
          nextPaymentDate == null) {
        continue;
      }

      candidates.add(
        DetectedSubscriptionCandidate(
          id: '${account.provider.name}-${message.id}',
          provider: account.provider,
          accountId: account.id,
          sourceMessageId: message.id,
          serviceName: serviceName,
          normalizedServiceName: _normalize(serviceName),
          merchantLabel: message.senderName.isNotEmpty
              ? message.senderName
              : message.senderEmail,
          amount: amount,
          currency: currency,
          category: category,
          billingFrequency: frequency,
          nextPaymentDate: nextPaymentDate,
          renewalDate: renewalDate,
          trialEndDate: trialEndDate,
          website: website,
          cancellationUrl: cancellationUrl,
          iconHint: providerHint,
          providerSlugHint: providerHint,
          notes: _buildNotes(
            message: message,
            amount: amount,
            frequency: frequency,
            nextPaymentDate: nextPaymentDate,
            renewalDate: renewalDate,
            trialEndDate: trialEndDate,
          ),
          confidence: confidence,
          detectedAt: DateTime.now(),
          evidenceDate:
              nextPaymentDate ??
              renewalDate ??
              trialEndDate ??
              message.receivedAt,
          evidenceSources: _evidenceSources(message),
          attachments: message.attachments
              .map(
                (attachment) => CandidateAttachmentReference(
                  id: attachment.id,
                  fileName: attachment.fileName,
                  mimeType: attachment.mimeType,
                  fileExtension: attachment.fileExtension,
                  fileSize: attachment.fileSize,
                ),
              )
              .toList(growable: false),
          matchedServiceId: null,
          matchedCanonicalName: null,
          duplicatePaymentId: null,
          duplicateReason: null,
        ),
      );
    }

    return _dedupeByMessageAndService(candidates);
  }

  String _combinedBody(EmailImportMessageSource message) =>
      '${message.subject}\n${message.snippet}\n${message.bodyText}'.trim();

  bool _looksSubscriptionRelated(String normalizedBody) {
    return _billingKeywords.any(normalizedBody.contains);
  }

  String _extractServiceName(EmailImportMessageSource message, String body) {
    final senderName = _cleanServiceLabel(message.senderName);
    if (_isUsefulServiceName(senderName)) {
      return senderName;
    }

    final subjectName = _cleanServiceLabel(
      message.subject
          .replaceAll(
            RegExp(
              r'(invoice|receipt|renewal|payment|trial|billing|charged|subscription|membership)',
              caseSensitive: false,
            ),
            '',
          )
          .trim(),
    );
    if (_isUsefulServiceName(subjectName)) {
      return subjectName;
    }

    final explicitPatterns = [
      RegExp(
        r'(?:for|from|with)\s+([A-Z][A-Za-z0-9&+.\- ]{2,40})',
        caseSensitive: false,
      ),
      RegExp(
        r'([A-Z][A-Za-z0-9&+.\- ]{2,40})\s+(?:subscription|membership|plan|premium|trial)',
        caseSensitive: false,
      ),
    ];
    for (final pattern in explicitPatterns) {
      final match = pattern.firstMatch(body);
      final value = _cleanServiceLabel(match?.group(1) ?? '');
      if (_isUsefulServiceName(value)) {
        return value;
      }
    }

    return _serviceNameFromEmail(message.senderEmail);
  }

  double? _extractAmount(String text) {
    final matches = RegExp(
      r'(?:(USD|EUR|GBP|DKK|SEK|NOK|Rs|INR|AUD|CAD|CHF|[$€£])\s?)(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    ).allMatches(text);
    for (final match in matches) {
      final value = _parseAmount(match.group(2) ?? '');
      if (value != null && value > 0) {
        return value;
      }
    }
    return null;
  }

  String? _extractCurrency(String text) {
    final match = RegExp(
      r'(USD|EUR|GBP|DKK|SEK|NOK|Rs|INR|AUD|CAD|CHF|[$€£])',
      caseSensitive: false,
    ).firstMatch(text);
    final value = match?.group(1)?.toUpperCase();
    return switch (value) {
      '\$' => 'USD',
      '€' => 'EUR',
      '£' => 'GBP',
      'RS' => 'RS',
      _ => value,
    };
  }

  PaymentFrequency? _extractFrequency(String normalizedBody) {
    if (normalizedBody.contains('every week') ||
        normalizedBody.contains('weekly')) {
      return PaymentFrequency.weekly;
    }
    if (normalizedBody.contains('every month') ||
        normalizedBody.contains('monthly') ||
        normalizedBody.contains('per month')) {
      return PaymentFrequency.monthly;
    }
    if (normalizedBody.contains('quarterly') ||
        normalizedBody.contains('every quarter') ||
        normalizedBody.contains('per quarter')) {
      return PaymentFrequency.quarterly;
    }
    if (normalizedBody.contains('yearly') ||
        normalizedBody.contains('annually') ||
        normalizedBody.contains('annual') ||
        normalizedBody.contains('per year')) {
      return PaymentFrequency.yearly;
    }
    return null;
  }

  PaymentFrequency? _frequencyFromAmountContext(String normalizedBody) {
    if (normalizedBody.contains('/month')) return PaymentFrequency.monthly;
    if (normalizedBody.contains('/year')) return PaymentFrequency.yearly;
    if (normalizedBody.contains('/week')) return PaymentFrequency.weekly;
    return null;
  }

  DateTime? _extractNextPaymentDate(String text, DateTime referenceDate) {
    return _extractDateFromPatterns(
      text,
      referenceDate: referenceDate,
      patterns: const [
        'next payment',
        'next billing',
        'charged on',
        'billing date',
        'payment due',
      ],
    );
  }

  DateTime? _extractRenewalDate(String text, DateTime referenceDate) {
    return _extractDateFromPatterns(
      text,
      referenceDate: referenceDate,
      patterns: _renewalKeywords,
    );
  }

  DateTime? _extractTrialEndDate(String text, DateTime referenceDate) {
    return _extractDateFromPatterns(
      text,
      referenceDate: referenceDate,
      patterns: _trialKeywords,
    );
  }

  String? _extractWebsite(String text, String senderEmail) {
    final urlMatch = RegExp(
      r'https?://[^\s)>\]]+',
      caseSensitive: false,
    ).allMatches(text);
    for (final match in urlMatch) {
      final candidate = match.group(0);
      if (candidate == null) continue;
      final lower = candidate.toLowerCase();
      if (!lower.contains('cancel') &&
          !lower.contains('unsubscribe') &&
          !lower.contains('manage')) {
        return candidate;
      }
    }

    final domain = senderEmail.split('@').last.trim();
    if (domain.isNotEmpty && domain.contains('.')) {
      return 'https://$domain';
    }
    return null;
  }

  String? _extractCancellationUrl(String text) {
    final urlMatch = RegExp(
      r'https?://[^\s)>\]]+',
      caseSensitive: false,
    ).allMatches(text);
    for (final match in urlMatch) {
      final candidate = match.group(0);
      if (candidate == null) continue;
      final lower = candidate.toLowerCase();
      if (_cancellationKeywords.any(lower.contains)) {
        return candidate;
      }
    }
    return null;
  }

  PaymentCategory? _inferCategory(
    String serviceName,
    EmailImportMessageSource message,
    String normalizedBody,
  ) {
    final haystack =
        '${serviceName.toLowerCase()} ${message.senderEmail.toLowerCase()} ${normalizedBody.toLowerCase()}';
    if (haystack.contains('rent')) return PaymentCategory.rent;
    if (haystack.contains('utility') ||
        haystack.contains('electric') ||
        haystack.contains('water') ||
        haystack.contains('gas')) {
      return PaymentCategory.utilities;
    }
    if (haystack.contains('insurance')) return PaymentCategory.insurance;
    if (haystack.contains('internet') || haystack.contains('broadband')) {
      return PaymentCategory.internet;
    }
    if (haystack.contains('phone') || haystack.contains('mobile')) {
      return PaymentCategory.phone;
    }
    if (haystack.contains('gym') || haystack.contains('fitness')) {
      return PaymentCategory.gym;
    }
    if (haystack.contains('loan') || haystack.contains('repayment')) {
      return PaymentCategory.loan;
    }
    if (haystack.contains('membership')) return PaymentCategory.membership;
    if (haystack.contains('contract')) return PaymentCategory.contract;
    return PaymentCategory.subscription;
  }

  String? _providerHint(String serviceName, String senderEmail) {
    final seed = serviceName.isNotEmpty ? serviceName : senderEmail;
    final normalized = _normalize(seed);
    if (normalized.isEmpty) return null;
    return normalized;
  }

  String _buildNotes({
    required EmailImportMessageSource message,
    required double? amount,
    required PaymentFrequency? frequency,
    required DateTime? nextPaymentDate,
    required DateTime? renewalDate,
    required DateTime? trialEndDate,
  }) {
    final details = <String>[
      if (amount != null) 'Amount detected from billing email.',
      if (frequency != null) 'Billing cadence looks ${frequency.name}.',
      if (nextPaymentDate != null) 'Next payment date was inferred.',
      if (renewalDate != null) 'Renewal date was inferred.',
      if (trialEndDate != null) 'Trial end date was inferred.',
      if (message.attachments.isNotEmpty) 'Attachment metadata is available.',
    ];
    final snippet = message.snippet.trim();
    if (snippet.isNotEmpty) {
      details.add(snippet);
    }
    final joined = details.join(' ');
    return joined.length > 260 ? '${joined.substring(0, 260)}...' : joined;
  }

  List<CandidateEvidenceSource> _evidenceSources(
    EmailImportMessageSource message,
  ) {
    return [
      CandidateEvidenceSource.messageMetadata,
      CandidateEvidenceSource.emailBody,
      if (message.attachments.isNotEmpty) CandidateEvidenceSource.pdfAttachment,
    ];
  }

  double _confidenceFor({
    required EmailImportMessageSource message,
    required String normalizedBody,
    required String serviceName,
    required double? amount,
    required PaymentFrequency? frequency,
    required DateTime? nextPaymentDate,
    required DateTime? renewalDate,
    required DateTime? trialEndDate,
    required String? cancellationUrl,
  }) {
    var confidence = 0.18;
    if (_billingKeywords.any(normalizedBody.contains)) confidence += 0.16;
    if (_renewalKeywords.any(normalizedBody.contains)) confidence += 0.08;
    if (_trialKeywords.any(normalizedBody.contains)) confidence += 0.08;
    if (_cancellationKeywords.any(normalizedBody.contains)) confidence += 0.06;
    if (amount != null && amount > 0) confidence += 0.18;
    if (frequency != null) confidence += 0.08;
    if (nextPaymentDate != null) confidence += 0.08;
    if (renewalDate != null) confidence += 0.08;
    if (trialEndDate != null) confidence += 0.08;
    if (cancellationUrl != null) confidence += 0.05;
    if (message.attachments.isNotEmpty) confidence += 0.04;
    if (_isUsefulServiceName(serviceName)) confidence += 0.08;
    if (message.senderEmail.toLowerCase().contains(_normalize(serviceName))) {
      confidence += 0.07;
    }
    if (message.subject.toLowerCase().contains('receipt') ||
        message.subject.toLowerCase().contains('invoice')) {
      confidence += 0.08;
    }
    return confidence.clamp(0.0, 0.98);
  }

  List<DetectedSubscriptionCandidate> _dedupeByMessageAndService(
    List<DetectedSubscriptionCandidate> candidates,
  ) {
    final deduped = <String, DetectedSubscriptionCandidate>{};
    for (final candidate in candidates) {
      final key =
          '${candidate.sourceMessageId}:${candidate.normalizedServiceName}';
      final existing = deduped[key];
      if (existing == null || candidate.confidence > existing.confidence) {
        deduped[key] = candidate;
      }
    }
    return deduped.values.toList(growable: false);
  }

  DateTime? _extractDateFromPatterns(
    String text, {
    required DateTime referenceDate,
    required List<String> patterns,
  }) {
    final normalized = text.replaceAll('\n', ' ');
    for (final pattern in patterns) {
      final regex = RegExp(
        '${RegExp.escape(pattern)}[^A-Za-z0-9]{0,20}([A-Za-z]{3,9}\\s+\\d{1,2}(?:,\\s*\\d{4})?|\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}|\\d{4}[/-]\\d{1,2}[/-]\\d{1,2})',
        caseSensitive: false,
      );
      final match = regex.firstMatch(normalized);
      final parsed = _parseLooseDate(match?.group(1), referenceDate);
      if (parsed != null) {
        return parsed;
      }
    }

    final standalone = RegExp(
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2}(?:,\s*\d{4})?',
      caseSensitive: false,
    ).firstMatch(normalized);
    return _parseLooseDate(standalone?.group(0), referenceDate);
  }

  DateTime? _parseLooseDate(String? raw, DateTime referenceDate) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();

    final numeric = RegExp(
      r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$',
    ).firstMatch(value);
    if (numeric != null) {
      final month = int.tryParse(numeric.group(1)!);
      final day = int.tryParse(numeric.group(2)!);
      var year = int.tryParse(numeric.group(3)!);
      if (month == null || day == null || year == null) return null;
      if (year < 100) year += 2000;
      return _safeDate(year, month, day);
    }

    final iso = RegExp(
      r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$',
    ).firstMatch(value);
    if (iso != null) {
      final year = int.tryParse(iso.group(1)!);
      final month = int.tryParse(iso.group(2)!);
      final day = int.tryParse(iso.group(3)!);
      if (year == null || month == null || day == null) return null;
      return _safeDate(year, month, day);
    }

    final monthName = RegExp(
      r'^([A-Za-z]{3,9})\s+(\d{1,2})(?:,\s*(\d{4}))?$',
      caseSensitive: false,
    ).firstMatch(value);
    if (monthName != null) {
      final month = _monthFromName(monthName.group(1)!);
      final day = int.tryParse(monthName.group(2)!);
      final year = int.tryParse(monthName.group(3) ?? '') ?? referenceDate.year;
      if (month == null || day == null) return null;
      var parsed = _safeDate(year, month, day);
      if (parsed != null &&
          monthName.group(3) == null &&
          parsed.isBefore(referenceDate.subtract(const Duration(days: 32)))) {
        parsed = _safeDate(year + 1, month, day);
      }
      return parsed;
    }

    return null;
  }

  DateTime? _safeDate(int year, int month, int day) {
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  int? _monthFromName(String raw) {
    switch (raw.substring(0, 3).toLowerCase()) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        return null;
    }
  }

  double? _parseAmount(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'\s'), '');
    if (cleaned.contains(',') && cleaned.contains('.')) {
      if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      final decimals = cleaned.split(',').last;
      cleaned = decimals.length == 2
          ? cleaned.replaceAll(',', '.')
          : cleaned.replaceAll(',', '');
    }
    return double.tryParse(cleaned);
  }

  String _serviceNameFromEmail(String senderEmail) {
    final domain = senderEmail.split('@').last.toLowerCase();
    final base = domain.split('.').first;
    return _cleanServiceLabel(base.replaceAll(RegExp(r'[-_.]+'), ' '));
  }

  String _cleanServiceLabel(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'no[\s_-]?reply', caseSensitive: false), '')
        .replaceAll(RegExp(r'support', caseSensitive: false), '')
        .replaceAll(RegExp(r'billing', caseSensitive: false), '')
        .replaceAll(RegExp(r'payments?', caseSensitive: false), '')
        .replaceAll(RegExp(r'notifications?', caseSensitive: false), '')
        .replaceAll(RegExp(r'[@<>"]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.length <= 2
              ? part.toUpperCase()
              : part[0].toUpperCase() + part.substring(1),
        )
        .join(' ');
  }

  bool _isUsefulServiceName(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty || normalized.length < 3) return false;
    const banned = {
      'noreply',
      'billing',
      'payments',
      'receipt',
      'invoice',
      'subscription',
      'membership',
      'renewal',
      'support',
    };
    return !banned.contains(normalized);
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}
