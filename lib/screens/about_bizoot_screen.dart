import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../theme/app_theme.dart';
import '../utils/app_version_helper.dart';
import '../widgets/bizoot_branding.dart';
import '../widgets/legal_screen_shell.dart';

class AboutBizootScreen extends StatelessWidget {
  const AboutBizootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'About Bizoot',
        da: 'Om Bizoot',
        de: 'Über Bizoot',
        es: 'Acerca de Bizoot',
      ),
      subtitle: localeText(
        context,
        en: 'A subscription intelligence product built to help people feel more in control of their money.',
        da: 'Et produkt til abonnementsindsigt, skabt for at hjælpe mennesker med at få mere kontrol over deres penge.',
        de: 'Ein Produkt für Abo-Intelligenz, das Menschen helfen soll, ihre Finanzen besser im Griff zu haben.',
        es: 'Un producto de inteligencia de suscripciones creado para ayudar a las personas a sentir más control sobre su dinero.',
      ),
      icon: Icons.auto_awesome_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Mission',
            da: 'Mission',
            de: 'Mission',
            es: 'Misión',
          ),
          body: localeText(
            context,
            en: 'Bizoot exists to make recurring spending feel visible, calm, and actionable. The goal is simple: help people spot hidden costs, avoid surprise renewals, and feel confident about what is safe to spend.',
            da: 'Bizoot findes for at gøre tilbagevendende udgifter synlige, rolige og handlingsklare. Målet er enkelt: hjælpe mennesker med at opdage skjulte omkostninger, undgå uventede fornyelser og føle sig trygge ved, hvad de kan bruge.',
            de: 'Bizoot soll wiederkehrende Ausgaben sichtbar, übersichtlich und handlungsorientiert machen. Das Ziel ist einfach: versteckte Kosten erkennen, überraschende Verlängerungen vermeiden und sicherer einschätzen, was man ausgeben kann.',
            es: 'Bizoot existe para que los gastos recurrentes se sientan visibles, tranquilos y accionables. El objetivo es simple: ayudar a detectar costes ocultos, evitar renovaciones sorpresa y tener más confianza sobre lo que se puede gastar.',
          ),
          footer: const [
            Center(child: BizootLogo(height: 42)),
          ],
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Version',
            da: 'Version',
            de: 'Version',
            es: 'Versión',
          ),
          body: localeText(
            context,
            en: 'This device is running the current Bizoot app build.',
            da: 'Denne enhed kører den aktuelle Bizoot-version.',
            de: 'Dieses Gerät verwendet die aktuelle Bizoot-App-Version.',
            es: 'Este dispositivo está ejecutando la versión actual de Bizoot.',
          ),
          footer: [
            FutureBuilder<String>(
              future: loadAppVersionLabel(),
              builder: (context, snapshot) => Text(
                snapshot.data == null
                    ? localeText(
                        context,
                        en: 'Loading version...',
                        da: 'Indlæser version...',
                        de: 'Version wird geladen...',
                        es: 'Cargando versión...',
                      )
                    : localeText(
                        context,
                        en: 'Version ${snapshot.data}',
                        da: 'Version ${snapshot.data}',
                        de: 'Version ${snapshot.data}',
                        es: 'Versión ${snapshot.data}',
                      ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: BizootColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Branding',
            da: 'Branding',
            de: 'Markenauftritt',
            es: 'Identidad visual',
          ),
          body: localeText(
            context,
            en: 'Bizoot uses a dark neon visual system designed to feel premium, useful, and trustworthy across Android and iOS.',
            da: 'Bizoot bruger et mørkt neonpræget designsystem, som skal føles premium, nyttigt og troværdigt på både Android og iOS.',
            de: 'Bizoot nutzt ein dunkles, neonbetontes Designsystem, das sich auf Android und iOS hochwertig, nützlich und vertrauenswürdig anfühlen soll.',
            es: 'Bizoot usa un sistema visual oscuro con toques neón diseñado para sentirse premium, útil y confiable tanto en Android como en iOS.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Copyright',
            da: 'Copyright',
            de: 'Urheberrecht',
            es: 'Derechos de autor',
          ),
          body: localeText(
            context,
            en: '© 2026 Bizoot. All rights reserved.',
            da: '© 2026 Bizoot. Alle rettigheder forbeholdes.',
            de: '© 2026 Bizoot. Alle Rechte vorbehalten.',
            es: '© 2026 Bizoot. Todos los derechos reservados.',
          ),
        ),
      ],
    );
  }
}
