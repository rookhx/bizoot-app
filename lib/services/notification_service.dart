import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../models/insight_event.dart';
import '../models/calendar_event.dart';
import '../models/notification_preferences.dart';
import '../models/recurring_payment.dart';
import '../models/user_settings.dart';
import '../utils/formatters.dart';
import '../utils/payment_math.dart';
import 'financial_intelligence_service.dart';
import 'intelligence_service.dart';
import 'smart_control_service.dart';

class NotificationService {
  NotificationService();

  final SmartControlService _smartControlService = const SmartControlService();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _managedNotificationIdsKey = 'bizoot_managed_notification_ids';
  static const _weeklySummaryIdRaw = 'weekly-summary';
  static const _testNotificationIdRaw = 'test-instant';
  static const _debugNotificationIdRaw = 'debug-10-seconds';
  static const _duplicateInsightIdRaw = 'duplicate-categories';
  static const _moneySavingInsightIdRaw = 'money-saving';

  bool _initialized = false;
  bool _permissionsGranted = false;

  bool get permissionsGranted => _permissionsGranted;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bizoot_smart_notifications',
    'Bizoot smart notifications',
    description: 'Upcoming payments, trials, weekly summaries, and savings alerts.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      try {
        await _plugin.initialize(
          settings: settings,
        );
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      } catch (_) {
        // Keep initialization safe. Notification features should fail softly.
      }
      _initialized = true;
    }
    await _refreshLocalTimezone();
    _permissionsGranted = await areNotificationsEnabled();
  }

  Future<void> initializeNotifications() => initialize();

  Future<bool> requestPermissions() async {
    await initialize();
    var granted = true;

    try {
      if (Platform.isAndroid) {
        granted = await _plugin
                .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            true;
      } else if (Platform.isIOS) {
        granted = await _plugin
                .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
    } catch (_) {
      granted = false;
    }

    _permissionsGranted = granted && await areNotificationsEnabled();
    return _permissionsGranted;
  }

  Future<bool> requestNotificationPermission() => requestPermissions();

  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        return await _plugin
                .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                ?.areNotificationsEnabled() ??
            false;
      }
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> openNotificationSettings() async {
    try {
      final uri = Uri.parse('app-settings:');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Safe no-op if system settings cannot be opened.
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_managedNotificationIdsKey);
    } catch (_) {
      // Safe no-op
    }
  }

  Future<void> cancelNotificationById(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Safe no-op
    }
  }

  Future<void> showTestNotification() async {
    await initialize();
    await requestPermissions();
    if (!_permissionsGranted) return;

    try {
      await _plugin.show(
        id: _stableNotificationId(_testNotificationIdRaw),
        title: 'Bizoot test alert',
        body: 'Your smart savings notifications are working.',
        notificationDetails: _notificationDetails(),
      );
    } catch (_) {
      // Safe no-op
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await initialize();
    await requestPermissions();
    if (!_permissionsGranted) return;

    try {
      await _plugin.show(
        id: _stableNotificationId('instant-$title-$body'),
        title: title,
        body: body,
        notificationDetails: _notificationDetails(),
        payload: data == null ? null : jsonEncode(data),
      );
    } catch (_) {
      // Safe no-op
    }
  }

  Future<void> scheduleDebugNotification() async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    await scheduleNotification(
      id: _stableNotificationId(_debugNotificationIdRaw),
      title: 'Bizoot debug alert',
      body: 'This test notification was scheduled 10 seconds ago.',
      scheduledAt: when,
    );
  }

  Future<void> schedulePaymentReminder({
    required RecurringPayment payment,
    required ReminderTiming fallbackTiming,
  }) async {
    await scheduleUpcomingPaymentAlert(payment: payment, fallbackTiming: fallbackTiming);
  }

  Future<void> scheduleTrialReminder({
    required RecurringPayment payment,
    required int daysBefore,
  }) async {
    if (payment.trialEndDate == null || daysBefore < 1) return;
    final scheduledAt = _dateAtHour(payment.trialEndDate!.subtract(Duration(days: daysBefore)), hour: 10);
    await scheduleNotification(
      id: _stableNotificationId('trial-${payment.id}-$daysBefore'),
      title: 'Trial ending soon',
      body:
          'Your ${payment.name} trial ends soon. Cancel before it becomes ${formatCurrency(payment.convertsToPaidAmount ?? payment.amount, payment.currency)}/month.',
      scheduledAt: scheduledAt,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    String? payload,
    DateTimeComponents? repeatComponents,
  }) async {
    await initialize();
    if (!_permissionsGranted) return;

    final now = tz.TZDateTime.now(tz.local);
    final target = scheduledAt.isBefore(now) ? now.add(const Duration(minutes: 1)) : scheduledAt;

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: target,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeatComponents,
        payload: payload,
      );
      await _rememberManagedNotificationId(id);
    } catch (_) {
      // Never crash the app because of notification scheduling.
    }
  }

  Future<void> scheduleWeeklySummary({
    required WeeklySummaryData summary,
  }) async {
    final nextSunday = _nextInstanceOfWeekday(7, hour: 19, minute: 0);
    await scheduleNotification(
      id: _stableNotificationId(_weeklySummaryIdRaw),
      title: 'Weekly Bizoot summary',
      body:
          'You have ${summary.nextWeekCount} payments next week totaling ${formatCurrency(summary.totalDue, summary.currency)}.',
      scheduledAt: nextSunday,
      repeatComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleSmartInsightReminder({
    required SmartNotificationOpportunity opportunity,
    required int weekday,
  }) async {
    final when = _nextWeekdayEvening(weekday);
    await scheduleNotification(
      id: _stableNotificationId('smart-${opportunity.id}'),
      title: opportunity.title,
      body: opportunity.body,
      scheduledAt: when,
      repeatComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleCalendarEventReminder(CalendarEvent event) async {
    final now = tz.TZDateTime.now(tz.local);
    final eventDay = tz.TZDateTime(
      tz.local,
      event.date.year,
      event.date.month,
      event.date.day,
      9,
    );
    final scheduledAt = eventDay.isAfter(now.add(const Duration(hours: 12)))
        ? eventDay.subtract(const Duration(days: 1))
        : now.add(const Duration(minutes: 1));

    await scheduleNotification(
      id: _stableNotificationId('calendar-reminder-${event.id}'),
      title: event.title,
      body: '${event.type} on ${formatShortDate(event.date)}.',
      scheduledAt: scheduledAt,
    );
  }

  Future<void> cancelReminderForPayment(RecurringPayment payment) async {
    final ids = <int>[
      for (final timing in ReminderTiming.values) _stableNotificationId('payment-${payment.id}-${timing.name}'),
      _stableNotificationId('trial-${payment.id}-3'),
      _stableNotificationId('trial-${payment.id}-1'),
      _stableNotificationId('renewal-${payment.id}-30'),
      _stableNotificationId('renewal-${payment.id}-7'),
      _stableNotificationId('contract-${payment.id}-30'),
      _stableNotificationId('contract-${payment.id}-7'),
      _stableNotificationId('still-using-${payment.id}'),
      _stableNotificationId('considering-${payment.id}'),
    ];
    for (final id in ids.toSet()) {
      await cancelNotificationById(id);
      await _forgetManagedNotificationId(id);
    }
  }

  Future<bool> resyncAllReminders({
    required List<RecurringPayment> payments,
    required UserSettings settings,
    required NotificationPreferences preferences,
    required bool hasPremiumAccess,
    required IntelligenceService intelligenceService,
  }) {
    return syncSmartNotifications(
      payments: payments,
      settings: settings,
      preferences: preferences,
      hasPremiumAccess: hasPremiumAccess,
      intelligenceService: intelligenceService,
    );
  }

  Future<void> scheduleTrialEndingAlert({
    required RecurringPayment payment,
  }) async {
    if (payment.trialEndDate == null) return;
    final daysLeft = _daysUntil(payment.trialEndDate!);
    if (daysLeft < 1 || daysLeft > 3) return;
    if (daysLeft >= 3) {
      await scheduleTrialReminder(payment: payment, daysBefore: 3);
    }
    if (daysLeft >= 1) {
      await scheduleTrialReminder(payment: payment, daysBefore: 1);
    }
  }

  Future<void> scheduleUpcomingPaymentAlert({
    required RecurringPayment payment,
    required ReminderTiming fallbackTiming,
  }) async {
    final reminderTiming = payment.reminderEnabled ? payment.reminderTiming : fallbackTiming;
    final dueDate = payment.nextDueDate;
    if (!payment.isActive || dueDate.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) return;

    final scheduledAt = _dateAtHour(
      dueDate.subtract(_durationForReminder(reminderTiming)),
      hour: reminderTiming == ReminderTiming.sameDay ? 8 : 10,
    );

    await scheduleNotification(
      id: _stableNotificationId('payment-${payment.id}-${reminderTiming.name}'),
      title: 'Upcoming payment',
      body: 'You\'ll be charged ${formatCurrency(payment.amount, payment.currency)} for ${payment.name} ${_dueDescriptor(dueDate)}.',
      scheduledAt: scheduledAt,
    );
  }

  Future<void> scheduleStillUsingAlert({
    required RecurringPayment payment,
  }) async {
    final when = _nextMonthlyPrompt();
    await scheduleNotification(
      id: _stableNotificationId('still-using-${payment.id}'),
      title: 'Still using ${payment.name}?',
      body: 'Still using ${payment.name}? It costs you ${formatCurrency(yearlyEquivalent(payment), payment.currency)}/year.',
      scheduledAt: when,
      repeatComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> scheduleRenewalReminder({
    required RecurringPayment payment,
    required DateTime targetDate,
    required int daysBefore,
    required String reminderKind,
  }) async {
    final scheduledAt = _dateAtHour(targetDate.subtract(Duration(days: daysBefore)), hour: 10);
    final label = reminderKind == 'contract' ? 'Contract ending soon' : 'Renewal coming up';
    final body = reminderKind == 'contract'
        ? '${payment.name} ends soon. Review it before ${formatCurrency(payment.amount, payment.currency)} renews again.'
        : '${payment.name} renews soon. Review it before the next ${formatCurrency(payment.amount, payment.currency)} charge.';
    await scheduleNotification(
      id: _stableNotificationId('$reminderKind-${payment.id}-$daysBefore'),
      title: label,
      body: body,
      scheduledAt: scheduledAt,
    );
  }

  Future<bool> syncSmartNotifications({
    required List<RecurringPayment> payments,
    required UserSettings settings,
    required NotificationPreferences preferences,
    required bool hasPremiumAccess,
    required IntelligenceService intelligenceService,
  }) async {
    await initialize();
    await _refreshLocalTimezone();
    await _cancelManagedNotifications();

    if (!preferences.paymentRemindersEnabled) {
      _permissionsGranted = await areNotificationsEnabled();
      return _permissionsGranted;
    }

    final granted = await requestPermissions();
    if (!granted) return false;

    final activePayments = payments.where((item) => item.isActive).toList(growable: false);
    final defaultTiming = RecurringPayment.reminderTimingFromString(preferences.defaultReminderTiming);

    for (final payment in activePayments.where((item) => item.reminderEnabled)) {
      await schedulePaymentReminder(payment: payment, fallbackTiming: defaultTiming);
    }

    if (hasPremiumAccess && preferences.trialAlertsEnabled) {
      for (final payment in activePayments.where((item) => item.isTrial && item.trialReminderEnabled)) {
        await scheduleTrialEndingAlert(payment: payment);
      }
    }

    if (hasPremiumAccess && preferences.paymentRemindersEnabled) {
      for (final payment in activePayments) {
        final renewal = payment.renewalDate;
        final contractEnd = payment.contractEndDate;
        if (renewal != null && renewal.isAfter(DateTime.now())) {
          await scheduleRenewalReminder(
            payment: payment,
            targetDate: renewal,
            daysBefore: 30,
            reminderKind: 'renewal',
          );
          await scheduleRenewalReminder(
            payment: payment,
            targetDate: renewal,
            daysBefore: 7,
            reminderKind: 'renewal',
          );
        }
        if (contractEnd != null && contractEnd.isAfter(DateTime.now())) {
          await scheduleRenewalReminder(
            payment: payment,
            targetDate: contractEnd,
            daysBefore: 30,
            reminderKind: 'contract',
          );
          await scheduleRenewalReminder(
            payment: payment,
            targetDate: contractEnd,
            daysBefore: 7,
            reminderKind: 'contract',
          );
        }
      }
    }

    if (hasPremiumAccess && preferences.weeklySummaryEnabled) {
      final report = intelligenceService.buildWeeklyReport(settings, payments);
      final now = DateTime.now();
      final nextWeekStart = now.add(const Duration(days: 7));
      final nextWeekEnd = now.add(const Duration(days: 14));
      final nextWeekCount = payments.where((item) {
        return item.isActive &&
            item.nextDueDate.isAfter(nextWeekStart) &&
            item.nextDueDate.isBefore(nextWeekEnd);
      }).length;
      await scheduleWeeklySummary(
        summary: WeeklySummaryData(
          totalDue: report.totalNextWeek,
          potentialSavings: report.potentialSavings,
          healthScore: report.healthScore,
          currency: settings.currency,
          nextWeekCount: nextWeekCount,
        ),
      );
    }

    if (hasPremiumAccess && preferences.stillUsingAlertsEnabled) {
      for (final payment in activePayments.where((item) => yearlyEquivalent(item) > 120)) {
        await scheduleStillUsingAlert(payment: payment);
      }
    }

    if (hasPremiumAccess && (preferences.savingsInsightsEnabled || preferences.cancellationNudgesEnabled)) {
      await _scheduleSavingsAlerts(
        payments: activePayments,
        settings: settings,
        preferences: preferences,
        intelligenceService: intelligenceService,
      );
    }

    if (hasPremiumAccess && preferences.savingsInsightsEnabled) {
      final opportunities = intelligenceService.buildSnapshot(settings, payments, isPremiumUser: true).insights;
      for (final opportunity in opportunities.take(2)) {
        await scheduleSmartInsightReminder(
          opportunity: SmartNotificationOpportunity(
            id: opportunity.id,
            category: SmartNotificationCategory.insights,
            priority: opportunity.priority,
            title: opportunity.title,
            body: opportunity.body,
          ),
          weekday: 4,
        );
      }

      final controlSnapshot = _smartControlService.buildSnapshot(
        settings,
        payments,
        hasPremiumAccess: true,
      );

      for (final signal in controlSnapshot.priceIncreaseSignals.take(1)) {
        await scheduleSmartInsightReminder(
          opportunity: SmartNotificationOpportunity(
            id: 'price-increase-${signal.payment.id}',
            category: SmartNotificationCategory.insights,
            priority: signal.percentageChange >= 12 ? InsightPriority.high : InsightPriority.medium,
            title: 'Price increase detected',
            body: '${signal.payment.name} increased by ${signal.percentageChange.toStringAsFixed(0)}% since the last update.',
          ),
          weekday: 3,
        );
      }

      for (final risk in controlSnapshot.renewalRisks.take(1)) {
        await scheduleSmartInsightReminder(
          opportunity: SmartNotificationOpportunity(
            id: 'renewal-risk-${risk.payment.id}',
            category: SmartNotificationCategory.reminders,
            priority: risk.daysRemaining <= 7 ? InsightPriority.high : InsightPriority.medium,
            title: 'Renewal risk',
            body: '${risk.payment.name} ${risk.label.toLowerCase()} in ${risk.daysRemaining} day${risk.daysRemaining == 1 ? '' : 's'}.',
          ),
          weekday: 1,
        );
      }
    }

    return true;
  }

  Future<void> _scheduleSavingsAlerts({
    required List<RecurringPayment> payments,
    required UserSettings settings,
    required NotificationPreferences preferences,
    required IntelligenceService intelligenceService,
  }) async {
    final insights = intelligenceService.buildInsights(settings, payments);
    final duplicateInsight = _firstInsightById(insights, 'duplicates');
    if (preferences.savingsInsightsEnabled && duplicateInsight != null) {
      final when = _nextWeekdayEvening(5);
      await scheduleNotification(
        id: _stableNotificationId(_duplicateInsightIdRaw),
        title: 'Possible savings insight',
        body: duplicateInsight.body,
        scheduledAt: when,
        repeatComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    final savingsInsight = _firstInsightById(insights, 'savings');
    if (preferences.savingsInsightsEnabled && savingsInsight != null) {
      final when = _nextWeekdayEvening(2);
      await scheduleNotification(
        id: _stableNotificationId(_moneySavingInsightIdRaw),
        title: 'Money-saving opportunity',
        body: savingsInsight.body,
        scheduledAt: when,
        repeatComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    for (final payment in payments.where(
      (item) => preferences.cancellationNudgesEnabled && item.cancellationStatus == CancellationStatus.considering,
    )) {
      final when = _nextWeekdayEvening(3);
      await scheduleNotification(
        id: _stableNotificationId('considering-${payment.id}'),
        title: 'Still thinking about cancelling?',
        body: 'You marked ${payment.name} as considering. Reviewing it this week could save ${formatCurrency(yearlyEquivalent(payment), payment.currency)}/year.',
        scheduledAt: when,
        repeatComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  Duration _durationForReminder(ReminderTiming timing) {
    switch (timing) {
      case ReminderTiming.sameDay:
        return Duration.zero;
      case ReminderTiming.oneDayBefore:
        return const Duration(days: 1);
      case ReminderTiming.threeDaysBefore:
        return const Duration(days: 3);
      case ReminderTiming.sevenDaysBefore:
        return const Duration(days: 7);
    }
  }

  String _dueDescriptor(DateTime dueDate) {
    final days = _daysUntil(dueDate);
    if (days <= 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days <= 3) return 'in 3 days';
    return 'in $days days';
  }

  int _daysUntil(DateTime target) {
    return (target.difference(DateTime.now()).inHours / 24).ceil();
  }

  InsightEvent? _firstInsightById(List<InsightEvent> insights, String id) {
    for (final insight in insights) {
      if (insight.id == id) {
        return insight;
      }
    }
    return null;
  }

  int _stableNotificationId(String raw) {
    var hash = 0;
    for (final unit in raw.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash;
  }

  tz.TZDateTime _dateAtHour(DateTime input, {required int hour, int minute = 0}) {
    final local = tz.TZDateTime.from(input, tz.local);
    return tz.TZDateTime(tz.local, local.year, local.month, local.day, hour, minute);
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, {required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekdayEvening(int weekday) {
    return _nextInstanceOfWeekday(weekday, hour: 19, minute: 0);
  }

  tz.TZDateTime _nextMonthlyPrompt() {
    final now = tz.TZDateTime.now(tz.local);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final year = now.month == 12 ? now.year + 1 : now.year;
    return tz.TZDateTime(tz.local, year, nextMonth, 1, 19);
  }

  Future<void> _refreshLocalTimezone() async {
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _cancelManagedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_managedNotificationIdsKey) ?? const <String>[];
      for (final raw in ids) {
        final id = int.tryParse(raw);
        if (id != null) {
          await cancelNotificationById(id);
        }
      }
      await prefs.remove(_managedNotificationIdsKey);
    } catch (_) {
      // Safe no-op
    }
  }

  Future<void> _rememberManagedNotificationId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_managedNotificationIdsKey) ?? const <String>[];
    final next = {...existing, '$id'}.toList(growable: false);
    await prefs.setStringList(_managedNotificationIdsKey, next);
  }

  Future<void> _forgetManagedNotificationId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_managedNotificationIdsKey) ?? const <String>[];
    final next = existing.where((item) => item != '$id').toList(growable: false);
    if (next.isEmpty) {
      await prefs.remove(_managedNotificationIdsKey);
      return;
    }
    await prefs.setStringList(_managedNotificationIdsKey, next);
  }
}

class WeeklySummaryData {
  final double totalDue;
  final double potentialSavings;
  final int healthScore;
  final String currency;
  final int nextWeekCount;

  const WeeklySummaryData({
    required this.totalDue,
    required this.potentialSavings,
    required this.healthScore,
    required this.currency,
    required this.nextWeekCount,
  });
}
