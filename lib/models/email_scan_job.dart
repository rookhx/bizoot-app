import 'connected_email_account.dart';

enum EmailScanJobStatus { queued, scanning, completed, failed, cancelled }

class EmailScanJob {
  final String id;
  final String userId;
  final ConnectedEmailProvider provider;
  final String accountId;
  final EmailScanJobStatus status;
  final DateTime windowStart;
  final DateTime windowEnd;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int scannedMessageCount;
  final int candidateCount;
  final String? errorMessage;

  const EmailScanJob({
    required this.id,
    required this.userId,
    required this.provider,
    required this.accountId,
    required this.status,
    required this.windowStart,
    required this.windowEnd,
    required this.createdAt,
    required this.startedAt,
    required this.completedAt,
    required this.scannedMessageCount,
    required this.candidateCount,
    required this.errorMessage,
  });

  EmailScanJob copyWith({
    String? id,
    String? userId,
    ConnectedEmailProvider? provider,
    String? accountId,
    EmailScanJobStatus? status,
    DateTime? windowStart,
    DateTime? windowEnd,
    DateTime? createdAt,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? scannedMessageCount,
    int? candidateCount,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EmailScanJob(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      accountId: accountId ?? this.accountId,
      status: status ?? this.status,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      createdAt: createdAt ?? this.createdAt,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      scannedMessageCount: scannedMessageCount ?? this.scannedMessageCount,
      candidateCount: candidateCount ?? this.candidateCount,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
