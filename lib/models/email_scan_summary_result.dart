import 'connected_email_account.dart';
import 'detected_subscription_candidate.dart';
import 'email_scan_job.dart';
import 'import_review_item.dart';

class EmailScanSummaryResult {
  final ConnectedEmailAccount account;
  final EmailScanJob job;
  final DateTime windowStart;
  final DateTime windowEnd;
  final List<DetectedSubscriptionCandidate> candidates;
  final List<ImportReviewItem> reviewItems;
  final int freeTierVisibleLimit;
  final bool premiumAccess;

  const EmailScanSummaryResult({
    required this.account,
    required this.job,
    required this.windowStart,
    required this.windowEnd,
    required this.candidates,
    required this.reviewItems,
    required this.freeTierVisibleLimit,
    required this.premiumAccess,
  });

  int get totalDetectedCount => candidates.length;
  int get visibleReviewCount =>
      reviewItems.where((item) => !item.isLockedByPlan).length;
  int get lockedReviewCount =>
      reviewItems.where((item) => item.isLockedByPlan).length;
  bool get isFreeTierLimited => !premiumAccess && lockedReviewCount > 0;
}
