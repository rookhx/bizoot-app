import 'connected_email_account.dart';
import 'recurring_payment.dart';

enum CandidateEvidenceSource { messageMetadata, emailBody, pdfAttachment }

class CandidateAttachmentReference {
  final String id;
  final String fileName;
  final String mimeType;
  final String fileExtension;
  final int fileSize;

  const CandidateAttachmentReference({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileExtension,
    required this.fileSize,
  });
}

class DetectedSubscriptionCandidate {
  final String id;
  final ConnectedEmailProvider provider;
  final String accountId;
  final String sourceMessageId;
  final String serviceName;
  final String normalizedServiceName;
  final String? merchantLabel;
  final double? amount;
  final String currency;
  final PaymentCategory? category;
  final PaymentFrequency? billingFrequency;
  final DateTime? nextPaymentDate;
  final DateTime? renewalDate;
  final DateTime? trialEndDate;
  final String? website;
  final String? cancellationUrl;
  final String? iconHint;
  final String? providerSlugHint;
  final String notes;
  final double confidence;
  final DateTime detectedAt;
  final DateTime? evidenceDate;
  final List<CandidateEvidenceSource> evidenceSources;
  final List<CandidateAttachmentReference> attachments;
  final String? matchedServiceId;
  final String? matchedCanonicalName;
  final String? duplicatePaymentId;
  final String? duplicateReason;

  const DetectedSubscriptionCandidate({
    required this.id,
    required this.provider,
    required this.accountId,
    required this.sourceMessageId,
    required this.serviceName,
    required this.normalizedServiceName,
    required this.merchantLabel,
    required this.amount,
    required this.currency,
    required this.category,
    required this.billingFrequency,
    required this.nextPaymentDate,
    required this.renewalDate,
    required this.trialEndDate,
    required this.website,
    required this.cancellationUrl,
    required this.iconHint,
    required this.providerSlugHint,
    required this.notes,
    required this.confidence,
    required this.detectedAt,
    required this.evidenceDate,
    required this.evidenceSources,
    required this.attachments,
    required this.matchedServiceId,
    required this.matchedCanonicalName,
    required this.duplicatePaymentId,
    required this.duplicateReason,
  });

  bool get hasStrongMatch =>
      (matchedServiceId?.isNotEmpty ?? false) ||
      (matchedCanonicalName?.isNotEmpty ?? false);
  bool get isDuplicate => duplicatePaymentId?.isNotEmpty ?? false;

  DetectedSubscriptionCandidate copyWith({
    String? id,
    ConnectedEmailProvider? provider,
    String? accountId,
    String? sourceMessageId,
    String? serviceName,
    String? normalizedServiceName,
    String? merchantLabel,
    bool clearMerchantLabel = false,
    double? amount,
    String? currency,
    PaymentCategory? category,
    bool clearCategory = false,
    PaymentFrequency? billingFrequency,
    bool clearBillingFrequency = false,
    DateTime? nextPaymentDate,
    bool clearNextPaymentDate = false,
    DateTime? renewalDate,
    bool clearRenewalDate = false,
    DateTime? trialEndDate,
    bool clearTrialEndDate = false,
    String? website,
    bool clearWebsite = false,
    String? cancellationUrl,
    bool clearCancellationUrl = false,
    String? iconHint,
    bool clearIconHint = false,
    String? providerSlugHint,
    bool clearProviderSlugHint = false,
    String? notes,
    double? confidence,
    DateTime? detectedAt,
    DateTime? evidenceDate,
    bool clearEvidenceDate = false,
    List<CandidateEvidenceSource>? evidenceSources,
    List<CandidateAttachmentReference>? attachments,
    String? matchedServiceId,
    bool clearMatchedServiceId = false,
    String? matchedCanonicalName,
    bool clearMatchedCanonicalName = false,
    String? duplicatePaymentId,
    bool clearDuplicatePaymentId = false,
    String? duplicateReason,
    bool clearDuplicateReason = false,
  }) {
    return DetectedSubscriptionCandidate(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      accountId: accountId ?? this.accountId,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      serviceName: serviceName ?? this.serviceName,
      normalizedServiceName:
          normalizedServiceName ?? this.normalizedServiceName,
      merchantLabel: clearMerchantLabel
          ? null
          : (merchantLabel ?? this.merchantLabel),
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: clearCategory ? null : (category ?? this.category),
      billingFrequency: clearBillingFrequency
          ? null
          : (billingFrequency ?? this.billingFrequency),
      nextPaymentDate: clearNextPaymentDate
          ? null
          : (nextPaymentDate ?? this.nextPaymentDate),
      renewalDate: clearRenewalDate ? null : (renewalDate ?? this.renewalDate),
      trialEndDate: clearTrialEndDate
          ? null
          : (trialEndDate ?? this.trialEndDate),
      website: clearWebsite ? null : (website ?? this.website),
      cancellationUrl: clearCancellationUrl
          ? null
          : (cancellationUrl ?? this.cancellationUrl),
      iconHint: clearIconHint ? null : (iconHint ?? this.iconHint),
      providerSlugHint: clearProviderSlugHint
          ? null
          : (providerSlugHint ?? this.providerSlugHint),
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      detectedAt: detectedAt ?? this.detectedAt,
      evidenceDate: clearEvidenceDate
          ? null
          : (evidenceDate ?? this.evidenceDate),
      evidenceSources: evidenceSources ?? this.evidenceSources,
      attachments: attachments ?? this.attachments,
      matchedServiceId: clearMatchedServiceId
          ? null
          : (matchedServiceId ?? this.matchedServiceId),
      matchedCanonicalName: clearMatchedCanonicalName
          ? null
          : (matchedCanonicalName ?? this.matchedCanonicalName),
      duplicatePaymentId: clearDuplicatePaymentId
          ? null
          : (duplicatePaymentId ?? this.duplicatePaymentId),
      duplicateReason: clearDuplicateReason
          ? null
          : (duplicateReason ?? this.duplicateReason),
    );
  }
}
