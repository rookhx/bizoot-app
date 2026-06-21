import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../services/financial_intelligence_service.dart';
import '../services/smart_control_service.dart';
import '../services/smart_insights_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/payment_math.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/category_donut_card.dart';
import '../widgets/health_score_card.dart';
import '../widgets/spending_trend_card.dart';
import 'payment_detail_screen.dart';

enum ReportFocusSection { overview, health, insights, trends, categories }

class WeeklyReportScreen extends StatefulWidget {
  final bool embedded;
  final ReportFocusSection initialFocus;

  const WeeklyReportScreen({
    super.key,
    this.embedded = false,
    this.initialFocus = ReportFocusSection.overview,
  });

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  int _selectedRangeMonths = 6;

  List<SpendingTrendPoint> _rangePoints(List<SpendingTrendPoint> points) {
    if (points.isEmpty) return const [];
    final count = _selectedRangeMonths == 3 ? 3 : points.length;
    if (points.length <= count) return points;
    return points.sublist(points.length - count);
  }

  void _openPaymentById(BuildContext context, String? paymentId) {
    if (paymentId == null || paymentId.isEmpty) return;
    final appState = context.read<AppState>();
    final payment = appState.payments
        .where((item) => item.id == paymentId)
        .firstOrNull;
    if (payment == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentDetailScreen(payment: payment)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final snapshot = appState.intelligenceSnapshot;
    final control = appState.smartControlSnapshot;
    final trendPoints = _rangePoints(snapshot.monthlyTrend);
    final highlightIndex = trendPoints.isEmpty ? 0 : trendPoints.length - 1;
    final smartInsights = appState.smartInsights;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Financial intelligence, visual analysis, and deeper recurring spending patterns.',
              da: 'Finansiel indsigt, visuel analyse og dybere moenstre i dine tilbagevendende udgifter.',
              de: 'Finanzielle Einblicke, visuelle Analysen und tiefere Muster deiner wiederkehrenden Ausgaben.',
              es: 'Inteligencia financiera, analisis visual y patrones mas profundos de gasto recurrente.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _ReportsRangeCard(
            selectedMonths: _selectedRangeMonths,
            onChanged: (months) =>
                setState(() => _selectedRangeMonths = months),
          ),
          const SizedBox(height: 20),
          HealthScoreCard(
            snapshot: snapshot.healthScore,
            onPressed: () =>
                _showHealthBreakdown(context, snapshot.healthScore),
          ),
          const SizedBox(height: 20),
          if (trendPoints.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final cardHeight = isWide ? 420.0 : 360.0;
                return SizedBox(
                  height: cardHeight,
                  child: SpendingTrendCard(
                    point: trendPoints[highlightIndex],
                    points: trendPoints,
                    highlightIndex: highlightIndex,
                    currency: appState.settings.currency,
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          CategoryDonutCard(
            breakdown: snapshot.categoryBreakdown,
            currency: appState.settings.currency,
            onPressed: () => _showCategoryBreakdown(
              context,
              snapshot.categoryBreakdown,
              appState.settings.currency,
            ),
          ),
          const SizedBox(height: 20),
          _CategoryComparisonBarsCard(
            breakdown: snapshot.categoryBreakdown,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _FinancialIntelligenceCenterCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _OptimizationSignalsCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _RiskBreakdownCard(snapshot: snapshot),
          const SizedBox(height: 20),
          _PaymentClustersCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _SmartControlAnalyticsCard(
            snapshot: control,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _SmartInsightsReportsCard(
            insights: smartInsights,
            onOpenPayment: (paymentId) => _openPaymentById(context, paymentId),
            onOpenHealth: () =>
                _showHealthBreakdown(context, snapshot.healthScore),
            onOpenCategoryBreakdown: () => _showCategoryBreakdown(
              context,
              snapshot.categoryBreakdown,
              appState.settings.currency,
            ),
          ),
          const SizedBox(height: 20),
          _AdvancedHighlightsCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _InsightsFeedCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
          ),
          const SizedBox(height: 20),
          _ReportHighlightsCard(
            snapshot: snapshot,
            currency: appState.settings.currency,
            monthlyIncome: appState.settings.monthlyIncome,
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return AppScaffold(
      title: localeText(
        context,
        en: 'Reports',
        da: 'Rapporter',
        de: 'Berichte',
        es: 'Informes',
      ),
      child: content,
    );
  }

  void _showHealthBreakdown(
    BuildContext context,
    HealthScoreSnapshot snapshot,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BizootColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeText(
                context,
                en: 'Health score breakdown',
                da: 'Oversigt over sundhedsscore',
                de: 'Aufschluesselung des Gesundheitswerts',
                es: 'Desglose de la puntuacion de salud',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              snapshot.explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...snapshot.breakdown.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BizootColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.impact > 0 ? '+' : ''}${item.impact}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: item.impact >= 0
                                  ? BizootColors.success
                                  : BizootColors.danger,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryBreakdown(
    BuildContext context,
    List<CategorySpendBreakdown> breakdown,
    String currency,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BizootColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeText(
                context,
                en: 'Category breakdown',
                da: 'Kategorioversigt',
                de: 'Kategorienaufschluesselung',
                es: 'Desglose por categorias',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...breakdown.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatCurrency(item.monthlySpend, currency),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartControlAnalyticsCard extends StatelessWidget {
  final SmartControlSnapshot snapshot;
  final String currency;

  const _SmartControlAnalyticsCard({
    required this.snapshot,
    required this.currency,
  });

  String _latestPriceChangeLabel(BuildContext context) {
    if (snapshot.priceIncreaseSignals.isEmpty) {
      return localeText(
        context,
        en: 'No recent change',
        da: 'Ingen nylig aendring',
        de: 'Keine aktuelle Aenderung',
        es: 'Sin cambio reciente',
      );
    }
    final signal = snapshot.priceIncreaseSignals.first;
    final summary = signal.shouldUsePercentCopy
        ? '${signal.displayPercentage.toStringAsFixed(0)}%'
        : '${formatCurrency(signal.deltaAmount, currency)}/month';
    return '${signal.payment.name} - $summary';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Smart Control analytics',
              da: 'Smart Control-analyse',
              de: 'Smart-Control-Analyse',
              es: 'Analitica de Smart Control',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'A clearer view of pressure, price changes, and renewal timing.',
              da: 'Et klarere billede af pres, prisendringer og fornyelsestidspunkter.',
              de: 'Ein klarerer Blick auf Druck, Preisveraenderungen und Verlaengerungszeitpunkte.',
              es: 'Una vista mas clara de la presion, los cambios de precio y los tiempos de renovacion.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _ReportLine(
            title: localeText(
              context,
              en: 'Score',
              da: 'Score',
              de: 'Wert',
              es: 'Puntuacion',
            ),
            value: '${snapshot.healthScore.score} / 100',
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Latest price change',
              da: 'Seneste prisendring',
              de: 'Letzte Preisveraenderung',
              es: 'Ultimo cambio de precio',
            ),
            value: _latestPriceChangeLabel(context),
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Renewal risks',
              da: 'Fornyelsesrisici',
              de: 'Verlaengerungsrisiken',
              es: 'Riesgos de renovacion',
            ),
            value: '${snapshot.renewalRisks.length}',
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Projected yearly savings',
              da: 'Forventet aarlig besparelse',
              de: 'Geschaetzte jaehrliche Ersparnis',
              es: 'Ahorro anual proyectado',
            ),
            value: formatCurrency(snapshot.projectedYearlySavings, currency),
          ),
        ],
      ),
    );
  }
}

class _ReportsRangeCard extends StatelessWidget {
  final int selectedMonths;
  final ValueChanged<int> onChanged;

  const _ReportsRangeCard({
    required this.selectedMonths,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [3, 6, 12];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Report range',
              da: 'Rapportperiode',
              de: 'Berichtszeitraum',
              es: 'Rango del informe',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'Switch between 3, 6, and 12 month views for the recurring trend.',
              da: 'Skift mellem 3, 6 og 12 maaneders visning for udviklingen i tilbagevendende udgifter.',
              de: 'Wechsle zwischen 3-, 6- und 12-Monatsansichten fuer den Verlauf wiederkehrender Ausgaben.',
              es: 'Cambia entre vistas de 3, 6 y 12 meses para la tendencia recurrente.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: options
                .map(
                  (months) => Expanded(
                    child: ChoiceChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            localeText(
                              context,
                              en: '$months Months',
                              da: '$months Maaneder',
                              de: '$months Monate',
                              es: '$months Meses',
                            ),
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      selected: selectedMonths == months,
                      onSelected: (_) => onChanged(months),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      selectedColor: BizootColors.primary.withValues(
                        alpha: 0.2,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      labelStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: BizootColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                      side: BorderSide(
                        color: selectedMonths == months
                            ? BizootColors.primary
                            : BizootColors.border.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryComparisonBarsCard extends StatelessWidget {
  final List<CategorySpendBreakdown> breakdown;
  final String currency;

  const _CategoryComparisonBarsCard({
    required this.breakdown,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final items = breakdown.take(4).toList(growable: false);
    final peak = items.isEmpty
        ? 1.0
        : items
              .map((item) => item.monthlySpend)
              .reduce((best, next) => next > best ? next : best);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Category comparison bars',
              da: 'Kategorisammenligning',
              de: 'Kategorievergleich',
              es: 'Comparacion por categorias',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'Compare where your recurring money goes across the strongest categories.',
              da: 'Sammenlign hvor dine tilbagevendende penge gaar hen paa tvrs af dine vigtigste kategorier.',
              de: 'Vergleiche, wohin dein wiederkehrendes Geld ueber deine wichtigsten Kategorien fliesst.',
              es: 'Compara hacia donde va tu dinero recurrente entre tus categorias principales.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              localeText(
                context,
                en: 'Add more recurring items to unlock category comparisons.',
                da: 'Tilfoej flere tilbagevendende poster for at laase op for kategorisammenligninger.',
                de: 'Fuege mehr wiederkehrende Eintraege hinzu, um Kategorievergleiche freizuschalten.',
                es: 'Agrega mas elementos recurrentes para desbloquear comparaciones por categorias.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatCurrency(item.monthlySpend, currency),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: peak <= 0
                            ? 0
                            : (item.monthlySpend / peak).clamp(0, 1),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _categoryColor(item.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.percentileMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
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

class _RiskBreakdownCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;

  const _RiskBreakdownCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final risk = snapshot.riskReport;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Risk breakdown',
              da: 'Risikooversigt',
              de: 'Risikoaufschluesselung',
              es: 'Desglose de riesgo',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          _ReportLine(
            title: localeText(
              context,
              en: 'Current risk level',
              da: 'Nuvaerende risikoniveau',
              de: 'Aktuelles Risikoniveau',
              es: 'Nivel de riesgo actual',
            ),
            value: risk.label,
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Overlap count',
              da: 'Antal overlap',
              de: 'Anzahl an Ueberschneidungen',
              es: 'Cantidad de solapamientos',
            ),
            value: '${risk.overlapCount}',
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Active trials',
              da: 'Aktive proever',
              de: 'Aktive Testphasen',
              es: 'Pruebas activas',
            ),
            value: '${risk.trialCount}',
          ),
          if (risk.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...risk.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: BizootColors.orange,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentClustersCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _PaymentClustersCard({required this.snapshot, required this.currency});

  @override
  Widget build(BuildContext context) {
    final clusters = snapshot.paymentClusters;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Payment clusters',
              da: 'Betalingsklynger',
              de: 'Zahlungscluster',
              es: 'Grupos de pagos',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'See where multiple recurring charges stack up in the same payment window.',
              da: 'Se hvor flere tilbagevendende betalinger samler sig i det samme betalingsvindue.',
              de: 'Sieh, wo sich mehrere wiederkehrende Abbuchungen im selben Zahlungsfenster stapeln.',
              es: 'Mira donde se acumulan varios cargos recurrentes dentro de la misma ventana de pago.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (clusters.isEmpty)
            Text(
              localeText(
                context,
                en: 'No strong payment clustering detected.',
                da: 'Ingen tydelige betalingsklynger registreret.',
                de: 'Keine starken Zahlungscluster erkannt.',
                es: 'No se detectaron agrupaciones fuertes de pagos.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            )
          else
            ...clusters.map(
              (cluster) => _SignalInfoTile(
                title: cluster.label,
                value: formatCurrency(cluster.totalAmount, currency),
                body: localeText(
                  context,
                  en: '${cluster.paymentCount} items are grouped here: ${cluster.services.take(3).join(', ')}${cluster.services.length > 3 ? '...' : ''}',
                  da: '${cluster.paymentCount} poster er samlet her: ${cluster.services.take(3).join(', ')}${cluster.services.length > 3 ? '...' : ''}',
                  de: '${cluster.paymentCount} Eintr\u00e4ge sind hier geb\u00fcndelt: ${cluster.services.take(3).join(', ')}${cluster.services.length > 3 ? '...' : ''}',
                  es: '${cluster.paymentCount} elementos est\u00e1n agrupados aqu\u00ed: ${cluster.services.take(3).join(', ')}${cluster.services.length > 3 ? '...' : ''}',
                ),
                accent: BizootColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SmartInsightsReportsCard extends StatelessWidget {
  final List<SmartInsightCard> insights;
  final ValueChanged<String?> onOpenPayment;
  final VoidCallback onOpenHealth;
  final VoidCallback onOpenCategoryBreakdown;

  const _SmartInsightsReportsCard({
    required this.insights,
    required this.onOpenPayment,
    required this.onOpenHealth,
    required this.onOpenCategoryBreakdown,
  });

  void _handleAction(SmartInsightCard insight) {
    if (insight.id.contains('category-warning')) {
      onOpenCategoryBreakdown();
      return;
    }
    if (insight.id.contains('recurring-burden')) {
      onOpenHealth();
      return;
    }
    onOpenPayment(insight.relatedPaymentId);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Smart insights in reports',
              da: 'Smart indsigt i rapporter',
              de: 'Smart Insights in Berichten',
              es: 'Smart insights en informes',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'Richer report actions around burden, duplication, biggest costs, and savings opportunities.',
              da: 'Rigere rapporthandlinger omkring belastning, overlap, stoerste omkostninger og sparemuligheder.',
              de: 'Tiefere Berichtaktionen zu Belastung, Ueberschneidungen, groessten Kosten und Sparchancen.',
              es: 'Acciones de informe mas ricas sobre carga, duplicacion, mayores costes y oportunidades de ahorro.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty)
            Text(
              localeText(
                context,
                en: 'No smart insights yet.',
                da: 'Endnu ingen smart indsigt.',
                de: 'Noch keine Smart Insights.',
                es: 'Aun no hay smart insights.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            )
          else
            ...insights
                .take(6)
                .map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _handleAction(insight),
                      borderRadius: BorderRadius.circular(22),
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    insight.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                if (insight.impactLabel != null) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    insight.impactLabel!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _smartInsightColor(
                                            insight.severity,
                                          ),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              insight.explanation,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: BizootColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              insight.actionLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: BizootColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AdvancedHighlightsCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _AdvancedHighlightsCard({
    required this.snapshot,
    required this.currency,
  });

  List<String> _friendlyHighlights(BuildContext context) {
    final highlights = <String>[
      localeText(
        context,
        en: 'At this pace, your recurring spending adds up to about ${formatCurrency(snapshot.report.yearlyProjection, currency)} per year.',
        da: 'I dette tempo loeber dine tilbagevendende udgifter op i cirka ${formatCurrency(snapshot.report.yearlyProjection, currency)} om aaret.',
        de: 'In diesem Tempo summieren sich deine wiederkehrenden Ausgaben auf etwa ${formatCurrency(snapshot.report.yearlyProjection, currency)} pro Jahr.',
        es: 'Con este ritmo, tus gastos recurrentes suman aproximadamente ${formatCurrency(snapshot.report.yearlyProjection, currency)} al ano.',
      ),
      localeText(
        context,
        en: 'Your current recurring risk level is ${snapshot.riskReport.label.toLowerCase()}.',
        da: 'Dit nuvaerende risikoniveau for tilbagevendende udgifter er ${snapshot.riskReport.label.toLowerCase()}.',
        de: 'Dein aktuelles Risiko bei wiederkehrenden Ausgaben liegt im Bereich ${snapshot.riskReport.label.toLowerCase()}.',
        es: 'Tu nivel actual de riesgo recurrente esta en el rango ${snapshot.riskReport.label.toLowerCase()}.',
      ),
    ];
    return highlights;
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _friendlyHighlights(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Advanced report highlights',
              da: 'Avancerede rapporthojdepunkter',
              de: 'Erweiterte Berichtshighlights',
              es: 'Aspectos avanzados del informe',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...highlights.map(
            (highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: BizootColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      highlight,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BizootColors.textSecondary,
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

class _FinancialIntelligenceCenterCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _FinancialIntelligenceCenterCard({
    required this.snapshot,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final largestPayment = snapshot.largestSubscription;
    final topCategory = snapshot.mostExpensiveCategory;
    final leadAmount =
        topCategory?.monthlySpend ?? snapshot.monthlyRecurringSpend;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: BizootGradients.surfaceStrong,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: BizootColors.border.withValues(alpha: 0.62),
              ),
              boxShadow: [
                BoxShadow(
                  color: BizootColors.primary.withValues(alpha: 0.14),
                  blurRadius: 30,
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: BizootGradients.main,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: BizootColors.secondary.withValues(
                              alpha: 0.26,
                            ),
                            blurRadius: 24,
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localeText(
                              context,
                              en: 'Financial intelligence center',
                              da: 'Finansielt intelligenscenter',
                              de: 'Finanz-Intelligence-Center',
                              es: 'Centro de inteligencia financiera',
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localeText(
                              context,
                              en: 'Your strongest recurring pressure, cost concentration, and optimization path in one premium view.',
                              da: 'Dit stoerste tilbagevendende pres, din omkostningskoncentration og din optimeringsretning i et premium overblik.',
                              de: 'Dein staerkster wiederkehrender Druck, deine Kostenkonzentration und dein Optimierungspfad in einer Premium-Ansicht.',
                              es: 'Tu mayor presion recurrente, concentracion de costes y ruta de optimizacion en una sola vista premium.',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: BizootColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: BizootColors.border.withValues(alpha: 0.38),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localeText(
                          context,
                          en: 'Dominant pressure',
                          da: 'Stoerste pres',
                          de: 'Staerkster Druck',
                          es: 'Mayor presion',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BizootColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topCategory?.label ??
                            snapshot.report.topCategorySummary,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(leadAmount, currency),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: BizootColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.report.topCategorySummary,
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
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 620;
              final tiles = [
                _IntelligenceMetricTile(
                  label: localeText(
                    context,
                    en: 'Optimization signal',
                    da: 'Optimeringssignal',
                    de: 'Optimierungssignal',
                    es: 'Senal de optimizacion',
                  ),
                  value: snapshot.report.optimizationSummary,
                  accent: BizootColors.success,
                ),
                _IntelligenceMetricTile(
                  label: localeText(
                    context,
                    en: 'Biggest recurring cost',
                    da: 'Stoerste tilbagevendende udgift',
                    de: 'Groesste wiederkehrende Ausgabe',
                    es: 'Mayor coste recurrente',
                  ),
                  value: largestPayment == null
                      ? localeText(
                          context,
                          en: 'No major cost detected yet',
                          da: 'Endnu ingen stor udgift registreret',
                          de: 'Noch kein grosser Kostenpunkt erkannt',
                          es: 'Aun no se detecta un coste importante',
                        )
                      : '${largestPayment.name} - ${formatCurrency(monthlyEquivalent(largestPayment), currency)}/month',
                  accent: BizootColors.orange,
                ),
                _IntelligenceMetricTile(
                  label: localeText(
                    context,
                    en: 'Highest category concentration',
                    da: 'Hoeste kategorikoncentration',
                    de: 'Hoechste Kategoriekonzentration',
                    es: 'Mayor concentracion por categoria',
                  ),
                  value: topCategory == null
                      ? localeText(
                          context,
                          en: 'No category concentration yet',
                          da: 'Endnu ingen tydelig kategorikoncentration',
                          de: 'Noch keine klare Kategoriekonzentration',
                          es: 'Aun no hay concentracion clara por categoria',
                        )
                      : '${topCategory.label} - ${formatCurrency(topCategory.monthlySpend, currency)}',
                  accent: BizootColors.secondary,
                ),
              ];

              if (wide) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: tiles[0]),
                        const SizedBox(width: 12),
                        Expanded(child: tiles[1]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    tiles[2],
                  ],
                );
              }

              return Column(
                children: [
                  tiles[0],
                  const SizedBox(height: 12),
                  tiles[1],
                  const SizedBox(height: 12),
                  tiles[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptimizationSignalsCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _OptimizationSignalsCard({
    required this.snapshot,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final clusters = snapshot.paymentClusters.take(2).toList(growable: false);
    final duplicates = snapshot.duplicateGroups.take(2).toList(growable: false);
    final dormant = snapshot.dormantSubscriptions
        .take(2)
        .toList(growable: false);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Optimization opportunities',
              da: 'Optimeringsmuligheder',
              de: 'Optimierungschancen',
              es: 'Oportunidades de optimizacion',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'Deeper signals around overlap, dormancy, and concentrated payment windows.',
              da: 'DybdegÃƒÂ¥ende signaler om overlap, inaktivitet og koncentrerede betalingsvinduer.',
              de: 'Tiefere Signale zu Ueberschneidungen, Inaktivitaet und konzentrierten Zahlungsfenstern.',
              es: 'Senales mas profundas sobre solapamientos, inactividad y ventanas de pago concentradas.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (duplicates.isNotEmpty)
            ...duplicates.map(
              (group) => _SignalInfoTile(
                title: localeText(
                  context,
                  en: 'Duplicate category overlap',
                  da: 'Overlap i samme kategori',
                  de: 'Ueberschneidung in derselben Kategorie',
                  es: 'Solapamiento en la misma categoria',
                ),
                value: formatCurrency(group.yearlyImpact, currency),
                body: localeText(
                  context,
                  en: '${group.payments.length} ${group.label.toLowerCase()} items are active at the same time.',
                  da: '${group.payments.length} ${group.label.toLowerCase()} poster er aktive samtidig.',
                  de: '${group.payments.length} ${group.label.toLowerCase()}-Eintr\u00e4ge sind gleichzeitig aktiv.',
                  es: '${group.payments.length} elementos de ${group.label.toLowerCase()} est\u00e1n activos al mismo tiempo.',
                ),
                accent: BizootColors.orange,
              ),
            ),
          if (dormant.isNotEmpty)
            ...dormant.map(
              (item) => _SignalInfoTile(
                title: localeText(
                  context,
                  en: 'Dormant subscription',
                  da: 'Inaktivt abonnement',
                  de: 'Inaktives Abo',
                  es: 'Suscripcion inactiva',
                ),
                value: formatCurrency(item.yearlyCost, currency),
                body: localeText(
                  context,
                  en: '${item.payment.name} looks inactive for roughly ${item.dormantDays} days.',
                  da: '${item.payment.name} ser inaktiv ud i cirka ${item.dormantDays} dage.',
                  de: '${item.payment.name} wirkt seit ungef\u00e4hr ${item.dormantDays} Tagen inaktiv.',
                  es: '${item.payment.name} parece inactiva desde hace aproximadamente ${item.dormantDays} d\u00edas.',
                ),
                accent: BizootColors.success,
              ),
            ),
          if (clusters.isNotEmpty)
            ...clusters.map(
              (cluster) => _SignalInfoTile(
                title: localeText(
                  context,
                  en: 'Payment cluster',
                  da: 'Betalingsklynge',
                  de: 'Zahlungscluster',
                  es: 'Grupo de pagos',
                ),
                value: formatCurrency(cluster.totalAmount, currency),
                body: localeText(
                  context,
                  en: '${cluster.paymentCount} items stack around ${cluster.label}.',
                  da: '${cluster.paymentCount} poster ligger samlet omkring ${cluster.label}.',
                  de: '${cluster.paymentCount} Eintr\u00e4ge ballen sich um ${cluster.label}.',
                  es: '${cluster.paymentCount} elementos se acumulan alrededor de ${cluster.label}.',
                ),
                accent: BizootColors.primary,
              ),
            ),
          if (duplicates.isEmpty && dormant.isEmpty && clusters.isEmpty)
            Text(
              localeText(
                context,
                en: 'No strong optimization signals yet. As more recurring history builds up, Bizoot will surface deeper patterns here.',
                da: 'Endnu ingen stÃƒÂ¦rke optimeringssignaler. Naar der opbygges mere historik, viser Bizoot dybere moenstre her.',
                de: 'Noch keine starken Optimierungssignale. Mit mehr Verlauf zeigt Bizoot hier tiefere Muster.',
                es: 'Aun no hay senales fuertes de optimizacion. A medida que crezca el historial, Bizoot mostrara patrones mas profundos aqui.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightsFeedCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;

  const _InsightsFeedCard({required this.snapshot, required this.currency});

  @override
  Widget build(BuildContext context) {
    final items = snapshot.insights.take(4).toList(growable: false);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Insights in reports',
              da: 'Indsigter i rapporter',
              de: 'Insights in Berichten',
              es: 'Insights en informes',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            localeText(
              context,
              en: 'Richer context around burden, duplication, biggest costs, and savings opportunities.',
              da: 'Rigere kontekst om belastning, overlap, stoerste omkostninger og sparemuligheder.',
              de: 'Tieferer Kontext zu Belastung, Ueberschneidungen, groessten Kosten und Sparchancen.',
              es: 'Contexto mas rico sobre carga, duplicacion, mayores costes y oportunidades de ahorro.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              localeText(
                context,
                en: 'No extra report insights yet.',
                da: 'Endnu ingen ekstra rapportindsigter.',
                de: 'Noch keine zusaetzlichen Report-Insights.',
                es: 'Aun no hay insights extra en informes.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.metricLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: _insightColor(item.severity),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportHighlightsCard extends StatelessWidget {
  final FinancialIntelligenceSnapshot snapshot;
  final String currency;
  final double monthlyIncome;

  const _ReportHighlightsCard({
    required this.snapshot,
    required this.currency,
    required this.monthlyIncome,
  });

  String _recurringBurdenLabel(BuildContext context) {
    final burden = snapshot.recurringBurdenPercentage;
    if (monthlyIncome <= 0) {
      return localeText(
        context,
        en: 'Income not set',
        da: 'Indkomst ikke angivet',
        de: 'Einkommen nicht gesetzt',
        es: 'Ingresos no configurados',
      );
    }
    if (burden <= 100) {
      return '${burden.toStringAsFixed(1)}%';
    }
    final overage = burden - 100;
    return localeText(
      context,
      en: '${burden.toStringAsFixed(1)}% of income (${overage.toStringAsFixed(1)}% above income)',
      da: '${burden.toStringAsFixed(1)}% af indkomsten (${overage.toStringAsFixed(1)}% over indkomsten)',
      de: '${burden.toStringAsFixed(1)}% des Einkommens (${overage.toStringAsFixed(1)}% ueber dem Einkommen)',
      es: '${burden.toStringAsFixed(1)}% de los ingresos (${overage.toStringAsFixed(1)}% por encima de los ingresos)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Financial highlights',
              da: 'Finansielle hojdepunkter',
              de: 'Finanzielle Highlights',
              es: 'Aspectos financieros destacados',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _ReportLine(
            title: localeText(
              context,
              en: 'Monthly recurring spend',
              da: 'Maanedligt tilbagevendende forbrug',
              de: 'Monatliche wiederkehrende Ausgaben',
              es: 'Gasto recurrente mensual',
            ),
            value: formatCurrency(snapshot.monthlyRecurringSpend, currency),
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Yearly projection',
              da: 'Aarlig prognose',
              de: 'Jaehrliche Projektion',
              es: 'Proyeccion anual',
            ),
            value: formatCurrency(snapshot.yearlyRecurringProjection, currency),
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Safe to spend',
              da: 'Sikkert at bruge',
              de: 'Sicher verfuegbar',
              es: 'Seguro para gastar',
            ),
            value: formatCurrency(snapshot.safeToSpend, currency),
          ),
          _ReportLine(
            title: localeText(
              context,
              en: 'Recurring burden',
              da: 'Tilbagevendende belastning',
              de: 'Wiederkehrende Belastung',
              es: 'Carga recurrente',
            ),
            value: _recurringBurdenLabel(context),
          ),
        ],
      ),
    );
  }
}

class _IntelligenceMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _IntelligenceMetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BizootColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalInfoTile extends StatelessWidget {
  final String title;
  final String value;
  final String body;
  final Color accent;

  const _SignalInfoTile({
    required this.title,
    required this.value,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  final String title;
  final String value;

  const _ReportLine({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

Color _categoryColor(String id) {
  switch (id) {
    case 'rent':
      return const Color(0xFF8B5CF6);
    case 'utilities':
      return const Color(0xFF22D3EE);
    case 'insurance':
      return const Color(0xFF3B82F6);
    case 'internet':
      return const Color(0xFF38BDF8);
    case 'phone':
      return const Color(0xFFFACC15);
    case 'gym':
      return const Color(0xFF22C55E);
    case 'subscription':
    case 'streaming':
      return const Color(0xFFEC4899);
    default:
      return BizootColors.primary;
  }
}

Color _insightColor(InsightSeverity severity) {
  switch (severity) {
    case InsightSeverity.high:
      return BizootColors.danger;
    case InsightSeverity.medium:
      return BizootColors.orange;
    case InsightSeverity.low:
      return BizootColors.success;
  }
}

Color _smartInsightColor(SmartInsightSeverity severity) {
  switch (severity) {
    case SmartInsightSeverity.urgent:
      return BizootColors.danger;
    case SmartInsightSeverity.warning:
      return BizootColors.orange;
    case SmartInsightSeverity.savings:
      return BizootColors.success;
    case SmartInsightSeverity.info:
      return BizootColors.primary;
  }
}
