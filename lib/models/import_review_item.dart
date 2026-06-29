import 'detected_subscription_candidate.dart';
import 'recurring_payment.dart';

enum ImportReviewStatus { pending, approved, skipped, duplicate, locked }

class ImportReviewItem {
  final String id;
  final DetectedSubscriptionCandidate candidate;
  final ImportReviewStatus status;
  final bool isLockedByPlan;
  final bool isDuplicate;
  final String? matchedExistingPaymentId;
  final String? reviewNote;
  final RecurringPayment? paymentDraft;

  const ImportReviewItem({
    required this.id,
    required this.candidate,
    required this.status,
    required this.isLockedByPlan,
    required this.isDuplicate,
    required this.matchedExistingPaymentId,
    required this.reviewNote,
    required this.paymentDraft,
  });

  ImportReviewItem copyWith({
    String? id,
    DetectedSubscriptionCandidate? candidate,
    ImportReviewStatus? status,
    bool? isLockedByPlan,
    bool? isDuplicate,
    String? matchedExistingPaymentId,
    bool clearMatchedExistingPaymentId = false,
    String? reviewNote,
    bool clearReviewNote = false,
    RecurringPayment? paymentDraft,
    bool clearPaymentDraft = false,
  }) {
    return ImportReviewItem(
      id: id ?? this.id,
      candidate: candidate ?? this.candidate,
      status: status ?? this.status,
      isLockedByPlan: isLockedByPlan ?? this.isLockedByPlan,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      matchedExistingPaymentId: clearMatchedExistingPaymentId
          ? null
          : (matchedExistingPaymentId ?? this.matchedExistingPaymentId),
      reviewNote: clearReviewNote ? null : (reviewNote ?? this.reviewNote),
      paymentDraft: clearPaymentDraft
          ? null
          : (paymentDraft ?? this.paymentDraft),
    );
  }
}
