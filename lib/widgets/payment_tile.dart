import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../services/brand_icon_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'animated_pressable.dart';
import 'brand_icon.dart';

class PaymentTile extends StatelessWidget {
  final RecurringPayment payment;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;

  const PaymentTile({
    super.key,
    required this.payment,
    this.onTap,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = BrandIconService.instance.canonicalDisplayName(
      payment.name,
      serviceId: payment.iconKey,
      iconKey: payment.iconKey,
    );
    final metaStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary);
    final dueState = _DueState.fromDate(context, payment.nextDueDate);

    return AnimatedPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BrandIcon(
              serviceId: payment.iconKey,
              serviceName: payment.name,
              category: _localizedCategoryLabel(context, payment.category),
              iconKey: payment.iconKey,
              size: 54,
            ),
            const SizedBox(width: BizootSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: BizootSpacing.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaPill(
                        label: _localizedCategoryLabel(
                          context,
                          payment.category,
                        ),
                      ),
                      _MetaPill(
                        label: _localizedFrequencyLabel(
                          context,
                          payment.frequency,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BizootSpacing.sm),
                  Text(
                    dueState.label,
                    style: metaStyle?.copyWith(
                      color: dueState.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(formatShortDate(payment.nextDueDate), style: metaStyle),
                  if (payment.isTrial && payment.trialEndDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        localeText(
                          context,
                          en: 'Trial ends ${formatShortDate(payment.trialEndDate!)}',
                          da: 'Proeveperiode slutter ${formatShortDate(payment.trialEndDate!)}',
                          de: 'Testphase endet ${formatShortDate(payment.trialEndDate!)}',
                          es: 'La prueba termina ${formatShortDate(payment.trialEndDate!)}',
                        ),
                        style: metaStyle?.copyWith(color: BizootColors.orange),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: BizootSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onMarkPaid != null &&
                    payment.isActive &&
                    !payment.isCancelled) ...[
                  _QuickPaidButton(onTap: onMarkPaid!),
                  const SizedBox(height: 8),
                ],
                Text(
                  formatCurrency(payment.amount, payment.currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: BizootSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: BizootColors.textMuted.withValues(alpha: 0.9),
                ),
              ],
            ),
          ],
        ),
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
          border: Border.all(
            color: BizootColors.success.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 12,
              color: BizootColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              localeText(
                context,
                en: 'Mark as paid',
                da: 'Marker som betalt',
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
      return localeText(
        context,
        en: 'Subscription',
        da: 'Abo',
        de: 'Abo',
        es: 'Suscripcion',
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
        es: 'Telefono',
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
        da: 'Laan',
        de: 'Kredit',
        es: 'Prestamo',
      );
    case PaymentCategory.membership:
      return localeText(
        context,
        en: 'Membership',
        da: 'Medlemskab',
        de: 'Mitgliedschaft',
        es: 'Membresia',
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

String _localizedFrequencyLabel(
  BuildContext context,
  PaymentFrequency frequency,
) {
  switch (frequency) {
    case PaymentFrequency.weekly:
      return localeText(
        context,
        en: 'Weekly',
        da: 'Ugentlig',
        de: 'Woechentlich',
        es: 'Semanal',
      );
    case PaymentFrequency.monthly:
      return localeText(
        context,
        en: 'Monthly',
        da: 'Maanedlig',
        de: 'Monatlich',
        es: 'Mensual',
      );
    case PaymentFrequency.quarterly:
      return localeText(
        context,
        en: 'Quarterly',
        da: 'Kvartalsvis',
        de: 'Vierteljaehrlich',
        es: 'Trimestral',
      );
    case PaymentFrequency.yearly:
      return localeText(
        context,
        en: 'Yearly',
        da: 'Aarlig',
        de: 'Jaehrlich',
        es: 'Anual',
      );
  }
}

class _DueState {
  final String label;
  final Color color;

  const _DueState({required this.label, required this.color});

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
        es: 'Proximo pago',
      ),
      color: BizootColors.success,
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: BizootColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
