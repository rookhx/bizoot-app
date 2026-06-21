import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../l10n/locale_text.dart';
import '../utils/app_feedback.dart';
import '../widgets/app_button.dart';
import '../widgets/legal_screen_shell.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri, String fallbackMessage) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      showErrorSnackBar(context, fallbackMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'Contact Support',
        da: 'Kontakt support',
        de: 'Support kontaktieren',
        es: 'Contactar soporte',
      ),
      subtitle: localeText(
        context,
        en: 'Reach Bizoot support for bugs, billing questions, or launch feedback.',
        da: 'Kontakt Bizoot-support om fejl, spørgsmål om betaling eller produktfeedback.',
        de: 'Wende dich an den Bizoot-Support bei Fehlern, Abrechnungsfragen oder Produktfeedback.',
        es: 'Contacta con el soporte de Bizoot para errores, dudas de facturación o comentarios del producto.',
      ),
      icon: Icons.support_agent_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Support email',
            da: 'Supportmail',
            de: 'Support-E-Mail',
            es: 'Correo de soporte',
          ),
          body: localeText(
            context,
            en: 'For launch support, account help, or privacy questions, contact Bizoot at ${AppConfig.supportEmail}.',
            da: 'Ved spørgsmål om lancering, konto eller privatliv kan du kontakte Bizoot på ${AppConfig.supportEmail}.',
            de: 'Bei Fragen zu Start, Konto oder Datenschutz erreichst du Bizoot unter ${AppConfig.supportEmail}.',
            es: 'Para ayuda con el lanzamiento, la cuenta o la privacidad, contacta con Bizoot en ${AppConfig.supportEmail}.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Get help fast',
            da: 'Få hurtig hjælp',
            de: 'Schnell Hilfe bekommen',
            es: 'Obtén ayuda rápido',
          ),
          body: localeText(
            context,
            en: 'Use the actions below to report an issue or share product feedback with the Bizoot team.',
            da: 'Brug handlingerne nedenfor til at rapportere et problem eller dele feedback med Bizoot-teamet.',
            de: 'Nutze die folgenden Aktionen, um ein Problem zu melden oder Feedback mit dem Bizoot-Team zu teilen.',
            es: 'Usa las acciones de abajo para informar un problema o compartir comentarios con el equipo de Bizoot.',
          ),
          footer: [
            AppButton(
              label: localeText(
                context,
                en: 'Report an issue',
                da: 'Rapportér et problem',
                de: 'Problem melden',
                es: 'Reportar un problema',
              ),
              icon: Icons.bug_report_outlined,
              onPressed: () => _open(
                context,
                Uri(
                  scheme: 'mailto',
                  path: AppConfig.supportEmail,
                  query: 'subject=Bizoot issue report',
                ),
                localeText(
                  context,
                  en: 'We could not open your email app right now.',
                  da: 'Vi kunne ikke åbne din mailapp lige nu.',
                  de: 'Deine E-Mail-App konnte gerade nicht geöffnet werden.',
                  es: 'No pudimos abrir tu aplicación de correo en este momento.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: localeText(
                context,
                en: 'Send feedback',
                da: 'Send feedback',
                de: 'Feedback senden',
                es: 'Enviar comentarios',
              ),
              icon: Icons.rate_review_outlined,
              secondary: true,
              onPressed: () => _open(
                context,
                Uri(
                  scheme: 'mailto',
                  path: AppConfig.supportEmail,
                  query: 'subject=Bizoot product feedback',
                ),
                localeText(
                  context,
                  en: 'We could not open your email app right now.',
                  da: 'Vi kunne ikke åbne din mailapp lige nu.',
                  de: 'Deine E-Mail-App konnte gerade nicht geöffnet werden.',
                  es: 'No pudimos abrir tu aplicación de correo en este momento.',
                ),
              ),
            ),
          ],
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Support topics',
            da: 'Supportemner',
            de: 'Hilfethemen',
            es: 'Temas de soporte',
          ),
          body: localeText(
            context,
            en: 'Common help topics include notification setup, cancellation links, subscription limits, sync, and account deletion.',
            da: 'Typiske emner er notifikationsopsætning, opsigelseslinks, abonnementsgrænser, synkronisering og sletning af konto.',
            de: 'Häufige Themen sind Benachrichtigungseinrichtung, Kündigungslinks, Abolimits, Synchronisierung und Kontolöschung.',
            es: 'Los temas de ayuda más comunes incluyen configuración de notificaciones, enlaces de cancelación, límites de suscripción, sincronización y eliminación de cuenta.',
          ),
        ),
      ],
    );
  }
}
