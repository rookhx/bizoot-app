import 'dart:convert';

import '../models/detected_subscription_candidate.dart';
import '../models/recurring_payment.dart';
import 'email_import_service.dart';

class AttachmentParsingService {
  const AttachmentParsingService();

  static const supportedExtensions = ['pdf'];
  static const int _maxAttachmentBytes = 2 * 1024 * 1024;

  List<CandidateAttachmentReference> supportedAttachmentsForMessage(
    EmailImportMessageSource message,
  ) {
    return message.attachments
        .where(
          (attachment) =>
              supportedExtensions.contains(
                attachment.fileExtension.toLowerCase(),
              ) &&
              attachment.fileSize > 0 &&
              attachment.fileSize <= _maxAttachmentBytes,
        )
        .map(
          (attachment) => CandidateAttachmentReference(
            id: attachment.id,
            fileName: attachment.fileName,
            mimeType: attachment.mimeType,
            fileExtension: attachment.fileExtension,
            fileSize: attachment.fileSize,
          ),
        )
        .toList(growable: false);
  }

  Future<List<DetectedSubscriptionCandidate>> enrichCandidates({
    required List<DetectedSubscriptionCandidate> candidates,
    required List<EmailImportMessageSource> messages,
  }) async {
    final messagesById = {for (final message in messages) message.id: message};

    return candidates
        .map((candidate) {
          final message = messagesById[candidate.sourceMessageId];
          if (message == null) {
            return candidate;
          }

          final supportedAttachments = supportedAttachmentsForMessage(message);
          _ParsedAttachmentData? strongestAttachment;

          for (final attachment in message.attachments) {
            if (!supportedExtensions.contains(
              attachment.fileExtension.toLowerCase(),
            )) {
              continue;
            }
            if (attachment.fileSize <= 0 ||
                attachment.fileSize > _maxAttachmentBytes) {
              continue;
            }
            final bytes = attachment.bytes;
            if (bytes == null || bytes.isEmpty) {
              continue;
            }

            final parsed = _parsePdfAttachment(
              bytes: bytes,
              fileName: attachment.fileName,
            );
            if (parsed == null) {
              continue;
            }

            if (strongestAttachment == null ||
                parsed.confidenceBoost > strongestAttachment.confidenceBoost) {
              strongestAttachment = parsed;
            }
          }

          final candidateWithAttachments = candidate.copyWith(
            attachments: supportedAttachments,
          );
          if (strongestAttachment == null) {
            return candidateWithAttachments;
          }

          return _mergeAttachmentData(
            candidate: candidateWithAttachments,
            parsed: strongestAttachment,
          );
        })
        .toList(growable: false);
  }

  _ParsedAttachmentData? _parsePdfAttachment({
    required List<int> bytes,
    required String fileName,
  }) {
    final text = _extractPdfText(bytes);
    if (text.isEmpty) {
      return null;
    }

    final providerName =
        _extractProviderName(text) ?? _providerNameFromFileName(fileName);
    final amountResult = _extractAmount(text);
    final invoiceDate = _extractDate(
      text,
      patterns: const [
        r'invoice\s+date[:\s]+([A-Za-z0-9,\-\/ ]+)',
        r'billed\s+on[:\s]+([A-Za-z0-9,\-\/ ]+)',
        r'payment\s+date[:\s]+([A-Za-z0-9,\-\/ ]+)',
      ],
    );
    final renewalDate = _extractDate(
      text,
      patterns: const [
        r'renew(?:al|s)?\s+date[:\s]+([A-Za-z0-9,\-\/ ]+)',
        r'next\s+(?:billing|payment|renewal)\s+date[:\s]+([A-Za-z0-9,\-\/ ]+)',
        r'next\s+(?:billing|payment|renewal)[:\s]+([A-Za-z0-9,\-\/ ]+)',
      ],
    );
    final billingFrequency = _extractFrequency(text);
    final reference = _extractReference(text);
    final hints = _extractRecurringHints(text);

    if (providerName == null &&
        amountResult == null &&
        invoiceDate == null &&
        renewalDate == null &&
        billingFrequency == null &&
        reference == null &&
        hints.isEmpty) {
      return null;
    }

    return _ParsedAttachmentData(
      providerName: providerName,
      amount: amountResult?.amount,
      currency: amountResult?.currency,
      invoiceDate: invoiceDate,
      renewalDate: renewalDate,
      billingFrequency: billingFrequency,
      notes: [
        if (reference != null) 'Attachment reference: $reference',
        ...hints,
      ],
      confidenceBoost: amountResult != null || renewalDate != null
          ? 0.12
          : 0.06,
    );
  }

  DetectedSubscriptionCandidate _mergeAttachmentData({
    required DetectedSubscriptionCandidate candidate,
    required _ParsedAttachmentData parsed,
  }) {
    final noteParts = <String>[
      if (candidate.notes.trim().isNotEmpty) candidate.notes.trim(),
      ...parsed.notes.where(
        (note) => note.trim().isNotEmpty && !candidate.notes.contains(note),
      ),
    ];
    final evidenceSources = <CandidateEvidenceSource>{
      ...candidate.evidenceSources,
      CandidateEvidenceSource.pdfAttachment,
    }.toList(growable: false);

    return candidate.copyWith(
      serviceName: parsed.providerName ?? candidate.serviceName,
      normalizedServiceName: parsed.providerName == null
          ? candidate.normalizedServiceName
          : _normalize(parsed.providerName!),
      merchantLabel: parsed.providerName ?? candidate.merchantLabel,
      amount: parsed.amount ?? candidate.amount,
      currency: parsed.currency ?? candidate.currency,
      billingFrequency: parsed.billingFrequency ?? candidate.billingFrequency,
      nextPaymentDate:
          parsed.renewalDate ?? parsed.invoiceDate ?? candidate.nextPaymentDate,
      renewalDate: parsed.renewalDate ?? candidate.renewalDate,
      notes: noteParts.join(' '),
      confidence: (candidate.confidence + parsed.confidenceBoost).clamp(
        0.0,
        1.0,
      ),
      evidenceSources: evidenceSources,
    );
  }

  String _extractPdfText(List<int> bytes) {
    final decodedText = ascii.decode(bytes, allowInvalid: true);
    final matches = RegExp(r'[\x20-\x7E]{4,}').allMatches(decodedText);
    final buffer = StringBuffer();

    for (final match in matches) {
      final chunk = match.group(0)?.trim() ?? '';
      if (chunk.isEmpty) {
        continue;
      }
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(chunk);
    }

    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractProviderName(String text) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:merchant|provider|service|subscription)[:\s]+([A-Za-z0-9&+.\- ]{3,})',
        caseSensitive: false,
      ),
      RegExp(
        r'thank you for (?:your|choosing)\s+([A-Za-z0-9&+.\- ]{3,})',
        caseSensitive: false,
      ),
      RegExp(
        r'([A-Za-z][A-Za-z0-9&+.\- ]{2,})\s+(?:invoice|receipt|billing|subscription)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final value = _cleanProviderName(match?.group(1));
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  String? _providerNameFromFileName(String fileName) {
    final stem = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return _cleanProviderName(stem.replaceAll(RegExp(r'[_\-]+'), ' '));
  }

  _AmountResult? _extractAmount(String text) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:amount due|total due|total paid|amount paid|invoice total|total)[:\s]*(USD|EUR|GBP|DKK|SEK|NOK|INR|\$)?\s?([0-9][0-9,.\s]{0,14})',
        caseSensitive: false,
      ),
      RegExp(
        r'(USD|EUR|GBP|DKK|SEK|NOK|INR|\$)\s?([0-9][0-9,.\s]{0,14})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) {
        continue;
      }
      final currency = _normalizeCurrency(match.group(1));
      final amount = _parseAmountValue(match.group(2));
      if (amount != null) {
        return _AmountResult(amount: amount, currency: currency);
      }
    }

    return null;
  }

  DateTime? _extractDate(String text, {required List<String> patterns}) {
    for (final patternText in patterns) {
      final pattern = RegExp(patternText, caseSensitive: false);
      final match = pattern.firstMatch(text);
      final rawValue = match?.group(1)?.trim();
      final parsed = _parseFlexibleDate(rawValue);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  PaymentFrequency? _extractFrequency(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('monthly') || normalized.contains('per month')) {
      return PaymentFrequency.monthly;
    }
    if (normalized.contains('weekly') || normalized.contains('per week')) {
      return PaymentFrequency.weekly;
    }
    if (normalized.contains('quarterly') ||
        normalized.contains('every 3 months')) {
      return PaymentFrequency.quarterly;
    }
    if (normalized.contains('annual') ||
        normalized.contains('annually') ||
        normalized.contains('yearly') ||
        normalized.contains('per year')) {
      return PaymentFrequency.yearly;
    }
    return null;
  }

  String? _extractReference(String text) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:invoice|billing|reference|ref)\s*(?:number|no\.?|id)?[:\s#-]+([A-Z0-9\-]{4,})',
        caseSensitive: false,
      ),
      RegExp(
        r'order\s*(?:number|no\.?|id)?[:\s#-]+([A-Z0-9\-]{4,})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  List<String> _extractRecurringHints(String text) {
    final normalized = text.toLowerCase();
    return [
      if (normalized.contains('auto-renew'))
        'Attachment suggests auto-renew is enabled.',
      if (normalized.contains('trial'))
        'Attachment includes trial-related billing language.',
      if (normalized.contains('renews on'))
        'Attachment includes an explicit renewal cue.',
      if (normalized.contains('subscription'))
        'Attachment references an ongoing subscription.',
    ];
  }

  String? _cleanProviderName(String? value) {
    if (value == null) {
      return null;
    }
    final cleaned = value
        .replaceAll(
          RegExp(
            r'\b(invoice|receipt|billing|subscription|statement)\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.length < 2 ? null : cleaned;
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  String? _normalizeCurrency(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    if (raw.trim() == r'$') {
      return 'USD';
    }
    return raw.trim().toUpperCase();
  }

  double? _parseAmountValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final normalized = raw.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (normalized.isEmpty) {
      return null;
    }

    var candidate = normalized;
    final hasComma = candidate.contains(',');
    final hasDot = candidate.contains('.');

    if (hasComma && hasDot) {
      if (candidate.lastIndexOf(',') > candidate.lastIndexOf('.')) {
        candidate = candidate.replaceAll('.', '').replaceAll(',', '.');
      } else {
        candidate = candidate.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = candidate.split(',');
      if (parts.length == 2 && parts.last.length <= 2) {
        candidate = candidate.replaceAll(',', '.');
      } else {
        candidate = candidate.replaceAll(',', '');
      }
    }

    return double.tryParse(candidate);
  }

  DateTime? _parseFlexibleDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final trimmed = raw.trim();
    final direct = DateTime.tryParse(trimmed);
    if (direct != null) {
      return direct;
    }

    final slashMatch = RegExp(
      r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
    ).firstMatch(trimmed);
    if (slashMatch != null) {
      final first = int.tryParse(slashMatch.group(1) ?? '');
      final second = int.tryParse(slashMatch.group(2) ?? '');
      final year = int.tryParse(slashMatch.group(3) ?? '');
      if (first != null && second != null && year != null) {
        final normalizedYear = year < 100 ? 2000 + year : year;
        if (first <= 12) {
          return DateTime(normalizedYear, first, second);
        }
        if (second <= 12) {
          return DateTime(normalizedYear, second, first);
        }
      }
    }

    final monthNameMatch = RegExp(
      r'([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(\d{4})|(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})',
    ).firstMatch(trimmed);
    if (monthNameMatch != null) {
      if (monthNameMatch.group(1) != null) {
        final month = _monthIndex(monthNameMatch.group(1)!);
        final day = int.tryParse(monthNameMatch.group(2) ?? '');
        final year = int.tryParse(monthNameMatch.group(3) ?? '');
        if (month != null && day != null && year != null) {
          return DateTime(year, month, day);
        }
      } else {
        final day = int.tryParse(monthNameMatch.group(4) ?? '');
        final month = _monthIndex(monthNameMatch.group(5)!);
        final year = int.tryParse(monthNameMatch.group(6) ?? '');
        if (month != null && day != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  int? _monthIndex(String monthName) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[monthName.substring(0, 3).toLowerCase()];
  }
}

class _AmountResult {
  const _AmountResult({required this.amount, this.currency});

  final double amount;
  final String? currency;
}

class _ParsedAttachmentData {
  const _ParsedAttachmentData({
    required this.providerName,
    required this.amount,
    required this.currency,
    required this.invoiceDate,
    required this.renewalDate,
    required this.billingFrequency,
    required this.notes,
    required this.confidenceBoost,
  });

  final String? providerName;
  final double? amount;
  final String? currency;
  final DateTime? invoiceDate;
  final DateTime? renewalDate;
  final PaymentFrequency? billingFrequency;
  final List<String> notes;
  final double confidenceBoost;
}
