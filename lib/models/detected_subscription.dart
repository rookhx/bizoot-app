import 'recurring_payment.dart';

class DetectedSubscription {
  final String name;
  final String providerName;
  final double? amount;
  final String currency;
  final PaymentFrequency frequency;
  final DateTime? nextDueDate;
  final PaymentCategory category;
  final String? iconKey;
  final String? cancellationUrl;
  final String sourceEmailSubject;
  final String senderEmail;
  final DateTime emailDate;
  final double confidence; // 0.0 – 1.0

  bool isSelected;

  DetectedSubscription({
    required this.name,
    required this.providerName,
    this.amount,
    this.currency = 'USD',
    this.frequency = PaymentFrequency.monthly,
    this.nextDueDate,
    this.category = PaymentCategory.subscription,
    this.iconKey,
    this.cancellationUrl,
    required this.sourceEmailSubject,
    required this.senderEmail,
    required this.emailDate,
    this.confidence = 0.5,
    this.isSelected = true,
  });

  RecurringPayment toRecurringPayment(String userId) {
    final now = DateTime.now();
    return RecurringPayment(
      id: '',
      userId: userId,
      name: name,
      providerName: providerName,
      amount: amount ?? 0.0,
      currency: currency,
      category: category,
      frequency: frequency,
      nextDueDate: nextDueDate ?? now.add(const Duration(days: 30)),
      renewalDate: nextDueDate ?? now.add(const Duration(days: 30)),
      status: PaymentStatus.active,
      cancellationStatus: CancellationStatus.active,
      cancelledAt: null,
      reminderEnabled: true,
      reminderTiming: ReminderTiming.threeDaysBefore,
      isTrial: false,
      trialEndDate: null,
      trialReminderEnabled: false,
      convertsToPaidAmount: null,
      trialNotes: '',
      cancellationNotes: '',
      isCancellable: true,
      isEssential: false,
      iconKey: iconKey ?? '',
      cancellationUrl: cancellationUrl ?? '',
      priceHistory: const [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
