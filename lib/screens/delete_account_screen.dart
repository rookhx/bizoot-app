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
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(AppState appState) async {
    _passwordController.clear();
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'This permanently deletes your Bizoot account and all of its data. It cannot be undone. Enter your password to confirm.',
                    da: 'Dette sletter permanent din Bizoot-konto og alle dens data. Det kan ikke fortrydes. Indtast din adgangskode for at bekraefte.',
                    de: 'Dies loescht dein Bizoot-Konto und alle zugehoerigen Daten dauerhaft. Es kann nicht rueckgaengig gemacht werden. Gib dein Passwort ein, um zu bestaetigen.',
                    es: 'Esto elimina permanentemente tu cuenta de Bizoot y todos sus datos. No se puede deshacer. Introduce tu contrasena para confirmar.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Password',
                      da: 'Adgangskode',
                      de: 'Passwort',
                      es: 'Contrasena',
                    ),
                  ),
                ),
              ],
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

    final password = _passwordController.text;
    if (password.isEmpty) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'Enter your password to confirm deletion.',
          da: 'Indtast din adgangskode for at bekraefte sletningen.',
          de: 'Gib dein Passwort ein, um die Loeschung zu bestaetigen.',
          es: 'Introduce tu contrasena para confirmar la eliminacion.',
        ),
      );
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await appState.deleteAccount(password);
      if (!mounted) return;
      AppHaptics.delete();
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Your account and all of its data have been deleted.',
          da: 'Din konto og alle dens data er blevet slettet.',
          de: 'Dein Konto und alle zugehoerigen Daten wurden geloescht.',
          es: 'Tu cuenta y todos sus datos se han eliminado.',
        ),
        icon: Icons.delete_forever_outlined,
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _passwordController.clear();
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
            en: 'This permanently deletes your Bizoot account, removes your data, cancels local notifications, and clears cached payment state from this device. It cannot be undone.',
            da: 'Dette sletter permanent din Bizoot-konto, fjerner dine data, annullerer lokale notifikationer og rydder cachede betalingsdata fra denne enhed. Det kan ikke fortrydes.',
            de: 'Dies loescht dein Bizoot-Konto dauerhaft, entfernt deine Daten, bricht lokale Benachrichtigungen ab und leert zwischengespeicherte Zahlungsdaten auf diesem Geraet. Es kann nicht rueckgaengig gemacht werden.',
            es: 'Esto elimina permanentemente tu cuenta de Bizoot, borra tus datos, cancela las notificaciones locales y limpia el estado de pagos en cache de este dispositivo. No se puede deshacer.',
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
