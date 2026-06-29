import '../models/connected_email_account.dart';
import '../models/custom_subscription_service.dart';
import '../models/detected_subscription_candidate.dart';
import '../models/email_scan_job.dart';
import '../models/email_scan_summary_result.dart';
import '../models/import_review_item.dart';
import '../models/recurring_payment.dart';
import 'attachment_parsing_service.dart';
import 'email_parsing_service.dart';
import 'gmail_import_service.dart';
import 'outlook_import_service.dart';
import 'subscription_candidate_matcher.dart';

class EmailImportAttachmentSource {
  final String id;
  final String fileName;
  final String mimeType;
  final String fileExtension;
  final int fileSize;
  final List<int>? bytes;

  const EmailImportAttachmentSource({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileExtension,
    required this.fileSize,
    this.bytes,
  });
}

class EmailImportMessageSource {
  final String id;
  final ConnectedEmailProvider provider;
  final String accountId;
  final String senderEmail;
  final String senderName;
  final String subject;
  final String snippet;
  final String bodyText;
  final DateTime receivedAt;
  final List<EmailImportAttachmentSource> attachments;

  const EmailImportMessageSource({
    required this.id,
    required this.provider,
    required this.accountId,
    required this.senderEmail,
    required this.senderName,
    required this.subject,
    required this.snippet,
    required this.bodyText,
    required this.receivedAt,
    required this.attachments,
  });
}

class EmailImportService {
  EmailImportService({
    required this.gmailImportService,
    required this.outlookImportService,
    this.emailParsingService = const EmailParsingService(),
    this.attachmentParsingService = const AttachmentParsingService(),
    this.subscriptionCandidateMatcher = const SubscriptionCandidateMatcher(),
  });

  final GmailImportService gmailImportService;
  final OutlookImportService outlookImportService;
  final EmailParsingService emailParsingService;
  final AttachmentParsingService attachmentParsingService;
  final SubscriptionCandidateMatcher subscriptionCandidateMatcher;

  static const int scanWindowDays = 365;
  static const int freeTierReviewLimit = 5;
  DateTime buildWindowStart(DateTime now) =>
      now.subtract(const Duration(days: scanWindowDays));

  Future<EmailScanSummaryResult> prepareImportReview({
    required String userId,
    required ConnectedEmailAccount account,
    required bool hasPremiumAccess,
    required List<RecurringPayment> existingPayments,
    required List<CustomSubscriptionService> customServices,
    required int activeSubscriptionLimit,
    DateTime? now,
  }) async {
    final scanStartedAt = now ?? DateTime.now();
    final windowEnd = scanStartedAt;
    final windowStart = buildWindowStart(windowEnd);

    var job = EmailScanJob(
      id: 'scan-${account.provider.name}-${scanStartedAt.microsecondsSinceEpoch}',
      userId: userId,
      provider: account.provider,
      accountId: account.id,
      status: EmailScanJobStatus.scanning,
      windowStart: windowStart,
      windowEnd: windowEnd,
      createdAt: scanStartedAt,
      startedAt: scanStartedAt,
      completedAt: null,
      scannedMessageCount: 0,
      candidateCount: 0,
      errorMessage: null,
    );

    final messages = await _fetchMessages(
      account: account,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
    final parsedCandidates = emailParsingService.parseMessages(
      account: account,
      messages: messages,
    );
    final enrichedCandidates = await attachmentParsingService.enrichCandidates(
      candidates: parsedCandidates,
      messages: messages,
    );
    final matchedCandidates = await subscriptionCandidateMatcher
        .matchCandidates(
          candidates: enrichedCandidates,
          existingPayments: existingPayments,
          customServices: customServices,
        );

    final sortedCandidates = [...matchedCandidates]
      ..sort((a, b) {
        final aDate = a.evidenceDate ?? a.detectedAt;
        final bDate = b.evidenceDate ?? b.detectedAt;
        return bDate.compareTo(aDate);
      });

    final reviewItems = _buildReviewItems(
      userId: userId,
      candidates: sortedCandidates,
      hasPremiumAccess: hasPremiumAccess,
      existingPayments: existingPayments,
      activeSubscriptionLimit: activeSubscriptionLimit,
    );

    job = job.copyWith(
      status: EmailScanJobStatus.completed,
      completedAt: DateTime.now(),
      scannedMessageCount: messages.length,
      candidateCount: sortedCandidates.length,
    );

    return EmailScanSummaryResult(
      account: account,
      job: job,
      windowStart: windowStart,
      windowEnd: windowEnd,
      candidates: sortedCandidates,
      reviewItems: reviewItems,
      freeTierVisibleLimit: freeTierReviewLimit,
      premiumAccess: hasPremiumAccess,
    );
  }

  Future<List<EmailImportMessageSource>> _fetchMessages({
    required ConnectedEmailAccount account,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    switch (account.provider) {
      case ConnectedEmailProvider.gmail:
        return gmailImportService.fetchMessages(
          account: account,
          windowStart: windowStart,
          windowEnd: windowEnd,
        );
      case ConnectedEmailProvider.outlook:
        return outlookImportService.fetchMessages(
          account: account,
          windowStart: windowStart,
          windowEnd: windowEnd,
        );
    }
  }

  List<ImportReviewItem> _buildReviewItems({
    required String userId,
    required List<DetectedSubscriptionCandidate> candidates,
    required bool hasPremiumAccess,
    required List<RecurringPayment> existingPayments,
    required int activeSubscriptionLimit,
  }) {
    final activeSubscriptionCount = existingPayments
        .where((payment) => payment.isActive)
        .length;
    final remainingFreeSlots = activeSubscriptionLimit < 0
        ? freeTierReviewLimit
        : (activeSubscriptionLimit - activeSubscriptionCount).clamp(
            0,
            freeTierReviewLimit,
          );
    final visibleLimit = hasPremiumAccess
        ? candidates.length
        : remainingFreeSlots;
    return candidates
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final candidate = entry.value;
          final locked = !hasPremiumAccess && index >= visibleLimit;
          final duplicate = candidate.isDuplicate;
          return ImportReviewItem(
            id: 'review-${candidate.id}',
            candidate: candidate,
            status: locked
                ? ImportReviewStatus.locked
                : duplicate
                ? ImportReviewStatus.duplicate
                : ImportReviewStatus.pending,
            isLockedByPlan: locked,
            isDuplicate: duplicate,
            matchedExistingPaymentId: candidate.duplicatePaymentId,
            reviewNote: locked
                ? remainingFreeSlots <= 0
                      ? 'Locked because the free plan already has 5 active subscriptions.'
                      : 'Locked on free plan after the remaining $remainingFreeSlots import slot(s) were used.'
                : duplicate
                ? candidate.duplicateReason
                : null,
            paymentDraft: locked ? null : _buildPaymentDraft(userId, candidate),
          );
        })
        .toList(growable: false);
  }

  bool shouldAutoSyncConnectedAccount(
    ConnectedEmailAccount account, {
    DateTime? now,
  }) => true;

  RecurringPayment _buildPaymentDraft(
    String userId,
    DetectedSubscriptionCandidate candidate,
  ) {
    final now = DateTime.now();
    final dueDate =
        candidate.nextPaymentDate ??
        candidate.renewalDate ??
        candidate.evidenceDate ??
        now;
    return RecurringPayment(
      id: 'import-draft-${candidate.id}',
      userId: userId,
      name: candidate.matchedCanonicalName ?? candidate.serviceName,
      providerName: candidate.merchantLabel ?? candidate.serviceName,
      amount: candidate.amount ?? 0,
      currency: candidate.currency,
      category: candidate.category ?? PaymentCategory.subscription,
      frequency: candidate.billingFrequency ?? PaymentFrequency.monthly,
      nextDueDate: dueDate,
      renewalDate: candidate.renewalDate,
      contractEndDate: null,
      reminderEnabled: true,
      reminderTiming: ReminderTiming.oneDayBefore,
      status: PaymentStatus.active,
      isTrial: candidate.trialEndDate != null,
      trialEndDate: candidate.trialEndDate,
      trialReminderEnabled: candidate.trialEndDate != null,
      convertsToPaidAmount: candidate.amount,
      trialNotes: '',
      cancellationUrl: candidate.cancellationUrl ?? '',
      managementUrl: candidate.website ?? '',
      cancellationNotes: '',
      loginEmail: '',
      username: '',
      signInMethod: SignInMethod.email,
      passwordHint: '',
      recoveryEmail: '',
      accountNotes: candidate.notes,
      policyNumber: '',
      documentLabel: '',
      isEssential:
          (candidate.category ?? PaymentCategory.subscription).isEssential,
      isCancellable: true,
      cancellationStatus: CancellationStatus.active,
      cancelledAt: null,
      iconKey: candidate.iconHint ?? 'credit_card',
      priceHistory: const [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
