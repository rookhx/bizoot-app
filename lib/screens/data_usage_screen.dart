import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../widgets/legal_screen_shell.dart';

class DataUsageScreen extends StatelessWidget {
  const DataUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'Data Usage',
        da: 'Dataforbrug',
        de: 'Datennutzung',
        es: 'Uso de datos',
      ),
      subtitle: localeText(
        context,
        en:
            'Understand what Bizoot stores, why it is used, and how it supports your subscription dashboard.',
        da:
            'Forstå, hvad Bizoot gemmer, hvorfor det bruges, og hvordan det understøtter dit abonnementsoverblik.',
        de:
            'Verstehe, welche Daten Bizoot speichert, warum sie verwendet werden und wie sie dein Abo-Dashboard unterstützen.',
        es:
            'Entiende qué guarda Bizoot, por qué se usa y cómo respalda tu panel de suscripciones.',
      ),
      icon: Icons.storage_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Core account data',
            da: 'Grundlæggende kontodata',
            de: 'Zentrale Kontodaten',
            es: 'Datos principales de la cuenta',
          ),
          body:
              localeText(
                context,
                en:
                    'Bizoot stores profile details, onboarding choices, preferred currency, notification preferences, and subscription settings so your account can be restored across devices.',
                da:
                    'Bizoot gemmer profiloplysninger, onboardingvalg, foretrukken valuta, notifikationspræferencer og abonnementsindstillinger, så din konto kan gendannes på tværs af enheder.',
                de:
                    'Bizoot speichert Profildaten, Onboarding-Auswahlen, bevorzugte Währung, Benachrichtigungseinstellungen und Abo-Einstellungen, damit dein Konto auf mehreren Geräten wiederhergestellt werden kann.',
                es:
                    'Bizoot guarda los datos del perfil, las elecciones del onboarding, la moneda preferida, las preferencias de notificaciones y los ajustes de suscripción para que tu cuenta pueda restaurarse en varios dispositivos.',
              ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Subscription data',
            da: 'Abonnementsdata',
            de: 'Abonnementdaten',
            es: 'Datos de suscripciones',
          ),
          body:
              localeText(
                context,
                en:
                    'Bizoot uses service names, categories, billing frequencies, amounts, renewal dates, cancellation links, and custom services to power reminders, reports, and recurring-spend intelligence.',
                da:
                    'Bizoot bruger tjenestenavne, kategorier, faktureringsfrekvenser, beløb, fornyelsesdatoer, opsigelseslinks og egne tjenester til at drive påmindelser, rapporter og indsigt i tilbagevendende forbrug.',
                de:
                    'Bizoot verwendet Dienstnamen, Kategorien, Abrechnungsintervalle, Beträge, Verlängerungsdaten, Kündigungslinks und eigene Dienste für Erinnerungen, Berichte und Analysen zu wiederkehrenden Ausgaben.',
                es:
                    'Bizoot utiliza nombres de servicios, categorías, frecuencias de cobro, importes, fechas de renovación, enlaces de cancelación y servicios personalizados para generar recordatorios, informes e inteligencia sobre gasto recurrente.',
              ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Insights and reports',
            da: 'Indsigter og rapporter',
            de: 'Einblicke und Berichte',
            es: 'Insights e informes',
          ),
          body:
              localeText(
                context,
                en:
                    'Your saved payments may be analyzed locally and, when synced, through Bizoot cloud storage to generate monthly totals, health scores, reminders, savings opportunities, and trend summaries.',
                da:
                    'Dine gemte betalinger kan analyseres lokalt og, når de synkroniseres, via Bizoots cloudlager for at generere månedlige totaler, sundhedsscorer, påmindelser, sparemuligheder og trendsammendrag.',
                de:
                    'Deine gespeicherten Zahlungen können lokal und bei Synchronisierung über den Bizoot-Cloudspeicher analysiert werden, um Monatssummen, Gesundheitswerte, Erinnerungen, Sparchancen und Trendzusammenfassungen zu erzeugen.',
                es:
                    'Tus pagos guardados pueden analizarse localmente y, al sincronizarse, a través del almacenamiento en la nube de Bizoot para generar totales mensuales, puntuaciones de salud, recordatorios, oportunidades de ahorro y resúmenes de tendencias.',
              ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Retention and deletion',
            da: 'Opbevaring og sletning',
            de: 'Aufbewahrung und Löschung',
            es: 'Retención y eliminación',
          ),
          body:
              localeText(
                context,
                en:
                    'Your Bizoot data remains attached to your account until you delete it or request deletion. If you delete your account, Bizoot will remove user-owned records and clear local cached data from the app.',
                da:
                    'Dine Bizoot-data forbliver knyttet til din konto, indtil du sletter dem eller anmoder om sletning. Hvis du sletter din konto, fjerner Bizoot brugerdata og rydder lokale cachedata fra appen.',
                de:
                    'Deine Bizoot-Daten bleiben mit deinem Konto verknüpft, bis du sie löschst oder eine Löschung anforderst. Wenn du dein Konto löschst, entfernt Bizoot nutzereigene Daten und leert lokale Cache-Daten aus der App.',
                es:
                    'Tus datos de Bizoot permanecen vinculados a tu cuenta hasta que los elimines o solicites su eliminación. Si eliminas tu cuenta, Bizoot borrará los registros del usuario y limpiará los datos en caché locales de la app.',
              ),
        ),
      ],
    );
  }
}
