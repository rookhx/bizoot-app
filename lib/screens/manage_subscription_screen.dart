import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(context, en: 'Manage Subscription', da: 'Administrer abonnement', de: 'Abonnement verwalten', es: 'Gestionar suscripción'),
      subtitle: localeText(context, en: 'A store-billing placeholder until Android and iOS subscription setup is completed.', da: 'En midlertidig butikstekst, indtil Android- og iOS-abonnementer er sat fuldt op.', de: 'Ein vorläufiger Store-Hinweis, bis die Android- und iOS-Abonnement-Einrichtung abgeschlossen ist.', es: 'Un marcador temporal de facturación en tienda hasta completar la configuración de suscripciones en Android e iOS.'),
      icon: Icons.workspace_premium_outlined,
      children: [
        LegalSectionCard(
          title: localeText(context, en: 'Store-managed billing', da: 'Butiksstyret betaling', de: 'Store-verwaltete Abrechnung', es: 'Facturación gestionada por la tienda'),
          body: localeText(context, en: 'Bizoot plans to manage premium subscriptions through Google Play and the Apple App Store. Renewal dates, trial handling, cancellations, and receipts will come from the store where the purchase was made.', da: 'Bizoot planlægger at håndtere premiumabonnementer via Google Play og Apple App Store. Fornyelsesdatoer, prøveperioder, opsigelser og kvitteringer kommer fra den butik, hvor købet blev foretaget.', de: 'Bizoot plant, Premium-Abos über Google Play und den Apple App Store zu verwalten. Verlängerungsdaten, Testphasen, Kündigungen und Belege kommen aus dem Store, in dem der Kauf getätigt wurde.', es: 'Bizoot planea gestionar las suscripciones premium a través de Google Play y Apple App Store. Las fechas de renovación, pruebas, cancelaciones y recibos vendrán de la tienda donde se realizó la compra.'),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Manage subscription placeholder', da: 'Midlertidig abonnementsstyring', de: 'Platzhalter für Abo-Verwaltung', es: 'Marcador para gestionar suscripción'),
          body: localeText(context, en: 'This screen is intentionally a placeholder in the current launch-prep build. Before billing goes live, replace this content with direct store management links and a real restore purchases action.', da: 'Denne skærm er bevidst midlertidig i den nuværende launch-klargøring. Før betaling går live, bør indholdet erstattes med direkte butikslinks og en rigtig gendan køb-handling.', de: 'Dieser Bildschirm ist in der aktuellen Startvorbereitung absichtlich nur ein Platzhalter. Bevor die Abrechnung live geht, sollte dieser Inhalt durch direkte Store-Links und eine echte Wiederherstellen-Funktion ersetzt werden.', es: 'Esta pantalla es intencionalmente temporal en la versión actual de preparación para lanzamiento. Antes de activar la facturación, este contenido debe sustituirse por enlaces directos de tienda y una acción real de restaurar compras.'),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Restore purchases placeholder', da: 'Midlertidig gendan køb', de: 'Platzhalter für Käufe wiederherstellen', es: 'Marcador para restaurar compras'),
          body: localeText(context, en: 'Restore purchases is not active in this build because live store products have not been configured yet. Once billing is enabled, users should be able to refresh entitlements here.', da: 'Gendan køb er ikke aktiv i denne version, fordi de live butikprodukter endnu ikke er konfigureret. Når betaling er aktiveret, bør brugere kunne opdatere deres adgang her.', de: 'Käufe wiederherstellen ist in diesem Build nicht aktiv, weil die Live-Store-Produkte noch nicht konfiguriert sind. Sobald die Abrechnung aktiviert ist, sollten Nutzer ihre Berechtigungen hier aktualisieren können.', es: 'Restaurar compras no está activo en esta versión porque los productos reales de tienda aún no están configurados. Cuando la facturación esté habilitada, los usuarios deberían poder actualizar aquí sus accesos.'),
        ),
      ],
    );
  }
}
