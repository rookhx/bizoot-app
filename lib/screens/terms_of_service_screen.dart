import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'Terms of Service',
        da: 'Servicevilkår',
        de: 'Nutzungsbedingungen',
        es: 'Términos del servicio',
      ),
      subtitle: localeText(
        context,
        en: 'The basic rules for using Bizoot and its subscription intelligence features.',
        da: 'De grundlæggende regler for brug af Bizoot og dets abonnementsfunktioner.',
        de: 'Die grundlegenden Regeln für die Nutzung von Bizoot und seiner Abo-Intelligenzfunktionen.',
        es: 'Las reglas básicas para usar Bizoot y sus funciones de inteligencia de suscripciones.',
      ),
      icon: Icons.gavel_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Using Bizoot',
            da: 'Brug af Bizoot',
            de: 'Nutzung von Bizoot',
            es: 'Uso de Bizoot',
          ),
          body: localeText(
            context,
            en: 'Bizoot is designed to help you track recurring payments, trials, bills, and subscription insights. You agree to use the app lawfully and avoid uploading misleading, abusive, or malicious content.',
            da: 'Bizoot er designet til at hjælpe dig med at følge tilbagevendende betalinger, prøveperioder, regninger og abonnementsindsigt. Du accepterer at bruge appen lovligt og undgå vildledende, krænkende eller skadeligt indhold.',
            de: 'Bizoot wurde entwickelt, um dir bei wiederkehrenden Zahlungen, Testphasen, Rechnungen und Abo-Einblicken zu helfen. Du verpflichtest dich, die App rechtmäßig zu nutzen und keine irreführenden, missbräuchlichen oder schädlichen Inhalte hochzuladen.',
            es: 'Bizoot está diseñado para ayudarte a seguir pagos recurrentes, pruebas, facturas e información de suscripciones. Aceptas usar la app de forma legal y evitar contenido engañoso, abusivo o malicioso.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Billing and Premium',
            da: 'Betaling og Premium',
            de: 'Abrechnung und Premium',
            es: 'Facturación y Premium',
          ),
          body: localeText(
            context,
            en: 'If Bizoot offers trials or Premium access, the details shown during purchase and the platform billing flow will apply.',
            da: 'Hvis Bizoot tilbyder prøveperioder eller Premium-adgang, gælder de oplysninger, der vises under køb, samt platformens betalingsflow.',
            de: 'Wenn Bizoot Testphasen oder Premium-Zugang anbietet, gelten die Informationen, die beim Kauf angezeigt werden, sowie der Abrechnungsablauf der Plattform.',
            es: 'Si Bizoot ofrece pruebas o acceso Premium, se aplicarán los detalles mostrados durante la compra y el flujo de facturación de la plataforma.',
          ),
        ),
      ],
    );
  }
}
