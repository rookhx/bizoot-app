import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../services/brand_icon_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'animated_pressable.dart';
import 'app_card.dart';
import 'brand_icon.dart';

class UpcomingPaymentsCard extends StatelessWidget {
  final List<RecurringPayment> payments;
  final VoidCallback onViewAllPressed;
  final ValueChanged<RecurringPayment> onPaymentTap;
  final ValueChanged<RecurringPayment>? onMarkPaid;

  const UpcomingPaymentsCard({
    super.key,
    required this.payments,
    required this.onViewAllPressed,
    required this.onPaymentTap,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
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
                        en: 'Upcoming payments',
                        da: 'Kommende betalinger',
                        de: 'Bevorstehende Zahlungen',
                        es: 'Próximos pagos',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localeText(
                        context,
                        en: 'What is due next across your subscriptions and bills.',
                        da: 'Det næste, der forfalder på tværs af dine abonnementer og regninger.',
                        de: 'Was als Nächstes bei deinen Abos und Rechnungen fällig wird.',
                        es: 'Lo próximo que vence entre tus suscripciones y facturas.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
                    ),
                  ],
                ),
              ),
              AnimatedPressable(
                onTap: onViewAllPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BizootColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    localeText(
                      context,
                      en: 'View all',
                      da: 'Se alle',
                      de: 'Alle anzeigen',
                      es: 'Ver todo',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BizootColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (payments.isEmpty)
            Text(
              localeText(
                context,
                en: 'No upcoming payments yet.',
                da: 'Ingen kommende betalinger endnu.',
                de: 'Noch keine bevorstehenden Zahlungen.',
                es: 'Todavía no hay próximos pagos.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
            )
          else
            ...payments.map((payment) {
              final dueState = _DueState.fromDate(context, payment.nextDueDate);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedPressable(
                  onTap: () => onPaymentTap(payment),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: BizootColors.border.withValues(alpha: 0.42)),
                    ),
                    child: Row(
                      children: [
                        BrandIcon(
                          serviceId: payment.iconKey,
                          serviceName: payment.name,
                          category: _localizedCategoryLabel(context, payment.category),
                          iconKey: payment.iconKey,
                          size: 44,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                BrandIconService.instance.canonicalDisplayName(
                                  payment.name,
                                  serviceId: payment.iconKey,
                                  iconKey: payment.iconKey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dueState.label,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: dueState.color,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatShortDate(payment.nextDueDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: BizootColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (onMarkPaid != null && payment.isActive && !payment.isCancelled) ...[
                              _QuickPaidButton(onTap: () => onMarkPaid!(payment)),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              formatCurrency(payment.amount, payment.currency),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _localizedCategoryLabel(context, payment.category),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
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
}

class _QuickPaidButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickPaidButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: BizootColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BizootColors.success.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 12, color: BizootColors.success),
            const SizedBox(width: 4),
            Text(
              localeText(
                context,
                en: 'Mark as paid',
                da: 'Markér som betalt',
                de: 'Als bezahlt markieren',
                es: 'Marcar como pagado',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedCategoryLabel(BuildContext context, PaymentCategory category) {
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

class _DueState {
  final String label;
  final Color color;

  const _DueState({
    required this.label,
    required this.color,
  });

  factory _DueState.fromDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (!normalizedDate.isAfter(today)) {
      return _DueState(
        label: localeText(
          context,
          en: 'Balance Due',
          da: 'Forfalden betaling',
          de: 'Offener Betrag',
          es: 'Pago pendiente',
        ),
        color: BizootColors.danger,
      );
    }

    return _DueState(
      label: localeText(
        context,
        en: 'Upcoming Payment',
        da: 'Kommende betaling',
        de: 'Bevorstehende Zahlung',
        es: 'Próximo pago',
      ),
      color: BizootColors.success,
    );
  }
}
