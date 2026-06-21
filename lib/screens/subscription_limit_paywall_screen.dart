import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import 'paywall_screen.dart';

class SubscriptionLimitPaywallScreen extends StatelessWidget {
  final int activeCount;
  final int limit;
  final bool trialActive;
  final int trialDaysRemaining;
  final VoidCallback? onMaybeLater;

  const SubscriptionLimitPaywallScreen({
    super.key,
    required this.activeCount,
    required this.limit,
    required this.trialActive,
    required this.trialDaysRemaining,
    this.onMaybeLater,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: localeText(
        context,
        en: 'Upgrade to continue',
        da: 'Opgrader for at fortsætte',
        de: 'Upgrade zum Fortfahren',
        es: 'Actualiza para continuar',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trialActive
                      ? localeText(
                          context,
                          en: "You've reached your $limit active-item trial limit.",
                          da: 'Du har nået din prøvegrænse på $limit abonnementer.',
                          de: 'Du hast dein Testlimit von $limit Abonnements erreicht.',
                          es: 'Has alcanzado tu límite de prueba de $limit suscripciones.',
                        )
                      : localeText(
                          context,
                          en: "You've reached your free limit of $limit subscriptions.",
                          da: 'Du har nået din gratis grænse på $limit abonnementer.',
                          de: 'Du hast dein kostenloses Limit von $limit Abonnements erreicht.',
                          es: 'Has alcanzado tu límite gratuito de $limit suscripciones.',
                        ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                Text(
                  trialActive
                      ? localeText(
                          context,
                          en: 'You are currently trying Bizoot Premium. Upgrade to track unlimited recurring items and keep your full premium experience after the trial ends.',
                          da: 'Du prøver lige nu Bizoot Premium. Opgrader for at spore ubegrænsede abonnementer og beholde hele premium-oplevelsen efter prøveperioden.',
                          de: 'Du testest derzeit Bizoot Premium. Mit einem Upgrade kannst du unbegrenzt Abos verfolgen und das volle Premium-Erlebnis nach der Testphase behalten.',
                          es: 'Ahora mismo estás probando Bizoot Premium. Actualiza para seguir suscripciones ilimitadas y mantener toda la experiencia premium después de la prueba.',
                        )
                      : localeText(
                          context,
                          en: 'Upgrade to keep smart insights, advanced analytics, advanced reminders, cancellation intelligence, and unlimited tracking.',
                          da: 'Opgrader for at beholde smart indsigt, avanceret analyse, avancerede påmindelser, opsigelsesintelligens og ubegrænset sporing.',
                          de: 'Upgrade, um Smart Insights, erweiterte Analysen, erweiterte Erinnerungen, Kündigungsintelligenz und unbegrenztes Tracking zu behalten.',
                          es: 'Actualiza para mantener smart insights, análisis avanzados, recordatorios avanzados, inteligencia de cancelación y seguimiento ilimitado.',
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: BizootColors.border.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localeText(
                          context,
                          en: '$activeCount / $limit active items used',
                          da: '$activeCount / $limit abonnementer brugt',
                          de: '$activeCount / $limit Abos genutzt',
                          es: '$activeCount / $limit suscripciones usadas',
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trialActive
                            ? localeText(
                                context,
                                en: 'Trial: $trialDaysRemaining day${trialDaysRemaining == 1 ? '' : 's'} left • $limit active-item trial limit',
                                da: 'Prøveperiode: $trialDaysRemaining dag${trialDaysRemaining == 1 ? '' : 'e'} tilbage • grænse på $limit abonnementer',
                                de: 'Testphase: noch $trialDaysRemaining Tag${trialDaysRemaining == 1 ? '' : 'e'} • Limit von $limit Abos',
                                es: 'Prueba: quedan $trialDaysRemaining día${trialDaysRemaining == 1 ? '' : 's'} • límite de $limit suscripciones',
                              )
                            : localeText(
                                context,
                                en: 'Your data stays safe. Upgrade anytime to continue adding more subscriptions.',
                                da: 'Dine data forbliver sikre. Opgrader når som helst for at tilføje flere abonnementer.',
                                de: 'Deine Daten bleiben sicher. Upgrade jederzeit, um weitere Abos hinzuzufügen.',
                                es: 'Tus datos siguen seguros. Actualiza cuando quieras para seguir añadiendo suscripciones.',
                              ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BizootSpacing.lg),
                AppButton(
                  label: localeText(
                    context,
                    en: 'Upgrade to Premium',
                    da: 'Opgrader til Premium',
                    de: 'Auf Premium upgraden',
                    es: 'Actualizar a Premium',
                  ),
                  icon: Icons.workspace_premium_outlined,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
                const SizedBox(height: BizootSpacing.sm),
                AppButton(
                  label: localeText(
                    context,
                    en: 'Maybe later',
                    da: 'Måske senere',
                    de: 'Vielleicht später',
                    es: 'Quizá más tarde',
                  ),
                  icon: Icons.arrow_back_rounded,
                  secondary: true,
                  onPressed:
                      onMaybeLater ?? () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
