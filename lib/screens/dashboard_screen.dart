import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/models/ai_insight.dart';
import '../l10n/locale_text.dart';
import '../models/calendar_event.dart';
import '../models/recurring_payment.dart';
import '../services/app_state.dart';
import '../services/financial_intelligence_service.dart';
import '../services/smart_control_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_icon.dart';
import '../widgets/bizoot_branding.dart';
import '../widgets/empty_state.dart';
import '../widgets/gradient_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/premium_lock_card.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_trend_card.dart';
import 'add_payment_screen.dart';
import 'payment_detail_screen.dart';
import 'paywall_screen.dart';
import 'profile_screen.dart';
import 'subscription_limit_paywall_screen.dart';
import 'smart_control_center_screen.dart';
import 'weekly_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openAddPayment(BuildContext context, AppState appState) {
    AppHaptics.tap();
    if (!appState.canAddSubscription) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubscriptionLimitPaywallScreen(
            activeCount: appState.activeSubscriptionCount,
            limit: appState.subscriptionLimit,
            trialActive: appState.isTrialActive,
            trialDaysRemaining: appState.trialDaysRemaining,
          ),
        ),
      );
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddPaymentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final snapshot = appState.intelligenceSnapshot;
    final committedRatio = appState.settings.monthlyIncome <= 0
        ? 0.0
        : (appState.monthlySpend / appState.settings.monthlyIncome).toDouble();

    if (appState.isBootstrapping) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.payments.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'Turn subscriptions into control',
          da: 'GÃƒÂ¸r abonnementer til kontrol',
          de: 'Mach aus Abos echte Kontrolle',
          es: 'Convierte suscripciones en control',
        ),
        body: localeText(
          context,
          en: 'Add your first recurring payment and Bizoot will turn it into a clear monthly picture with insights, reminders, and savings signals.',
          da: 'TilfÃƒÂ¸j din fÃƒÂ¸rste tilbagevendende betaling, og Bizoot omsÃƒÂ¦tter den til et klart mÃƒÂ¥nedligt overblik med indsigt, pÃƒÂ¥mindelser og spare-signaler.',
          de: 'FÃƒÂ¼ge deine erste wiederkehrende Zahlung hinzu, und Bizoot verwandelt sie in ein klares Monatsbild mit Insights, Erinnerungen und Sparsignalen.',
          es: 'AÃƒÂ±ade tu primer pago recurrente y Bizoot lo convertirÃƒÂ¡ en una visiÃƒÂ³n mensual clara con insights, recordatorios y seÃƒÂ±ales de ahorro.',
        ),
        action: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openAddPayment(context, appState),
            child: Text(
              localeText(
                context,
                en: 'Add first payment',
                da: 'TilfÃƒÂ¸j fÃƒÂ¸rste betaling',
                de: 'Erste Zahlung hinzufÃƒÂ¼gen',
                es: 'AÃƒÂ±adir primer pago',
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 128),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedReveal(
            delay: 0,
            child: _DashboardTopRow(
              fullName: appState.userProfile.fullName,
              avatarUrl: appState.userProfile.avatarUrl,
              onProfileTap: () {
                AppHaptics.tap();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          _AnimatedReveal(
            delay: 40,
            child: _HeroCard(
              appState: appState,
              snapshot: snapshot,
              committedRatio: committedRatio,
            ),
          ),
          const SizedBox(height: 18),
          _AnimatedReveal(
            delay: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 420;
                final cardWidth = wide
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _HealthSnapshotCard(
                        snapshot: snapshot.healthScore,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WeeklyReportScreen(
                              initialFocus: ReportFocusSection.health,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _RiskIndicatorCard(
                        risk: snapshot.riskReport,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WeeklyReportScreen(
                              initialFocus: ReportFocusSection.overview,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.home_repair_service_outlined,
            title: localeText(
              context,
              en: 'Life Essentials',
              da: 'Livets faste udgifter',
              de: 'Wichtige Lebensausgaben',
              es: 'Esenciales de la vida',
            ),
            subtitle: localeText(
              context,
              en: 'Critical recurring obligations beyond normal subscriptions.',
              da: 'Vigtige tilbagevendende forpligtelser ud over normale abonnementer.',
              de: 'Wichtige wiederkehrende Verpflichtungen jenseits normaler Abonnements.',
              es: 'Obligaciones recurrentes importantes mÃƒÂ¡s allÃƒÂ¡ de las suscripciones normales.',
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _LifeEssentialsPreviewCard(appState: appState),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.tune_outlined,
            title: localeText(
              context,
              en: 'Smart Control',
              da: 'Smart Control',
              de: 'Smart Control',
              es: 'Smart Control',
            ),
            subtitle: localeText(
              context,
              en: 'A compact view of the biggest recurring-life pressure right now.',
              da: 'Et kompakt overblik over det stÃƒÂ¸rste pres i dine tilbagevendende udgifter lige nu.',
              de: 'Ein kompakter Blick auf den grÃƒÂ¶ÃƒÅ¸ten Druck in deinem wiederkehrenden Finanzleben gerade jetzt.',
              es: 'Una vista compacta de la mayor presiÃƒÂ³n de tu vida financiera recurrente ahora mismo.',
            ),
            trailing: _OpenPillButton(
              label: localeText(
                context,
                en: 'View Control Center',
                da: 'Se Smart Control',
                de: 'Control Center ÃƒÂ¶ffnen',
                es: 'Ver Smart Control',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SmartControlCenterScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _SmartControlPreviewCard(appState: appState),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: localeText(
              context,
              en: 'Smart Insights',
              da: 'Smart indsigt',
              de: 'Smart Insights',
              es: 'Smart Insights',
            ),
            subtitle: localeText(
              context,
              en: 'Top actions Bizoot thinks you should look at right now.',
              da: 'De vigtigste handlinger Bizoot mener, du bÃƒÂ¸r kigge pÃƒÂ¥ lige nu.',
              de: 'Die wichtigsten Aktionen, die Bizoot dir gerade empfiehlt.',
              es: 'Las acciones principales que Bizoot cree que deberÃƒÂ­as revisar ahora mismo.',
            ),
            trailing: _OpenPillButton(
              label: localeText(
                context,
                en: 'View all',
                da: 'Se alle',
                de: 'Alle ansehen',
                es: 'Ver todo',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyReportScreen(
                    initialFocus: ReportFocusSection.insights,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _SmartInsightsSection(appState: appState),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.notifications_active_outlined,
            title: localeText(
              context,
              en: 'Alerts & reminders',
              da: 'Advarsler og pÃƒÂ¥mindelser',
              de: 'Warnungen & Erinnerungen',
              es: 'Alertas y recordatorios',
            ),
            subtitle: localeText(
              context,
              en: 'The warnings and reminders that matter most right now.',
              da: 'De advarsler og pÃƒÂ¥mindelser, der betyder mest lige nu.',
              de: 'Die Warnungen und Erinnerungen, die gerade am wichtigsten sind.',
              es: 'Las alertas y recordatorios que mÃƒÂ¡s importan ahora mismo.',
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _UpcomingRemindersSection(appState: appState),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.savings_outlined,
            title: localeText(
              context,
              en: 'Savings opportunities',
              da: 'Sparemuligheder',
              de: 'SparmÃƒÂ¶glichkeiten',
              es: 'Oportunidades de ahorro',
            ),
            subtitle: localeText(
              context,
              en: 'Actionable recommendations designed to reduce recurring drag and improve control.',
              da: 'Konkrete anbefalinger, der skal reducere tilbagevendende udgiftspres og give bedre kontrol.',
              de: 'Konkrete Empfehlungen, um wiederkehrende Belastung zu senken und mehr Kontrolle zu schaffen.',
              es: 'Recomendaciones accionables para reducir la carga recurrente y mejorar el control.',
            ),
            trailing: _OpenPillButton(
              label: localeText(
                context,
                en: 'Reports',
                da: 'Rapporter',
                de: 'Berichte',
                es: 'Informes',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyReportScreen(
                    initialFocus: ReportFocusSection.insights,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          if (snapshot.duplicateGroups.isEmpty &&
              snapshot.dormantSubscriptions.isEmpty)
            EmptyState(
              title: localeText(
                context,
                en: 'No urgent savings signals',
                da: 'Ingen presserende spare-signaler',
                de: 'Keine dringenden Sparsignale',
                es: 'No hay seÃƒÂ±ales urgentes de ahorro',
              ),
              body: localeText(
                context,
                en: 'Bizoot will surface dormant services, overlap risks, and growth warnings when they become meaningful.',
                da: 'Bizoot viser inaktive tjenester, overlap-risici og vÃƒÂ¦kst-advarsler, nÃƒÂ¥r de bliver relevante.',
                de: 'Bizoot zeigt ruhende Dienste, ÃƒÅ“berschneidungsrisiken und Wachstumswarnungen an, sobald sie relevant werden.',
                es: 'Bizoot mostrarÃƒÂ¡ servicios inactivos, riesgos de solapamiento y alertas de crecimiento cuando sean relevantes.',
              ),
            )
          else ...[
            if (snapshot.dormantSubscriptions.isNotEmpty)
              _OpportunityCard(
                title: localeText(
                  context,
                  en: 'Dormant subscriptions',
                  da: 'Inaktive abonnementer',
                  de: 'Inaktive Abonnements',
                  es: 'Suscripciones inactivas',
                ),
                body: localeText(
                  context,
                  en: 'Cancelling ${snapshot.dormantSubscriptions.take(2).map((item) => item.payment.name).join(' and ')} could save ${formatCurrency(snapshot.dormantSubscriptions.fold<double>(0, (sum, item) => sum + item.yearlyCost), appState.settings.currency)}/year.',
                  da: 'Hvis du opsiger ${snapshot.dormantSubscriptions.take(2).map((item) => item.payment.name).join(' og ')}, kan du spare ${formatCurrency(snapshot.dormantSubscriptions.fold<double>(0, (sum, item) => sum + item.yearlyCost), appState.settings.currency)}/ÃƒÂ¥r.',
                  de: 'Wenn du ${snapshot.dormantSubscriptions.take(2).map((item) => item.payment.name).join(' und ')} kÃƒÂ¼ndigst, kÃƒÂ¶nntest du ${formatCurrency(snapshot.dormantSubscriptions.fold<double>(0, (sum, item) => sum + item.yearlyCost), appState.settings.currency)}/Jahr sparen.',
                  es: 'Cancelar ${snapshot.dormantSubscriptions.take(2).map((item) => item.payment.name).join(' y ')} podrÃƒÂ­a ahorrarte ${formatCurrency(snapshot.dormantSubscriptions.fold<double>(0, (sum, item) => sum + item.yearlyCost), appState.settings.currency)}/aÃƒÂ±o.',
                ),
                icon: Icons.self_improvement_outlined,
                accent: BizootColors.orange,
              ),
            if (snapshot.dormantSubscriptions.isEmpty &&
                snapshot.duplicateGroups.isNotEmpty)
              _OpportunityCard(
                title: localeText(
                  context,
                  en: 'Overlapping services',
                  da: 'Overlappende tjenester',
                  de: 'ÃƒÅ“berschneidende Dienste',
                  es: 'Servicios solapados',
                ),
                body: localeText(
                  context,
                  en: 'You have ${snapshot.duplicateGroups.first.payments.length} ${snapshot.duplicateGroups.first.label.toLowerCase()} services active at once. Reducing one may save ${formatCurrency(snapshot.duplicateGroups.first.yearlyImpact, appState.settings.currency)}/year.',
                  da: 'Du har ${snapshot.duplicateGroups.first.payments.length} aktive ${snapshot.duplicateGroups.first.label.toLowerCase()}-tjenester pÃƒÂ¥ samme tid. Hvis du reducerer ÃƒÂ©n, kan du spare ${formatCurrency(snapshot.duplicateGroups.first.yearlyImpact, appState.settings.currency)}/ÃƒÂ¥r.',
                  de: 'Du hast ${snapshot.duplicateGroups.first.payments.length} aktive ${snapshot.duplicateGroups.first.label.toLowerCase()}-Dienste gleichzeitig. Wenn du einen reduzierst, kÃƒÂ¶nntest du ${formatCurrency(snapshot.duplicateGroups.first.yearlyImpact, appState.settings.currency)}/Jahr sparen.',
                  es: 'Tienes ${snapshot.duplicateGroups.first.payments.length} servicios de ${snapshot.duplicateGroups.first.label.toLowerCase()} activos al mismo tiempo. Reducir uno podrÃƒÂ­a ahorrarte ${formatCurrency(snapshot.duplicateGroups.first.yearlyImpact, appState.settings.currency)}/aÃƒÂ±o.',
                ),
                icon: Icons.layers_outlined,
                accent: BizootColors.primary,
              ),
          ],
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.multiline_chart_outlined,
            title: localeText(
              context,
              en: 'Trend & categories',
              da: 'Trend og kategorier',
              de: 'Trends & Kategorien',
              es: 'Tendencia y categorÃƒÂ­as',
            ),
            subtitle: localeText(
              context,
              en: 'Quick trend movement and category pressure.',
              da: 'Hurtigt overblik over udvikling og kategoripres.',
              de: 'Schneller Blick auf Trendbewegung und Kategoriedruck.',
              es: 'Vista rÃƒÂ¡pida de la tendencia y la presiÃƒÂ³n por categorÃƒÂ­a.',
            ),
            trailing: _OpenPillButton(
              label: localeText(
                context,
                en: 'Reports',
                da: 'Rapporter',
                de: 'Berichte',
                es: 'Informes',
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyReportScreen(
                    initialFocus: ReportFocusSection.trends,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          if (_hasEnoughTrendData(snapshot.monthlyTrend))
            SizedBox(
              height: 272,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.monthlyTrend.isNotEmpty ? 1 : 0,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final previewIndex = snapshot.monthlyTrend.length - 1;
                  final point = snapshot.monthlyTrend[previewIndex];
                  return SizedBox(
                    width: 228,
                    child: SpendingTrendCard(
                      point: point,
                      points: snapshot.monthlyTrend,
                      highlightIndex: previewIndex,
                      currency: appState.settings.currency,
                    ),
                  );
                },
              ),
            )
          else
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeText(
                      context,
                      en: 'Trend preview',
                      da: 'Trendoversigt',
                      de: 'Trendvorschau',
                      es: 'Vista de tendencia',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      en: 'Add a few recurring payments to unlock the monthly trend view.',
                      da: 'Tilfoej et par tilbagevendende betalinger for at laase den maanedlige trend op.',
                      de: 'Fuege ein paar wiederkehrende Zahlungen hinzu, um die Monatsansicht freizuschalten.',
                      es: 'Agrega algunos pagos recurrentes para desbloquear la vista de tendencia mensual.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: BizootSpacing.md),
          _CategoryDistributionCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 28),
          SectionHeader(
            icon: Icons.upcoming_outlined,
            title: localeText(
              context,
              en: 'Upcoming Life Events',
              da: 'Kommende faste begivenheder',
              de: 'Bevorstehende Lebensereignisse',
              es: 'PrÃƒÂ³ximos eventos recurrentes',
            ),
            subtitle: localeText(
              context,
              en: 'A compact preview of the next recurring events across payments, renewals, trials, and contracts.',
              da: 'En kompakt forhÃƒÂ¥ndsvisning af de nÃƒÂ¦ste tilbagevendende begivenheder pÃƒÂ¥ tvÃƒÂ¦rs af betalinger, fornyelser, prÃƒÂ¸ver og kontrakter.',
              de: 'Eine kompakte Vorschau der nÃƒÂ¤chsten wiederkehrenden Ereignisse ÃƒÂ¼ber Zahlungen, VerlÃƒÂ¤ngerungen, Testphasen und VertrÃƒÂ¤ge hinweg.',
              es: 'Una vista compacta de los prÃƒÂ³ximos eventos recurrentes entre pagos, renovaciones, pruebas y contratos.',
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _UpcomingLifeEventsPreview(appState: appState),
        ],
      ),
    );
  }

  bool _hasEnoughTrendData(List<SpendingTrendPoint> points) {
    return points.where((point) => point.hasTrackedData).length >= 2;
  }
}

class _UpcomingLifeEventsPreview extends StatelessWidget {
  final AppState appState;

  const _UpcomingLifeEventsPreview({required this.appState});

  @override
  Widget build(BuildContext context) {
    final events = appState.upcomingCalendarEvents
        .take(3)
        .toList(growable: false);
    if (events.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'No upcoming life events yet.',
          da: 'Ingen kommende faste begivenheder endnu.',
          de: 'Noch keine bevorstehenden wiederkehrenden Ereignisse.',
          es: 'AÃƒÂºn no hay prÃƒÂ³ximos eventos recurrentes.',
        ),
        body: localeText(
          context,
          en: 'Add recurring essentials and subscriptions to build your timeline.',
          da: 'TilfÃƒÂ¸j tilbagevendende basisudgifter og abonnementer for at opbygge din tidslinje.',
          de: 'FÃƒÂ¼ge wiederkehrende Essentials und Abos hinzu, um deine Timeline aufzubauen.',
          es: 'Agrega esenciales recurrentes y suscripciones para construir tu lÃƒÂ­nea temporal.',
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeText(
                        context,
                        en: 'Upcoming calendar events',
                        da: 'Kommende kalenderbegivenheder',
                        de: 'Bevorstehende Kalenderereignisse',
                        es: 'PrÃƒÂ³ximos eventos del calendario',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localeText(
                        context,
                        en: 'Next 3 recurring life events from your unified calendar.',
                        da: 'De nÃƒÂ¦ste 3 tilbagevendende begivenheder fra din samlede kalender.',
                        de: 'Die nÃƒÂ¤chsten 3 wiederkehrenden Ereignisse aus deinem einheitlichen Kalender.',
                        es: 'Los prÃƒÂ³ximos 3 eventos recurrentes de tu calendario unificado.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _OpenPillButton(
                label: localeText(
                  context,
                  en: 'View Calendar',
                  da: 'Se kalender',
                  de: 'Kalender ansehen',
                  es: 'Ver calendario',
                ),
                onPressed: () => appState.setSelectedTab(1),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...events.map((event) {
            final payment = _paymentForEvent(event);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: payment == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentDetailScreen(payment: payment),
                        ),
                      ),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: BizootColors.border.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Row(
                    children: [
                      BrandIcon(
                        serviceId: payment?.iconKey ?? event.iconKey,
                        serviceName: event.title,
                        category: _categoryLabel(context, event.category),
                        iconKey: payment?.iconKey ?? event.iconKey,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_eventTypeLabel(context, event.eventType)} ${formatShortDate(event.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Color(event.colorValue),
                                    fontWeight: FontWeight.w800,
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _eventTypeLabel(context, event.eventType),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: BizootColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  RecurringPayment? _paymentForEvent(CalendarEvent event) {
    for (final payment in appState.payments) {
      if (payment.id == event.sourceItemId) return payment;
    }
    return null;
  }
}

String _eventTypeLabel(BuildContext context, CalendarEventType type) {
  switch (type) {
    case CalendarEventType.paymentDue:
      return localeText(
        context,
        en: 'Payment',
        da: 'Betaling',
        de: 'Zahlung',
        es: 'Pago',
      );
    case CalendarEventType.renewalDue:
      return localeText(
        context,
        en: 'Renewal',
        da: 'Fornyelse',
        de: 'VerlÃƒÂ¤ngerung',
        es: 'RenovaciÃƒÂ³n',
      );
    case CalendarEventType.contractEnd:
      return localeText(
        context,
        en: 'Contract',
        da: 'Kontrakt',
        de: 'Vertrag',
        es: 'Contrato',
      );
    case CalendarEventType.trialEnd:
      return localeText(
        context,
        en: 'Trial',
        da: 'PrÃƒÂ¸veperiode',
        de: 'Testphase',
        es: 'Prueba',
      );
    case CalendarEventType.reminder:
      return localeText(
        context,
        en: 'Reminder',
        da: 'PÃƒÂ¥mindelse',
        de: 'Erinnerung',
        es: 'Recordatorio',
      );
  }
}

String _categoryLabel(BuildContext context, PaymentCategory category) {
  switch (category) {
    case PaymentCategory.subscription:
      return localeText(
        context,
        en: 'Subscription',
        da: 'Abonnement',
        de: 'Abo',
        es: 'SuscripciÃƒÂ³n',
      );
    case PaymentCategory.rent:
      return localeText(
        context,
        en: 'Rent',
        da: 'Husleje',
        de: 'Miete',
        es: 'Alquiler',
      );
    case PaymentCategory.utilities:
      return localeText(
        context,
        en: 'Utilities',
        da: 'Forsyninger',
        de: 'Nebenkosten',
        es: 'Servicios',
      );
    case PaymentCategory.insurance:
      return localeText(
        context,
        en: 'Insurance',
        da: 'Forsikring',
        de: 'Versicherung',
        es: 'Seguro',
      );
    case PaymentCategory.internet:
      return localeText(
        context,
        en: 'Internet',
        da: 'Internet',
        de: 'Internet',
        es: 'Internet',
      );
    case PaymentCategory.phone:
      return localeText(
        context,
        en: 'Phone',
        da: 'Telefon',
        de: 'Telefon',
        es: 'TelÃƒÂ©fono',
      );
    case PaymentCategory.gym:
      return localeText(
        context,
        en: 'Gym',
        da: 'Fitness',
        de: 'Fitness',
        es: 'Gimnasio',
      );
    case PaymentCategory.loan:
      return localeText(
        context,
        en: 'Loan',
        da: 'LÃƒÂ¥n',
        de: 'Kredit',
        es: 'PrÃƒÂ©stamo',
      );
    case PaymentCategory.membership:
      return localeText(
        context,
        en: 'Membership',
        da: 'Medlemskab',
        de: 'Mitgliedschaft',
        es: 'MembresÃƒÂ­a',
      );
    case PaymentCategory.contract:
      return localeText(
        context,
        en: 'Contract',
        da: 'Kontrakt',
        de: 'Vertrag',
        es: 'Contrato',
      );
    case PaymentCategory.other:
      return localeText(
        context,
        en: 'Other',
        da: 'Andet',
        de: 'Sonstiges',
        es: 'Otro',
      );
  }
}

class _LifeEssentialsPreviewCard extends StatelessWidget {
  final AppState appState;

  const _LifeEssentialsPreviewCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final nextCritical = appState.nextCriticalBill;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MiniPreviewMetric(
                label: localeText(
                  context,
                  en: 'Essentials total',
                  da: 'Basisudgifter i alt',
                  de: 'Essentials gesamt',
                  es: 'Total de esenciales',
                ),
                value: formatCurrency(
                  appState.monthlyEssentialsSpend,
                  appState.settings.currency,
                ),
              ),
              _MiniPreviewMetric(
                label: localeText(
                  context,
                  en: 'Renewals this month',
                  da: 'Fornyelser denne mÃƒÂ¥ned',
                  de: 'VerlÃƒÂ¤ngerungen diesen Monat',
                  es: 'Renovaciones este mes',
                ),
                value: '${appState.renewalsThisMonth.length}',
              ),
              _MiniPreviewMetric(
                label: localeText(
                  context,
                  en: 'Missing links',
                  da: 'Manglende links',
                  de: 'Fehlende Links',
                  es: 'Enlaces faltantes',
                ),
                value:
                    '${appState.itemsMissingManagementLinks.where((item) => item.category != PaymentCategory.subscription).length}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            nextCritical == null
                ? localeText(
                    context,
                    en: 'No critical life-essential bill is due next.',
                    da: 'Ingen kritisk basisregning forfalder som den nÃƒÂ¦ste.',
                    de: 'Als NÃƒÂ¤chstes ist keine kritische wichtige Rechnung fÃƒÂ¤llig.',
                    es: 'No hay una factura esencial crÃƒÂ­tica prÃƒÂ³xima a vencer.',
                  )
                : localeText(
                    context,
                    en: 'Next critical bill: ${nextCritical.name}',
                    da: 'NÃƒÂ¦ste kritiske regning: ${nextCritical.name}',
                    de: 'NÃƒÂ¤chste kritische Rechnung: ${nextCritical.name}',
                    es: 'PrÃƒÂ³xima factura crÃƒÂ­tica: ${nextCritical.name}',
                  ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MiniPreviewMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniPreviewMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SmartControlPreviewCard extends StatelessWidget {
  final AppState appState;

  const _SmartControlPreviewCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    return _SmartControlPreviewCardRefined(appState: appState);
  }
}

class _SmartControlPreviewCardRefined extends StatelessWidget {
  final AppState appState;

  const _SmartControlPreviewCardRefined({required this.appState});

  PriceIncreaseSignal? _matchingPriceIncreaseSignal(
    SmartControlSnapshot snapshot,
    String? paymentId,
  ) {
    if (paymentId == null || paymentId.isEmpty) {
      return null;
    }
    for (final signal in snapshot.priceIncreaseSignals) {
      if (signal.payment.id == paymentId) {
        return signal;
      }
    }
    return null;
  }

  String _resolvedInsightBody(
    BuildContext context,
    SmartControlSnapshot snapshot,
    SmartControlInsight insight,
  ) {
    final priceSignal = _matchingPriceIncreaseSignal(
      snapshot,
      insight.relatedPaymentId,
    );
    if (priceSignal != null) {
      return localeText(
        context,
        en: priceSignal.shouldUsePercentCopy
            ? '${priceSignal.payment.name} increased by ${priceSignal.displayPercentage.toStringAsFixed(0)}% since the last update.'
            : '${priceSignal.payment.name} went up by ${formatCurrency(priceSignal.deltaAmount, appState.settings.currency)}/month since the last update.',
        da: priceSignal.shouldUsePercentCopy
            ? '${priceSignal.payment.name} er steget med ${priceSignal.displayPercentage.toStringAsFixed(0)}% siden sidste opdatering.'
            : '${priceSignal.payment.name} steg med ${formatCurrency(priceSignal.deltaAmount, appState.settings.currency)}/maaned siden sidste opdatering.',
        de: priceSignal.shouldUsePercentCopy
            ? '${priceSignal.payment.name} ist seit dem letzten Update um ${priceSignal.displayPercentage.toStringAsFixed(0)}% gestiegen.'
            : '${priceSignal.payment.name} ist seit dem letzten Update um ${formatCurrency(priceSignal.deltaAmount, appState.settings.currency)}/Monat gestiegen.',
        es: priceSignal.shouldUsePercentCopy
            ? '${priceSignal.payment.name} aumento un ${priceSignal.displayPercentage.toStringAsFixed(0)}% desde la ultima actualizacion.'
            : '${priceSignal.payment.name} subio ${formatCurrency(priceSignal.deltaAmount, appState.settings.currency)}/mes desde la ultima actualizacion.',
      );
    }

    if (insight.id == 'essential-burden' &&
        snapshot.essentialBurden.essentialBurdenPercentage >= 100) {
      return localeText(
        context,
        en: 'Your essential recurring costs are now higher than your monthly income.',
        da: 'Dine essentielle tilbagevendende udgifter er nu hojere end din maanedlige indkomst.',
        de: 'Deine essenziellen wiederkehrenden Kosten liegen jetzt ueber deinem Monatseinkommen.',
        es: 'Tus costes esenciales recurrentes ya superan tus ingresos mensuales.',
      );
    }

    return insight.body;
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = appState.smartControlSnapshot;
    final topInsight = snapshot.topUrgentRecommendation;
    final visibleInsight = appState.hasPremiumFeatureAccess
        ? topInsight
        : (snapshot.insights.isEmpty ? null : snapshot.insights.first);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DashboardFeatureBadge(
                icon: Icons.tune_rounded,
                accent: BizootColors.primary,
                secondaryAccent: BizootColors.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeText(
                        context,
                        en: 'Smart Control Score',
                        da: 'Smart Control-score',
                        de: 'Smart-Control-Wert',
                        es: 'Puntuacion de Smart Control',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${snapshot.healthScore.score} / 100',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: BizootColors.border.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: Text(
                            snapshot.healthScore.status,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BizootColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    localeText(
                      context,
                      en: 'Projected yearly savings',
                      da: 'Forventet aarlig besparelse',
                      de: 'Geschaetzte jaehrliche Ersparnis',
                      es: 'Ahorro anual proyectado',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    formatCurrency(
                      snapshot.projectedYearlySavings,
                      appState.settings.currency,
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (visibleInsight != null) ...[
            const SizedBox(height: 14),
            Text(
              visibleInsight.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _resolvedInsightBody(context, snapshot, visibleInsight),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Text(
              localeText(
                context,
                en: 'No smart control insights yet. Add a few recurring essentials and Bizoot will start finding opportunities.',
                da: 'Ingen Smart Control-indsigter endnu. Tilfoej et par tilbagevendende basisudgifter, saa begynder Bizoot at finde muligheder.',
                de: 'Noch keine Smart-Control-Einblicke. Fuege einige wiederkehrende Grundkosten hinzu, dann erkennt Bizoot erste Chancen.',
                es: 'Aun no hay insights de Smart Control. Agrega algunos gastos esenciales recurrentes y Bizoot empezara a encontrar oportunidades.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
          ],
          if (!appState.hasPremiumFeatureAccess) ...[
            const SizedBox(height: 12),
            Text(
              localeText(
                context,
                en: 'Advanced Smart Control recommendations unlock with Premium after your trial.',
                da: 'Avancerede Smart Control-anbefalinger laases op med Premium efter din proeveperiode.',
                de: 'Erweiterte Smart-Control-Empfehlungen werden nach deiner Testphase mit Premium freigeschaltet.',
                es: 'Las recomendaciones avanzadas de Smart Control se desbloquean con Premium despues de tu prueba.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedReveal extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedReveal({required this.child, required this.delay});

  @override
  State<_AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<_AnimatedReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: BizootDurations.medium,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: BizootDurations.medium,
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        child: widget.child,
      ),
    );
  }
}

class _DashboardTopRow extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;
  final VoidCallback onProfileTap;

  const _DashboardTopRow({
    required this.fullName,
    required this.avatarUrl,
    required this.onProfileTap,
  });

  String get _firstName {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? '' : trimmed.split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String get _initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (parts.isEmpty) return 'B';
    return parts.map((item) => item[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    final normalizedAvatarUrl = avatarUrl?.trim() ?? '';
    final localAvatarFile = normalizedAvatarUrl.isEmpty
        ? null
        : File(normalizedAvatarUrl);
    final ImageProvider<Object>? avatarProvider = !hasAvatar
        ? null
        : (normalizedAvatarUrl.startsWith('http://') ||
              normalizedAvatarUrl.startsWith('https://'))
        ? NetworkImage(normalizedAvatarUrl)
        : (localAvatarFile != null && localAvatarFile.existsSync()
              ? FileImage(localAvatarFile)
              : null);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BizootAppIconImage(size: 42),
                  const SizedBox(width: 12),
                  GradientText(
                    localeText(
                      context,
                      en: 'Bizoot',
                      da: 'Bizoot',
                      de: 'Bizoot',
                      es: 'Bizoot',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _firstName.isEmpty
                    ? localeText(
                        context,
                        en: _greeting == 'morning'
                            ? 'Good morning'
                            : _greeting == 'afternoon'
                            ? 'Good afternoon'
                            : 'Good evening',
                        da: _greeting == 'morning'
                            ? 'Godmorgen'
                            : _greeting == 'afternoon'
                            ? 'God eftermiddag'
                            : 'God aften',
                        de: _greeting == 'morning'
                            ? 'Guten Morgen'
                            : _greeting == 'afternoon'
                            ? 'Guten Tag'
                            : 'Guten Abend',
                        es: _greeting == 'morning'
                            ? 'Buenos dÃƒÂ­as'
                            : _greeting == 'afternoon'
                            ? 'Buenas tardes'
                            : 'Buenas noches',
                      )
                    : localeText(
                        context,
                        en: _greeting == 'morning'
                            ? 'Good morning, $_firstName'
                            : _greeting == 'afternoon'
                            ? 'Good afternoon, $_firstName'
                            : 'Good evening, $_firstName',
                        da: _greeting == 'morning'
                            ? 'Godmorgen, $_firstName'
                            : _greeting == 'afternoon'
                            ? 'God eftermiddag, $_firstName'
                            : 'God aften, $_firstName',
                        de: _greeting == 'morning'
                            ? 'Guten Morgen, $_firstName'
                            : _greeting == 'afternoon'
                            ? 'Guten Tag, $_firstName'
                            : 'Guten Abend, $_firstName',
                        es: _greeting == 'morning'
                            ? 'Buenos dÃƒÂ­as, $_firstName'
                            : _greeting == 'afternoon'
                            ? 'Buenas tardes, $_firstName'
                            : 'Buenas noches, $_firstName',
                      ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localeText(
                  context,
                  en: 'Your subscription overview',
                  da: 'Dit abonnementsoverblik',
                  de: 'Dein Abo-ÃƒÅ“berblick',
                  es: 'Tu resumen de suscripciones',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BizootGradients.main,
              boxShadow: [
                BoxShadow(
                  color: BizootColors.primary.withValues(alpha: 0.24),
                  blurRadius: 18,
                  spreadRadius: -8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: BizootColors.surfaceElevated,
              backgroundImage: avatarProvider,
              child: hasAvatar
                  ? null
                  : Text(
                      _initials,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BizootColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final AppState appState;
  final FinancialIntelligenceSnapshot snapshot;
  final double committedRatio;

  const _HeroCard({
    required this.appState,
    required this.snapshot,
    required this.committedRatio,
  });

  @override
  Widget build(BuildContext context) {
    final next = appState.nextUpcoming;
    final trendPoint = snapshot.monthlyTrend.isEmpty
        ? null
        : snapshot.monthlyTrend.last;
    final limit = appState.subscriptionLimit <= 0
        ? 5
        : appState.subscriptionLimit;
    final usageProgress = limit <= 0
        ? 0.0
        : (appState.activeSubscriptionCount / limit).clamp(0.0, 1.0).toDouble();
    final trendColor = trendPoint == null
        ? BizootColors.textSecondary
        : !trendPoint.hasComparison
        ? BizootColors.textSecondary
        : trendPoint.isIncrease
        ? BizootColors.success
        : trendPoint.isDecrease
        ? BizootColors.danger
        : BizootColors.primary;
    final trendLabel = trendPoint == null
        ? localeText(
            context,
            en: 'Current month',
            da: 'Denne mÃƒÂ¥ned',
            de: 'Dieser Monat',
            es: 'Este mes',
          )
        : !trendPoint.hasComparison
        ? localeText(
            context,
            en: 'Current month',
            da: 'Denne mÃƒÂ¥ned',
            de: 'Dieser Monat',
            es: 'Este mes',
          )
        : trendPoint.isIncrease
        ? localeText(
            context,
            en: '+${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs last month',
            da: '+${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs sidste mÃƒÂ¥ned',
            de: '+${trendPoint.changePercentage.abs().toStringAsFixed(0)}% gegenÃƒÂ¼ber letztem Monat',
            es: '+${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs el mes pasado',
          )
        : trendPoint.isDecrease
        ? localeText(
            context,
            en: '-${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs last month',
            da: '-${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs sidste mÃƒÂ¥ned',
            de: '-${trendPoint.changePercentage.abs().toStringAsFixed(0)}% gegenÃƒÂ¼ber letztem Monat',
            es: '-${trendPoint.changePercentage.abs().toStringAsFixed(0)}% vs el mes pasado',
          )
        : localeText(
            context,
            en: 'Stable vs last month',
            da: 'Stabil vs sidste mÃƒÂ¥ned',
            de: 'Stabil gegenÃƒÂ¼ber letztem Monat',
            es: 'Estable vs el mes pasado',
          );
    final usageTitle = appState.shouldShowUpgradeWall
        ? localeText(
            context,
            en: 'Trial limit reached',
            da: 'PrÃƒÂ¸vegrÃƒÂ¦nse nÃƒÂ¥et',
            de: 'Testlimit erreicht',
            es: 'LÃƒÂ­mite de prueba alcanzado',
          )
        : appState.isTrialActive
        ? localeText(
            context,
            en: 'Premium trial active',
            da: 'Premium-prÃƒÂ¸ve aktiv',
            de: 'Premium-Test aktiv',
            es: 'Prueba Premium activa',
          )
        : localeText(
            context,
            en: 'Free plan',
            da: 'Gratis plan',
            de: 'Kostenloser Plan',
            es: 'Plan gratuito',
          );
    final usageBody = appState.shouldShowUpgradeWall
        ? localeText(
            context,
            en: 'Upgrade for unlimited tracking.',
            da: 'Opgrader for ubegrÃƒÂ¦nset sporing.',
            de: 'Upgrade fÃƒÂ¼r unbegrenztes Tracking.',
            es: 'Mejora para seguimiento ilimitado.',
          )
        : appState.isTrialActive
        ? localeText(
            context,
            en: '5 active item trial limit',
            da: 'PrÃƒÂ¸vegrÃƒÂ¦nse pÃƒÂ¥ 5 abonnementer',
            de: 'Testlimit von 5 Abos',
            es: 'LÃƒÂ­mite de prueba de 5 suscripciones',
          )
        : localeText(
            context,
            en: 'Upgrade anytime for unlimited tracking',
            da: 'Opgrader nÃƒÂ¥r som helst for ubegrÃƒÂ¦nset sporing',
            de: 'Jederzeit upgraden fÃƒÂ¼r unbegrenztes Tracking',
            es: 'Mejora cuando quieras para seguimiento ilimitado',
          );
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Monthly recurring spend',
              da: 'MÃƒÂ¥nedligt tilbagevendende forbrug',
              de: 'Monatliche wiederkehrende Ausgaben',
              es: 'Gasto recurrente mensual',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BizootColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GradientText(
            formatCurrency(appState.monthlySpend, appState.settings.currency),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 36,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  localeText(
                    context,
                    en: '${(committedRatio * 100).toStringAsFixed(0)}% of income committed.',
                    da: '${(committedRatio * 100).toStringAsFixed(0)}% af indkomsten er bundet.',
                    de: '${(committedRatio * 100).toStringAsFixed(0)}% des Einkommens sind gebunden.',
                    es: '${(committedRatio * 100).toStringAsFixed(0)}% de los ingresos estÃƒÂ¡n comprometidos.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (snapshot.monthlyTrend.length > 1)
                SizedBox(
                  width: 86,
                  height: 32,
                  child: _MicroTrendSparkline(
                    points: snapshot.monthlyTrend,
                    color: trendColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                icon: Icons.trending_up_rounded,
                iconColor: trendColor,
                label: trendLabel,
              ),
              _MetricChip(
                icon: Icons.wallet_outlined,
                iconColor: BizootColors.primary,
                label: localeText(
                  context,
                  en: appState.safeToSpend >= 0
                      ? 'Safe to spend ${formatCurrency(appState.safeToSpend, appState.settings.currency)}'
                      : 'Monthly gap ${formatCurrency(appState.safeToSpend.abs(), appState.settings.currency)}',
                  da: 'Til rÃƒÂ¥dighed ${formatCurrency(appState.safeToSpend, appState.settings.currency)}',
                  de: 'VerfÃƒÂ¼gbar ${formatCurrency(appState.safeToSpend, appState.settings.currency)}',
                  es: 'Disponible ${formatCurrency(appState.safeToSpend, appState.settings.currency)}',
                ),
              ),
              if (next != null)
                _MetricChip(
                  icon: Icons.schedule_outlined,
                  iconColor: BizootColors.orange,
                  label: localeText(
                    context,
                    en: 'Next: ${next.name}',
                    da: 'NÃƒÂ¦ste: ${next.name}',
                    de: 'Als NÃƒÂ¤chstes: ${next.name}',
                    es: 'Siguiente: ${next.name}',
                  ),
                ),
            ],
          ),
          if (!appState.isPremiumUser) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;
                  final titleBlock = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BizootColors.primary.withValues(alpha: 0.14),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          size: 16,
                          color: BizootColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usageTitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: BizootColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              usageBody,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BizootColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (compact) ...[
                        titleBlock,
                        const SizedBox(height: 12),
                        _OpenPillButton(
                          label: localeText(
                            context,
                            en: 'Upgrade',
                            da: 'Opgrader',
                            de: 'Upgrade',
                            es: 'Mejorar',
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          ),
                        ),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: titleBlock),
                            const SizedBox(width: 12),
                            _OpenPillButton(
                              label: localeText(
                                context,
                                en: 'Upgrade',
                                da: 'Opgrader',
                                de: 'Upgrade',
                                es: 'Mejorar',
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PaywallScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: usageProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            BizootColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(
                            localeText(
                              context,
                              en: '${appState.activeSubscriptionCount} / $limit active items used',
                              da: '${appState.activeSubscriptionCount} / $limit abonnementer brugt',
                              de: '${appState.activeSubscriptionCount} / $limit Abos genutzt',
                              es: '${appState.activeSubscriptionCount} / $limit suscripciones usadas',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: BizootColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          if (appState.isTrialActive)
                            Text(
                              localeText(
                                context,
                                en: 'Trial: ${appState.trialDaysRemaining} day${appState.trialDaysRemaining == 1 ? '' : 's'} left',
                                da: 'Prøve: ${appState.trialDaysRemaining} dag${appState.trialDaysRemaining == 1 ? '' : 'e'} tilbage',
                                de: 'Test: noch ${appState.trialDaysRemaining} Tag${appState.trialDaysRemaining == 1 ? '' : 'e'}',
                                es: 'Prueba: quedan ${appState.trialDaysRemaining} día${appState.trialDaysRemaining == 1 ? '' : 's'}',
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BizootColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _MetricChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroTrendSparkline extends StatelessWidget {
  final List<SpendingTrendPoint> points;
  final Color color;

  const _MicroTrendSparkline({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(points: points, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<SpendingTrendPoint> points;
  final Color color;

  const _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final values = points.map((point) => point.amount).toList(growable: false);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 0.01
        ? 1.0
        : (maxValue - minValue);
    final spacing = size.width / (points.length - 1);
    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final dx = spacing * index;
      final normalized = (values[index] - minValue) / range;
      final dy = size.height - (normalized * (size.height - 6)) - 3;
      if (index == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.55),
          color,
          BizootColors.pink.withValues(alpha: 0.9),
        ],
      ).createShader(Offset.zero & size);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _HealthSnapshotCard extends StatelessWidget {
  final HealthScoreSnapshot snapshot;
  final VoidCallback onPressed;

  const _HealthSnapshotCard({required this.snapshot, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final pointsFromIdeal = (100 - snapshot.score).clamp(0, 100);
    final riskLabel = snapshot.breakdown.isEmpty
        ? snapshot.label
        : snapshot.breakdown.first.title;
    final deltaColor = pointsFromIdeal == 0
        ? BizootColors.success
        : pointsFromIdeal >= 35
        ? BizootColors.danger
        : pointsFromIdeal >= 15
        ? BizootColors.orange
        : BizootColors.primary;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BizootColors.primary.withValues(alpha: 0.22),
                  BizootColors.primary.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0.18, 0.68, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: BizootColors.primary.withValues(alpha: 0.20),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: snapshot.score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      BizootColors.primary,
                    ),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BizootColors.surfaceElevated.withValues(alpha: 0.94),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.score}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      '/100',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Health score',
                    da: 'Sundhedsscore',
                    de: 'Gesundheitswert',
                    es: 'PuntuaciÃƒÂ³n de salud',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.score} / 100',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: deltaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: deltaColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    pointsFromIdeal == 0
                        ? localeText(
                            context,
                            en: 'Perfect score',
                            da: 'Perfekt score',
                            de: 'Perfekter Wert',
                            es: 'PuntuaciÃƒÂ³n perfecta',
                          )
                        : localeText(
                            context,
                            en: '$pointsFromIdeal points from ideal',
                            da: '$pointsFromIdeal point fra idealet',
                            de: '$pointsFromIdeal Punkte vom Ideal entfernt',
                            es: '$pointsFromIdeal puntos del ideal',
                          ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: deltaColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  localeText(
                    context,
                    en: 'Main risk: $riskLabel',
                    da: 'StÃƒÂ¸rste risiko: $riskLabel',
                    de: 'Hauptrisiko: $riskLabel',
                    es: 'Riesgo principal: $riskLabel',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _OpenPillButton(
                  label: localeText(
                    context,
                    en: 'View full analysis',
                    da: 'Se fuld analyse',
                    de: 'VollstÃƒÂ¤ndige Analyse ansehen',
                    es: 'Ver anÃƒÂ¡lisis completo',
                  ),
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskIndicatorCard extends StatelessWidget {
  final SubscriptionRiskReport risk;
  final VoidCallback onPressed;

  const _RiskIndicatorCard({required this.risk, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final accent = switch (risk.level) {
      RiskLevel.high => BizootColors.danger,
      RiskLevel.medium => BizootColors.orange,
      RiskLevel.low => BizootColors.success,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: accent),
              const SizedBox(width: 8),
              Text(
                localeText(
                  context,
                  en: 'Important alerts',
                  da: 'Vigtige advarsler',
                  de: 'Wichtige Hinweise',
                  es: 'Alertas importantes',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            risk.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            risk.reasons.isEmpty
                ? localeText(
                    context,
                    en: 'No major recurring risks detected right now.',
                    da: 'Ingen stÃƒÂ¸rre tilbagevendende risici registreret lige nu.',
                    de: 'Derzeit keine grÃƒÂ¶ÃƒÅ¸eren wiederkehrenden Risiken erkannt.',
                    es: 'No se detectan riesgos recurrentes importantes en este momento.',
                  )
                : risk.reasons.first,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _OpenPillButton(
            label: localeText(
              context,
              en: 'Review details',
              da: 'GennemgÃƒÂ¥ detaljer',
              de: 'Details prÃƒÂ¼fen',
              es: 'Revisar detalles',
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _RecurringBurdenCard extends StatelessWidget {
  final double burdenPercentage;
  final double safeToSpend;
  final String currency;

  const _RecurringBurdenCard({
    required this.burdenPercentage,
    required this.safeToSpend,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Recurring burden',
              da: 'Tilbagevendende belastning',
              de: 'Wiederkehrende Belastung',
              es: 'Carga recurrente',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            '${burdenPercentage.toStringAsFixed(1)}% of income',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            safeToSpend >= 0
                ? '${formatCurrency(safeToSpend, currency)} remains after recurring commitments each month.'
                : 'Your recurring commitments are ${formatCurrency(safeToSpend.abs(), currency)} above your current monthly comfort range.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OpenPillButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _OpenPillButton({required this.onPressed, this.label = 'Open'});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: BizootGradients.main,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _WeeklyReportCard extends StatelessWidget {
  final AppState appState;

  const _WeeklyReportCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final report = appState.weeklyReport;
    return AppCard(
      child: Column(
        children: [
          _ReportRow(
            icon: Icons.today_outlined,
            label: localeText(
              context,
              en: 'This week',
              da: 'Denne uge',
              de: 'Diese Woche',
              es: 'Esta semana',
            ),
            value: formatCurrency(
              report.totalThisWeek,
              appState.settings.currency,
            ),
          ),
          const SizedBox(height: 14),
          _ReportRow(
            icon: Icons.date_range_outlined,
            label: localeText(
              context,
              en: 'Next week',
              da: 'NÃƒÂ¦ste uge',
              de: 'NÃƒÂ¤chste Woche',
              es: 'La prÃƒÂ³xima semana',
            ),
            value: formatCurrency(
              report.totalNextWeek,
              appState.settings.currency,
            ),
          ),
          const SizedBox(height: 14),
          _ReportRow(
            icon: Icons.star_outline_rounded,
            label: localeText(
              context,
              en: 'Biggest upcoming',
              da: 'StÃƒÂ¸rste kommende',
              de: 'GrÃƒÂ¶ÃƒÅ¸ter nÃƒÂ¤chster Posten',
              es: 'Mayor prÃƒÂ³ximo',
            ),
            value:
                report.biggestUpcomingPaymentName ==
                    localeText(
                      context,
                      en: 'No upcoming payments',
                      da: 'Ingen kommende betalinger',
                      de: 'Keine bevorstehenden Zahlungen',
                      es: 'No hay prÃƒÂ³ximos pagos',
                    )
                ? localeText(
                    context,
                    en: 'No upcoming payments',
                    da: 'Ingen kommende betalinger',
                    de: 'Keine bevorstehenden Zahlungen',
                    es: 'No hay prÃƒÂ³ximos pagos',
                  )
                : '${report.biggestUpcomingPaymentName} Ã¢â‚¬Â¢ ${formatCurrency(report.biggestUpcomingPaymentAmount, appState.settings.currency)}',
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReportRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: BizootColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BizootColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  const _OpportunityCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDistributionCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _CategoryDistributionCard({
    required this.snapshot,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Category snapshot',
              da: 'Kategorioversigt',
              de: 'KategorieÃƒÂ¼berblick',
              es: 'Resumen por categorÃƒÂ­a',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            localeText(
              context,
              en: 'Open Reports for the full category breakdown and deeper comparisons.',
              da: 'Ãƒâ€¦bn Rapporter for hele kategorioversigten og dybere sammenligninger.',
              de: 'Ãƒâ€“ffne Berichte fÃƒÂ¼r die vollstÃƒÂ¤ndige KategorieÃƒÂ¼bersicht und tiefere Vergleiche.',
              es: 'Abre Informes para ver el desglose completo por categorÃƒÂ­a y comparaciones mÃƒÂ¡s profundas.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (snapshot.categoryBreakdown.isEmpty)
            Text(
              localeText(
                context,
                en: 'Add more recurring payments to unlock category distribution.',
                da: 'TilfÃƒÂ¸j flere tilbagevendende betalinger for at lÃƒÂ¥se op for kategorifordeling.',
                de: 'FÃƒÂ¼ge mehr wiederkehrende Zahlungen hinzu, um die Kategorienverteilung freizuschalten.',
                es: 'Agrega mÃƒÂ¡s pagos recurrentes para desbloquear la distribuciÃƒÂ³n por categorÃƒÂ­as.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            )
          else
            ...snapshot.categoryBreakdown
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.percentileMessage,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: BizootColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: SizedBox(
                            height: 28,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatCurrency(item.monthlySpend, currency),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PremiumInsightsCarousel extends StatelessWidget {
  final List<PremiumInsightCardData> insights;

  const _PremiumInsightsCarousel({required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'No premium insights yet',
          da: 'Ingen premium-indsigter endnu',
          de: 'Noch keine Premium-Einblicke',
          es: 'AÃƒÂºn no hay insights premium',
        ),
        body: localeText(
          context,
          en: 'Bizoot will surface high-signal recommendations as your recurring history becomes richer.',
          da: 'Bizoot vil vise mere vÃƒÂ¦rdifulde anbefalinger, nÃƒÂ¥r din historik med tilbagevendende udgifter bliver rigere.',
          de: 'Bizoot zeigt hochwertigere Empfehlungen, sobald deine Historie wiederkehrender Ausgaben umfangreicher wird.',
          es: 'Bizoot mostrarÃƒÂ¡ recomendaciones mÃƒÂ¡s valiosas a medida que tu historial recurrente sea mÃƒÂ¡s rico.',
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: insights.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final insight = insights[index];
          return SizedBox(
            width: 260,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.body,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    insight.metricLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SmartInsightsSection extends StatelessWidget {
  final AppState appState;

  const _SmartInsightsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final insights = appState.aiInsights;
    if (insights.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'No smart insights yet',
          da: 'Ingen smarte indsigter endnu',
          de: 'Noch keine smarten Einblicke',
          es: 'AÃƒÂºn no hay insights inteligentes',
        ),
        body: localeText(
          context,
          en: 'Add more recurring payments and Bizoot will begin surfacing stronger local recommendations.',
          da: 'TilfÃƒÂ¸j flere tilbagevendende betalinger, sÃƒÂ¥ begynder Bizoot at vise stÃƒÂ¦rkere lokale anbefalinger.',
          de: 'FÃƒÂ¼ge mehr wiederkehrende Zahlungen hinzu, dann zeigt Bizoot stÃƒÂ¤rkere lokale Empfehlungen an.',
          es: 'Agrega mÃƒÂ¡s pagos recurrentes y Bizoot empezarÃƒÂ¡ a mostrar recomendaciones locales mÃƒÂ¡s sÃƒÂ³lidas.',
        ),
      );
    }

    final visibleInsights = appState.hasPremiumFeatureAccess
        ? insights.take(2)
        : insights.take(1);

    return Column(
      children: [
        ...visibleInsights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardFeatureBadge(
                        icon: _iconForSeverity(insight.severity),
                        accent: _colorForSeverity(insight.severity),
                        secondaryAccent: BizootColors.secondary,
                        size: 44,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            insight.title,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (insight.financialImpactLabel != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        insight.financialImpactLabel!,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _colorForSeverity(insight.severity),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    insight.explanation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _OpenPillButton(
                      label:
                          insight.premiumLocked &&
                              !appState.hasPremiumFeatureAccess
                          ? localeText(
                              context,
                              en: 'Unlock smart insights',
                              da: 'LÃƒÂ¥s smarte indsigter op',
                              de: 'Smarte Einblicke freischalten',
                              es: 'Desbloquear insights inteligentes',
                            )
                          : insight.actionLabel,
                      onPressed: () {
                        if (insight.premiumLocked &&
                            !appState.hasPremiumFeatureAccess) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          );
                          return;
                        }
                        if (insight.relatedPaymentId == null) return;
                        RecurringPayment? payment;
                        for (final item in appState.payments) {
                          if (item.id == insight.relatedPaymentId) {
                            payment = item;
                            break;
                          }
                        }
                        if (payment == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentDetailScreen(payment: payment!),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (!appState.hasPremiumFeatureAccess)
          PremiumLockCard(
            title: localeText(
              context,
              en: 'Full AI insights are premium',
              da: 'Fuld AI-indsigt er premium',
              de: 'VollstÃƒÂ¤ndige KI-Einblicke sind Premium',
              es: 'Los insights completos de IA son premium',
            ),
            body: localeText(
              context,
              en: 'Free users can preview one local AI insight. Upgrade to unlock full forecasts, cancellation recommendations, and health-score explanations.',
              da: 'Gratisbrugere kan se en lokal AI-indsigt som forhÃƒÂ¥ndsvisning. Opgrader for at lÃƒÂ¥se op for fulde prognoser, opsigelsesanbefalinger og forklaringer pÃƒÂ¥ sundhedsscoren.',
              de: 'Kostenlose Nutzer kÃƒÂ¶nnen eine lokale KI-Einsicht als Vorschau sehen. Upgrade, um vollstÃƒÂ¤ndige Prognosen, KÃƒÂ¼ndigungsempfehlungen und ErklÃƒÂ¤rungen zum Gesundheitswert freizuschalten.',
              es: 'Los usuarios gratuitos pueden previsualizar un insight local de IA. Mejora para desbloquear previsiones completas, recomendaciones de cancelaciÃƒÂ³n y explicaciones de la puntuaciÃƒÂ³n de salud.',
            ),
            previewTitle: insights.first.title,
            previewBody: insights.first.explanation,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
          ),
      ],
    );
  }

  IconData _iconForSeverity(AiInsightSeverity severity) {
    return switch (severity) {
      AiInsightSeverity.info => Icons.insights_outlined,
      AiInsightSeverity.warning => Icons.warning_amber_rounded,
      AiInsightSeverity.savings => Icons.savings_outlined,
      AiInsightSeverity.urgent => Icons.priority_high_rounded,
    };
  }

  Color _colorForSeverity(AiInsightSeverity severity) {
    return switch (severity) {
      AiInsightSeverity.info => BizootColors.primary,
      AiInsightSeverity.warning => BizootColors.orange,
      AiInsightSeverity.savings => BizootColors.success,
      AiInsightSeverity.urgent => BizootColors.danger,
    };
  }
}

class _UpcomingRemindersSection extends StatelessWidget {
  final AppState appState;

  const _UpcomingRemindersSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final reminders = appState.smartNotificationPreview;
    if (reminders.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'No reminders queued yet',
          da: 'Ingen pÃƒÂ¥mindelser planlagt endnu',
          de: 'Noch keine Erinnerungen geplant',
          es: 'AÃƒÂºn no hay recordatorios programados',
        ),
        body: localeText(
          context,
          en: 'Turn on reminders and add upcoming subscriptions to keep this section active.',
          da: 'SlÃƒÂ¥ pÃƒÂ¥mindelser til og tilfÃƒÂ¸j kommende abonnementer for at holde denne sektion aktiv.',
          de: 'Aktiviere Erinnerungen und fÃƒÂ¼ge bevorstehende Abos hinzu, um diesen Bereich aktiv zu halten.',
          es: 'Activa los recordatorios y agrega suscripciones prÃƒÂ³ximas para mantener esta secciÃƒÂ³n activa.',
        ),
      );
    }

    return Column(
      children: reminders.take(2).map((reminder) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _iconForCategory(reminder.category),
                  color: BizootColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reminder.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForCategory(SmartNotificationCategory category) {
    return switch (category) {
      SmartNotificationCategory.critical =>
        Icons.notification_important_outlined,
      SmartNotificationCategory.savings => Icons.savings_outlined,
      SmartNotificationCategory.reminders => Icons.schedule_outlined,
      SmartNotificationCategory.insights => Icons.auto_awesome_outlined,
    };
  }
}

class _DashboardFeatureBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color secondaryAccent;
  final double size;

  const _DashboardFeatureBadge({
    required this.icon,
    required this.accent,
    required this.secondaryAccent,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.2),
            secondaryAccent.withValues(alpha: 0.16),
            BizootColors.surfaceElevated.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: accent, size: size * 0.46),
    );
  }
}

// ignore: unused_element
class _EngagementCard extends StatelessWidget {
  final EngagementSummary summary;

  const _EngagementCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: '${summary.streakDays} day clarity streak',
              da: '${summary.streakDays} dages overbliksstreak',
              de: '${summary.streakDays}-Tage-Klarheitsserie',
              es: 'racha de ${summary.streakDays} dÃƒÂ­as de claridad',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'You optimized ${summary.optimizedSubscriptions} subscriptions and unlocked ${summary.monthlySummariesUnlocked} summaries recently.',
              da: 'Du har optimeret ${summary.optimizedSubscriptions} abonnementer og lÃƒÂ¥st ${summary.monthlySummariesUnlocked} oversigter op for nylig.',
              de: 'Du hast kÃƒÂ¼rzlich ${summary.optimizedSubscriptions} Abos optimiert und ${summary.monthlySummariesUnlocked} Zusammenfassungen freigeschaltet.',
              es: 'Optimizaste ${summary.optimizedSubscriptions} suscripciones y desbloqueaste ${summary.monthlySummariesUnlocked} resÃƒÂºmenes recientemente.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          if (summary.badges.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: summary.badges.take(3).map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BizootColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    badge.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
