import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bizoot_branding.dart';
import '../widgets/gradient_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/neon_icon_box.dart';

const String kEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const String kPrivacyPolicyUrl = 'https://bizoot.com/privacy-policy/';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Future<void> _openUrl(String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'Could not open the link.',
          da: 'Linket kunne ikke åbnes.',
          de: 'Der Link konnte nicht geöffnet werden.',
          es: 'No se pudo abrir el enlace.',
        ),
      );
    }
  }

  Future<void> _startPremiumCheckout(AppState appState) async {
    final result = await appState.purchasePremium();
    if (!mounted) return;
    if (result.success || result.premiumActive) {
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Premium unlocked successfully.',
          da: 'Premium blev låst op.',
          de: 'Premium wurde erfolgreich freigeschaltet.',
          es: 'Premium se desbloqueó correctamente.',
        ),
      );
      return;
    }
    if (result.message?.isNotEmpty == true) {
      showErrorSnackBar(context, result.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return AppScaffold(
      title: localeText(
        context,
        en: 'Premium',
        da: 'Premium',
        de: 'Premium',
        es: 'Premium',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BizootLogo(height: 34),
                const SizedBox(height: BizootSpacing.md),
                Text(
                  'BIZOOT PREMIUM',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BizootSpacing.sm),
                GradientText(
                  localeText(
                    context,
                    en: 'Stop wasting money on forgotten subscriptions.',
                    da: 'Stop med at spilde penge på glemte abonnementer.',
                    de: 'Verschwende kein Geld mehr für vergessene Abonnements.',
                    es: 'Deja de perder dinero en suscripciones olvidadas.',
                  ),
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: BizootSpacing.sm),
                Text(
                  appState.isTrialActive
                      ? localeText(
                          context,
                          en: 'You are currently experiencing Bizoot Premium during your 7-day trial. Upgrade to keep premium intelligence and unlock unlimited recurring-item tracking.',
                          da: 'Du oplever lige nu Bizoot Premium i din 7-dages prøveperiode. Opgrader for at beholde premium-indsigt og låse op for ubegrænset sporing.',
                          de: 'Du nutzt Bizoot Premium derzeit während deiner 7-Tage-Testphase. Upgrade, um Premium-Intelligenz zu behalten und unbegrenztes Tracking freizuschalten.',
                          es: 'Ahora mismo estás disfrutando de Bizoot Premium durante tu prueba de 7 días. Actualiza para mantener la inteligencia premium y desbloquear seguimiento ilimitado.',
                        )
                      : localeText(
                          context,
                          en: 'Upgrade to unlock smart insights, advanced analytics, AI-style recommendations, and unlimited recurring-item tracking.',
                          da: 'Opgrader for at låse op for smart indsigt, avancerede analyser, AI-lignende anbefalinger og ubegrænset abonnementssporing.',
                          de: 'Upgrade, um Smart Insights, erweiterte Analysen, KI-ähnliche Empfehlungen und unbegrenztes Abo-Tracking freizuschalten.',
                          es: 'Actualiza para desbloquear smart insights, analítica avanzada, recomendaciones tipo IA y seguimiento ilimitado de suscripciones.',
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (appState.isTrialActive) ...[
                  Text(
                    localeText(
                      context,
                      en: 'Trial users get full premium features, with a 5 active-item limit.',
                      da: 'Prøvebrugere får alle premium-funktioner med en grænse på 5 aktive abonnementer.',
                      de: 'Testnutzer erhalten alle Premium-Funktionen mit einem Limit von 5 aktiven Abonnements.',
                      es: 'Los usuarios en prueba obtienen todas las funciones premium con un límite de 5 suscripciones activas.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: BizootSpacing.lg),
                ] else
                  const SizedBox(height: BizootSpacing.lg),
                AppButton(
                  label: appState.isPurchaseInProgress
                      ? localeText(
                          context,
                          en: 'Opening...',
                          da: 'Åbner...',
                          de: 'Wird geöffnet...',
                          es: 'Abriendo...',
                        )
                      : localeText(
                          context,
                          en: 'Get Premium',
                          da: 'Få Premium',
                          de: 'Premium holen',
                          es: 'Obtener Premium',
                        ),
                  icon: Icons.bolt_outlined,
                  onPressed: appState.isPurchaseInProgress
                      ? null
                      : () => _startPremiumCheckout(appState),
                ),
                const SizedBox(height: BizootSpacing.md),
                Text(
                  localeText(
                    context,
                    en: 'Premium subscriptions renew through your device billing provider unless cancelled before the renewal period ends. Billing, receipts, and cancellations are managed by the platform where you subscribe.',
                    da: 'Premium-abonnementer fornyes via din enheds betalingsudbyder, medmindre de opsiges før fornyelsesperioden slutter. Fakturering, kvitteringer og opsigelser håndteres af den platform, hvor du tegner abonnementet.',
                    de: 'Premium-Abonnements verlängern sich über den Zahlungsanbieter deines Geräts, sofern sie nicht vor Ende des Verlängerungszeitraums gekündigt werden. Abrechnung, Belege und Kündigungen werden von der Plattform verwaltet, auf der du abonnierst.',
                    es: 'Las suscripciones Premium se renuevan a través del proveedor de pagos de tu dispositivo, salvo que las canceles antes de que termine el período de renovación. La facturación, los recibos y las cancelaciones se gestionan en la plataforma donde te suscribes.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: BizootSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (Platform.isIOS)
                      TextButton(
                        onPressed: () => _openUrl(kEulaUrl),
                        child: Text(
                          localeText(
                            context,
                            en: 'Terms of Use (EULA)',
                            da: 'Brugervilkår (EULA)',
                            de: 'Nutzungsbedingungen (EULA)',
                            es: 'Términos de uso (EULA)',
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () => _openUrl(kPrivacyPolicyUrl),
                      child: Text(
                        localeText(
                          context,
                          en: 'Privacy Policy',
                          da: 'Privatlivspolitik',
                          de: 'Datenschutzrichtlinie',
                          es: 'Política de privacidad',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          ...[
            (
              localeText(
                context,
                en: 'Avoid surprise charges',
                da: 'Undgå overraskende gebyrer',
                de: 'Überraschende Gebühren vermeiden',
                es: 'Evita cargos sorpresa',
              ),
              Icons.notifications_active_outlined,
            ),
            (
              localeText(
                context,
                en: 'Never miss trial endings',
                da: 'Gå aldrig glip af prøveperioders slutdato',
                de: 'Verpasse nie das Ende einer Testphase',
                es: 'No vuelvas a perder el final de una prueba',
              ),
              Icons.timer_outlined,
            ),
            (
              localeText(
                context,
                en: 'See your safe-to-spend amount',
                da: 'Se dit sikre forbrugsbeløb',
                de: 'Sieh deinen sicheren Ausgabebetrag',
                es: 'Consulta tu importe seguro para gastar',
              ),
              Icons.account_balance_wallet_outlined,
            ),
            (
              localeText(
                context,
                en: 'Get premium intelligence insights',
                da: 'Få premium-indsigt',
                de: 'Erhalte Premium-Insights',
                es: 'Obtén inteligencia premium',
              ),
              Icons.psychology_alt_outlined,
            ),
            (
              localeText(
                context,
                en: 'See yearly projections and trend analysis',
                da: 'Se årlige projektioner og trendanalyse',
                de: 'Sieh Jahresprognosen und Trendanalysen',
                es: 'Consulta proyecciones anuales y análisis de tendencias',
              ),
              Icons.stacked_line_chart_outlined,
            ),
            (
              localeText(
                context,
                en: 'Find subscriptions you should cancel',
                da: 'Find abonnementer du bør opsige',
                de: 'Finde Abonnements, die du kündigen solltest',
                es: 'Encuentra suscripciones que deberías cancelar',
              ),
              Icons.content_cut_outlined,
            ),
            (
              localeText(
                context,
                en: 'Unlock risk scoring and optimization reports',
                da: 'Lås op for risikovurdering og optimeringsrapporter',
                de: 'Schalte Risikobewertung und Optimierungsberichte frei',
                es: 'Desbloquea puntuación de riesgo e informes de optimización',
              ),
              Icons.shield_outlined,
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeonIconBox(icon: item.$2, size: 42),
                    const SizedBox(width: BizootSpacing.sm),
                    Expanded(
                      child: Text(
                        item.$1,
                        style: const TextStyle(
                          color: BizootColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
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
