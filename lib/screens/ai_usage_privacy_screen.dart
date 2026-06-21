import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class AiUsagePrivacyScreen extends StatelessWidget {
  const AiUsagePrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'AI Usage & Privacy',
        da: 'AI-brug og privatliv',
        de: 'KI-Nutzung und Datenschutz',
        es: 'Uso de IA y privacidad',
      ),
      subtitle: localeText(
        context,
        en: 'See how Bizoot uses local insights to keep your recurring spending clear and actionable.',
        da: 'Se hvordan Bizoot bruger lokale indsigter til at gøre dine tilbagevendende udgifter klare og handlingsklare.',
        de: 'Sieh, wie Bizoot lokale Einblicke nutzt, um deine wiederkehrenden Ausgaben klar und handlungsorientiert darzustellen.',
        es: 'Descubre cómo Bizoot usa análisis locales para que tus gastos recurrentes sean más claros y útiles.',
      ),
      icon: Icons.auto_awesome_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Local insights only',
            da: 'Kun lokale indsigter',
            de: 'Nur lokale Einblicke',
            es: 'Solo análisis locales',
          ),
          body: localeText(
            context,
            en: 'Bizoot uses local, rule-based intelligence to surface savings opportunities, spending trends, and health-score explanations.',
            da: 'Bizoot bruger lokal, regelbaseret intelligens til at vise besparelsesmuligheder, udgiftstendenser og forklaringer på sundhedsscoren.',
            de: 'Bizoot nutzt lokale, regelbasierte Intelligenz, um Sparmöglichkeiten, Ausgabentrends und Erklärungen zum Gesundheitswert sichtbar zu machen.',
            es: 'Bizoot usa inteligencia local y basada en reglas para mostrar oportunidades de ahorro, tendencias de gasto y explicaciones del índice de salud.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Sensitive details stay out',
            da: 'Følsomme oplysninger holdes ude',
            de: 'Sensible Daten bleiben außen vor',
            es: 'Los datos sensibles quedan fuera',
          ),
          body: localeText(
            context,
            en: 'Passwords, login details, phone numbers, email addresses, and direct personal identifiers are not used to generate insights.',
            da: 'Adgangskoder, loginoplysninger, telefonnumre, mailadresser og direkte personlige identifikatorer bruges ikke til at generere indsigter.',
            de: 'Passwörter, Anmeldedaten, Telefonnummern, E-Mail-Adressen und direkte persönliche Kennungen werden nicht verwendet, um Einblicke zu erzeugen.',
            es: 'Las contraseñas, datos de acceso, números de teléfono, correos electrónicos e identificadores personales directos no se usan para generar análisis.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'What insights use',
            da: 'Hvad indsigterne bruger',
            de: 'Was die Einblicke verwenden',
            es: 'Qué usan los análisis',
          ),
          body: localeText(
            context,
            en: 'Bizoot looks at subscription names, categories, billing amounts, billing frequency, and upcoming dates to generate recommendations inside the app.',
            da: 'Bizoot ser på abonnementsnavne, kategorier, beløb, faktureringsfrekvens og kommende datoer for at skabe anbefalinger i appen.',
            de: 'Bizoot betrachtet Abo-Namen, Kategorien, Abrechnungsbeträge, Abrechnungsfrequenz und kommende Termine, um Empfehlungen in der App zu erstellen.',
            es: 'Bizoot analiza nombres de suscripciones, categorías, importes, frecuencia de cobro y próximas fechas para generar recomendaciones dentro de la app.',
          ),
        ),
      ],
    );
  }
}
