import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/locale_text.dart';
import '../models/calendar_event.dart';
import '../models/recurring_payment.dart';
import '../services/app_state.dart';
import '../services/recurring_life_calendar_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_gradient_card.dart';
import '../widgets/premium_lock_card.dart';
import '../widgets/section_header.dart';
import 'payment_detail_screen.dart';
import 'paywall_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFilter _filter = CalendarFilter.all;

  DateTime get _visibleRangeStart =>
      DateTime(_focusedDay.year, _focusedDay.month, 1).subtract(const Duration(days: 35));
  DateTime get _visibleRangeEnd =>
      DateTime(_focusedDay.year, _focusedDay.month + 1, 0).add(const Duration(days: 35));

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final canUseFull = appState.hasPremiumFeatureAccess;
    final service = appState.recurringLifeCalendarService;
    final allEvents = service.buildEvents(
      appState.payments,
      from: _visibleRangeStart,
      to: _visibleRangeEnd,
      hasPremiumAccess: canUseFull,
    );
    final filteredEvents = service.filterEvents(allEvents, _filter);
    final selectedEvents = _eventsForDay(filteredEvents, _selectedDay);
    final timelineEvents = service.filterEvents(appState.upcomingCalendarEvents, _filter);
    final monthEvents = filteredEvents.where((event) => _isSameMonth(event.date, _focusedDay)).toList(growable: false);

    if (allEvents.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'Your recurring life calendar is empty.',
          da: 'Din kalender for tilbagevendende udgifter er tom.',
          de: 'Dein Kalender für wiederkehrende Ausgaben ist leer.',
          es: 'Tu calendario de vida recurrente está vacío.',
        ),
        body: localeText(
          context,
          en: 'Add rent, subscriptions, utilities, or renewals to see everything in one timeline.',
          da: 'Tilføj husleje, abonnementer, forsyninger eller fornyelser for at se alt i én tidslinje.',
          de: 'Füge Miete, Abonnements, Nebenkosten oder Verlängerungen hinzu, um alles in einer Timeline zu sehen.',
          es: 'Añade alquiler, suscripciones, servicios o renovaciones para verlo todo en una sola línea temporal.',
        ),
      );
    }

    final visibleFilters = canUseFull
        ? CalendarFilter.values
        : const [
            CalendarFilter.all,
            CalendarFilter.payments,
            CalendarFilter.essentials,
            CalendarFilter.subscriptions,
          ];

    final overview = _CalendarOverview.fromEvents(monthEvents);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        SectionHeader(
          icon: Icons.calendar_month_outlined,
          title: localeText(
            context,
            en: 'Recurring life calendar',
            da: 'Kalender for faste udgifter',
            de: 'Kalender für wiederkehrende Ausgaben',
            es: 'Calendario de vida recurrente',
          ),
          subtitle: localeText(
            context,
            en: 'Track bills, rent, renewals, trials, and contract dates in one timeline.',
            da: 'Følg regninger, husleje, fornyelser, prøveperioder og kontraktdatoer i én tidslinje.',
            de: 'Verfolge Rechnungen, Miete, Verlängerungen, Testphasen und Vertragsdaten in einer einzigen Timeline.',
            es: 'Sigue facturas, alquiler, renovaciones, pruebas y fechas de contrato en una sola línea temporal.',
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CalendarMetricCard(
              label: localeText(context, en: 'Payments', da: 'Betalinger', de: 'Zahlungen', es: 'Pagos'),
              value: '${overview.paymentCount}',
              accent: const Color(0xFF9B6DFF),
              detail: localeText(context, en: 'Recurring bills and subscriptions this month', da: 'Tilbagevendende regninger og abonnementer denne måned', de: 'Wiederkehrende Rechnungen und Abos in diesem Monat', es: 'Facturas y suscripciones recurrentes este mes'),
            ),
            _CalendarMetricCard(
              label: localeText(context, en: 'Renewals', da: 'Fornyelser', de: 'Verlängerungen', es: 'Renovaciones'),
              value: '${overview.renewalCount}',
              accent: const Color(0xFF4C8DFF),
              detail: localeText(context, en: 'Policies, annual plans, and memberships this month', da: 'Policer, årsplaner og medlemskaber denne måned', de: 'Policen, Jahrespläne und Mitgliedschaften in diesem Monat', es: 'Pólizas, planes anuales y membresías este mes'),
            ),
            _CalendarMetricCard(
              label: localeText(context, en: 'Trials', da: 'Prøver', de: 'Testphasen', es: 'Pruebas'),
              value: '${overview.trialCount}',
              accent: const Color(0xFFFFB449),
              detail: localeText(context, en: 'Ending this month and worth reviewing', da: 'Slutter denne måned og værd at gennemgå', de: 'Enden in diesem Monat und sollten geprüft werden', es: 'Terminan este mes y conviene revisarlos'),
            ),
            _CalendarMetricCard(
              label: localeText(context, en: 'Contracts', da: 'Kontrakter', de: 'Verträge', es: 'Contratos'),
              value: '${overview.contractCount}',
              accent: const Color(0xFFFF7A59),
              detail: localeText(context, en: 'End dates and renewal checkpoints this month', da: 'Slutdatoer og fornyelsespunkter denne måned', de: 'Enddaten und Verlängerungspunkte in diesem Monat', es: 'Fechas de fin y puntos de renovación este mes'),
            ),
            _CalendarMetricCard(
              label: localeText(context, en: 'Due today', da: 'Forfalder i dag', de: 'Heute fällig', es: 'Vence hoy'),
              value: '${overview.dueTodayCount}',
              accent: BizootColors.orange,
              detail: localeText(context, en: 'Needs attention right away', da: 'Kræver opmærksomhed med det samme', de: 'Benötigt sofort Aufmerksamkeit', es: 'Necesita atención de inmediato'),
            ),
            _CalendarMetricCard(
              label: localeText(context, en: 'Overdue', da: 'Forfalden', de: 'Überfällig', es: 'Vencido'),
              value: '${overview.overdueCount}',
              accent: BizootColors.danger,
              detail: localeText(context, en: 'Still unpaid or awaiting action', da: 'Stadig ubetalt eller afventer handling', de: 'Noch unbezahlt oder wartet auf Aktion', es: 'Aún sin pagar o pendiente de acción'),
            ),
          ],
        ),
        const SizedBox(height: BizootSpacing.md),
        GlassGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar<CalendarEvent>(
                firstDay: DateTime.now().subtract(const Duration(days: 730)),
                lastDay: DateTime.now().add(const Duration(days: 1460)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventsForDay(filteredEvents, day),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(Icons.chevron_left, color: BizootColors.textPrimary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: BizootColors.textPrimary),
                  titleTextStyle: TextStyle(
                    color: BizootColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: BizootColors.textSecondary),
                  weekendStyle: TextStyle(color: BizootColors.textSecondary),
                ),
                calendarStyle: CalendarStyle(
                  outsideTextStyle: const TextStyle(color: BizootColors.textMuted),
                  defaultTextStyle: const TextStyle(color: BizootColors.textPrimary),
                  weekendTextStyle: const TextStyle(color: BizootColors.textPrimary),
                  todayDecoration: BoxDecoration(
                    color: BizootColors.primary.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    gradient: BizootGradients.main,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: BizootColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final eventList = events.whereType<CalendarEvent>().toList(growable: false);
                    if (eventList.isEmpty) return const SizedBox.shrink();
                    return Positioned(
                      bottom: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: eventList.take(3).map((event) {
                          final color = Color(event.colorValue);
                          return Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                          );
                        }).toList(growable: false),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
              ),
              const SizedBox(height: 16),
              const _CalendarLegend(),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        GlassGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeText(
                  context,
                  en: 'Event types',
                  da: 'Begivenhedstyper',
                  de: 'Ereignistypen',
                  es: 'Tipos de evento',
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                localeText(
                  context,
                  en: 'Filter by the kind of recurring obligation you want to review.',
                  da: 'Filtrér efter den type tilbagevendende forpligtelse, du vil gennemgå.',
                  de: 'Filtere nach der Art der wiederkehrenden Verpflichtung, die du prüfen möchtest.',
                  es: 'Filtra por el tipo de obligación recurrente que quieras revisar.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: visibleFilters.map((filter) {
                  final selected = _filter == filter;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(_filterLabel(filter)),
                    onSelected: (_) => setState(() => _filter = filter),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        ),
        if (!canUseFull) ...[
          const SizedBox(height: 12),
          PremiumLockCard(
            title: localeText(
              context,
              en: 'Advanced calendar filters are premium',
              da: 'Avancerede kalenderfiltre er premium',
              de: 'Erweiterte Kalenderfilter sind Premium',
              es: 'Los filtros avanzados del calendario son Premium',
            ),
            body: localeText(
              context,
              en: 'Unlock renewal, trial, and contract intelligence across unlimited recurring items.',
              da: 'Lås op for fornyelses-, prøve- og kontraktindsigt på tværs af ubegrænsede tilbagevendende poster.',
              de: 'Schalte Verlängerungs-, Test- und Vertrags-Insights für unbegrenzt viele wiederkehrende Einträge frei.',
              es: 'Desbloquea inteligencia de renovaciones, pruebas y contratos en elementos recurrentes ilimitados.',
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
          ),
        ],
        const SizedBox(height: BizootSpacing.xl),
        SectionHeader(
          icon: Icons.event_note_outlined,
          title: isSameDay(_selectedDay, DateTime.now())
              ? localeText(
                  context,
                  en: 'Today in your recurring life',
                  da: 'I dag i dine faste udgifter',
                  de: 'Heute in deinen wiederkehrenden Ausgaben',
                  es: 'Hoy en tu vida recurrente',
                )
              : localeText(
                  context,
                  en: 'Life events for ${formatShortDate(_selectedDay)}',
                  da: 'Begivenheder for ${formatShortDate(_selectedDay)}',
                  de: 'Ereignisse für ${formatShortDate(_selectedDay)}',
                  es: 'Eventos para ${formatShortDate(_selectedDay)}',
                ),
          subtitle: localeText(
            context,
            en: 'See what is due, what is ending, and what needs a quick action on this date.',
            da: 'Se hvad der forfalder, hvad der slutter, og hvad der kræver handling på denne dato.',
            de: 'Sieh, was fällig ist, was endet und was an diesem Datum schnelle Aktion braucht.',
            es: 'Mira qué vence, qué termina y qué necesita una acción rápida en esta fecha.',
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        if (selectedEvents.isEmpty)
          EmptyState(
            title: localeText(
              context,
              en: 'Nothing scheduled for this date.',
              da: 'Intet planlagt på denne dato.',
              de: 'Für dieses Datum ist nichts geplant.',
              es: 'No hay nada programado para esta fecha.',
            ),
            body: localeText(
              context,
              en: 'Try another date or switch filters to see a different slice of your timeline.',
              da: 'Prøv en anden dato eller skift filter for at se en anden del af tidslinjen.',
              de: 'Versuche ein anderes Datum oder wechsle den Filter, um einen anderen Teil deiner Timeline zu sehen.',
              es: 'Prueba otra fecha o cambia los filtros para ver otra parte de tu línea temporal.',
            ),
          )
        else
          ...selectedEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CalendarEventCard(
                event: event,
                payment: _paymentForEvent(appState.payments, event),
                onView: () => _openPayment(context, appState, event),
                onEdit: () => _openPayment(context, appState, event),
                onMarkPaid: event.isActionablePayment ? () => _markPaid(context, appState, event) : null,
                onRemindMe: () => _remindMe(context, appState, event),
              ),
            ),
          ),
        const SizedBox(height: BizootSpacing.xl),
        SectionHeader(
          icon: Icons.view_timeline_outlined,
          title: localeText(
            context,
            en: 'Upcoming life events',
            da: 'Kommende faste udgifter',
            de: 'Bevorstehende Lebensereignisse',
            es: 'Próximos eventos recurrentes',
          ),
          subtitle: localeText(
            context,
            en: 'Your next payments, renewals, trials, and contract checkpoints in one place.',
            da: 'Dine næste betalinger, fornyelser, prøveperioder og kontraktpunkter samlet ét sted.',
            de: 'Deine nächsten Zahlungen, Verlängerungen, Testphasen und Vertragsprüfpunkte an einem Ort.',
            es: 'Tus próximos pagos, renovaciones, pruebas y hitos de contrato en un solo lugar.',
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        if (timelineEvents.isEmpty)
          EmptyState(
            title: localeText(
              context,
              en: 'No upcoming life events.',
              da: 'Ingen kommende faste udgifter.',
              de: 'Keine bevorstehenden wiederkehrenden Ereignisse.',
              es: 'No hay próximos eventos recurrentes.',
            ),
            body: localeText(
              context,
              en: 'Add more recurring essentials to build out your timeline.',
              da: 'Tilføj flere faste udgifter for at udbygge din tidslinje.',
              de: 'Füge mehr wiederkehrende Ausgaben hinzu, um deine Timeline auszubauen.',
              es: 'Añade más esenciales recurrentes para completar tu línea temporal.',
            ),
          )
        else
          ...timelineEvents.take(canUseFull ? 14 : 7).map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: event.eventType == CalendarEventType.paymentDue
                  ? _CalendarPaymentTimelineTile(
                      event: event,
                      payment: _paymentForEvent(appState.payments, event),
                      onTap: () => _openPayment(context, appState, event),
                    )
                  : _UpcomingTimelineTile(
                      event: event,
                      payment: _paymentForEvent(appState.payments, event),
                      onTap: () => _openPayment(context, appState, event),
                    ),
            ),
          ),
      ],
    );
  }

  List<CalendarEvent> _eventsForDay(List<CalendarEvent> events, DateTime day) {
    return events.where((event) => isSameDay(event.date, day)).toList(growable: false);
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  RecurringPayment? _paymentForEvent(List<RecurringPayment> payments, CalendarEvent event) {
    for (final payment in payments) {
      if (payment.id == event.sourceItemId) return payment;
    }
    return null;
  }

  String _filterLabel(CalendarFilter filter) {
    switch (filter) {
      case CalendarFilter.all:
        return localeText(
          context,
          en: 'All',
          da: 'Alle',
          de: 'Alle',
          es: 'Todos',
        );
      case CalendarFilter.payments:
        return localeText(
          context,
          en: 'Payments',
          da: 'Betalinger',
          de: 'Zahlungen',
          es: 'Pagos',
        );
      case CalendarFilter.renewals:
        return localeText(
          context,
          en: 'Renewals',
          da: 'Fornyelser',
          de: 'Verlängerungen',
          es: 'Renovaciones',
        );
      case CalendarFilter.trials:
        return localeText(
          context,
          en: 'Trials',
          da: 'Prøver',
          de: 'Testphasen',
          es: 'Pruebas',
        );
      case CalendarFilter.contracts:
        return localeText(
          context,
          en: 'Contracts',
          da: 'Kontrakter',
          de: 'Verträge',
          es: 'Contratos',
        );
      case CalendarFilter.essentials:
        return localeText(
          context,
          en: 'Essentials',
          da: 'Faste udgifter',
          de: 'Essentials',
          es: 'Esenciales',
        );
      case CalendarFilter.subscriptions:
        return localeText(
          context,
          en: 'Subscriptions',
          da: 'Abonnementer',
          de: 'Abonnements',
          es: 'Suscripciones',
        );
    }
  }

  Future<void> _openPayment(BuildContext context, AppState appState, CalendarEvent event) async {
    final payment = _paymentForEvent(appState.payments, event);
    if (payment == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentDetailScreen(payment: payment)),
    );
  }

  Future<void> _markPaid(BuildContext context, AppState appState, CalendarEvent event) async {
    final payment = _paymentForEvent(appState.payments, event);
    if (payment == null) return;
    try {
      final nextDueDate = await appState.markPaymentAsPaid(payment);
      if (!context.mounted) return;
      AppHaptics.success();
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Next due date moved to ${formatShortDate(nextDueDate)}.',
          da: 'Næste forfaldsdato er flyttet til ${formatShortDate(nextDueDate)}.',
          de: 'Das nächste Fälligkeitsdatum wurde auf ${formatShortDate(nextDueDate)} verschoben.',
          es: 'La próxima fecha de pago se movió a ${formatShortDate(nextDueDate)}.',
        ),
      );
      setState(() {});
    } catch (_) {
      if (!context.mounted) return;
      AppHaptics.warning();
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not update the next due date right now.',
          da: 'Vi kunne ikke opdatere næste forfaldsdato lige nu.',
          de: 'Das nächste Fälligkeitsdatum konnte gerade nicht aktualisiert werden.',
          es: 'No pudimos actualizar la próxima fecha de pago ahora mismo.',
        ),
      );
    }
  }

  Future<void> _remindMe(BuildContext context, AppState appState, CalendarEvent event) async {
    await appState.remindMeAboutCalendarEvent(event);
    if (!context.mounted) return;
    AppHaptics.success();
    showSuccessSnackBar(
      context,
      localeText(
        context,
        en: 'Reminder scheduled for ${event.title}.',
        da: 'Påmindelse planlagt for ${event.title}.',
        de: 'Erinnerung für ${event.title} geplant.',
        es: 'Recordatorio programado para ${event.title}.',
      ),
    );
  }
}

class _CalendarOverview {
  final int paymentCount;
  final int renewalCount;
  final int trialCount;
  final int contractCount;
  final int dueTodayCount;
  final int overdueCount;

  const _CalendarOverview({
    required this.paymentCount,
    required this.renewalCount,
    required this.trialCount,
    required this.contractCount,
    required this.dueTodayCount,
    required this.overdueCount,
  });

  factory _CalendarOverview.fromEvents(List<CalendarEvent> events) {
    return _CalendarOverview(
      paymentCount: events.where((event) => event.eventType == CalendarEventType.paymentDue).length,
      renewalCount: events.where((event) => event.eventType == CalendarEventType.renewalDue).length,
      trialCount: events.where((event) => event.eventType == CalendarEventType.trialEnd).length,
      contractCount: events.where((event) => event.eventType == CalendarEventType.contractEnd).length,
      dueTodayCount: events.where((event) => event.status == CalendarEventStatus.dueToday).length,
      overdueCount: events.where((event) => event.status == CalendarEventStatus.overdue).length,
    );
  }
}

class _CalendarMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final String detail;

  const _CalendarMetricCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BizootColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BizootColors.textSecondary,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _LegendItem(label: localeText(context, en: 'Payments', da: 'Betalinger', de: 'Zahlungen', es: 'Pagos'), color: const Color(0xFF9B6DFF)),
        _LegendItem(label: localeText(context, en: 'Renewals', da: 'Fornyelser', de: 'Verlängerungen', es: 'Renovaciones'), color: const Color(0xFF4C8DFF)),
        _LegendItem(label: localeText(context, en: 'Trials', da: 'Prøver', de: 'Testphasen', es: 'Pruebas'), color: const Color(0xFFFFB449)),
        _LegendItem(label: localeText(context, en: 'Contracts', da: 'Kontrakter', de: 'Verträge', es: 'Contratos'), color: const Color(0xFFFF7A59)),
        _LegendItem(label: localeText(context, en: 'Overdue', da: 'Forfaldne', de: 'Überfällig', es: 'Vencidos'), color: BizootColors.danger),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  final CalendarEvent event;
  final RecurringPayment? payment;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback? onMarkPaid;
  final VoidCallback onRemindMe;

  const _CalendarEventCard({
    required this.event,
    required this.payment,
    required this.onView,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onRemindMe,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);
    final typeColor = Color(event.colorValue);
    final amountLabel = formatCurrency(event.amount, event.currency);
    final dueState = _dueStateForEvent(context, event);
    final dueMetaStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary);
    final eventTypeBadgeColor = event.eventType == CalendarEventType.paymentDue ? BizootColors.primary : typeColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandIcon(
                serviceId: payment?.iconKey ?? event.iconKey,
                serviceName: event.title,
                category: _categoryLabel(context, event.category),
                iconKey: payment?.iconKey ?? event.iconKey,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TinyBadge(label: _eventTypeLabel(context, event.eventType), color: eventTypeBadgeColor),
                        _TinyBadge(label: _statusLabel(context, event.status), color: statusColor),
                        _TinyBadge(
                          label: _priorityLabel(context, event.priority),
                          color: _priorityColor(event.priority),
                        ),
                        _TinyBadge(label: _categoryLabel(context, event.category), color: BizootColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (dueState != null) ...[
                      if (event.eventType == CalendarEventType.paymentDue) ...[
                        Text(
                          dueState.label,
                          style: dueMetaStyle?.copyWith(
                            color: dueState.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatShortDate(event.date),
                          style: dueMetaStyle,
                        ),
                      ] else ...[
                        Text(
                          _descriptionForEvent(context, event),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: BizootColors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatShortDate(event.date),
                          style: dueMetaStyle,
                        ),
                      ],
                    ] else ...[
                      Text(
                        _descriptionForEvent(context, event),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BizootColors.textSecondary,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatShortDate(event.date),
                        style: dueMetaStyle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    _iconForEventType(event.eventType),
                    color: typeColor,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                label: localeText(
                  context,
                  en: 'View',
                  da: 'Se',
                  de: 'Ansehen',
                  es: 'Ver',
                ),
                onTap: onView,
              ),
              _ActionChip(
                label: localeText(
                  context,
                  en: 'Edit',
                  da: 'Rediger',
                  de: 'Bearbeiten',
                  es: 'Editar',
                ),
                onTap: onEdit,
              ),
              if (onMarkPaid != null)
                _ActionChip(
                  label: localeText(
                    context,
                    en: 'Mark paid',
                    da: 'Markér som betalt',
                    de: 'Als bezahlt markieren',
                    es: 'Marcar como pagado',
                  ),
                  onTap: onMarkPaid!,
                ),
              _ActionChip(
                label: localeText(
                  context,
                  en: 'Remind me',
                  da: 'Påmind mig',
                  de: 'Erinnere mich',
                  es: 'Recuérdame',
                ),
                onTap: onRemindMe,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForEventType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.paymentDue:
        return Icons.payments_outlined;
      case CalendarEventType.renewalDue:
        return Icons.autorenew_rounded;
      case CalendarEventType.contractEnd:
        return Icons.description_outlined;
      case CalendarEventType.trialEnd:
        return Icons.hourglass_bottom_rounded;
      case CalendarEventType.reminder:
        return Icons.notifications_active_outlined;
    }
  }

  _CalendarDueState? _dueStateForEvent(BuildContext context, CalendarEvent event) {
    if (event.eventType != CalendarEventType.paymentDue) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
    if (!normalizedDate.isAfter(today)) {
      return _CalendarDueState(
        label: localeText(
          context,
          en: 'Balance Due',
          da: 'Skyldig betaling',
          de: 'Offener Betrag',
          es: 'Pago pendiente',
        ),
        color: BizootColors.danger,
      );
    }
    return _CalendarDueState(
      label: localeText(
        context,
        en: 'Upcoming Payment',
        da: 'Kommende betaling',
        de: 'Kommende Zahlung',
        es: 'Próximo pago',
      ),
      color: BizootColors.success,
    );
  }

  Color _statusColor(CalendarEventStatus status) {
    switch (status) {
      case CalendarEventStatus.overdue:
        return BizootColors.danger;
      case CalendarEventStatus.dueToday:
        return BizootColors.orange;
      case CalendarEventStatus.upcoming:
        return BizootColors.success;
      case CalendarEventStatus.paid:
        return BizootColors.primary;
      case CalendarEventStatus.cancelled:
        return BizootColors.textMuted;
    }
  }

  Color _priorityColor(CalendarEventPriority priority) {
    switch (priority) {
      case CalendarEventPriority.high:
        return BizootColors.danger;
      case CalendarEventPriority.medium:
        return BizootColors.orange;
      case CalendarEventPriority.low:
        return BizootColors.success;
    }
  }

  String _priorityLabel(BuildContext context, CalendarEventPriority priority) {
    switch (priority) {
      case CalendarEventPriority.high:
        return localeText(
          context,
          en: 'High priority',
          da: 'Høj prioritet',
          de: 'Hohe Priorität',
          es: 'Alta prioridad',
        );
      case CalendarEventPriority.medium:
        return localeText(
          context,
          en: 'Medium priority',
          da: 'Mellem prioritet',
          de: 'Mittlere Priorität',
          es: 'Prioridad media',
        );
      case CalendarEventPriority.low:
        return localeText(
          context,
          en: 'Low priority',
          da: 'Lav prioritet',
          de: 'Niedrige Priorität',
          es: 'Baja prioridad',
        );
    }
  }

  String _descriptionForEvent(BuildContext context, CalendarEvent event) {
    switch (event.eventType) {
      case CalendarEventType.paymentDue:
        return localeText(
          context,
          en: 'A recurring payment is scheduled on this date. Mark it paid once it has been handled.',
          da: 'En tilbagevendende betaling er planlagt på denne dato. Markér den som betalt, når den er håndteret.',
          de: 'An diesem Datum ist eine wiederkehrende Zahlung geplant. Markiere sie als bezahlt, sobald sie erledigt ist.',
          es: 'Hay un pago recurrente programado en esta fecha. Márcalo como pagado cuando ya esté gestionado.',
        );
      case CalendarEventType.renewalDue:
        return localeText(
          context,
          en: 'This item is due for renewal. Review the plan, pricing, or policy before it renews.',
          da: 'Denne post skal fornyes. Gennemgå plan, pris eller police før den fornyes.',
          de: 'Dieser Eintrag muss verlängert werden. Prüfe Plan, Preis oder Police, bevor er sich verlängert.',
          es: 'Este elemento debe renovarse. Revisa el plan, el precio o la póliza antes de que se renueve.',
        );
      case CalendarEventType.contractEnd:
        return localeText(
          context,
          en: 'This contract reaches its end date here. Review the terms before it lapses or renews.',
          da: 'Denne kontrakt når sin slutdato her. Gennemgå vilkårene før den udløber eller fornyes.',
          de: 'Dieser Vertrag erreicht hier sein Enddatum. Prüfe die Bedingungen, bevor er ausläuft oder sich verlängert.',
          es: 'Este contrato llega aquí a su fecha final. Revisa las condiciones antes de que venza o se renueve.',
        );
      case CalendarEventType.trialEnd:
        return localeText(
          context,
          en: 'This trial is ending soon. Decide whether to keep it before billing begins.',
          da: 'Denne prøveperiode slutter snart. Beslut om du vil beholde den, før betalingen starter.',
          de: 'Diese Testphase endet bald. Entscheide vor dem Start der Abrechnung, ob du sie behalten willst.',
          es: 'Esta prueba terminará pronto. Decide si quieres conservarla antes de que empiece el cobro.',
        );
      case CalendarEventType.reminder:
        return localeText(
          context,
          en: 'A reminder has been scheduled for this recurring item.',
          da: 'Der er planlagt en påmindelse for denne tilbagevendende post.',
          de: 'Für diesen wiederkehrenden Eintrag wurde eine Erinnerung geplant.',
          es: 'Se ha programado un recordatorio para este elemento recurrente.',
        );
    }
  }
}

class _UpcomingTimelineTile extends StatelessWidget {
  final CalendarEvent event;
  final RecurringPayment? payment;
  final VoidCallback onTap;

  const _UpcomingTimelineTile({
    required this.event,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(event.colorValue);
    final daysUntil = _daysUntil(event.date);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${event.date.day}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        _monthLabel(event.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: BizootColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 54,
                  margin: const EdgeInsets.only(top: 6),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ],
            ),
            const SizedBox(width: 12),
            BrandIcon(
              serviceId: payment?.iconKey ?? event.iconKey,
              serviceName: event.title,
              category: _categoryLabel(context, event.category),
              iconKey: payment?.iconKey ?? event.iconKey,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eventTypeLabel(context, event.eventType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_eventTypeLabel(context, event.eventType)} • ${_timelineLabel(context, daysUntil)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(event.amount, event.currency),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  _categoryLabel(context, event.category),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.difference(today).inDays;
  }

  String _timelineLabel(BuildContext context, int daysUntil) {
    if (daysUntil < 0) {
      return localeText(
        context,
        en: '${daysUntil.abs()} day${daysUntil.abs() == 1 ? '' : 's'} overdue',
        da: '${daysUntil.abs()} dag${daysUntil.abs() == 1 ? '' : 'e'} forsinket',
        de: '${daysUntil.abs()} Tag${daysUntil.abs() == 1 ? '' : 'e'} überfällig',
        es: '${daysUntil.abs()} día${daysUntil.abs() == 1 ? '' : 's'} vencido${daysUntil.abs() == 1 ? '' : 's'}',
      );
    }
    if (daysUntil == 0) {
      return localeText(
        context,
        en: 'Today',
        da: 'I dag',
        de: 'Heute',
        es: 'Hoy',
      );
    }
    return localeText(
      context,
      en: 'In $daysUntil day${daysUntil == 1 ? '' : 's'}',
      da: 'Om $daysUntil dag${daysUntil == 1 ? '' : 'e'}',
      de: 'In $daysUntil Tag${daysUntil == 1 ? '' : 'en'}',
      es: 'En $daysUntil día${daysUntil == 1 ? '' : 's'}',
    );
  }

  String _monthLabel(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}

class _CalendarPaymentTimelineTile extends StatelessWidget {
  final CalendarEvent event;
  final RecurringPayment? payment;
  final VoidCallback onTap;

  const _CalendarPaymentTimelineTile({
    required this.event,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _CalendarDueState.fromDate(event.date);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: BizootColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BizootColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${event.date.day}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: BizootColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        _monthLabel(event.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: BizootColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 54,
                  margin: const EdgeInsets.only(top: 6),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ],
            ),
            const SizedBox(width: 12),
            BrandIcon(
              serviceId: payment?.iconKey ?? event.iconKey,
              serviceName: event.title,
              category: _categoryLabel(context, event.category),
              iconKey: payment?.iconKey ?? event.iconKey,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localeText(context, en: 'Payment', da: 'Betaling', de: 'Zahlung', es: 'Pago'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BizootColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.localizedLabel(context),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: status.color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatShortDate(event.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(event.amount, event.currency),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  _categoryLabel(context, event.category),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}

class _CalendarDueState {
  final String label;
  final Color color;

  const _CalendarDueState({
    required this.label,
    required this.color,
  });

  String localizedLabel(BuildContext context) {
    if (label == 'Balance Due') {
      return localeText(context, en: 'Balance Due', da: 'Skyldigt beløb', de: 'Offener Betrag', es: 'Saldo pendiente');
    }
    if (label == 'Upcoming Payment') {
      return localeText(context, en: 'Upcoming Payment', da: 'Kommende betaling', de: 'Bevorstehende Zahlung', es: 'Próximo pago');
    }
    return label;
  }

  factory _CalendarDueState.fromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!normalizedDate.isAfter(today)) {
      return const _CalendarDueState(
        label: 'Balance Due',
        color: BizootColors.danger,
      );
    }
    return const _CalendarDueState(
      label: 'Upcoming Payment',
      color: BizootColors.success,
    );
  }
}

String _eventTypeLabel(BuildContext context, CalendarEventType type) {
  switch (type) {
    case CalendarEventType.paymentDue:
      return localeText(context, en: 'Payment', da: 'Betaling', de: 'Zahlung', es: 'Pago');
    case CalendarEventType.renewalDue:
      return localeText(context, en: 'Renewal', da: 'Fornyelse', de: 'Verlängerung', es: 'Renovación');
    case CalendarEventType.contractEnd:
      return localeText(context, en: 'Contract', da: 'Kontrakt', de: 'Vertrag', es: 'Contrato');
    case CalendarEventType.trialEnd:
      return localeText(context, en: 'Trial', da: 'Prøveperiode', de: 'Testphase', es: 'Prueba');
    case CalendarEventType.reminder:
      return localeText(context, en: 'Reminder', da: 'Påmindelse', de: 'Erinnerung', es: 'Recordatorio');
  }
}

String _statusLabel(BuildContext context, CalendarEventStatus status) {
  switch (status) {
    case CalendarEventStatus.upcoming:
      return localeText(context, en: 'Upcoming', da: 'Kommende', de: 'Bevorstehend', es: 'Próximo');
    case CalendarEventStatus.dueToday:
      return localeText(context, en: 'Due today', da: 'Forfalder i dag', de: 'Heute fällig', es: 'Vence hoy');
    case CalendarEventStatus.overdue:
      return localeText(context, en: 'Overdue', da: 'Forfalden', de: 'Überfällig', es: 'Vencido');
    case CalendarEventStatus.paid:
      return localeText(context, en: 'Paid', da: 'Betalt', de: 'Bezahlt', es: 'Pagado');
    case CalendarEventStatus.cancelled:
      return localeText(context, en: 'Cancelled', da: 'Opsagt', de: 'Gekündigt', es: 'Cancelado');
  }
}

String _categoryLabel(BuildContext context, PaymentCategory category) {
  switch (category) {
    case PaymentCategory.subscription:
      return localeText(context, en: 'Subscription', da: 'Abonnement', de: 'Abo', es: 'Suscripción');
    case PaymentCategory.rent:
      return localeText(context, en: 'Rent', da: 'Husleje', de: 'Miete', es: 'Alquiler');
    case PaymentCategory.utilities:
      return localeText(context, en: 'Utilities', da: 'Forsyninger', de: 'Nebenkosten', es: 'Servicios');
    case PaymentCategory.insurance:
      return localeText(context, en: 'Insurance', da: 'Forsikring', de: 'Versicherung', es: 'Seguro');
    case PaymentCategory.internet:
      return localeText(context, en: 'Internet', da: 'Internet', de: 'Internet', es: 'Internet');
    case PaymentCategory.phone:
      return localeText(context, en: 'Phone', da: 'Telefon', de: 'Telefon', es: 'Teléfono');
    case PaymentCategory.gym:
      return localeText(context, en: 'Gym', da: 'Fitness', de: 'Fitness', es: 'Gimnasio');
    case PaymentCategory.loan:
      return localeText(context, en: 'Loan', da: 'Lån', de: 'Kredit', es: 'Préstamo');
    case PaymentCategory.membership:
      return localeText(context, en: 'Membership', da: 'Medlemskab', de: 'Mitgliedschaft', es: 'Membresía');
    case PaymentCategory.contract:
      return localeText(context, en: 'Contract', da: 'Kontrakt', de: 'Vertrag', es: 'Contrato');
    case PaymentCategory.other:
      return localeText(context, en: 'Other', da: 'Andet', de: 'Sonstiges', es: 'Otro');
  }
}

class _TinyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TinyBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color == BizootColors.textMuted ? BizootColors.textSecondary : color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BizootColors.border.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: BizootColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
