import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../models/connected_email_account.dart';
import '../models/import_review_item.dart';
import '../models/recurring_payment.dart';
import '../screens/paywall_screen.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand_service_icon.dart';

enum _ImportFlowStep { provider, consent, scanning, review, confirm }

class EmailImportFlowScreen extends StatefulWidget {
  const EmailImportFlowScreen({super.key});

  @override
  State<EmailImportFlowScreen> createState() => _EmailImportFlowScreenState();
}

class _EmailImportFlowScreenState extends State<EmailImportFlowScreen> {
  _ImportFlowStep _step = _ImportFlowStep.provider;
  ConnectedEmailProvider? _provider;
  final Set<String> _selectedIds = <String>{};
  final List<_DetectedDraft> _items = <_DetectedDraft>[];
  bool _isImporting = false;
  double _progress = 0.12;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return AppScaffold(
      title: _title(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          if (_step == _ImportFlowStep.provider)
            _providerStep(context, appState),
          if (_step == _ImportFlowStep.consent) _consentStep(context, appState),
          if (_step == _ImportFlowStep.scanning) _scanningStep(context),
          if (_step == _ImportFlowStep.review) _reviewStep(context),
          if (_step == _ImportFlowStep.confirm) _confirmStep(context, appState),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    switch (_step) {
      case _ImportFlowStep.provider:
        return localeText(
          context,
          en: 'Import from Email',
          da: 'Importer fra e-mail',
          de: 'Aus E-Mail importieren',
          es: 'Importar desde correo',
        );
      case _ImportFlowStep.consent:
        return localeText(
          context,
          en: 'Privacy First',
          da: 'Privatliv fÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¸rst',
          de: 'Datenschutz zuerst',
          es: 'Privacidad primero',
        );
      case _ImportFlowStep.scanning:
        return localeText(
          context,
          en: 'Scanning',
          da: 'Scanner',
          de: 'Scannen',
          es: 'Escaneando',
        );
      case _ImportFlowStep.review:
        return localeText(
          context,
          en: 'Review detected items',
          da: 'GennemgÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥ fundne poster',
          de: 'Erkannte EintrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤ge prÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼fen',
          es: 'Revisar elementos detectados',
        );
      case _ImportFlowStep.confirm:
        return localeText(
          context,
          en: 'Confirm import',
          da: 'BekrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¦ft import',
          de: 'Import bestÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤tigen',
          es: 'Confirmar importaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n',
        );
    }
  }

  Widget _providerStep(BuildContext context, AppState appState) {
    final gmailAccount = appState.gmailImportAccount;
    final gmailConnected = gmailAccount?.isConnected == true;
    final gmailSelected = _provider == ConnectedEmailProvider.gmail;
    final outlookAccount = appState.outlookImportAccount;
    final outlookConnected = outlookAccount?.isConnected == true;
    final outlookSelected = _provider == ConnectedEmailProvider.outlook;
    final connectErrorFallback = localeText(
      context,
      en: 'Bizoot could not connect Gmail right now. Please try again.',
      da: 'Bizoot kunne ikke forbinde Gmail lige nu. Prov igen.',
      de: 'Bizoot konnte Gmail gerade nicht verbinden. Bitte versuche es erneut.',
      es: 'Bizoot no pudo conectar Gmail en este momento. Intentalo de nuevo.',
    );
    final disconnectErrorFallback = localeText(
      context,
      en: 'Bizoot could not disconnect Gmail right now. Please try again.',
      da: 'Bizoot kunne ikke afbryde Gmail lige nu. Prov igen.',
      de: 'Bizoot konnte Gmail gerade nicht trennen. Bitte versuche es erneut.',
      es: 'Bizoot no pudo desconectar Gmail en este momento. Intentalo de nuevo.',
    );
    final outlookConnectErrorFallback = localeText(
      context,
      en: 'Bizoot could not connect Outlook right now. Please try again.',
      da: 'Bizoot kunne ikke forbinde Outlook lige nu. Prov igen.',
      de: 'Bizoot konnte Outlook gerade nicht verbinden. Bitte versuche es erneut.',
      es: 'Bizoot no pudo conectar Outlook en este momento. Intentalo de nuevo.',
    );
    final outlookDisconnectErrorFallback = localeText(
      context,
      en: 'Bizoot could not disconnect Outlook right now. Please try again.',
      da: 'Bizoot kunne ikke afbryde Outlook lige nu. Prov igen.',
      de: 'Bizoot konnte Outlook gerade nicht trennen. Bitte versuche es erneut.',
      es: 'Bizoot no pudo desconectar Outlook en este momento. Intentalo de nuevo.',
    );
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeText(
                  context,
                  en: 'Choose Gmail or Outlook',
                  da: 'VÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¦lg Gmail eller Outlook',
                  de: 'WÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤hle Gmail oder Outlook',
                  es: 'Elige Gmail u Outlook',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: BizootSpacing.xs),
              Text(
                localeText(
                  context,
                  en: 'Bizoot scans up to 1 year of relevant billing emails and lets you review every detected subscription before anything is saved.',
                  da: 'Bizoot scanner op til 1 ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥r af relevante betalingsmails og lader dig gennemgÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥ hvert fundet abonnement, fÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¸r noget bliver gemt.',
                  de: 'Bizoot scannt bis zu 1 Jahr relevante Abrechnungs-E-Mails und lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤sst dich jedes erkannte Abonnement prÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼fen, bevor etwas gespeichert wird.',
                  es: 'Bizoot escanea hasta 1 aÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±o de correos de facturaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n relevantes y te deja revisar cada suscripciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n detectada antes de guardar nada.',
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              _ProviderChoice(
                title: 'Gmail',
                subtitle: localeText(
                  context,
                  en: 'Google receipts, Play billing, and inbox subscriptions.',
                  da: 'Google-kvitteringer, Play-betalinger og abonnementer fra indbakken.',
                  de: 'Google-Belege, Play-Abrechnungen und Abonnements aus dem Posteingang.',
                  es: 'Recibos de Google, cobros de Play y suscripciones del correo.',
                ),
                color: const Color(0xFFEA4335),
                icon: Icons.mail_outline_rounded,
                selected: gmailSelected,
                onTap: () =>
                    setState(() => _provider = ConnectedEmailProvider.gmail),
              ),
              if (gmailSelected) ...[
                const SizedBox(height: BizootSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BizootColors.surfaceElevated.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: BizootColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !gmailConnected
                            ? localeText(
                                context,
                                en: 'Gmail is not connected yet.',
                                da: 'Gmail er ikke forbundet endnu.',
                                de: 'Gmail ist noch nicht verbunden.',
                                es: 'Gmail todavia no esta conectado.',
                              )
                            : localeText(
                                context,
                                en: 'Connected Gmail account',
                                da: 'Forbundet Gmail-konto',
                                de: 'Verknupftes Gmail-Konto',
                                es: 'Cuenta de Gmail conectada',
                              ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gmailConnected
                            ? gmailAccount!.emailAddress
                            : _localizedAccountErrorMessage(
                                    context,
                                    gmailAccount,
                                  ) ??
                                  localeText(
                                    context,
                                    en: 'Connect your Gmail account to prepare the 1-year scan pipeline.',
                                    da: 'Forbind din Gmail-konto for at klargore scanning af det seneste ar.',
                                    de: 'Verbinde dein Gmail-Konto, um die Scan-Pipeline fur das letzte Jahr vorzubereiten.',
                                    es: 'Conecta tu cuenta de Gmail para preparar el escaneo del ultimo ano.',
                                  ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                      if (gmailConnected) ...[
                        const SizedBox(height: 8),
                        Text(
                          localeText(
                            context,
                            en: 'Scope: Gmail read-only for subscription detection.',
                            da: 'Adgang: kun laesning af Gmail til abonnementsregistrering.',
                            de: 'Berechtigung: Gmail nur lesend zur Abo-Erkennung.',
                            es: 'Permiso: solo lectura de Gmail para detectar suscripciones.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: BizootColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: BizootSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: !gmailConnected
                                  ? localeText(
                                      context,
                                      en: 'Connect Gmail',
                                      da: 'Forbind Gmail',
                                      de: 'Gmail verbinden',
                                      es: 'Conectar Gmail',
                                    )
                                  : localeText(
                                      context,
                                      en: 'Refresh status',
                                      da: 'Opdater status',
                                      de: 'Status aktualisieren',
                                      es: 'Actualizar estado',
                                    ),
                              icon: Icons.link_rounded,
                              onPressed: () async {
                                try {
                                  if (!gmailConnected) {
                                    await appState.connectGmailImportAccount();
                                  } else {
                                    await appState
                                        .refreshConnectedEmailAccounts();
                                  }
                                  if (!context.mounted) return;
                                  setState(() {});
                                } catch (error) {
                                  if (!context.mounted) return;
                                  showErrorSnackBar(
                                    context,
                                    connectErrorFallback,
                                  );
                                }
                              },
                            ),
                          ),
                          if (gmailConnected) ...[
                            const SizedBox(width: BizootSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: localeText(
                                  context,
                                  en: 'Disconnect',
                                  da: 'Afbryd',
                                  de: 'Trennen',
                                  es: 'Desconectar',
                                ),
                                secondary: true,
                                icon: Icons.link_off_rounded,
                                onPressed: () async {
                                  try {
                                    await appState
                                        .disconnectGmailImportAccount();
                                    if (!context.mounted) return;
                                    setState(() {});
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    showErrorSnackBar(
                                      context,
                                      disconnectErrorFallback,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: BizootSpacing.sm),
              _ProviderChoice(
                title: 'Outlook',
                subtitle: localeText(
                  context,
                  en: 'Microsoft receipts, work inboxes, and household billing.',
                  da: 'Microsoft-kvitteringer, arbejdsindbakker og husholdningsbetalinger.',
                  de: 'Microsoft-Belege, Arbeits-Postf\\u00e4cher und Haushaltsabrechnungen.',
                  es: 'Recibos de Microsoft, bandejas de trabajo y pagos del hogar.',
                ),
                color: const Color(0xFF0078D4),
                icon: Icons.outbox_outlined,
                selected: outlookSelected,
                onTap: () =>
                    setState(() => _provider = ConnectedEmailProvider.outlook),
              ),
              if (outlookSelected) ...[
                const SizedBox(height: BizootSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BizootColors.surfaceElevated.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: BizootColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !outlookConnected
                            ? localeText(
                                context,
                                en: 'Outlook is not connected yet.',
                                da: 'Outlook er ikke forbundet endnu.',
                                de: 'Outlook ist noch nicht verbunden.',
                                es: 'Outlook todavia no esta conectado.',
                              )
                            : localeText(
                                context,
                                en: 'Connected Outlook account',
                                da: 'Forbundet Outlook-konto',
                                de: 'Verknupftes Outlook-Konto',
                                es: 'Cuenta de Outlook conectada',
                              ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outlookConnected
                            ? outlookAccount!.emailAddress
                            : _localizedAccountErrorMessage(
                                    context,
                                    outlookAccount,
                                  ) ??
                                  localeText(
                                    context,
                                    en: 'Connect your Outlook account to prepare the Microsoft Graph scan pipeline.',
                                    da: 'Forbind din Outlook-konto for at klargore Microsoft Graph-scanningen.',
                                    de: 'Verbinde dein Outlook-Konto, um die Microsoft-Graph-Scanpipeline vorzubereiten.',
                                    es: 'Conecta tu cuenta de Outlook para preparar el flujo de escaneo de Microsoft Graph.',
                                  ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                      if (outlookConnected) ...[
                        const SizedBox(height: 8),
                        Text(
                          localeText(
                            context,
                            en: 'Scope: Outlook mail read-only for subscription detection.',
                            da: 'Adgang: kun laesning af Outlook-mail til abonnementsregistrering.',
                            de: 'Berechtigung: Outlook-Mail nur lesend zur Abo-Erkennung.',
                            es: 'Permiso: solo lectura de Outlook para detectar suscripciones.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: BizootColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: BizootSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: !outlookConnected
                                  ? localeText(
                                      context,
                                      en: 'Connect Outlook',
                                      da: 'Forbind Outlook',
                                      de: 'Outlook verbinden',
                                      es: 'Conectar Outlook',
                                    )
                                  : localeText(
                                      context,
                                      en: 'Refresh status',
                                      da: 'Opdater status',
                                      de: 'Status aktualisieren',
                                      es: 'Actualizar estado',
                                    ),
                              icon: Icons.link_rounded,
                              onPressed: () async {
                                try {
                                  if (!outlookConnected) {
                                    await appState
                                        .connectOutlookImportAccount();
                                  } else {
                                    await appState
                                        .refreshConnectedEmailAccounts();
                                  }
                                  if (!context.mounted) return;
                                  setState(() {});
                                } catch (error) {
                                  if (!context.mounted) return;
                                  showErrorSnackBar(
                                    context,
                                    outlookConnectErrorFallback,
                                  );
                                }
                              },
                            ),
                          ),
                          if (outlookConnected) ...[
                            const SizedBox(width: BizootSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: localeText(
                                  context,
                                  en: 'Disconnect',
                                  da: 'Afbryd',
                                  de: 'Trennen',
                                  es: 'Desconectar',
                                ),
                                secondary: true,
                                icon: Icons.link_off_rounded,
                                onPressed: () async {
                                  try {
                                    await appState
                                        .disconnectOutlookImportAccount();
                                    if (!context.mounted) return;
                                    setState(() {});
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    showErrorSnackBar(
                                      context,
                                      outlookDisconnectErrorFallback,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        AppButton(
          label: localeText(
            context,
            en: 'Continue',
            da: 'FortsÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¦t',
            de: 'Weiter',
            es: 'Continuar',
          ),
          icon: Icons.arrow_forward_rounded,
          onPressed: _provider == null
              ? null
              : () => setState(() => _step = _ImportFlowStep.consent),
        ),
      ],
    );
  }

  Widget _consentStep(BuildContext context, AppState appState) {
    final requiresConnection =
        _provider == ConnectedEmailProvider.gmail ||
        _provider == ConnectedEmailProvider.outlook;
    final hasConnection =
        !requiresConnection ||
        (_provider == ConnectedEmailProvider.gmail
            ? appState.gmailImportAccount?.isConnected == true
            : appState.outlookImportAccount?.isConnected == true);
    final activeAccount = _provider == ConnectedEmailProvider.gmail
        ? appState.gmailImportAccount
        : appState.outlookImportAccount;
    final providerLabel = _provider == ConnectedEmailProvider.outlook
        ? 'Outlook'
        : 'Gmail';
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeText(
                  context,
                  en: 'Before you scan',
                  da: 'FÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¸r du scanner',
                  de: 'Bevor du scannst',
                  es: 'Antes de escanear',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: BizootSpacing.sm),
              _bullet(
                context,
                localeText(
                  context,
                  en: 'Only relevant billing emails from the last 12 months are reviewed.',
                  da: 'Kun relevante betalingsmails fra de sidste 12 mÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥neder bliver gennemgÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥et.',
                  de: 'Nur relevante Abrechnungs-E-Mails aus den letzten 12 Monaten werden geprÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ft.',
                  es: 'Solo se revisan correos de facturaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n relevantes de los ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºltimos 12 meses.',
                ),
              ),
              _bullet(
                context,
                localeText(
                  context,
                  en: 'Free users review detected results before import. Premium can sync connected inboxes automatically after upgrade.',
                  da: 'Gratisbrugere gennemgar fundne resultater for import. Premium kan synkronisere tilknyttede indbakker automatisk efter opgradering.',
                  de: 'Kostenlose Nutzer prufen erkannte Ergebnisse vor dem Import. Premium kann verbundene Postfacher nach dem Upgrade automatisch synchronisieren.',
                  es: 'Los usuarios gratis revisan los resultados detectados antes de importar. Premium puede sincronizar bandejas conectadas automaticamente despues de mejorar.',
                ),
              ),
              _bullet(
                context,
                localeText(
                  context,
                  en: 'Free users can import up to 5 active subscriptions total, including email imports.',
                  da: 'Gratisbrugere kan importere op til 5 aktive abonnementer i alt, inklusive e-mailimporter.',
                  de: 'Kostenlose Nutzer konnen insgesamt bis zu 5 aktive Abonnements importieren, einschliesslich E-Mail-Importen.',
                  es: 'Los usuarios gratis pueden importar hasta 5 suscripciones activas en total, incluidas las importadas por correo.',
                ),
              ),
              _bullet(
                context,
                localeText(
                  context,
                  en: 'Premium unlocks the full 1-year import list and daily re-scans for connected inboxes.',
                  da: 'Premium laser hele 1-ars-importlisten op og giver daglige genscanninger af tilknyttede indbakker.',
                  de: 'Premium schaltet die vollstandige 1-Jahres-Importliste und tagliche erneute Scans verbundener Postfacher frei.',
                  es: 'Premium desbloquea la lista completa del ultimo ano y nuevos escaneos diarios de las bandejas conectadas.',
                ),
              ),
            ],
          ),
        ),
        if (requiresConnection && !hasConnection) ...[
          const SizedBox(height: BizootSpacing.md),
          AppCard(
            child: Text(
              activeAccount?.errorMessage ??
                  localeText(
                    context,
                    en: 'Connect your $providerLabel account on the previous step before starting the scan preview.',
                    da: 'Forbind din $providerLabel-konto pa forrige trin, for du starter scanningsforhandsvisningen.',
                    de: 'Verbinde dein $providerLabel-Konto im vorherigen Schritt, bevor du die Scanvorschau startest.',
                    es: 'Conecta tu cuenta de $providerLabel en el paso anterior antes de iniciar la vista previa del escaneo.',
                  ),
            ),
          ),
        ] else if (requiresConnection) ...[
          const SizedBox(height: BizootSpacing.md),
          AppCard(
            child: Text(
              localeText(
                context,
                en: 'Connected as ${activeAccount!.emailAddress}. $providerLabel read-only access is prepared for the scan pipeline.',
                da: 'Forbundet som ${activeAccount.emailAddress}. $providerLabel-adgang kun til laesning er klargjort til scanning.',
                de: 'Verbunden als ${activeAccount.emailAddress}. Der schreibgeschutzte $providerLabel-Zugriff ist fur die Scan-Pipeline vorbereitet.',
                es: 'Conectado como ${activeAccount.emailAddress}. El acceso de solo lectura a $providerLabel esta preparado para el escaneo.',
              ),
            ),
          ),
        ],
        if (!appState.hasPremiumFeatureAccess) ...[
          const SizedBox(height: BizootSpacing.md),
          AppCard(
            child: Text(
              localeText(
                context,
                en: 'You are on the free plan, so Bizoot will preview only the imports that still fit under the 5 active-subscription limit.',
                da: 'Du er pa gratisplanen, sa Bizoot viser kun de importer, der stadig passer inden for graensen pa 5 aktive abonnementer.',
                de: 'Du nutzt den kostenlosen Plan, daher zeigt Bizoot nur die Importe, die noch innerhalb des Limits von 5 aktiven Abonnements liegen.',
                es: 'Estas en el plan gratuito, asi que Bizoot mostrara solo las importaciones que aun quepan dentro del limite de 5 suscripciones activas.',
              ),
            ),
          ),
        ],
        const SizedBox(height: BizootSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Back',
                  da: 'Tilbage',
                  de: 'ZurÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ck',
                  es: 'AtrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡s',
                ),
                secondary: true,
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    setState(() => _step = _ImportFlowStep.provider),
              ),
            ),
            const SizedBox(width: BizootSpacing.sm),
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Start scan',
                  da: 'Start scanning',
                  de: 'Scan starten',
                  es: 'Iniciar escaneo',
                ),
                icon: Icons.shield_outlined,
                onPressed: hasConnection ? () => _startScan(appState) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scanningStep(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localeText(
            context,
            en: 'Preparing your import preview',
            da: 'Forbereder din importforhÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥ndsvisning',
            de: 'Bereite deine Importvorschau vor',
            es: 'Preparando tu vista previa de importaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n',
          ),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: BizootSpacing.sm),
        Text(
          _status,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
        ),
        const SizedBox(height: BizootSpacing.lg),
        LinearProgressIndicator(
          value: _progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    ),
  );

  Widget _reviewStep(BuildContext context) {
    final appState = context.read<AppState>();
    final eligibleItems = _items
        .where(_isEligibleForImport)
        .toList(growable: false);
    final selectedCount = _items
        .where(
          (item) =>
              _selectedIds.contains(item.id) && _isEligibleForImport(item),
        )
        .length;
    final lockedCount = _items.where((item) => item.locked).length;
    final duplicateCount = _items.where((item) => item.duplicate).length;
    final skippedCount = _items.where((item) => item.skipped).length;
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeText(
                  context,
                  en: 'Review detected subscriptions',
                  da: 'Gennemga fundne abonnementer',
                  de: 'Erkannte Abonnements prÃ¼fen',
                  es: 'Revisar suscripciones detectadas',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: BizootSpacing.xs),
              Text(
                localeText(
                  context,
                  en: 'Nothing is added until you confirm. Review each item, edit details if needed, and choose what should import.',
                  da: 'Intet bliver tilfÃ¸jet, fÃ¸r du bekrÃ¦fter. GennemgÃ¥ hver post, ret detaljer ved behov, og vÃ¦lg hvad der skal importeres.',
                  de: 'Es wird nichts hinzugefÃ¼gt, bis du bestÃ¤tigst. PrÃ¼fe jeden Eintrag, passe Details bei Bedarf an und wÃ¤hle aus, was importiert werden soll.',
                  es: 'No se aÃ±ade nada hasta que confirmes. Revisa cada elemento, ajusta los detalles si hace falta y decide quÃ© debe importarse.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BizootColors.textSecondary,
                ),
              ),
              const SizedBox(height: BizootSpacing.sm),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryPill(
                    label: localeText(
                      context,
                      en: 'Selected',
                      da: 'Valgt',
                      de: 'AusgewÃ¤hlt',
                      es: 'Seleccionado',
                    ),
                    value: '$selectedCount',
                    color: BizootColors.success,
                  ),
                  _SummaryPill(
                    label: localeText(
                      context,
                      en: 'Ready',
                      da: 'Klar',
                      de: 'Bereit',
                      es: 'Listo',
                    ),
                    value: '${eligibleItems.length}',
                    color: BizootColors.primary,
                  ),
                  if (duplicateCount > 0)
                    _SummaryPill(
                      label: localeText(
                        context,
                        en: 'Duplicates',
                        da: 'Duplikater',
                        de: 'Duplikate',
                        es: 'Duplicados',
                      ),
                      value: '$duplicateCount',
                      color: BizootColors.yellow,
                    ),
                  if (skippedCount > 0)
                    _SummaryPill(
                      label: localeText(
                        context,
                        en: 'Skipped',
                        da: 'Sprunget over',
                        de: 'Ãœbersprungen',
                        es: 'Omitidos',
                      ),
                      value: '$skippedCount',
                      color: BizootColors.textMuted,
                    ),
                  if (lockedCount > 0)
                    _SummaryPill(
                      label: localeText(
                        context,
                        en: 'Locked',
                        da: 'LÃ¥st',
                        de: 'Gesperrt',
                        es: 'Bloqueado',
                      ),
                      value: '$lockedCount',
                      color: BizootColors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
        if (lockedCount > 0 && !appState.hasPremiumFeatureAccess) ...[
          const SizedBox(height: BizootSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Unlock the full import list',
                    da: 'LÃ¥s hele importlisten op',
                    de: 'VollstÃ¤ndige Importliste freischalten',
                    es: 'Desbloquea la lista completa de importaciÃ³n',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: BizootSpacing.xs),
                Text(
                  localeText(
                    context,
                    en: 'Free stays capped at 5 active subscriptions total. Upgrade to review and import the remaining $lockedCount detected subscriptions.',
                    da: 'Gratis forbliver begranset til 5 aktive abonnementer i alt. Opgrader for at gennemga og importere de resterende $lockedCount fundne abonnementer.',
                    de: 'Der Gratisplan bleibt auf insgesamt 5 aktive Abonnements begrenzt. Upgrade, um die verbleibenden $lockedCount erkannten Abonnements zu prufen und zu importieren.',
                    es: 'El plan gratis sigue limitado a 5 suscripciones activas en total. Mejora para revisar e importar las $lockedCount suscripciones detectadas restantes.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BizootSpacing.sm),
                AppButton(
                  label: localeText(
                    context,
                    en: 'Upgrade to Premium',
                    da: 'Opgrader til Premium',
                    de: 'Auf Premium upgraden',
                    es: 'Mejorar a Premium',
                  ),
                  icon: Icons.workspace_premium_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: BizootSpacing.md),
        ..._items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: BizootSpacing.sm),
            child: _ReviewCard(
              item: item,
              selected:
                  _selectedIds.contains(item.id) && _isEligibleForImport(item),
              onChanged: item.locked || item.duplicate || item.skipped
                  ? null
                  : (value) => setState(
                      () => value
                          ? _selectedIds.add(item.id)
                          : _selectedIds.remove(item.id),
                    ),
              onEdit: item.locked ? null : () => _editItem(item),
              onSkip: item.locked ? null : () => _toggleSkip(item),
              onMarkDuplicate: item.locked
                  ? null
                  : () => _toggleDuplicate(item),
            ),
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Back',
                  da: 'Tilbage',
                  de: 'Zuruck',
                  es: 'Atras',
                ),
                secondary: true,
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    setState(() => _step = _ImportFlowStep.consent),
              ),
            ),
            const SizedBox(width: BizootSpacing.sm),
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Continue',
                  da: 'Fortsat',
                  de: 'Weiter',
                  es: 'Continuar',
                ),
                icon: Icons.arrow_forward_rounded,
                onPressed: selectedCount == 0
                    ? null
                    : () => setState(() => _step = _ImportFlowStep.confirm),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _confirmStep(BuildContext context, AppState appState) {
    final selected = _items
        .where(
          (item) =>
              _selectedIds.contains(item.id) && _isEligibleForImport(item),
        )
        .toList(growable: false);
    return Column(
      children: [
        ..._items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: BizootSpacing.sm),
            child: _ReviewCard(
              item: item,
              selected:
                  _selectedIds.contains(item.id) && _isEligibleForImport(item),
              onChanged: item.locked || item.duplicate || item.skipped
                  ? null
                  : (value) => setState(
                      () => value
                          ? _selectedIds.add(item.id)
                          : _selectedIds.remove(item.id),
                    ),
              onEdit: item.locked ? null : () => _editItem(item),
              onSkip: item.locked ? null : () => _toggleSkip(item),
              onMarkDuplicate: item.locked
                  ? null
                  : () => _toggleDuplicate(item),
            ),
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Back',
                  da: 'Tilbage',
                  de: 'ZurÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ck',
                  es: 'AtrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡s',
                ),
                secondary: true,
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    setState(() => _step = _ImportFlowStep.consent),
              ),
            ),
            const SizedBox(width: BizootSpacing.sm),
            Expanded(
              child: AppButton(
                label: localeText(
                  context,
                  en: 'Continue',
                  da: 'FortsÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¦t',
                  de: 'Weiter',
                  es: 'Continuar',
                ),
                icon: Icons.arrow_forward_rounded,
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () => setState(() => _step = _ImportFlowStep.confirm),
              ),
            ),
          ],
        ),
        if (_step == _ImportFlowStep.confirm) ...[
          const SizedBox(height: BizootSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Ready to import ${selected.length} items',
                    da: 'Klar til at importere ${selected.length} poster',
                    de: 'Bereit, ${selected.length} EintrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤ge zu importieren',
                    es: 'Listo para importar ${selected.length} elementos',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: BizootSpacing.sm),
                ...selected.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        BrandServiceIcon(
                          serviceName: item.name,
                          serviceId: item.iconKey,
                          category: item.category.displayLabel,
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: BizootColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Text(
                          formatCurrency(item.amount, item.currency),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: BizootColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: localeText(
                    context,
                    en: 'Review again',
                    da: 'GennemgÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¥ igen',
                    de: 'Erneut prÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼fen',
                    es: 'Revisar de nuevo',
                  ),
                  secondary: true,
                  icon: Icons.arrow_back_rounded,
                  onPressed: _isImporting
                      ? null
                      : () => setState(() => _step = _ImportFlowStep.review),
                ),
              ),
              const SizedBox(width: BizootSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _isImporting
                      ? localeText(
                          context,
                          en: 'Importing...',
                          da: 'Importerer...',
                          de: 'Importiere...',
                          es: 'Importando...',
                        )
                      : localeText(
                          context,
                          en: 'Import now',
                          da: 'Importer nu',
                          de: 'Jetzt importieren',
                          es: 'Importar ahora',
                        ),
                  icon: Icons.download_done_rounded,
                  isLoading: _isImporting,
                  onPressed: _isImporting
                      ? null
                      : () => _importSelected(appState),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _startScan(AppState appState) async {
    final provider = _provider;
    if (provider == null) return;
    setState(() {
      _step = _ImportFlowStep.scanning;
      _status = localeText(
        context,
        en: 'Connecting your import pipeline...',
        da: 'Forbinder din importpipeline...',
        de: 'Verbinde deine Import-Pipeline...',
        es: 'Conectando tu flujo de importacion...',
      );
      _progress = 0.18;
    });
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      setState(() {
        _status = localeText(
          context,
          en: 'Reviewing relevant billing emails from the last year...',
          da: 'Gennemgar relevante betalingsmails fra det sidste ar...',
          de: 'Prufe relevante Abrechnungs-E-Mails aus dem letzten Jahr...',
          es: 'Revisando correos de facturacion relevantes del ultimo ano...',
        );
        _progress = 0.54;
      });

      final account = provider == ConnectedEmailProvider.gmail
          ? appState.gmailImportAccount
          : appState.outlookImportAccount;
      if (account == null) {
        throw StateError(
          provider == ConnectedEmailProvider.gmail
              ? 'gmail_not_connected'
              : 'outlook_not_connected',
        );
      }
      final review = await appState.prepareEmailImportReview(account: account);
      final nextItems = review.reviewItems
          .map(_draftFromReviewItem)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _status = localeText(
          context,
          en: 'Matching services, amounts, and renewal clues...',
          da: 'Matcher tjenester, belob og fornyelsessignaler...',
          de: 'Ordne Dienste, Betrage und Verlangerungshinweise zu...',
          es: 'Relacionando servicios, importes y senales de renovacion...',
        );
        _progress = 0.88;
        _items
          ..clear()
          ..addAll(nextItems);
        _selectedIds
          ..clear()
          ..addAll(
            _items
                .where((item) => !item.locked && !item.duplicate)
                .map((item) => item.id),
          );
        _step = _ImportFlowStep.review;
      });
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not prepare the email import preview right now. Please try again.',
          da: 'Vi kunne ikke klargore Gmail-importforhandsvisningen lige nu. Prov igen.',
          de: 'Die Gmail-Importvorschau konnte gerade nicht vorbereitet werden. Bitte versuche es erneut.',
          es: 'No pudimos preparar la vista previa de importacion de Gmail en este momento. Intentalo de nuevo.',
        ),
      );
      setState(() => _step = _ImportFlowStep.consent);
    }
  }

  Future<void> _importSelected(AppState appState) async {
    final selected = _items
        .where(
          (item) =>
              _selectedIds.contains(item.id) && _isEligibleForImport(item),
        )
        .toList(growable: false);
    if (selected.isEmpty) {
      return;
    }
    setState(() => _isImporting = true);
    try {
      final importedCount = await appState.importPayments(
        selected
            .map((item) => item.toPayment(appState.settings.userId))
            .toList(growable: false),
        rememberAsCustomPaymentIds: selected
            .where((item) => item.rememberAsCustom)
            .map((item) => item.id)
            .toSet(),
      );
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: '$importedCount subscriptions were added to Bizoot.',
          da: '$importedCount abonnementer blev tilfojet til Bizoot.',
          de: '$importedCount Abonnements wurden zu Bizoot hinzugefugt.',
          es: 'Se anadieron $importedCount suscripciones a Bizoot.',
        ),
      );
      Navigator.of(context).pop();
    } on StateError catch (error) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        error.message == 'subscription_limit_reached'
            ? localeText(
                context,
                en: 'Your current plan does not have enough room for all selected imports. Upgrade or import fewer items.',
                da: 'Din nuvaerende plan har ikke plads til alle valgte importer. Opgrader eller importer faerre poster.',
                de: 'Dein aktueller Plan hat nicht genug Platz fur alle ausgewahlten Importe. Upgrade oder importiere weniger Eintrage.',
                es: 'Tu plan actual no tiene espacio suficiente para todas las importaciones seleccionadas. Mejora el plan o importa menos elementos.',
              )
            : localeText(
                context,
                en: 'We could not import these items right now. Please try again.',
                da: 'Vi kunne ikke importere disse poster lige nu. Prov igen.',
                de: 'Diese Eintrage konnten gerade nicht importiert werden. Bitte versuche es erneut.',
                es: 'No pudimos importar estos elementos ahora mismo. Intentalo de nuevo.',
              ),
      );
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not import these items right now. Please try again.',
          da: 'Vi kunne ikke importere disse poster lige nu. Prov igen.',
          de: 'Diese Eintrage konnten gerade nicht importiert werden. Bitte versuche es erneut.',
          es: 'No pudimos importar estos elementos ahora mismo. Intentalo de nuevo.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  bool _isEligibleForImport(_DetectedDraft item) =>
      !item.locked && !item.duplicate && !item.skipped;

  void _replaceItem(_DetectedDraft nextItem) {
    final index = _items.indexWhere((item) => item.id == nextItem.id);
    if (index == -1) return;
    _items[index] = nextItem;
  }

  void _toggleSkip(_DetectedDraft item) {
    setState(() {
      final nextItem = item.copyWith(skipped: !item.skipped);
      if (nextItem.skipped) {
        _selectedIds.remove(item.id);
      } else if (_isEligibleForImport(nextItem)) {
        _selectedIds.add(item.id);
      }
      _replaceItem(nextItem);
    });
  }

  void _toggleDuplicate(_DetectedDraft item) {
    setState(() {
      final nextItem = item.copyWith(
        duplicate: !item.duplicate,
        skipped: false,
      );
      if (nextItem.duplicate) {
        _selectedIds.remove(item.id);
      } else if (_isEligibleForImport(nextItem)) {
        _selectedIds.add(item.id);
      }
      _replaceItem(nextItem);
    });
  }

  Future<void> _editItem(_DetectedDraft item) async {
    final nameController = TextEditingController(text: item.name);
    final amountController = TextEditingController(
      text: item.amount == 0 ? '' : item.amount.toStringAsFixed(2),
    );
    var selectedCategory = item.category;
    final updated = await showModalBottomSheet<_DetectedDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeText(
                        context,
                        en: 'Edit detected subscription',
                        da: 'Rediger fundet abonnement',
                        de: 'Erkanntes Abonnement bearbeiten',
                        es: 'Editar suscripciÃ³n detectada',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: BizootSpacing.sm),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: localeText(
                          context,
                          en: 'Service name',
                          da: 'Tjenestenavn',
                          de: 'Dienstname',
                          es: 'Nombre del servicio',
                        ),
                      ),
                    ),
                    const SizedBox(height: BizootSpacing.sm),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: localeText(
                          context,
                          en: 'Amount',
                          da: 'Belob',
                          de: 'Betrag',
                          es: 'Importe',
                        ),
                      ),
                    ),
                    const SizedBox(height: BizootSpacing.sm),
                    DropdownButtonFormField<PaymentCategory>(
                      initialValue: selectedCategory,
                      items: PaymentCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.displayLabel),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedCategory = value);
                      },
                      decoration: InputDecoration(
                        labelText: localeText(
                          context,
                          en: 'Category',
                          da: 'Kategori',
                          de: 'Kategorie',
                          es: 'CategorÃ­a',
                        ),
                      ),
                    ),
                    const SizedBox(height: BizootSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: localeText(
                              context,
                              en: 'Cancel',
                              da: 'Annuller',
                              de: 'Abbrechen',
                              es: 'Cancelar',
                            ),
                            secondary: true,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: BizootSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: localeText(
                              context,
                              en: 'Save changes',
                              da: 'Gem Ã¦ndringer',
                              de: 'Ã„nderungen speichern',
                              es: 'Guardar cambios',
                            ),
                            onPressed: () {
                              final parsedAmount = double.tryParse(
                                amountController.text.trim().replaceAll(
                                  ',',
                                  '.',
                                ),
                              );
                              final nextName =
                                  nameController.text.trim().isEmpty
                                  ? item.name
                                  : nameController.text.trim();
                              final nextAmount = parsedAmount ?? item.amount;
                              Navigator.of(context).pop(
                                item.copyWith(
                                  name: nextName,
                                  amount: nextAmount,
                                  category: selectedCategory,
                                  duplicate: false,
                                  skipped: false,
                                  paymentOverride: item.paymentOverride
                                      ?.copyWith(
                                        name: nextName,
                                        providerName: nextName,
                                        amount: nextAmount,
                                        category: selectedCategory,
                                        iconKey: item.iconKey,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    nameController.dispose();
    amountController.dispose();
    if (updated == null) return;
    setState(() {
      _replaceItem(updated);
      if (_isEligibleForImport(updated)) {
        _selectedIds.add(updated.id);
      }
    });
  }

  _DetectedDraft _draftFromReviewItem(ImportReviewItem item) {
    final draft = item.paymentDraft;
    final fallbackIcon =
        item.candidate.providerSlugHint ??
        item.candidate.iconHint ??
        item.candidate.matchedCanonicalName ??
        item.candidate.serviceName;
    return _DetectedDraft(
      id: item.id,
      name:
          draft?.name ??
          item.candidate.matchedCanonicalName ??
          item.candidate.serviceName,
      amount: draft?.amount ?? item.candidate.amount ?? 0,
      currency: draft?.currency ?? item.candidate.currency,
      category:
          draft?.category ??
          item.candidate.category ??
          PaymentCategory.subscription,
      iconKey: (draft?.iconKey.isNotEmpty ?? false)
          ? draft!.iconKey
          : fallbackIcon,
      note: item.isLockedByPlan
          ? localeText(
              context,
              en: 'Locked by your current plan. Upgrade to import this detected subscription.',
              da: 'Last af din nuvaerende plan. Opgrader for at importere dette fundne abonnement.',
              de: 'Durch deinen aktuellen Plan gesperrt. Upgrade, um dieses erkannte Abonnement zu importieren.',
              es: 'Bloqueado por tu plan actual. Mejora para importar esta suscripcion detectada.',
            )
          : item.reviewNote ??
                localeText(
                  context,
                  en: 'Detected from recent billing email activity.',
                  da: 'Registreret fra nyere e-mailaktivitet omkring betalinger.',
                  de: 'Aus aktueller E-Mail-Abrechnungsaktivitat erkannt.',
                  es: 'Detectado a partir de actividad reciente de facturacion por correo.',
                ),
      duplicate: item.isDuplicate,
      locked: item.isLockedByPlan,
      skipped: item.status == ImportReviewStatus.skipped,
      rememberAsCustom: !item.candidate.hasStrongMatch,
      paymentOverride: draft,
    );
  }

  // ignore: unused_element
  List<_DetectedDraft> _previewItems(
    AppState appState,
    ConnectedEmailProvider provider,
  ) {
    final currency = appState.settings.currency.trim().toUpperCase().isEmpty
        ? 'USD'
        : appState.settings.currency.trim().toUpperCase();
    final free = !appState.hasPremiumFeatureAccess;
    final samples = [
      ['Netflix', 19.99, PaymentCategory.subscription, 'netflix'],
      ['Spotify', 17.99, PaymentCategory.subscription, 'spotify'],
      ['YouTube Premium', 13.99, PaymentCategory.subscription, 'youtube'],
      ['Canva Pro', 12.99, PaymentCategory.subscription, 'canva'],
      ['Google One', 9.99, PaymentCategory.subscription, 'googleone'],
      ['House Rent', 1450.0, PaymentCategory.rent, 'houserent'],
      [
        'Adobe Creative Cloud Trial',
        59.99,
        PaymentCategory.subscription,
        'adobe',
      ],
    ];
    return samples
        .asMap()
        .entries
        .map((entry) {
          final name = entry.value[0] as String;
          final amount = entry.value[1] as double;
          final category = entry.value[2] as PaymentCategory;
          final iconKey = entry.value[3] as String;
          final duplicate = appState.payments.any(
            (item) => _normalize(item.name) == _normalize(name),
          );
          return _DetectedDraft(
            id: 'draft-${provider.name}-${entry.key}',
            name: name,
            amount: amount,
            currency: currency,
            category: category,
            iconKey: iconKey,
            note: duplicate
                ? localeText(
                    context,
                    en: 'Already tracked in Bizoot.',
                    da: 'Allerede sporet i Bizoot.',
                    de: 'Bereits in Bizoot erfasst.',
                    es: 'Ya se estÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ siguiendo en Bizoot.',
                  )
                : localeText(
                    context,
                    en: 'Detected from recent billing email activity.',
                    da: 'Registreret fra nyere e-mailaktivitet omkring betalinger.',
                    de: 'Aus aktueller E-Mail-AbrechnungsaktivitÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¤t erkannt.',
                    es: 'Detectado a partir de actividad reciente de facturaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n por correo.',
                  ),
            duplicate: duplicate,
            locked: free && entry.key >= 5,
            skipped: false,
          );
        })
        .toList(growable: false);
  }

  Widget _bullet(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: BizootColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );

  // ignore: unused_element
  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String? _localizedAccountErrorMessage(
    BuildContext context,
    ConnectedEmailAccount? account,
  ) {
    if (account == null) return null;
    final message = account.errorMessage;
    if (message == null || message.trim().isEmpty) {
      return null;
    }

    final providerName = account.provider == ConnectedEmailProvider.gmail
        ? 'Gmail'
        : 'Outlook';
    return localeText(
      context,
      en: '$providerName needs to be reconnected before Bizoot can scan this inbox.',
      da: '$providerName skal forbindes igen, for Bizoot kan scanne denne indbakke.',
      de: '$providerName muss erneut verbunden werden, bevor Bizoot dieses Postfach scannen kann.',
      es: 'Hay que volver a conectar $providerName antes de que Bizoot pueda escanear esta bandeja.',
    );
  }
}

class _ProviderChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ProviderChoice({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BizootColors.surfaceElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? color : BizootColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.38)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? color : BizootColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _DetectedDraft item;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onSkip;
  final VoidCallback? onMarkDuplicate;
  const _ReviewCard({
    required this.item,
    required this.selected,
    required this.onChanged,
    required this.onEdit,
    required this.onSkip,
    required this.onMarkDuplicate,
  });
  @override
  Widget build(BuildContext context) {
    final color = item.locked
        ? BizootColors.orange
        : item.skipped
        ? BizootColors.textMuted
        : item.duplicate
        ? BizootColors.yellow
        : BizootColors.success;
    final label = item.locked
        ? localeText(
            context,
            en: 'Premium',
            da: 'Premium',
            de: 'Premium',
            es: 'Premium',
          )
        : item.skipped
        ? localeText(
            context,
            en: 'Skipped',
            da: 'Sprunget over',
            de: 'Ãœbersprungen',
            es: 'Omitido',
          )
        : item.duplicate
        ? localeText(
            context,
            en: 'Duplicate',
            da: 'Duplikat',
            de: 'Duplikat',
            es: 'Duplicado',
          )
        : localeText(
            context,
            en: 'Ready',
            da: 'Klar',
            de: 'Bereit',
            es: 'Listo',
          );
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandServiceIcon(
            serviceName: item.name,
            serviceId: item.iconKey,
            category: item.category.displayLabel,
            size: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: BizootColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(item.amount, item.currency),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withValues(alpha: 0.42)),
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InlineActionChip(
                      label: localeText(
                        context,
                        en: 'Edit',
                        da: 'Rediger',
                        de: 'Bearbeiten',
                        es: 'Editar',
                      ),
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                    _InlineActionChip(
                      label: item.skipped
                          ? localeText(
                              context,
                              en: 'Restore',
                              da: 'Gendan',
                              de: 'Wiederherstellen',
                              es: 'Restaurar',
                            )
                          : localeText(
                              context,
                              en: 'Skip',
                              da: 'Spring over',
                              de: 'Ãœberspringen',
                              es: 'Omitir',
                            ),
                      icon: item.skipped
                          ? Icons.undo_rounded
                          : Icons.skip_next_rounded,
                      onTap: onSkip,
                    ),
                    _InlineActionChip(
                      label: item.duplicate
                          ? localeText(
                              context,
                              en: 'Unmark duplicate',
                              da: 'Fjern duplikat',
                              de: 'Duplikat entfernen',
                              es: 'Quitar duplicado',
                            )
                          : localeText(
                              context,
                              en: 'Mark duplicate',
                              da: 'Marker som duplikat',
                              de: 'Als Duplikat markieren',
                              es: 'Marcar duplicado',
                            ),
                      icon: Icons.copy_all_rounded,
                      onTap: onMarkDuplicate,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: item.locked || item.duplicate || item.skipped
                ? false
                : selected,
            onChanged: onChanged == null
                ? null
                : (value) => onChanged!(value ?? false),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _InlineActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BizootColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: BizootColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectedDraft {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final PaymentCategory category;
  final String iconKey;
  final String note;
  final bool duplicate;
  final bool locked;
  final bool skipped;
  final bool rememberAsCustom;
  final RecurringPayment? paymentOverride;
  const _DetectedDraft({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.category,
    required this.iconKey,
    required this.note,
    required this.duplicate,
    required this.locked,
    required this.skipped,
    this.rememberAsCustom = false,
    this.paymentOverride,
  });

  _DetectedDraft copyWith({
    String? id,
    String? name,
    double? amount,
    String? currency,
    PaymentCategory? category,
    String? iconKey,
    String? note,
    bool? duplicate,
    bool? locked,
    bool? skipped,
    bool? rememberAsCustom,
    RecurringPayment? paymentOverride,
  }) {
    return _DetectedDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      note: note ?? this.note,
      duplicate: duplicate ?? this.duplicate,
      locked: locked ?? this.locked,
      skipped: skipped ?? this.skipped,
      rememberAsCustom: rememberAsCustom ?? this.rememberAsCustom,
      paymentOverride: paymentOverride ?? this.paymentOverride,
    );
  }

  RecurringPayment toPayment(String userId) =>
      paymentOverride?.copyWith(id: id, userId: userId) ??
      RecurringPayment(
        id: id,
        userId: userId,
        name: name,
        providerName: name,
        amount: amount,
        currency: currency,
        category: category,
        frequency: PaymentFrequency.monthly,
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        renewalDate: null,
        contractEndDate: null,
        reminderEnabled: true,
        reminderTiming: ReminderTiming.oneDayBefore,
        status: PaymentStatus.active,
        isTrial: name.toLowerCase().contains('trial'),
        trialEndDate: name.toLowerCase().contains('trial')
            ? DateTime.now().add(const Duration(days: 7))
            : null,
        trialReminderEnabled: name.toLowerCase().contains('trial'),
        convertsToPaidAmount: amount,
        trialNotes: '',
        cancellationUrl: '',
        managementUrl: '',
        cancellationNotes: '',
        loginEmail: '',
        username: '',
        signInMethod: SignInMethod.email,
        passwordHint: '',
        recoveryEmail: '',
        accountNotes: note,
        policyNumber: '',
        documentLabel: '',
        isEssential: category != PaymentCategory.subscription,
        isCancellable:
            category != PaymentCategory.rent &&
            category != PaymentCategory.loan,
        cancellationStatus: CancellationStatus.active,
        cancelledAt: null,
        iconKey: iconKey,
        priceHistory: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}

