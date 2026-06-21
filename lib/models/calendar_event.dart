import 'recurring_payment.dart';

enum CalendarEventType {
  paymentDue,
  renewalDue,
  contractEnd,
  trialEnd,
  reminder,
}

enum CalendarEventStatus {
  upcoming,
  dueToday,
  overdue,
  paid,
  cancelled,
}

enum CalendarEventPriority {
  low,
  medium,
  high,
}

class CalendarEvent {
  final String id;
  final String sourceItemId;
  final String title;
  final String type;
  final PaymentCategory category;
  final double amount;
  final String currency;
  final DateTime date;
  final CalendarEventType eventType;
  final CalendarEventStatus status;
  final CalendarEventPriority priority;
  final String iconKey;
  final int colorValue;
  final bool isPremiumLocked;

  const CalendarEvent({
    required this.id,
    required this.sourceItemId,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.eventType,
    required this.status,
    required this.priority,
    required this.iconKey,
    required this.colorValue,
    this.isPremiumLocked = false,
  });

  bool get isActionablePayment => eventType == CalendarEventType.paymentDue;

  String get eventTypeLabel {
    switch (eventType) {
      case CalendarEventType.paymentDue:
        return 'Payment';
      case CalendarEventType.renewalDue:
        return 'Renewal';
      case CalendarEventType.contractEnd:
        return 'Contract';
      case CalendarEventType.trialEnd:
        return 'Trial';
      case CalendarEventType.reminder:
        return 'Reminder';
    }
  }

  String get statusLabel {
    switch (status) {
      case CalendarEventStatus.upcoming:
        return 'Upcoming';
      case CalendarEventStatus.dueToday:
        return 'Due today';
      case CalendarEventStatus.overdue:
        return 'Overdue';
      case CalendarEventStatus.paid:
        return 'Paid';
      case CalendarEventStatus.cancelled:
        return 'Cancelled';
    }
  }
}
