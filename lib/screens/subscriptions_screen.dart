import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../utils/formatters.dart';
import '../utils/payment_math.dart';
import '../widgets/app_card.dart';
import '../widgets/document_vault_panel.dart';
import '../widgets/empty_state.dart';
import '../widgets/payment_tile.dart';
import 'add_payment_screen.dart';
import 'payment_detail_screen.dart';
import 'subscription_limit_paywall_screen.dart';

enum _SubscriptionSortOption { dueSoonest, highestAmount, alphabetical }

enum _ManagementMode { subscriptions, essentials }

enum _EssentialsSection { overview, renewals, documents }

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  String _searchQuery = '';
  _ManagementMode _mode = _ManagementMode.subscriptions;
  _EssentialsSection _essentialsSection = _EssentialsSection.overview;
  PaymentCategory? _selectedCategory;
  _SubscriptionSortOption _sortOption = _SubscriptionSortOption.dueSoonest;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openAddPayment(BuildContext context, AppState appState) {
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

  List<RecurringPayment> _filterAndSortPayments(
    List<RecurringPayment> payments,
  ) {
    final filtered = payments
        .where((payment) {
          final inSearch =
              _searchQuery.isEmpty ||
              payment.name.toLowerCase().contains(_searchQuery) ||
              payment.category.displayLabel.toLowerCase().contains(
                _searchQuery,
              );
          final inCategory =
              _selectedCategory == null ||
              payment.category == _selectedCategory;
          return inSearch && inCategory;
        })
        .toList(growable: false);

    final sorted = [...filtered];
    switch (_sortOption) {
      case _SubscriptionSortOption.dueSoonest:
        sorted.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        break;
      case _SubscriptionSortOption.highestAmount:
        sorted.sort(
          (a, b) => monthlyEquivalent(b).compareTo(monthlyEquivalent(a)),
        );
        break;
      case _SubscriptionSortOption.alphabetical:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sourcePayments = _mode == _ManagementMode.subscriptions
        ? appState.payments
              .where((item) => item.category == PaymentCategory.subscription)
              .toList(growable: false)
        : appState.payments
              .where((item) => item.category != PaymentCategory.subscription)
              .toList(growable: false);
    final activePayments = sourcePayments
        .where((item) => item.isActive)
        .toList(growable: false);
    final cancelledPayments = sourcePayments
        .where((item) => !item.isActive || item.isCancelled)
        .toList(growable: false);
    final visibleActive = _filterAndSortPayments(activePayments);
    final visibleCancelled = _filterAndSortPayments(cancelledPayments);
    final activeMonthlyTotal = activePayments.fold<double>(
      0,
      (sum, item) => sum + monthlyEquivalent(item),
    );
    final showManagementList =
        _mode == _ManagementMode.subscriptions ||
        _essentialsSection == _EssentialsSection.overview;
    final categories =
        (_mode == _ManagementMode.subscriptions
                ? const [PaymentCategory.subscription]
                : PaymentCategory.values.where(
                    (item) => item != PaymentCategory.subscription,
                  ))
            .toList(growable: false);

    return Stack(
      children: [
        ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            AppCard(
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
                              _mode == _ManagementMode.subscriptions
                                  ? localeText(
                                      context,
                                      en: 'Subscriptions',
                                      da: 'Abonnementer',
                                      de: 'Abonnements',
                                      es: 'Suscripciones',
                                    )
                                  : localeText(
                                      context,
                                      en: 'Life Essentials',
                                      da: 'Livets faste udgifter',
                                      de: 'Wichtige Lebensausgaben',
                                      es: 'Esenciales de la vida',
                                    ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _mode == _ManagementMode.subscriptions
                                  ? localeText(
                                      context,
                                      en: 'Manage your recurring subscription services in one focused list.',
                                      da: 'Administrér dine tilbagevendende abonnementstjenester i én fokuseret liste.',
                                      de: 'Verwalte deine wiederkehrenden Abonnementdienste in einer fokussierten Liste.',
                                      es: 'Gestiona tus servicios de suscripción recurrentes en una sola lista enfocada.',
                                    )
                                  : localeText(
                                      context,
                                      en: 'Manage rent, utilities, insurance, phone plans, contracts, and other recurring life obligations.',
                                      da: 'Administrér husleje, forsyninger, forsikring, telefonabonnementer, kontrakter og andre tilbagevendende livsomkostninger.',
                                      de: 'Verwalte Miete, Nebenkosten, Versicherungen, Telefontarife, Verträge und andere wiederkehrende Lebensverpflichtungen.',
                                      es: 'Gestiona alquiler, servicios, seguros, planes de teléfono, contratos y otras obligaciones recurrentes de la vida.',
                                    ),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: BizootColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BizootSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeToggleChip(
                          label: localeText(
                            context,
                            en: 'Subscriptions',
                            da: 'Abonnementer',
                            de: 'Abonnements',
                            es: 'Suscripciones',
                          ),
                          selected: _mode == _ManagementMode.subscriptions,
                          onTap: () => setState(() {
                            _mode = _ManagementMode.subscriptions;
                            _selectedCategory = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ModeToggleChip(
                          label: localeText(
                            context,
                            en: 'Life Essentials',
                            da: 'Livets faste udgifter',
                            de: 'Wichtige Lebensausgaben',
                            es: 'Esenciales de la vida',
                          ),
                          selected: _mode == _ManagementMode.essentials,
                          onTap: () => setState(() {
                            _mode = _ManagementMode.essentials;
                            _selectedCategory = null;
                            _essentialsSection = _EssentialsSection.overview;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BizootSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryChip(
                          label: _mode == _ManagementMode.subscriptions
                              ? localeText(
                                  context,
                                  en: 'Active',
                                  da: 'Aktive',
                                  de: 'Aktiv',
                                  es: 'Activas',
                                )
                              : localeText(
                                  context,
                                  en: 'Active essentials',
                                  da: 'Aktive faste udgifter',
                                  de: 'Aktive Essentials',
                                  es: 'Esenciales activos',
                                ),
                          value: '${activePayments.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryChip(
                          label: localeText(
                            context,
                            en: 'Monthly total',
                            da: 'Månedlig total',
                            de: 'Monatliche Summe',
                            es: 'Total mensual',
                          ),
                          value: formatCurrency(
                            activeMonthlyTotal,
                            appState.settings.currency,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_mode == _ManagementMode.essentials) ...[
                    const SizedBox(height: BizootSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryChip(
                            label: localeText(
                              context,
                              en: 'Renewals this month',
                              da: 'Fornyelser denne måned',
                              de: 'Verlängerungen diesen Monat',
                              es: 'Renovaciones este mes',
                            ),
                            value: '${appState.renewalsThisMonth.length}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryChip(
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
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: BizootSpacing.sm),
                  if (!appState.isPremiumUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.045),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: BizootColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_outlined,
                            color: BizootColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appState.isTrialActive
                                  ? '${appState.activeSubscriptionCount} / ${appState.subscriptionLimit} active items used - Trial: ${appState.trialDaysRemaining} days left'
                                  : '${appState.activeSubscriptionCount} / ${appState.subscriptionLimit} active items used - Upgrade for unlimited tracking',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: BizootColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_mode == _ManagementMode.essentials) ...[
              const SizedBox(height: BizootSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ModeToggleChip(
                      label: localeText(
                        context,
                        en: 'Overview',
                        da: 'Overblik',
                        de: 'Überblick',
                        es: 'Resumen',
                      ),
                      selected:
                          _essentialsSection == _EssentialsSection.overview,
                      onTap: () => setState(
                        () => _essentialsSection = _EssentialsSection.overview,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModeToggleChip(
                      label: localeText(
                        context,
                        en: 'Renewals',
                        da: 'Fornyelser',
                        de: 'Verlängerungen',
                        es: 'Renovaciones',
                      ),
                      selected:
                          _essentialsSection == _EssentialsSection.renewals,
                      onTap: () => setState(
                        () => _essentialsSection = _EssentialsSection.renewals,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModeToggleChip(
                      label: localeText(
                        context,
                        en: 'Documents',
                        da: 'Dokumenter',
                        de: 'Dokumente',
                        es: 'Documentos',
                      ),
                      selected:
                          _essentialsSection == _EssentialsSection.documents,
                      onTap: () => setState(
                        () => _essentialsSection = _EssentialsSection.documents,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BizootSpacing.md),
              if (_essentialsSection == _EssentialsSection.overview)
                _LifeEssentialsOverview(
                  appState: appState,
                  onOpenPayment: (payment) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentDetailScreen(payment: payment),
                    ),
                  ),
                )
              else if (_essentialsSection == _EssentialsSection.renewals)
                _RenewalsPanel(appState: appState)
              else
                const DocumentVaultPanel(),
            ],
            if (showManagementList) ...[
              const SizedBox(height: BizootSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: _mode == _ManagementMode.subscriptions
                      ? localeText(
                          context,
                          en: 'Search subscriptions',
                          da: 'Søg abonnementer',
                          de: 'Abos suchen',
                          es: 'Buscar suscripciones',
                        )
                      : localeText(
                          context,
                          en: 'Search life essentials',
                          da: 'Søg basisudgifter',
                          de: 'Essentials suchen',
                          es: 'Buscar esenciales',
                        ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedCategory == null,
                      label: Text(
                        localeText(
                          context,
                          en: 'All',
                          da: 'Alle',
                          de: 'Alle',
                          es: 'Todos',
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategory == category,
                          label: Text(
                            _localizedCategoryLabel(context, category),
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: BizootColors.primary,
                      labelColor: BizootColors.textPrimary,
                      unselectedLabelColor: BizootColors.textSecondary,
                      tabs: [
                        Tab(
                          text: localeText(
                            context,
                            en: 'Active',
                            da: 'Aktive',
                            de: 'Aktiv',
                            es: 'Activos',
                          ),
                        ),
                        Tab(
                          text: localeText(
                            context,
                            en: 'Cancelled',
                            da: 'Opsagt',
                            de: 'Gekündigt',
                            es: 'Cancelados',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<_SubscriptionSortOption>(
                    initialValue: _sortOption,
                    onSelected: (value) => setState(() => _sortOption = value),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _SubscriptionSortOption.dueSoonest,
                        child: Text(
                          localeText(
                            context,
                            en: 'Sort by due date',
                            da: 'Sorter efter forfaldsdato',
                            de: 'Nach Fälligkeitsdatum sortieren',
                            es: 'Ordenar por fecha de vencimiento',
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: _SubscriptionSortOption.highestAmount,
                        child: Text(
                          localeText(
                            context,
                            en: 'Sort by amount',
                            da: 'Sorter efter beløb',
                            de: 'Nach Betrag sortieren',
                            es: 'Ordenar por importe',
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: _SubscriptionSortOption.alphabetical,
                        child: Text(
                          localeText(
                            context,
                            en: 'Sort alphabetically',
                            da: 'Sorter alfabetisk',
                            de: 'Alphabetisch sortieren',
                            es: 'Ordenar alfabéticamente',
                          ),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: BizootColors.surfaceElevated.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: BizootColors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 18),
                          const SizedBox(width: 8),
                          Text(switch (_sortOption) {
                            _SubscriptionSortOption.dueSoonest => localeText(
                              context,
                              en: 'Due date',
                              da: 'Forfaldsdato',
                              de: 'Fälligkeitsdatum',
                              es: 'Fecha de vencimiento',
                            ),
                            _SubscriptionSortOption.highestAmount => localeText(
                              context,
                              en: 'Amount',
                              da: 'Beløb',
                              de: 'Betrag',
                              es: 'Importe',
                            ),
                            _SubscriptionSortOption.alphabetical => 'A-Z',
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BizootSpacing.md),
              IndexedStack(
                index: _tabController.index,
                children: [
                  _SubscriptionList(
                    payments: visibleActive,
                    emptyTitle: localeText(
                      context,
                      en: 'No subscriptions yet.',
                      da: 'Ingen abonnementer endnu.',
                      de: 'Noch keine Abos.',
                      es: 'Aún no hay suscripciones.',
                    ),
                    emptyBody: localeText(
                      context,
                      en: 'Add your first recurring payment.',
                      da: 'Tilføj din første tilbagevendende betaling.',
                      de: 'Füge deine erste wiederkehrende Zahlung hinzu.',
                      es: 'Añade tu primer pago recurrente.',
                    ),
                  ),
                  _SubscriptionList(
                    payments: visibleCancelled,
                    emptyTitle: localeText(
                      context,
                      en: 'No cancelled subscriptions yet.',
                      da: 'Ingen opsagte abonnementer endnu.',
                      de: 'Noch keine gekündigten Abos.',
                      es: 'Aún no hay suscripciones canceladas.',
                    ),
                    emptyBody: localeText(
                      context,
                      en: 'Cancelled or inactive subscriptions will appear here for easy reference.',
                      da: 'Opsagte eller inaktive abonnementer vises her for nemt overblik.',
                      de: 'Gekündigte oder inaktive Abos erscheinen hier zur schnellen Übersicht.',
                      es: 'Las suscripciones canceladas o inactivas aparecerán aquí para una referencia rápida.',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: BizootGradients.main,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: BizootColors.primary.withValues(alpha: 0.26),
                  blurRadius: 26,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () => _openAddPayment(context, appState),
              icon: const Icon(Icons.add),
              label: Text(
                localeText(
                  context,
                  en: 'Add Payment',
                  da: 'Tilføj betaling',
                  de: 'Zahlung hinzufügen',
                  es: 'Agregar pago',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  final List<RecurringPayment> payments;
  final String emptyTitle;
  final String emptyBody;

  const _SubscriptionList({
    required this.payments,
    required this.emptyTitle,
    required this.emptyBody,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return EmptyState(title: emptyTitle, body: emptyBody);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payment = payments[index];
        final appState = context.read<AppState>();
        return AppCard(
          padding: EdgeInsets.zero,
          child: PaymentTile(
            payment: payment,
            onMarkPaid: () async {
              try {
                final nextDueDate = await appState.markPaymentAsPaid(payment);
                if (!context.mounted) return;
                AppHaptics.success();
                showSuccessSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'Next due date moved to ${formatShortDate(nextDueDate)}.',
                    da: 'Næste forfaldsdato flyttet til ${formatShortDate(nextDueDate)}.',
                    de: 'Das nächste Fälligkeitsdatum wurde auf ${formatShortDate(nextDueDate)} verschoben.',
                    es: 'La próxima fecha de vencimiento se movió a ${formatShortDate(nextDueDate)}.',
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                AppHaptics.warning();
                showErrorSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'We could not update the next due date right now.',
                    da: 'Vi kunne ikke opdatere den næste forfaldsdato lige nu.',
                    de: 'Das nächste Fälligkeitsdatum konnte gerade nicht aktualisiert werden.',
                    es: 'No pudimos actualizar la próxima fecha de vencimiento ahora mismo.',
                  ),
                );
              }
            },
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentDetailScreen(payment: payment),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BizootColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? BizootGradients.main : null,
          color: selected
              ? null
              : BizootColors.surfaceElevated.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : BizootColors.border.withValues(alpha: 0.75),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _LifeEssentialsOverview extends StatelessWidget {
  final AppState appState;
  final ValueChanged<RecurringPayment> onOpenPayment;

  const _LifeEssentialsOverview({
    required this.appState,
    required this.onOpenPayment,
  });

  @override
  Widget build(BuildContext context) {
    final renewals = appState.renewalsThisMonth.take(3).toList(growable: false);
    final critical =
        (appState.activeEssentials.toList()
              ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate)))
            .take(3)
            .toList(growable: false);
    final missingLinks = appState.itemsMissingManagementLinks
        .where((item) => item.category != PaymentCategory.subscription)
        .take(3)
        .toList(growable: false);
    final savedCredentials = appState.itemsWithSavedLoginDetails
        .where((item) => item.category != PaymentCategory.subscription)
        .take(3)
        .toList(growable: false);

    return Column(
      children: [
        _EssentialsFocusCard(
          title: localeText(
            context,
            en: 'Essentials overview',
            da: 'Overblik over basisudgifter',
            de: 'Essentials-Überblick',
            es: 'Resumen de esenciales',
          ),
          subtitle: localeText(
            context,
            en: 'Monthly essentials total ${formatCurrency(appState.monthlyEssentialsSpend, appState.settings.currency)} across ${appState.activeEssentials.length} active items.',
            da: 'Samlede basisudgifter pr. måned ${formatCurrency(appState.monthlyEssentialsSpend, appState.settings.currency)} fordelt på ${appState.activeEssentials.length} aktive poster.',
            de: 'Monatliche Grundkosten gesamt ${formatCurrency(appState.monthlyEssentialsSpend, appState.settings.currency)} über ${appState.activeEssentials.length} aktive Einträge.',
            es: 'Total mensual de esenciales ${formatCurrency(appState.monthlyEssentialsSpend, appState.settings.currency)} en ${appState.activeEssentials.length} elementos activos.',
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        _EssentialsActionCard(
          title: localeText(
            context,
            en: 'Upcoming renewals',
            da: 'Kommende fornyelser',
            de: 'Bevorstehende Verlängerungen',
            es: 'Próximas renovaciones',
          ),
          body: renewals.isEmpty
              ? localeText(
                  context,
                  en: 'No renewals this month.',
                  da: 'Ingen fornyelser denne måned.',
                  de: 'Keine Verlängerungen in diesem Monat.',
                  es: 'No hay renovaciones este mes.',
                )
              : renewals.map((item) => item.name).join(' • '),
          actionLabel: renewals.isEmpty
              ? null
              : localeText(
                  context,
                  en: 'Review',
                  da: 'Gennemgå',
                  de: 'Prüfen',
                  es: 'Revisar',
                ),
          onTap: renewals.isEmpty ? null : () => onOpenPayment(renewals.first),
        ),
        const SizedBox(height: BizootSpacing.sm),
        _EssentialsActionCard(
          title: localeText(
            context,
            en: 'Critical bills',
            da: 'Vigtige regninger',
            de: 'Kritische Rechnungen',
            es: 'Facturas críticas',
          ),
          body: critical.isEmpty
              ? localeText(
                  context,
                  en: 'No critical bills yet.',
                  da: 'Ingen vigtige regninger endnu.',
                  de: 'Noch keine kritischen Rechnungen.',
                  es: 'Aún no hay facturas críticas.',
                )
              : critical.map((item) => item.name).join(' • '),
          actionLabel: critical.isEmpty
              ? null
              : localeText(
                  context,
                  en: 'View',
                  da: 'Se',
                  de: 'Ansehen',
                  es: 'Ver',
                ),
          onTap: critical.isEmpty ? null : () => onOpenPayment(critical.first),
        ),
        const SizedBox(height: BizootSpacing.sm),
        _EssentialsActionCard(
          title: localeText(
            context,
            en: 'Services with saved login details',
            da: 'Tjenester med gemte loginoplysninger',
            de: 'Dienste mit gespeicherten Anmeldedaten',
            es: 'Servicios con datos de acceso guardados',
          ),
          body: savedCredentials.isEmpty
              ? localeText(
                  context,
                  en: 'No saved service credentials yet.',
                  da: 'Ingen gemte tjenesteoplysninger endnu.',
                  de: 'Noch keine gespeicherten Zugangsdaten.',
                  es: 'Aún no hay credenciales guardadas.',
                )
              : savedCredentials.map((item) => item.name).join(' • '),
          actionLabel: savedCredentials.isEmpty
              ? null
              : localeText(
                  context,
                  en: 'Open',
                  da: 'Åbn',
                  de: 'Öffnen',
                  es: 'Abrir',
                ),
          onTap: savedCredentials.isEmpty
              ? null
              : () => onOpenPayment(savedCredentials.first),
        ),
        const SizedBox(height: BizootSpacing.sm),
        _EssentialsActionCard(
          title: localeText(
            context,
            en: 'Missing management links',
            da: 'Manglende administrationslinks',
            de: 'Fehlende Verwaltungslinks',
            es: 'Enlaces de gestión faltantes',
          ),
          body: missingLinks.isEmpty
              ? localeText(
                  context,
                  en: 'All visible essentials already have a management path saved.',
                  da: 'Alle synlige basisudgifter har allerede en gemt administrationsvej.',
                  de: 'Alle sichtbaren Essentials haben bereits einen gespeicherten Verwaltungsweg.',
                  es: 'Todos los esenciales visibles ya tienen una ruta de gestión guardada.',
                )
              : missingLinks.map((item) => item.name).join(' • '),
          actionLabel: missingLinks.isEmpty
              ? null
              : localeText(
                  context,
                  en: 'Fix',
                  da: 'Ret',
                  de: 'Beheben',
                  es: 'Corregir',
                ),
          onTap: missingLinks.isEmpty
              ? null
              : () => onOpenPayment(missingLinks.first),
        ),
      ],
    );
  }
}

class _RenewalsPanel extends StatelessWidget {
  final AppState appState;

  const _RenewalsPanel({required this.appState});

  @override
  Widget build(BuildContext context) {
    final renewals = appState.renewalsThisMonth;
    if (renewals.isEmpty) {
      return EmptyState(
        title: localeText(
          context,
          en: 'No renewals yet.',
          da: 'Ingen fornyelser endnu.',
          de: 'Noch keine Verlängerungen.',
          es: 'Aún no hay renovaciones.',
        ),
        body: localeText(
          context,
          en: 'Renewal dates, policy rollovers, and contract end dates will appear here.',
          da: 'Fornyelsesdatoer, policeskift og kontraktudløb vises her.',
          de: 'Verlängerungsdaten, Policenwechsel und Vertragsenden erscheinen hier.',
          es: 'Aquí aparecerán las fechas de renovación, renovaciones de pólizas y vencimientos de contratos.',
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: renewals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payment = renewals[index];
        return AppCard(
          padding: EdgeInsets.zero,
          child: PaymentTile(
            payment: payment,
            onMarkPaid: () async {
              try {
                final nextDueDate = await appState.markPaymentAsPaid(payment);
                if (!context.mounted) return;
                AppHaptics.success();
                showSuccessSnackBar(
                  context,
                  'Next due date moved to ${formatShortDate(nextDueDate)}.',
                );
              } catch (_) {
                if (!context.mounted) return;
                showErrorSnackBar(
                  context,
                  'We could not update the next due date right now.',
                );
              }
            },
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentDetailScreen(payment: payment),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _localizedCategoryLabel(BuildContext context, PaymentCategory category) {
  switch (category) {
    case PaymentCategory.subscription:
      return localeText(
        context,
        en: 'Subscription',
        da: 'Abonnement',
        de: 'Abo',
        es: 'Suscripción',
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
        es: 'Teléfono',
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
        da: 'Lån',
        de: 'Kredit',
        es: 'Préstamo',
      );
    case PaymentCategory.membership:
      return localeText(
        context,
        en: 'Membership',
        da: 'Medlemskab',
        de: 'Mitgliedschaft',
        es: 'Membresía',
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

class _EssentialsFocusCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EssentialsFocusCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EssentialsActionCard extends StatelessWidget {
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _EssentialsActionCard({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onTap, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
