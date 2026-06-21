import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class SubscriptionTermsScreen extends StatelessWidget {
  const SubscriptionTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(context, en: 'Subscription Terms', da: 'Abonnementsvilkår', de: 'Abonnementbedingungen', es: 'Términos de suscripción'),
      subtitle: localeText(context, en: 'Review the plan, trial, renewal, and cancellation terms that apply to Bizoot Premium.', da: 'Gennemgå plan-, prøve-, fornyelses- og opsigelsesvilkår for Bizoot Premium.', de: 'Prüfe die Plan-, Test-, Verlängerungs- und Kündigungsbedingungen für Bizoot Premium.', es: 'Revisa los términos del plan, prueba, renovación y cancelación aplicables a Bizoot Premium.'),
      icon: Icons.workspace_premium_outlined,
      children: [
        LegalSectionCard(
          title: localeText(context, en: 'Trial and renewal', da: 'Prøve og fornyelse', de: 'Testphase und Verlängerung', es: 'Prueba y renovación'),
          body: localeText(context, en: 'Bizoot may offer a free trial before Premium billing begins. If you subscribe later, the plan will renew automatically until you cancel through the app store linked to your purchase.', da: 'Bizoot kan tilbyde en gratis prøveperiode, før Premium-fakturering begynder. Hvis du senere abonnerer, fornyes planen automatisk, indtil du opsiger den via appbutikken, der er knyttet til dit køb.', de: 'Bizoot kann eine kostenlose Testphase anbieten, bevor die Premium-Abrechnung beginnt. Wenn du später abonnierst, verlängert sich der Plan automatisch, bis du ihn über den mit dem Kauf verknüpften App-Store kündigst.', es: 'Bizoot puede ofrecer una prueba gratuita antes de que comience la facturación Premium. Si te suscribes después, el plan se renovará automáticamente hasta que canceles a través de la tienda vinculada a tu compra.'),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Billing responsibility', da: 'Ansvar for betaling', de: 'Verantwortung für die Abrechnung', es: 'Responsabilidad de facturación'),
          body: localeText(context, en: 'Google Play or the Apple App Store will manage billing, renewals, and refunds once store purchases are enabled. Bizoot does not process raw card data directly inside the app.', da: 'Google Play eller Apple App Store håndterer betaling, fornyelser og refusioner, når butikskøb er aktiveret. Bizoot behandler ikke rå kortdata direkte i appen.', de: 'Google Play oder der Apple App Store verwalten Abrechnung, Verlängerungen und Rückerstattungen, sobald Käufe im Store aktiviert sind. Bizoot verarbeitet keine rohen Kartendaten direkt in der App.', es: 'Google Play o Apple App Store gestionarán la facturación, renovaciones y reembolsos cuando las compras en tienda estén habilitadas. Bizoot no procesa datos de tarjeta sin procesar directamente en la app.'),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Cancellation', da: 'Opsigelse', de: 'Kündigung', es: 'Cancelación'),
          body: localeText(context, en: 'You can cancel Premium at any time through your store subscription settings. Cancelling stops future renewals, but any active paid period will remain available until it ends.', da: 'Du kan til enhver tid opsige Premium via dine abonnementsindstillinger i butikken. Opsigelse stopper fremtidige fornyelser, men en aktiv betalt periode forbliver tilgængelig, indtil den udløber.', de: 'Du kannst Premium jederzeit über die Abonnement-Einstellungen deines Stores kündigen. Die Kündigung stoppt zukünftige Verlängerungen, aber ein aktiver bezahlter Zeitraum bleibt bis zu seinem Ende verfügbar.', es: 'Puedes cancelar Premium en cualquier momento desde la configuración de suscripciones de tu tienda. La cancelación detiene futuras renovaciones, pero cualquier periodo de pago activo seguirá disponible hasta que termine.'),
        ),
        LegalSectionCard(
          title: localeText(context, en: 'Feature access', da: 'Adgang til funktioner', de: 'Funktionszugriff', es: 'Acceso a funciones'),
          body: localeText(context, en: 'Premium may unlock unlimited subscription tracking, advanced analytics, smart insights, AI-ready recommendations, enhanced reminders, and richer reports. Feature details may evolve as Bizoot improves.', da: 'Premium kan låse op for ubegrænset abonnementssporing, avancerede analyser, smarte indsigter, AI-klare anbefalinger, forbedrede påmindelser og mere detaljerede rapporter. Funktionsdetaljer kan udvikle sig, efterhånden som Bizoot forbedres.', de: 'Premium kann unbegrenztes Abo-Tracking, erweiterte Analysen, smarte Einblicke, KI-fähige Empfehlungen, verbesserte Erinnerungen und umfangreichere Berichte freischalten. Funktionsdetails können sich weiterentwickeln, während Bizoot verbessert wird.', es: 'Premium puede desbloquear seguimiento ilimitado de suscripciones, analítica avanzada, insights inteligentes, recomendaciones preparadas para IA, recordatorios mejorados e informes más completos. Los detalles de las funciones pueden evolucionar a medida que Bizoot mejore.'),
        ),
      ],
    );
  }
}
