import 'package:flutter/material.dart';

import '../models/calendar_event.dart';
import '../models/recurring_payment.dart';
import '../services/brand_icon_service.dart';
import '../utils/payment_math.dart';

enum CalendarFilter {
  all,
  payments,
  renewals,
  trials,
  contracts,
  essentials,
  subscriptions,
}

class RecurringLifeCalendarService {
  const RecurringLifeCalendarService();

  List<CalendarEvent> buildEvents(
    List<RecurringPayment> payments, {
    required DateTime from,
    required DateTime to,
    required bool hasPremiumAccess,
  }) {
    final visiblePayments = _visiblePayments(payments, hasPremiumAccess: hasPremiumAccess);
    final events = <String, CalendarEvent>{};

    for (final payment in visiblePayments) {
      if (!payment.isCancelled) {
        for (final occurrence in _paymentOccurrences(payment, from: from, to: to)) {
          final event = _buildPaymentEvent(payment, occurrence);
          events[event.id] = event;
        }
      }

      final renewalDate = _rollForwardAnnualDate(payment.renewalDate, from: from, to: to);
      if (renewalDate != null && !_duplicatesPaymentEvent(payment, renewalDate)) {
        final event = _buildOneOffEvent(
          payment,
          id: 'renewal-${payment.id}-${renewalDate.toIso8601String()}',
          date: renewalDate,
          eventType: CalendarEventType.renewalDue,
          type: 'Renewal',
        );
        events[event.id] = event;
      }

      final contractDate = payment.contractEndDate;
      if (contractDate != null && _isInRange(contractDate, from, to)) {
        final event = _buildOneOffEvent(
          payment,
          id: 'contract-${payment.id}-${contractDate.toIso8601String()}',
          date: contractDate,
          eventType: CalendarEventType.contractEnd,
          type: 'Contract end',
        );
        events[event.id] = event;
      }

      final trialDate = payment.trialEndDate;
      if (payment.isTrial && trialDate != null && _isInRange(trialDate, from, to)) {
        final event = _buildOneOffEvent(
          payment,
          id: 'trial-${payment.id}-${trialDate.toIso8601String()}',
          date: trialDate,
          eventType: CalendarEventType.trialEnd,
          type: 'Trial end',
        );
        events[event.id] = event;
      }
    }

    final list = events.values.toList(growable: false)
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
      });
    return list;
  }

  List<CalendarEvent> upcomingTimeline(
    List<RecurringPayment> payments, {
    required bool hasPremiumAccess,
    int withinDays = 30,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(const Duration(days: 30));
    final to = today.add(Duration(days: withinDays));
    return buildEvents(
      payments,
      from: from,
      to: to,
      hasPremiumAccess: hasPremiumAccess,
    );
  }

  List<CalendarEvent> filterEvents(List<CalendarEvent> events, CalendarFilter filter) {
    switch (filter) {
      case CalendarFilter.all:
        return events;
      case CalendarFilter.payments:
        return events.where((event) => event.eventType == CalendarEventType.paymentDue).toList(growable: false);
      case CalendarFilter.renewals:
        return events.where((event) => event.eventType == CalendarEventType.renewalDue).toList(growable: false);
      case CalendarFilter.trials:
        return events.where((event) => event.eventType == CalendarEventType.trialEnd).toList(growable: false);
      case CalendarFilter.contracts:
        return events.where((event) => event.eventType == CalendarEventType.contractEnd).toList(growable: false);
      case CalendarFilter.essentials:
        return events.where((event) => event.category != PaymentCategory.subscription).toList(growable: false);
      case CalendarFilter.subscriptions:
        return events.where((event) => event.category == PaymentCategory.subscription).toList(growable: false);
    }
  }

  List<RecurringPayment> _visiblePayments(List<RecurringPayment> payments, {required bool hasPremiumAccess}) {
    final active = payments.where((item) => item.isActive || item.isTrial).toList(growable: false)
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    if (hasPremiumAccess) return active;
    return active.take(5).toList(growable: false);
  }

  List<DateTime> _paymentOccurrences(
    RecurringPayment payment, {
    required DateTime from,
    required DateTime to,
  }) {
    final occurrences = <DateTime>[];
    var current = DateTime(payment.nextDueDate.year, payment.nextDueDate.month, payment.nextDueDate.day);

    while (current.isBefore(from)) {
      final next = _advanceDate(current, payment.frequency);
      if (next == current) break;
      current = next;
    }

    while (!current.isAfter(to)) {
      if (_isInRange(current, from, to)) {
        occurrences.add(current);
      }
      final next = _advanceDate(current, payment.frequency);
      if (next == current) break;
      current = next;
    }

    return occurrences;
  }

  CalendarEvent _buildPaymentEvent(RecurringPayment payment, DateTime date) {
    return CalendarEvent(
      id: 'payment-${payment.id}-${date.toIso8601String()}',
      sourceItemId: payment.id,
      title: BrandIconService.instance.canonicalDisplayName(
        payment.name,
        serviceId: payment.iconKey,
        iconKey: payment.iconKey,
      ),
      type: 'Payment due',
      category: payment.category,
      amount: payment.amount,
      currency: payment.currency,
      date: date,
      eventType: CalendarEventType.paymentDue,
      status: _statusForDate(date, payment.isCancelled),
      priority: _priorityForPayment(payment, date),
      iconKey: payment.iconKey,
      colorValue: _colorForCategory(payment.category, isOverdue: _statusForDate(date, payment.isCancelled) == CalendarEventStatus.overdue),
    );
  }

  CalendarEvent _buildOneOffEvent(
    RecurringPayment payment, {
    required String id,
    required DateTime date,
    required CalendarEventType eventType,
    required String type,
  }) {
    return CalendarEvent(
      id: id,
      sourceItemId: payment.id,
      title: BrandIconService.instance.canonicalDisplayName(
        payment.name,
        serviceId: payment.iconKey,
        iconKey: payment.iconKey,
      ),
      type: type,
      category: payment.category,
      amount: payment.amount,
      currency: payment.currency,
      date: date,
      eventType: eventType,
      status: _statusForDate(date, payment.isCancelled),
      priority: _priorityForDate(date, eventType),
      iconKey: payment.iconKey,
      colorValue: _colorForEventType(payment.category, eventType),
    );
  }

  CalendarEventStatus _statusForDate(DateTime date, bool isCancelled) {
    if (isCancelled) return CalendarEventStatus.cancelled;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized.isBefore(today)) return CalendarEventStatus.overdue;
    if (normalized == today) return CalendarEventStatus.dueToday;
    return CalendarEventStatus.upcoming;
  }

  CalendarEventPriority _priorityForPayment(RecurringPayment payment, DateTime date) {
    final status = _statusForDate(date, payment.isCancelled);
    if (status == CalendarEventStatus.overdue || status == CalendarEventStatus.dueToday) {
      return CalendarEventPriority.high;
    }
    if (payment.category == PaymentCategory.rent || payment.category == PaymentCategory.insurance) {
      return CalendarEventPriority.high;
    }
    if (payment.category.isEssential) {
      return CalendarEventPriority.medium;
    }
    return CalendarEventPriority.low;
  }

  CalendarEventPriority _priorityForDate(DateTime date, CalendarEventType eventType) {
    final now = DateTime.now();
    final days = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (eventType == CalendarEventType.trialEnd || eventType == CalendarEventType.contractEnd) {
      return days <= 7 ? CalendarEventPriority.high : CalendarEventPriority.medium;
    }
    return days <= 7 ? CalendarEventPriority.high : CalendarEventPriority.medium;
  }

  bool _duplicatesPaymentEvent(RecurringPayment payment, DateTime date) {
    final due = DateTime(payment.nextDueDate.year, payment.nextDueDate.month, payment.nextDueDate.day);
    final normalized = DateTime(date.year, date.month, date.day);
    return due == normalized;
  }

  DateTime? _rollForwardAnnualDate(
    DateTime? base, {
    required DateTime from,
    required DateTime to,
  }) {
    if (base == null) return null;
    var candidate = DateTime(from.year, base.month, base.day);
    if (candidate.isBefore(from)) {
      candidate = DateTime(from.year + 1, base.month, base.day);
    }
    return _isInRange(candidate, from, to) ? candidate : null;
  }

  bool _isInRange(DateTime date, DateTime from, DateTime to) {
    final normalized = DateTime(date.year, date.month, date.day);
    final rangeStart = DateTime(from.year, from.month, from.day);
    final rangeEnd = DateTime(to.year, to.month, to.day);
    return !normalized.isBefore(rangeStart) && !normalized.isAfter(rangeEnd);
  }

  DateTime _advanceDate(DateTime date, PaymentFrequency frequency) {
    switch (frequency) {
      case PaymentFrequency.weekly:
        return date.add(const Duration(days: 7));
      case PaymentFrequency.monthly:
        return nextScheduledDueDate(date, PaymentFrequency.monthly, reference: date.subtract(const Duration(days: 1)));
      case PaymentFrequency.quarterly:
        return nextScheduledDueDate(date, PaymentFrequency.quarterly, reference: date.subtract(const Duration(days: 1)));
      case PaymentFrequency.yearly:
        return nextScheduledDueDate(date, PaymentFrequency.yearly, reference: date.subtract(const Duration(days: 1)));
    }
  }

  int _colorForCategory(PaymentCategory category, {bool isOverdue = false}) {
    if (isOverdue) return const Color(0xFFFF5A6B).toARGB32();
    switch (category) {
      case PaymentCategory.subscription:
      case PaymentCategory.membership:
        return const Color(0xFF9B6DFF).toARGB32();
      case PaymentCategory.rent:
        return const Color(0xFFE06BFF).toARGB32();
      case PaymentCategory.utilities:
        return const Color(0xFF30D8FF).toARGB32();
      case PaymentCategory.insurance:
        return const Color(0xFF4C8DFF).toARGB32();
      case PaymentCategory.internet:
        return const Color(0xFF53B8FF).toARGB32();
      case PaymentCategory.phone:
        return const Color(0xFFFFD84F).toARGB32();
      case PaymentCategory.gym:
        return const Color(0xFF3AE38C).toARGB32();
      case PaymentCategory.loan:
        return const Color(0xFFFF8E52).toARGB32();
      case PaymentCategory.contract:
        return const Color(0xFFFF7A59).toARGB32();
      case PaymentCategory.other:
        return const Color(0xFF7F8CA8).toARGB32();
    }
  }

  int _colorForEventType(PaymentCategory category, CalendarEventType eventType) {
    switch (eventType) {
      case CalendarEventType.trialEnd:
        return const Color(0xFFFFB449).toARGB32();
      case CalendarEventType.contractEnd:
        return const Color(0xFFFF7A59).toARGB32();
      case CalendarEventType.renewalDue:
        return const Color(0xFF4C8DFF).toARGB32();
      case CalendarEventType.paymentDue:
      case CalendarEventType.reminder:
        return _colorForCategory(category);
    }
  }

  int _priorityRank(CalendarEventPriority priority) {
    switch (priority) {
      case CalendarEventPriority.high:
        return 3;
      case CalendarEventPriority.medium:
        return 2;
      case CalendarEventPriority.low:
        return 1;
    }
  }
}
