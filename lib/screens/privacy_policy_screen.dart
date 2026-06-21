import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'Privacy Policy',
        da: 'Privatlivspolitik',
        de: 'Datenschutzerklärung',
        es: 'Política de privacidad',
      ),
      subtitle: localeText(
        context,
        en: 'How Bizoot collects, uses, stores, and protects your subscription data.',
        da: 'Sådan indsamler, bruger, opbevarer og beskytter Bizoot dine abonnementsdata.',
        de: 'So sammelt, nutzt, speichert und schützt Bizoot deine Abo-Daten.',
        es: 'Cómo Bizoot recopila, usa, almacena y protege tus datos de suscripciones.',
      ),
      icon: Icons.privacy_tip_outlined,
      children: [
        LegalSectionCard(
          title: localeText(context, en: 'Data we collect', da: 'Data vi indsamler', de: 'Welche Daten wir erfassen', es: 'Datos que recopilamos'),
          body: localeText(
            context,
            en: 'Bizoot stores the account details you provide, the recurring payments you track, and the settings you choose so the app can build your dashboard, calendar, reports, and reminders.',
            da: 'Bizoot gemmer de kontooplysninger, du angiver, de tilbagevendende betalinger, du følger, og de indstillinger, du vælger, så appen kan opbygge dit dashboard, din kalender, dine rapporter og dine påmindelser.',
            de: 'Bizoot speichert die Kontodaten, die du angibst, die wiederkehrenden Zahlungen, die du verfolgst, und die Einstellungen, die du auswählst, damit die App dein Dashboard, deinen Kalender, deine Berichte und Erinnerungen erstellen kann.',
            es: 'Bizoot guarda los datos de cuenta que proporcionas, los pagos recurrentes que sigues y los ajustes que eliges para crear tu panel, calendario, informes y recordatorios.',
          ),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Sensitive details', da: 'Følsomme oplysninger', de: 'Sensible Daten', es: 'Datos sensibles'),
          body: localeText(
            context,
            en: 'Passwords, login details, phone numbers, email addresses, and direct personal identifiers are not used to generate Bizoot insights.',
            da: 'Adgangskoder, loginoplysninger, telefonnumre, mailadresser og direkte personlige identifikatorer bruges ikke til at generere Bizoot-indsigter.',
            de: 'Passwörter, Anmeldedaten, Telefonnummern, E-Mail-Adressen und direkte persönliche Kennungen werden nicht verwendet, um Bizoot-Einblicke zu erzeugen.',
            es: 'Las contraseñas, datos de acceso, números de teléfono, correos electrónicos e identificadores personales directos no se usan para generar los análisis de Bizoot.',
          ),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Contact', da: 'Kontakt', de: 'Kontakt', es: 'Contacto'),
          body: localeText(
            context,
            en: 'For privacy questions or deletion requests, contact ${AppConfig.supportEmail}. Public policy: ${AppConfig.privacyPolicyUrl}',
            da: 'Ved spørgsmål om privatliv eller sletning kan du kontakte ${AppConfig.supportEmail}. Offentlig politik: ${AppConfig.privacyPolicyUrl}',
            de: 'Bei Fragen zum Datenschutz oder zu Löschanfragen kontaktiere ${AppConfig.supportEmail}. Öffentliche Richtlinie: ${AppConfig.privacyPolicyUrl}',
            es: 'Para preguntas sobre privacidad o solicitudes de eliminación, contacta con ${AppConfig.supportEmail}. Política pública: ${AppConfig.privacyPolicyUrl}',
          ),
        ),
      ],
    );
  }
}
