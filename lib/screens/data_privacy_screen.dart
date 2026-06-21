import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/legal_screen_shell.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    return LegalScreenShell(
      title: localeText(
        context,
        en: 'AI & Privacy Settings',
        da: 'AI- og privatlivsindstillinger',
        de: 'KI- und Datenschutzeinstellungen',
        es: 'Ajustes de IA y privacidad',
      ),
      subtitle: localeText(
        context,
        en: 'Control how Bizoot uses local insights to analyze your recurring spending.',
        da: 'Styr, hvordan Bizoot bruger lokale indsigter til at analysere dine tilbagevendende udgifter.',
        de: 'Steuere, wie Bizoot lokale Einblicke nutzt, um deine wiederkehrenden Ausgaben zu analysieren.',
        es: 'Controla cómo Bizoot usa análisis locales para revisar tus gastos recurrentes.',
      ),
      icon: Icons.admin_panel_settings_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'How Bizoot works',
            da: 'Sådan fungerer Bizoot',
            de: 'So funktioniert Bizoot',
            es: 'Cómo funciona Bizoot',
          ),
          body: localeText(
            context,
            en: 'Bizoot uses local insights to help analyze your recurring spending. Sensitive account details are not used for insights.',
            da: 'Bizoot bruger lokale indsigter til at analysere dine tilbagevendende udgifter. Følsomme kontooplysninger bruges ikke til indsigter.',
            de: 'Bizoot nutzt lokale Einblicke, um deine wiederkehrenden Ausgaben zu analysieren. Sensible Kontodaten werden dabei nicht verwendet.',
            es: 'Bizoot usa análisis locales para ayudarte a entender tus gastos recurrentes. Los datos sensibles de la cuenta no se usan para ello.',
          ),
        ),
        _PrivacyToggleCard(
          title: localeText(
            context,
            en: 'Enable AI insights',
            da: 'Aktivér AI-indsigter',
            de: 'KI-Einblicke aktivieren',
            es: 'Activar análisis de IA',
          ),
          subtitle: localeText(
            context,
            en: 'Show AI-style recommendations, forecasts, and health-score explanations in the app.',
            da: 'Vis anbefalinger, prognoser og forklaringer af sundhedsscore i appen.',
            de: 'Zeige Empfehlungen, Prognosen und Erklärungen zum Gesundheitswert in der App an.',
            es: 'Muestra recomendaciones, previsiones y explicaciones del índice de salud dentro de la app.',
          ),
          value: settings.aiInsightsEnabled,
          onChanged: (value) => appState.saveSettings(
            settings.copyWith(aiInsightsEnabled: value),
          ),
        ),
        _PrivacyToggleCard(
          title: localeText(
            context,
            en: 'Local AI processing',
            da: 'Lokal AI-behandling',
            de: 'Lokale KI-Verarbeitung',
            es: 'Procesamiento local de IA',
          ),
          subtitle: localeText(
            context,
            en: 'Bizoot keeps insight generation local and rule-based in this build.',
            da: 'Bizoot holder indsigtgenerering lokal og regelbaseret i denne version.',
            de: 'Bizoot hält die Generierung von Einblicken in dieser Version lokal und regelbasiert.',
            es: 'En esta versión, Bizoot mantiene la generación de análisis de forma local y basada en reglas.',
          ),
          value: true,
          onChanged: null,
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Privacy protection',
            da: 'Beskyttelse af privatliv',
            de: 'Datenschutz',
            es: 'Protección de la privacidad',
          ),
          body: localeText(
            context,
            en: 'Passwords, login details, phone numbers, email addresses, and direct personal identifiers are not used to generate Bizoot insights.',
            da: 'Adgangskoder, loginoplysninger, telefonnumre, mailadresser og direkte personlige identifikatorer bruges ikke til at generere Bizoot-indsigter.',
            de: 'Passwörter, Anmeldedaten, Telefonnummern, E-Mail-Adressen und direkte persönliche Kennungen werden nicht verwendet, um Bizoot-Einblicke zu erzeugen.',
            es: 'Las contraseñas, datos de acceso, números de teléfono, correos electrónicos e identificadores personales directos no se usan para generar los análisis de Bizoot.',
          ),
        ),
      ],
    );
  }
}

class _PrivacyToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PrivacyToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LegalSectionCard(
      title: title,
      body: subtitle,
      footer: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BizootColors.border.withValues(alpha: 0.75),
            ),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              value
                  ? localeText(
                      context,
                      en: 'Enabled',
                      da: 'Aktiveret',
                      de: 'Aktiviert',
                      es: 'Activado',
                    )
                  : localeText(
                      context,
                      en: 'Disabled',
                      da: 'Deaktiveret',
                      de: 'Deaktiviert',
                      es: 'Desactivado',
                    ),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              onChanged == null
                  ? localeText(
                      context,
                      en: 'This setting is always on in the current build.',
                      da: 'Denne indstilling er altid slået til i den nuværende version.',
                      de: 'Diese Einstellung ist in der aktuellen Version immer aktiv.',
                      es: 'Este ajuste siempre está activado en la versión actual.',
                    )
                  : localeText(
                      context,
                      en: 'Preference is saved to your Bizoot settings.',
                      da: 'Dit valg gemmes i dine Bizoot-indstillinger.',
                      de: 'Deine Auswahl wird in deinen Bizoot-Einstellungen gespeichert.',
                      es: 'La preferencia se guarda en tus ajustes de Bizoot.',
                    ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
            ),
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
