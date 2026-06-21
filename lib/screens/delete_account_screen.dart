import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../widgets/app_button.dart';
import '../widgets/legal_screen_shell.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleting = false;

  Future<void> _confirmDelete(AppState appState) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              localeText(
                context,
                en: 'Delete Bizoot account?',
                da: 'Slette Bizoot-kontoen?',
                de: 'Bizoot-Konto loeschen?',
                es: 'Eliminar la cuenta de Bizoot?',
              ),
            ),
            content: Text(
              localeText(
                context,
                en: 'This flow will delete your Bizoot data, clear cached device data, and sign you out.',
                da: 'Denne handling sletter dine Bizoot-data, rydder cachede enhedsdata og logger dig ud.',
                de: 'Dieser Vorgang loescht deine Bizoot-Daten, entfernt zwischengespeicherte Geraetedaten und meldet dich ab.',
                es: 'Este proceso eliminara tus datos de Bizoot, borrara los datos en cache del dispositivo y cerrara tu sesion.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localeText(
                    context,
                    en: 'Keep account',
                    da: 'Behold kontoen',
                    de: 'Konto behalten',
                    es: 'Conservar la cuenta',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localeText(
                    context,
                    en: 'Delete account',
                    da: 'Slet konto',
                    de: 'Konto loeschen',
                    es: 'Eliminar cuenta',
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await appState.deleteAccountPlaceholder();
      if (!mounted) return;
      AppHaptics.delete();
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Account data removed and signed out successfully.',
          da: 'Kontodata blev fjernet, og du er nu logget ud.',
          de: 'Kontodaten wurden entfernt und du wurdest erfolgreich abgemeldet.',
          es: 'Los datos de la cuenta se eliminaron y la sesion se cerro correctamente.',
        ),
        icon: Icons.delete_forever_outlined,
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not finish deleting your account right now.',
          da: 'Vi kunne ikke fuldfoere sletningen af din konto lige nu.',
          de: 'Wir konnten das Loeschen deines Kontos gerade nicht abschliessen.',
          es: 'No pudimos completar la eliminacion de tu cuenta en este momento.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return LegalScreenShell(
      title: localeText(
        context,
        en: 'Delete Account',
        da: 'Slet konto',
        de: 'Konto loeschen',
        es: 'Eliminar cuenta',
      ),
      subtitle: localeText(
        context,
        en: 'Review what happens before permanently removing access to Bizoot.',
        da: 'Se, hvad der sker, foer adgangen til Bizoot fjernes permanent.',
        de: 'Pruefe, was passiert, bevor der Zugang zu Bizoot dauerhaft entfernt wird.',
        es: 'Revisa lo que ocurrira antes de eliminar permanentemente el acceso a Bizoot.',
      ),
      icon: Icons.person_remove_outlined,
      children: [
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Important warning',
            da: 'Vigtig advarsel',
            de: 'Wichtiger Hinweis',
            es: 'Aviso importante',
          ),
          body: localeText(
            context,
            en: 'Deleting your account removes your saved payments, settings, notification preferences, and custom services from Bizoot storage.',
            da: 'Hvis du sletter din konto, fjernes gemte betalinger, indstillinger, notifikationsvalg og brugerdefinerede tjenester fra Bizoot.',
            de: 'Beim Loeschen deines Kontos werden gespeicherte Zahlungen, Einstellungen, Benachrichtigungspraeferenzen und benutzerdefinierte Dienste aus Bizoot entfernt.',
            es: 'Al eliminar tu cuenta se quitaran de Bizoot los pagos guardados, ajustes, preferencias de notificacion y servicios personalizados.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'What this flow does today',
            da: 'Hvad denne handling goer i dag',
            de: 'Was dieser Ablauf heute macht',
            es: 'Que hace este proceso hoy',
          ),
          body: localeText(
            context,
            en: 'The current flow deletes your Bizoot data, cancels local notifications, clears cached payment state from this device, and signs you out safely.',
            da: 'Den nuvaerende handling sletter dine Bizoot-data, annullerer lokale notifikationer, rydder cachede betalingsdata fra denne enhed og logger dig sikkert ud.',
            de: 'Der aktuelle Ablauf loescht deine Bizoot-Daten, entfernt lokale Benachrichtigungen, leert zwischengespeicherte Zahlungsdaten auf diesem Geraet und meldet dich sicher ab.',
            es: 'El flujo actual elimina tus datos de Bizoot, cancela las notificaciones locales, borra el estado de pagos en cache de este dispositivo y cierra tu sesion de forma segura.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Before you continue',
            da: 'Foer du fortsaetter',
            de: 'Bevor du fortfaehrst',
            es: 'Antes de continuar',
          ),
          body: localeText(
            context,
            en: 'Make sure you really want to remove your account and all connected Bizoot data from this app experience.',
            da: 'Soerg for, at du virkelig vil fjerne din konto og alle tilknyttede Bizoot-data fra appoplevelsen.',
            de: 'Stelle sicher, dass du dein Konto und alle verbundenen Bizoot-Daten wirklich aus dieser App-Erfahrung entfernen moechtest.',
            es: 'Asegurate de que realmente quieres eliminar tu cuenta y todos los datos de Bizoot relacionados con esta experiencia de la app.',
          ),
        ),
        LegalSectionCard(
          title: localeText(
            context,
            en: 'Delete account',
            da: 'Slet konto',
            de: 'Konto loeschen',
            es: 'Eliminar cuenta',
          ),
          body: localeText(
            context,
            en: 'Signed in as ${appState.authService.currentUser?.email ?? 'your Bizoot account'}.',
            da: 'Logget ind som ${appState.authService.currentUser?.email ?? 'din Bizoot-konto'}.',
            de: 'Angemeldet als ${appState.authService.currentUser?.email ?? 'dein Bizoot-Konto'}.',
            es: 'Has iniciado sesion como ${appState.authService.currentUser?.email ?? 'tu cuenta de Bizoot'}.',
          ),
          footer: [
            AppButton(
              label: _isDeleting
                  ? localeText(
                      context,
                      en: 'Deleting...',
                      da: 'Sletter...',
                      de: 'Wird geloescht...',
                      es: 'Eliminando...',
                    )
                  : localeText(
                      context,
                      en: 'Delete account',
                      da: 'Slet konto',
                      de: 'Konto loeschen',
                      es: 'Eliminar cuenta',
                    ),
              icon: Icons.delete_forever_outlined,
              isLoading: _isDeleting,
              onPressed: _isDeleting ? null : () => _confirmDelete(appState),
            ),
          ],
        ),
      ],
    );
  }
}
