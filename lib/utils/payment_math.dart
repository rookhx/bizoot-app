import '../models/recurring_payment.dart';

double monthlyEquivalent(RecurringPayment payment) {
  if (!payment.isActive) return 0;
  switch (payment.frequency) {
    case PaymentFrequency.weekly:
      return payment.amount * 4.33;
    case PaymentFrequency.monthly:
      return payment.amount;
    case PaymentFrequency.quarterly:
      return payment.amount / 3;
    case PaymentFrequency.yearly:
      return payment.amount / 12;
  }
}

double yearlyEquivalent(RecurringPayment payment) {
  if (!payment.isActive) return 0;
  return monthlyEquivalent(payment) * 12;
}

double potentialSavings(List<RecurringPayment> payments) {
  return payments
      .where((item) => item.isCancelled || item.status == PaymentStatus.inactive)
      .fold(0, (sum, item) => sum + yearlyEquivalent(item));
}

DateTime nextScheduledDueDate(
  DateTime dueDate,
  PaymentFrequency frequency, {
  DateTime? reference,
}) {
  final anchor = reference ?? DateTime.now();
  final today = DateTime(anchor.year, anchor.month, anchor.day);
  var next = _advanceDueDate(dueDate, frequency);

  while (!next.isAfter(today)) {
    next = _advanceDueDate(next, frequency);
  }

  return next;
}

DateTime _advanceDueDate(DateTime dueDate, PaymentFrequency frequency) {
  switch (frequency) {
    case PaymentFrequency.weekly:
      return dueDate.add(const Duration(days: 7));
    case PaymentFrequency.monthly:
      return _addMonthsPreservingDay(dueDate, 1);
    case PaymentFrequency.quarterly:
      return _addMonthsPreservingDay(dueDate, 3);
    case PaymentFrequency.yearly:
      return _addMonthsPreservingDay(dueDate, 12);
  }
}

DateTime _addMonthsPreservingDay(DateTime value, int monthsToAdd) {
  final totalMonths = value.month + monthsToAdd;
  final targetYear = value.year + ((totalMonths - 1) ~/ 12);
  final targetMonth = ((totalMonths - 1) % 12) + 1;
  final maxDay = DateTime(targetYear, targetMonth + 1, 0).day;
  final targetDay = value.day <= maxDay ? value.day : maxDay;

  return DateTime(
    targetYear,
    targetMonth,
    targetDay,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
