import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../services/app_state.dart';
import '../services/brand_icon_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand_icon.dart';
import '../widgets/document_card.dart';
import '../widgets/payment_form.dart';
import '../widgets/premium_lock_card.dart';
import 'document_viewer_screen.dart';
import 'paywall_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final RecurringPayment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _providerNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _cancellationUrlController;
  late final TextEditingController _managementUrlController;
  late final TextEditingController _cancellationNotesController;
  late final TextEditingController _trialNotesController;
  late final TextEditingController _convertsToPaidController;
  late final TextEditingController _loginEmailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordHintController;
  late final TextEditingController _recoveryEmailController;
  late final TextEditingController _accountNotesController;
  late final TextEditingController _policyNumberController;
  late final TextEditingController _documentLabelController;
  late PaymentCategory _category;
  late PaymentFrequency _frequency;
  late ReminderTiming _reminderTiming;
  late PaymentStatus _status;
  late CancellationStatus _cancellationStatus;
  late SignInMethod _signInMethod;
  late DateTime _nextDueDate;
  late DateTime? _renewalDate;
  late DateTime? _contractEndDate;
  late DateTime? _trialEndDate;
  late bool _reminderEnabled;
  late bool _isTrial;
  late bool _trialReminderEnabled;
  String? _duplicateWarning;
  bool _showPasswordHint = false;

  @override
  void dispose() {
    _nameController.dispose();
    _providerNameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _cancellationUrlController.dispose();
    _managementUrlController.dispose();
    _cancellationNotesController.dispose();
    _trialNotesController.dispose();
    _convertsToPaidController.dispose();
    _loginEmailController.dispose();
    _usernameController.dispose();
    _passwordHintController.dispose();
    _recoveryEmailController.dispose();
    _accountNotesController.dispose();
    _policyNumberController.dispose();
    _documentLabelController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final payment = widget.payment;
    _nameController = TextEditingController(
      text: BrandIconService.instance.canonicalDisplayName(
        payment.name,
        serviceId: payment.iconKey,
        iconKey: payment.iconKey,
      ),
    );
    _providerNameController = TextEditingController(text: payment.providerName);
    _amountController = TextEditingController(
      text: payment.amount.toStringAsFixed(2),
    );
    _currencyController = TextEditingController(text: payment.currency);
    _cancellationUrlController = TextEditingController(
      text: payment.cancellationUrl,
    );
    _managementUrlController = TextEditingController(
      text: payment.managementUrl,
    );
    _cancellationNotesController = TextEditingController(
      text: payment.cancellationNotes,
    );
    _trialNotesController = TextEditingController(text: payment.trialNotes);
    _convertsToPaidController = TextEditingController(
      text: payment.convertsToPaidAmount?.toStringAsFixed(2) ?? '',
    );
    _loginEmailController = TextEditingController(text: payment.loginEmail);
    _usernameController = TextEditingController(text: payment.username);
    _passwordHintController = TextEditingController(text: payment.passwordHint);
    _recoveryEmailController = TextEditingController(
      text: payment.recoveryEmail,
    );
    _accountNotesController = TextEditingController(text: payment.accountNotes);
    _policyNumberController = TextEditingController(text: payment.policyNumber);
    _documentLabelController = TextEditingController(
      text: payment.documentLabel,
    );
    _category = payment.category;
    _frequency = payment.frequency;
    _reminderTiming = payment.reminderTiming;
    _status = payment.status;
    _cancellationStatus = payment.cancellationStatus;
    _signInMethod = payment.signInMethod;
    _nextDueDate = payment.nextDueDate;
    _renewalDate = payment.renewalDate;
    _contractEndDate = payment.contractEndDate;
    _trialEndDate = payment.trialEndDate;
    _reminderEnabled = payment.reminderEnabled;
    _isTrial = payment.isTrial;
    _trialReminderEnabled = payment.trialReminderEnabled;
  }

  Future<void> _pickDate(BuildContext context, bool isTrialDate) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: isTrialDate
          ? (_trialEndDate ?? DateTime.now())
          : _nextDueDate,
    );
    if (picked != null) {
      setState(() {
        if (isTrialDate) {
          _trialEndDate = picked;
        } else {
          _nextDueDate = picked;
        }
      });
    }
  }

  Future<void> _pickRenewalDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _renewalDate ?? _nextDueDate,
    );
    if (picked != null) {
      setState(() => _renewalDate = picked);
    }
  }

  Future<void> _pickContractEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate:
          _contractEndDate ?? _nextDueDate.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _contractEndDate = picked);
    }
  }

  UserDocumentCategory get _suggestedDocumentCategory {
    switch (_category) {
      case PaymentCategory.rent:
        return UserDocumentCategory.property;
      case PaymentCategory.insurance:
        return UserDocumentCategory.insurance;
      case PaymentCategory.utilities:
      case PaymentCategory.internet:
      case PaymentCategory.phone:
        return UserDocumentCategory.bill;
      case PaymentCategory.loan:
        return UserDocumentCategory.loan;
      case PaymentCategory.membership:
      case PaymentCategory.gym:
        return UserDocumentCategory.membership;
      case PaymentCategory.contract:
        return UserDocumentCategory.contract;
      default:
        return UserDocumentCategory.other;
    }
  }

  Future<void> _openDocument(
    AppState appState,
    UserDocument document,
    String linkedItemName,
  ) async {
    try {
      final signedUrl = await appState.getSignedDocumentUrl(document);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentViewerScreen(
            document: document,
            signedUrl: signedUrl,
            linkedItemName: linkedItemName,
            onReplace: () async {
              Navigator.of(context).pop();
              await _replaceDocument(appState, document);
            },
            onDelete: () async {
              Navigator.of(context).pop();
              await _deleteDocument(appState, document);
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not open that document right now.',
          da: 'Vi kunne ikke åbne dokumentet lige nu.',
          de: 'Dieses Dokument konnte gerade nicht geöffnet werden.',
          es: 'No pudimos abrir ese documento en este momento.',
        ),
      );
    }
  }

  Future<void> _attachDocument(
    AppState appState,
    RecurringPayment payment,
  ) async {
    if (!appState.canStoreMoreDocuments) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }
    try {
      await appState.uploadDocumentForItem(
        linkedItemId: payment.id,
        title: payment.name,
        category: _suggestedDocumentCategory,
      );
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Document attached successfully.',
          da: 'Dokument blev vedhæftet.',
          de: 'Dokument wurde erfolgreich angehängt.',
          es: 'Documento adjuntado correctamente.',
        ),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      if (error.message == 'document_limit_reached') {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
        return;
      }
      if (error.message == 'document_pick_cancelled') {
        return;
      }
      final message = switch (error.message) {
        'document_too_large' => localeText(
          context,
          en: 'This file is too large. Please upload a file under 10MB.',
          da: 'Filen er for stor. Upload venligst en fil under 10 MB.',
          de: 'Diese Datei ist zu gross. Bitte lade eine Datei unter 10 MB hoch.',
          es: 'Este archivo es demasiado grande. Sube un archivo de menos de 10 MB.',
        ),
        'unsupported_document_type' => localeText(
          context,
          en: 'This file type is not supported yet.',
          da: 'Denne filtype understøttes ikke endnu.',
          de: 'Dieser Dateityp wird noch nicht unterstützt.',
          es: 'Este tipo de archivo todavía no es compatible.',
        ),
        _ => localeText(
          context,
          en: 'Upload will be available when you are back online.',
          da: 'Upload bliver tilgængelig, når du er online igen.',
          de: 'Der Upload wird verfügbar sein, sobald du wieder online bist.',
          es: 'La subida estará disponible cuando vuelvas a estar en línea.',
        ),
      };
      showErrorSnackBar(context, message);
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not attach that document right now.',
          da: 'Vi kunne ikke vedhæfte dokumentet lige nu.',
          de: 'Wir konnten das Dokument gerade nicht anhängen.',
          es: 'No pudimos adjuntar ese documento en este momento.',
        ),
      );
    }
  }

  Future<void> _replaceDocument(
    AppState appState,
    UserDocument document,
  ) async {
    try {
      await appState.replaceDocument(document);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Document replaced successfully.',
          da: 'Dokument blev udskiftet.',
          de: 'Dokument wurde erfolgreich ersetzt.',
          es: 'Documento reemplazado correctamente.',
        ),
      );
    } on StateError catch (error) {
      if (!mounted || error.message == 'document_pick_cancelled') return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not replace that document right now.',
          da: 'Vi kunne ikke udskifte dokumentet lige nu.',
          de: 'Dieses Dokument konnte gerade nicht ersetzt werden.',
          es: 'No pudimos reemplazar ese documento en este momento.',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not replace that document right now.',
          da: 'Vi kunne ikke udskifte dokumentet lige nu.',
          de: 'Dieses Dokument konnte gerade nicht ersetzt werden.',
          es: 'No pudimos reemplazar ese documento en este momento.',
        ),
      );
    }
  }

  Future<void> _deleteDocument(AppState appState, UserDocument document) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              localeText(
                context,
                en: 'Delete document?',
                da: 'Slette dokument?',
                de: 'Dokument löschen?',
                es: '¿Eliminar documento?',
              ),
            ),
            content: Text(
              localeText(
                context,
                en: 'This will remove the document from your Bizoot vault and this item.',
                da: 'Dette fjerner dokumentet fra din Bizoot-boks og fra dette element.',
                de: 'Dadurch wird das Dokument aus deinem Bizoot-Tresor und von diesem Eintrag entfernt.',
                es: 'Esto eliminará el documento de tu bóveda de Bizoot y de este elemento.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localeText(
                    context,
                    en: 'Keep',
                    da: 'Behold',
                    de: 'Behalten',
                    es: 'Conservar',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localeText(
                    context,
                    en: 'Delete',
                    da: 'Slet',
                    de: 'Löschen',
                    es: 'Eliminar',
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await appState.deleteDocument(document);
    if (!mounted) return;
    showSuccessSnackBar(
      context,
      localeText(
        context,
        en: 'Document deleted successfully.',
        da: 'Dokument blev slettet.',
        de: 'Dokument wurde erfolgreich gelöscht.',
        es: 'Documento eliminado correctamente.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final matchIndex = appState.payments.indexWhere(
      (item) => item.id == widget.payment.id,
    );
    final payment = matchIndex == -1
        ? widget.payment
        : appState.payments[matchIndex];
    final linkedDocuments = appState.linkedDocumentsForItem(payment.id);
    final displayName = BrandIconService.instance.canonicalDisplayName(
      payment.name,
      serviceId: payment.iconKey,
      iconKey: payment.iconKey,
    );
    return AppScaffold(
      title: localeText(
        context,
        en: 'Payment Detail',
        da: 'Betalingsdetaljer',
        de: 'Zahlungsdetails',
        es: 'Detalle del pago',
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Row(
              children: [
                BrandIcon(
                  serviceId: payment.iconKey,
                  serviceName: payment.name,
                  category: payment.category.displayLabel,
                  iconKey: payment.iconKey,
                  size: 60,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payment.category.displayLabel} • ${payment.frequency.displayLabel}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BizootColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(payment.amount, payment.currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (payment.isActive && !payment.isCancelled)
            AppButton(
              label: appState.isSavingPayment
                  ? localeText(
                      context,
                      en: 'Updating due date...',
                      da: 'Opdaterer forfaldsdato...',
                      de: 'Fälligkeitsdatum wird aktualisiert...',
                      es: 'Actualizando fecha de vencimiento...',
                    )
                  : localeText(
                      context,
                      en: 'Mark as paid',
                      da: 'Markér som betalt',
                      de: 'Als bezahlt markieren',
                      es: 'Marcar como pagado',
                    ),
              icon: Icons.check_circle_outline,
              isLoading: appState.isSavingPayment,
              onPressed: () async {
                try {
                  final nextDueDate = await appState.markPaymentAsPaid(payment);
                  if (!context.mounted) return;
                  AppHaptics.success();
                  showSuccessSnackBar(
                    context,
                    localeText(
                      context,
                      en: 'Next due date moved to ${formatShortDate(nextDueDate)}.',
                      da: 'Næste forfaldsdato er flyttet til ${formatShortDate(nextDueDate)}.',
                      de: 'Das nächste Fälligkeitsdatum wurde auf ${formatShortDate(nextDueDate)} verschoben.',
                      es: 'La próxima fecha de vencimiento se movió a ${formatShortDate(nextDueDate)}.',
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (_) {
                  if (!context.mounted) return;
                  AppHaptics.warning();
                  showErrorSnackBar(
                    context,
                    localeText(
                      context,
                      en: 'We could not update the next due date right now.',
                      da: 'Vi kunne ikke opdatere næste forfaldsdato lige nu.',
                      de: 'Das nächste Fälligkeitsdatum konnte gerade nicht aktualisiert werden.',
                      es: 'No pudimos actualizar la próxima fecha de vencimiento en este momento.',
                    ),
                  );
                }
              },
            ),
          if (payment.isActive && !payment.isCancelled)
            const SizedBox(height: 16),
          PaymentForm(
            formKey: _formKey,
            nameController: _nameController,
            providerNameController: _providerNameController,
            amountController: _amountController,
            currencyController: _currencyController,
            cancellationUrlController: _cancellationUrlController,
            managementUrlController: _managementUrlController,
            trialNotesController: _trialNotesController,
            cancellationNotesController: _cancellationNotesController,
            convertsToPaidController: _convertsToPaidController,
            loginEmailController: _loginEmailController,
            usernameController: _usernameController,
            passwordHintController: _passwordHintController,
            recoveryEmailController: _recoveryEmailController,
            accountNotesController: _accountNotesController,
            policyNumberController: _policyNumberController,
            documentLabelController: _documentLabelController,
            category: _category,
            frequency: _frequency,
            reminderTiming: _reminderTiming,
            status: _status,
            cancellationStatus: _cancellationStatus,
            signInMethod: _signInMethod,
            nextDueDate: _nextDueDate,
            renewalDate: _renewalDate,
            contractEndDate: _contractEndDate,
            trialEndDate: _trialEndDate,
            reminderEnabled: _reminderEnabled,
            isTrial: _isTrial,
            trialReminderEnabled: _trialReminderEnabled,
            isEssential: payment.isEssential,
            isCancellable: payment.isCancellable,
            onCategoryChanged: (value) =>
                setState(() => _category = value ?? _category),
            onFrequencyChanged: (value) =>
                setState(() => _frequency = value ?? _frequency),
            onReminderTimingChanged: (value) =>
                setState(() => _reminderTiming = value ?? _reminderTiming),
            onStatusChanged: (value) =>
                setState(() => _status = value ?? _status),
            onCancellationStatusChanged: (value) => setState(
              () => _cancellationStatus = value ?? _cancellationStatus,
            ),
            onSignInMethodChanged: (value) =>
                setState(() => _signInMethod = value ?? _signInMethod),
            onReminderEnabledChanged: (value) =>
                setState(() => _reminderEnabled = value),
            onTrialChanged: (value) => setState(() => _isTrial = value),
            onTrialReminderChanged: (value) =>
                setState(() => _trialReminderEnabled = value),
            onPickDate: (isTrialDate) => _pickDate(context, isTrialDate),
            onPickRenewalDate: () => _pickRenewalDate(context),
            onPickContractEndDate: () => _pickContractEndDate(context),
            appState: appState,
            duplicateWarning: _duplicateWarning,
            knownServiceSuggestions: const [],
            customServiceSuggestions: const [],
            autoFilledServiceName: null,
            showCreateCustom: false,
            showKeepTypingHint: false,
            showCancellationUrlAutoFilledBadge: false,
            showMissingCancellationUrlHelper: false,
            onNameChanged: (_) {},
            onServiceSuggestionSelected: (_) {},
            documentsSection: _LinkedDocumentsSection(
              documents: linkedDocuments,
              linkedItemName: displayName,
              isBusy:
                  appState.isUploadingDocument || appState.isDeletingDocument,
              onAttach: () => _attachDocument(appState, payment),
              onOpen: (document) =>
                  _openDocument(appState, document, displayName),
              onReplace: (document) => _replaceDocument(appState, document),
              onDelete: (document) => _deleteDocument(appState, document),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Login details',
                    da: 'Loginoplysninger',
                    de: 'Anmeldedaten',
                    es: 'Datos de acceso',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _LoginDetailRow(
                  label: 'Login Email',
                  value: _loginEmailController.text,
                  onCopy: _loginEmailController.text.trim().isEmpty
                      ? null
                      : () => _copyValue(
                          context,
                          localeText(
                            context,
                            en: 'Login Email',
                            da: 'Loginmail',
                            de: 'Anmelde-E-Mail',
                            es: 'Correo de acceso',
                          ),
                          _loginEmailController.text.trim(),
                        ),
                ),
                _LoginDetailRow(
                  label: 'Username / Account Name',
                  value: _usernameController.text,
                  onCopy: _usernameController.text.trim().isEmpty
                      ? null
                      : () => _copyValue(
                          context,
                          localeText(
                            context,
                            en: 'Username / Account Name',
                            da: 'Brugernavn / kontonavn',
                            de: 'Benutzername / Kontoname',
                            es: 'Usuario / nombre de cuenta',
                          ),
                          _usernameController.text.trim(),
                        ),
                ),
                _LoginDetailRow(
                  label: 'Sign-in Method',
                  value: _signInMethod.displayLabel,
                ),
                _LoginDetailRow(
                  label: 'Password Hint',
                  value: _passwordHintController.text,
                  hidden: !_showPasswordHint,
                  onToggleVisibility:
                      _passwordHintController.text.trim().isEmpty
                      ? null
                      : () => setState(
                          () => _showPasswordHint = !_showPasswordHint,
                        ),
                ),
                _LoginDetailRow(
                  label: 'Recovery Email',
                  value: _recoveryEmailController.text,
                  onCopy: _recoveryEmailController.text.trim().isEmpty
                      ? null
                      : () => _copyValue(
                          context,
                          localeText(
                            context,
                            en: 'Recovery Email',
                            da: 'Gendannelsesmail',
                            de: 'Wiederherstellungs-E-Mail',
                            es: 'Correo de recuperación',
                          ),
                          _recoveryEmailController.text.trim(),
                        ),
                ),
                _LoginDetailRow(
                  label: 'Private Notes',
                  value: _accountNotesController.text,
                  multiline: true,
                ),
                const SizedBox(height: 8),
                Text(
                  localeText(
                    context,
                    en: 'Login details stay visible only inside your Bizoot account.',
                    da: 'Loginoplysninger er kun synlige i din Bizoot-konto.',
                    de: 'Anmeldedaten sind nur in deinem Bizoot-Konto sichtbar.',
                    es: 'Los datos de acceso solo se muestran dentro de tu cuenta de Bizoot.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (appState.canUseCancellationAssistant)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeText(
                      context,
                      en: 'Help me cancel',
                      da: 'Hjælp mig med at opsige',
                      de: 'Beim Kündigen helfen',
                      es: 'Ayúdame a cancelar',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    payment.cancellationUrl.isEmpty
                        ? localeText(
                            context,
                            en: 'Store the exact cancellation link and notes so you do not have to search when you are ready.',
                            da: 'Gem det præcise opsigelseslink og noter, så du ikke skal lede efter dem senere.',
                            de: 'Speichere den genauen Kündigungslink und Notizen, damit du später nicht danach suchen musst.',
                            es: 'Guarda el enlace exacto de cancelación y las notas para no tener que buscarlos después.',
                          )
                        : payment.cancellationUrl,
                  ),
                  const SizedBox(height: 12),
                  if (_cancellationUrlController.text.isNotEmpty)
                    AppButton(
                      label: localeText(
                        context,
                        en: 'Open cancellation link',
                        da: 'Åbn opsigelseslink',
                        de: 'Kündigungslink öffnen',
                        es: 'Abrir enlace de cancelación',
                      ),
                      secondary: true,
                      icon: Icons.open_in_new,
                      onPressed: () async {
                        final uri = Uri.tryParse(
                          _cancellationUrlController.text,
                        );
                        if (uri != null) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: localeText(
                      context,
                      en: 'Mark as cancelled',
                      da: 'Markér som opsagt',
                      de: 'Als gekündigt markieren',
                      es: 'Marcar como cancelado',
                    ),
                    icon: Icons.cancel_outlined,
                    onPressed: () async {
                      final confirmed =
                          await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                localeText(
                                  context,
                                  en: 'Stop tracking this subscription?',
                                  da: 'Stoppe sporing af dette abonnement?',
                                  de: 'Dieses Abo nicht mehr verfolgen?',
                                  es: '¿Dejar de seguir esta suscripción?',
                                ),
                              ),
                              content: Text(
                                localeText(
                                  context,
                                  en: 'Bizoot will mark it as cancelled and move it into your savings context.',
                                  da: 'Bizoot markerer det som opsagt og flytter det til din opsparingskontekst.',
                                  de: 'Bizoot markiert es als gekündigt und berücksichtigt es in deinem Spar-Kontext.',
                                  es: 'Bizoot lo marcará como cancelado y lo moverá a tu contexto de ahorro.',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    localeText(
                                      context,
                                      en: 'Keep tracking',
                                      da: 'Fortsæt sporing',
                                      de: 'Weiter verfolgen',
                                      es: 'Seguir controlando',
                                    ),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    localeText(
                                      context,
                                      en: 'Mark cancelled',
                                      da: 'Markér som opsagt',
                                      de: 'Als gekündigt markieren',
                                      es: 'Marcar como cancelado',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (!confirmed) return;
                      try {
                        final updated = widget.payment.copyWith(
                          cancellationStatus: CancellationStatus.cancelled,
                          status: PaymentStatus.cancelled,
                          cancelledAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        await appState.savePayment(
                          updated,
                          original: widget.payment,
                        );
                        if (!context.mounted) return;
                        AppHaptics.success();
                        showSuccessSnackBar(
                          context,
                          localeText(
                            context,
                            en: 'Subscription marked as cancelled.',
                            da: 'Abonnementet er markeret som opsagt.',
                            de: 'Das Abo wurde als gekündigt markiert.',
                            es: 'La suscripción se marcó como cancelada.',
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (_) {
                        if (!context.mounted) return;
                        showErrorSnackBar(
                          context,
                          localeText(
                            context,
                            en: 'We could not update the cancellation status right now.',
                            da: 'Vi kunne ikke opdatere opsigelsesstatus lige nu.',
                            de: 'Der Kündigungsstatus konnte gerade nicht aktualisiert werden.',
                            es: 'No pudimos actualizar el estado de cancelación en este momento.',
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          else
            PremiumLockCard(
              title: localeText(
                context,
                en: 'Cancellation assistant is premium',
                da: 'Opsigelseshjælp er Premium',
                de: 'Kündigungsassistent ist Premium',
                es: 'El asistente de cancelación es Premium',
              ),
              body: localeText(
                context,
                en: 'Store cancellation links, notes, and saved-value context.',
                da: 'Gem opsigelseslinks, noter og kontekst om besparelser.',
                de: 'Speichere Kündigungslinks, Notizen und Spar-Kontext.',
                es: 'Guarda enlaces de cancelación, notas y contexto de ahorro.',
              ),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
            ),
          const SizedBox(height: 16),
          if (appState.canUseAdvancedInsights &&
              payment.priceHistory.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeText(
                      context,
                      en: 'Price history',
                      da: 'Prishistorik',
                      de: 'Preisverlauf',
                      es: 'Historial de precios',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...payment.priceHistory.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        localeText(
                          context,
                          en: '${payment.name} changed from ${formatCurrency(entry.oldAmount, payment.currency)} to ${formatCurrency(entry.newAmount, payment.currency)}. Yearly impact: ${formatCurrency(entry.yearlyDelta, payment.currency)}.',
                          da: '${payment.name} ændrede sig fra ${formatCurrency(entry.oldAmount, payment.currency)} til ${formatCurrency(entry.newAmount, payment.currency)}. Årlig effekt: ${formatCurrency(entry.yearlyDelta, payment.currency)}.',
                          de: '${payment.name} änderte sich von ${formatCurrency(entry.oldAmount, payment.currency)} auf ${formatCurrency(entry.newAmount, payment.currency)}. Jährliche Auswirkung: ${formatCurrency(entry.yearlyDelta, payment.currency)}.',
                          es: '${payment.name} cambió de ${formatCurrency(entry.oldAmount, payment.currency)} a ${formatCurrency(entry.newAmount, payment.currency)}. Impacto anual: ${formatCurrency(entry.yearlyDelta, payment.currency)}.',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          AppButton(
            label: appState.isSavingPayment
                ? localeText(
                    context,
                    en: 'Saving changes...',
                    da: 'Gemmer ændringer...',
                    de: 'Änderungen werden gespeichert...',
                    es: 'Guardando cambios...',
                  )
                : localeText(
                    context,
                    en: 'Save changes',
                    da: 'Gem ændringer',
                    de: 'Änderungen speichern',
                    es: 'Guardar cambios',
                  ),
            icon: Icons.check_circle_outline,
            isLoading: appState.isSavingPayment,
            onPressed: () async {
              AppHaptics.tap();
              setState(() {
                _duplicateWarning =
                    appState.isDuplicate(
                      _nameController.text,
                      _category,
                      ignoreId: payment.id,
                    )
                    ? localeText(
                        context,
                        en: 'You may already be tracking this.',
                        da: 'Du sporer muligvis allerede dette.',
                        de: 'Möglicherweise verfolgst du dies bereits.',
                        es: 'Puede que ya estés siguiendo esto.',
                      )
                    : null;
              });
              if (!_formKey.currentState!.validate()) return;
              final updated = payment.copyWith(
                name: _nameController.text.trim(),
                providerName: _providerNameController.text.trim(),
                amount: double.tryParse(_amountController.text) ?? 0,
                currency: _currencyController.text.trim().toUpperCase(),
                category: _category,
                frequency: _frequency,
                nextDueDate: _nextDueDate,
                renewalDate: _renewalDate,
                contractEndDate: _contractEndDate,
                reminderEnabled: _reminderEnabled,
                reminderTiming: _reminderTiming,
                status: _status,
                isTrial: _isTrial,
                trialEndDate: _trialEndDate,
                trialReminderEnabled: _trialReminderEnabled,
                convertsToPaidAmount: double.tryParse(
                  _convertsToPaidController.text,
                ),
                trialNotes: _trialNotesController.text.trim(),
                cancellationUrl: _cancellationUrlController.text.trim(),
                managementUrl: _managementUrlController.text.trim(),
                cancellationNotes: _cancellationNotesController.text.trim(),
                loginEmail: _loginEmailController.text.trim(),
                username: _usernameController.text.trim(),
                signInMethod: _signInMethod,
                passwordHint: _passwordHintController.text.trim(),
                recoveryEmail: _recoveryEmailController.text.trim(),
                accountNotes: _accountNotesController.text.trim(),
                policyNumber: _policyNumberController.text.trim(),
                documentLabel: _documentLabelController.text.trim(),
                isEssential: _category != PaymentCategory.subscription,
                isCancellable:
                    _category != PaymentCategory.rent &&
                    _category != PaymentCategory.loan,
                cancellationStatus: _cancellationStatus,
                cancelledAt: _cancellationStatus == CancellationStatus.cancelled
                    ? (payment.cancelledAt ?? DateTime.now())
                    : null,
                updatedAt: DateTime.now(),
              );
              try {
                await appState.savePayment(updated, original: payment);
                if (!context.mounted) return;
                AppHaptics.success();
                showSuccessSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'Payment updated successfully.',
                    da: 'Betaling blev opdateret.',
                    de: 'Zahlung wurde erfolgreich aktualisiert.',
                    es: 'Pago actualizado correctamente.',
                  ),
                );
                Navigator.of(context).pop();
              } catch (_) {
                if (!context.mounted) return;
                AppHaptics.warning();
                showErrorSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'We could not save those changes right now.',
                    da: 'Vi kunne ikke gemme ændringerne lige nu.',
                    de: 'Diese Änderungen konnten gerade nicht gespeichert werden.',
                    es: 'No pudimos guardar esos cambios en este momento.',
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: appState.isDeletingPayment
                ? localeText(
                    context,
                    en: 'Deleting payment...',
                    da: 'Sletter betaling...',
                    de: 'Zahlung wird gelöscht...',
                    es: 'Eliminando pago...',
                  )
                : localeText(
                    context,
                    en: 'Delete payment',
                    da: 'Slet betaling',
                    de: 'Zahlung löschen',
                    es: 'Eliminar pago',
                  ),
            icon: Icons.delete_outline,
            secondary: true,
            isLoading: appState.isDeletingPayment,
            onPressed: () async {
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        localeText(
                          context,
                          en: 'Delete payment?',
                          da: 'Slette betaling?',
                          de: 'Zahlung löschen?',
                          es: '¿Eliminar pago?',
                        ),
                      ),
                      content: Text(
                        localeText(
                          context,
                          en: 'This will remove the payment from your dashboard and reports.',
                          da: 'Dette fjerner betalingen fra dit dashboard og dine rapporter.',
                          de: 'Dadurch wird die Zahlung aus deinem Dashboard und deinen Berichten entfernt.',
                          es: 'Esto eliminará el pago de tu panel y tus informes.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            localeText(
                              context,
                              en: 'Cancel',
                              da: 'Annuller',
                              de: 'Abbrechen',
                              es: 'Cancelar',
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            localeText(
                              context,
                              en: 'Delete',
                              da: 'Slet',
                              de: 'Löschen',
                              es: 'Eliminar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!confirmed) return;
              try {
                await appState.deletePayment(payment);
                if (!context.mounted) return;
                AppHaptics.delete();
                showSuccessSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'Payment deleted permanently.',
                    da: 'Betalingen blev slettet permanent.',
                    de: 'Zahlung wurde dauerhaft gelöscht.',
                    es: 'Pago eliminado permanentemente.',
                  ),
                  icon: Icons.delete_outline,
                );
                Navigator.of(context).pop();
              } catch (_) {
                if (!context.mounted) return;
                showErrorSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'We could not delete this payment right now.',
                    da: 'Vi kunne ikke slette denne betaling lige nu.',
                    de: 'Diese Zahlung konnte gerade nicht gelöscht werden.',
                    es: 'No pudimos eliminar este pago en este momento.',
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _copyValue(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    AppHaptics.success();
    showSuccessSnackBar(
      context,
      localeText(
        context,
        en: '$label copied.',
        da: '$label kopieret.',
        de: '$label kopiert.',
        es: '$label copiado.',
      ),
    );
  }
}

class _LoginDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final VoidCallback? onToggleVisibility;
  final bool hidden;
  final bool multiline;

  const _LoginDetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.onToggleVisibility,
    this.hidden = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final displayValue = !hasValue
        ? localeText(
            context,
            en: 'Not saved',
            da: 'Ikke gemt',
            de: 'Nicht gespeichert',
            es: 'No guardado',
          )
        : hidden
        ? '••••••••'
        : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  maxLines: multiline ? null : 2,
                  overflow: multiline
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hasValue
                        ? BizootColors.textPrimary
                        : BizootColors.textSecondary,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onToggleVisibility != null)
            IconButton(
              tooltip: hidden
                  ? localeText(
                      context,
                      en: 'Show hint',
                      da: 'Vis hint',
                      de: 'Hinweis anzeigen',
                      es: 'Mostrar pista',
                    )
                  : localeText(
                      context,
                      en: 'Hide hint',
                      da: 'Skjul hint',
                      de: 'Hinweis ausblenden',
                      es: 'Ocultar pista',
                    ),
              onPressed: onToggleVisibility,
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          if (onCopy != null)
            IconButton(
              tooltip: localeText(
                context,
                en: 'Copy',
                da: 'Kopiér',
                de: 'Kopieren',
                es: 'Copiar',
              ),
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}

class _LinkedDocumentsSection extends StatelessWidget {
  final List<UserDocument> documents;
  final String linkedItemName;
  final bool isBusy;
  final VoidCallback onAttach;
  final ValueChanged<UserDocument> onOpen;
  final ValueChanged<UserDocument> onReplace;
  final ValueChanged<UserDocument> onDelete;

  const _LinkedDocumentsSection({
    required this.documents,
    required this.linkedItemName,
    required this.isBusy,
    required this.onAttach,
    required this.onOpen,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeText(
              context,
              en: 'Documents',
              da: 'Dokumenter',
              de: 'Dokumente',
              es: 'Documentos',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: BizootSpacing.xs),
          Text(
            documents.isEmpty
                ? localeText(
                    context,
                    en: 'Your documents are stored securely and linked only to your account.',
                    da: 'Dine dokumenter opbevares sikkert og er kun knyttet til din konto.',
                    de: 'Deine Dokumente werden sicher gespeichert und nur mit deinem Konto verknüpft.',
                    es: 'Tus documentos se guardan de forma segura y solo están vinculados a tu cuenta.',
                  )
                : localeText(
                    context,
                    en: '${documents.length} document${documents.length == 1 ? '' : 's'} linked to this item.',
                    da: '${documents.length} dokument${documents.length == 1 ? '' : 'er'} knyttet til dette element.',
                    de: '${documents.length} Dokument${documents.length == 1 ? '' : 'e'} mit diesem Eintrag verknüpft.',
                    es: '${documents.length} documento${documents.length == 1 ? '' : 's'} vinculado${documents.length == 1 ? '' : 's'} a este elemento.',
                  ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: BizootSpacing.md),
          AppButton(
            label: isBusy
                ? localeText(
                    context,
                    en: 'Working...',
                    da: 'Arbejder...',
                    de: 'Wird bearbeitet...',
                    es: 'Procesando...',
                  )
                : localeText(
                    context,
                    en: 'Attach Document',
                    da: 'Vedhæft dokument',
                    de: 'Dokument anhängen',
                    es: 'Adjuntar documento',
                  ),
            icon: Icons.attach_file_rounded,
            secondary: true,
            isLoading: isBusy,
            onPressed: isBusy ? null : onAttach,
          ),
          if (documents.isEmpty) ...[
            const SizedBox(height: BizootSpacing.md),
            Text(
              localeText(
                context,
                en: 'No document attached',
                da: 'Intet dokument vedhæftet',
                de: 'Kein Dokument angehängt',
                es: 'No hay documento adjunto',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            const SizedBox(height: BizootSpacing.md),
            ...documents.map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: BizootSpacing.sm),
                child: DocumentCard(
                  document: document,
                  linkedItemName: linkedItemName,
                  onOpen: () => onOpen(document),
                  onReplace: () => onReplace(document),
                  onDelete: () => onDelete(document),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
