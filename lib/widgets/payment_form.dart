import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../services/app_state.dart';
import '../services/custom_subscription_database_service.dart';
import '../theme/app_theme.dart';
import '../utils/supported_currencies.dart';
import 'app_card.dart';
import 'brand_icon.dart';
import 'neon_icon_box.dart';

class PaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController providerNameController;
  final TextEditingController amountController;
  final TextEditingController currencyController;
  final TextEditingController cancellationUrlController;
  final TextEditingController managementUrlController;
  final TextEditingController trialNotesController;
  final TextEditingController cancellationNotesController;
  final TextEditingController convertsToPaidController;
  final TextEditingController loginEmailController;
  final TextEditingController usernameController;
  final TextEditingController passwordHintController;
  final TextEditingController recoveryEmailController;
  final TextEditingController accountNotesController;
  final TextEditingController policyNumberController;
  final TextEditingController documentLabelController;
  final PaymentCategory category;
  final PaymentFrequency frequency;
  final ReminderTiming reminderTiming;
  final PaymentStatus status;
  final CancellationStatus cancellationStatus;
  final SignInMethod signInMethod;
  final DateTime nextDueDate;
  final DateTime? renewalDate;
  final DateTime? contractEndDate;
  final DateTime? trialEndDate;
  final bool reminderEnabled;
  final bool isTrial;
  final bool trialReminderEnabled;
  final bool isEssential;
  final bool isCancellable;
  final ValueChanged<PaymentCategory?> onCategoryChanged;
  final ValueChanged<PaymentFrequency?> onFrequencyChanged;
  final ValueChanged<ReminderTiming?> onReminderTimingChanged;
  final ValueChanged<PaymentStatus?> onStatusChanged;
  final ValueChanged<CancellationStatus?> onCancellationStatusChanged;
  final ValueChanged<SignInMethod?> onSignInMethodChanged;
  final ValueChanged<bool> onReminderEnabledChanged;
  final ValueChanged<bool> onTrialChanged;
  final ValueChanged<bool> onTrialReminderChanged;
  final Future<void> Function(bool isTrialDate) onPickDate;
  final Future<void> Function() onPickRenewalDate;
  final Future<void> Function() onPickContractEndDate;
  final AppState appState;
  final String? duplicateWarning;
  final List<SubscriptionSuggestionItem> knownServiceSuggestions;
  final List<SubscriptionSuggestionItem> customServiceSuggestions;
  final String? autoFilledServiceName;
  final bool showCreateCustom;
  final bool showKeepTypingHint;
  final bool showCancellationUrlAutoFilledBadge;
  final bool showMissingCancellationUrlHelper;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<SubscriptionSuggestionItem> onServiceSuggestionSelected;
  final Widget? documentsSection;

  const PaymentForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.providerNameController,
    required this.amountController,
    required this.currencyController,
    required this.cancellationUrlController,
    required this.managementUrlController,
    required this.trialNotesController,
    required this.cancellationNotesController,
    required this.convertsToPaidController,
    required this.loginEmailController,
    required this.usernameController,
    required this.passwordHintController,
    required this.recoveryEmailController,
    required this.accountNotesController,
    required this.policyNumberController,
    required this.documentLabelController,
    required this.category,
    required this.frequency,
    required this.reminderTiming,
    required this.status,
    required this.cancellationStatus,
    required this.signInMethod,
    required this.nextDueDate,
    required this.renewalDate,
    required this.contractEndDate,
    required this.trialEndDate,
    required this.reminderEnabled,
    required this.isTrial,
    required this.trialReminderEnabled,
    required this.isEssential,
    required this.isCancellable,
    required this.onCategoryChanged,
    required this.onFrequencyChanged,
    required this.onReminderTimingChanged,
    required this.onStatusChanged,
    required this.onCancellationStatusChanged,
    required this.onSignInMethodChanged,
    required this.onReminderEnabledChanged,
    required this.onTrialChanged,
    required this.onTrialReminderChanged,
    required this.onPickDate,
    required this.onPickRenewalDate,
    required this.onPickContractEndDate,
    required this.appState,
    required this.duplicateWarning,
    required this.knownServiceSuggestions,
    required this.customServiceSuggestions,
    required this.autoFilledServiceName,
    required this.showCreateCustom,
    required this.showKeepTypingHint,
    required this.showCancellationUrlAutoFilledBadge,
    required this.showMissingCancellationUrlHelper,
    required this.onNameChanged,
    required this.onServiceSuggestionSelected,
    this.documentsSection,
  });

  TextStyle? _dropdownTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: BizootColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
  }

  DropdownButtonFormField<T> _buildDropdownField<T>({
    required BuildContext context,
    required T value,
    required List<T> values,
    required String label,
    required String Function(T item) displayLabel,
    required ValueChanged<T?> onChanged,
  }) {
    final style = _dropdownTextStyle(context);
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      itemHeight: 56,
      menuMaxHeight: 320,
      dropdownColor: BizootColors.surfaceElevated,
      style: style,
      iconEnabledColor: BizootColors.textSecondary,
      decoration: InputDecoration(labelText: label),
      selectedItemBuilder: (context) {
        return values
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  displayLabel(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            )
            .toList();
      },
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ignore: unused_element
  DropdownButtonFormField<String> _buildCurrencyDropdown(BuildContext context) {
    final style = _dropdownTextStyle(context);
    final normalized = currencyController.text.trim().toUpperCase();
    final selected = findSupportedCurrency(normalized)?.code ?? 'USD';

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      itemHeight: 56,
      menuMaxHeight: 320,
      dropdownColor: BizootColors.surfaceElevated,
      style: style,
      iconEnabledColor: BizootColors.textSecondary,
      decoration: const InputDecoration(labelText: 'Currency'),
      selectedItemBuilder: (context) {
        return supportedCurrencies
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${item.code} • ${item.symbol}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            )
            .toList();
      },
      items: supportedCurrencies
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.code,
              child: SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${item.code} • ${item.label} (${item.symbol})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        currencyController.text = value;
      },
    );
  }

  Widget _buildCurrencyField() {
    final locale = appState.currentLocale.languageCode;
    final normalized = currencyController.text.trim().toUpperCase();
    final currency = findSupportedCurrency(normalized);
    final displayText = currency == null
        ? (normalized.isEmpty ? 'USD' : normalized)
        : '${currency.label} (${currency.symbol}) - ${currency.code}';

    return TextFormField(
      controller: TextEditingController(text: displayText),
      readOnly: true,
      enableInteractiveSelection: false,
      decoration: InputDecoration(
        labelText: locale == 'da'
            ? 'Valuta'
            : locale == 'de'
            ? 'Währung'
            : locale == 'es'
            ? 'Moneda'
            : 'Currency',
        helperText: locale == 'da'
            ? 'Udfyldes automatisk fra dit valgte land'
            : locale == 'de'
            ? 'Wird automatisch aus deinem gewählten Land übernommen'
            : locale == 'es'
            ? 'Se completa automáticamente según el país seleccionado'
            : 'Auto-filled from your selected country',
      ),
    );
  }

  bool get _showsContractEndDate =>
      category == PaymentCategory.rent ||
      category == PaymentCategory.phone ||
      category == PaymentCategory.internet ||
      category == PaymentCategory.contract;

  String _nameLabel(BuildContext context) {
    switch (category) {
      case PaymentCategory.rent:
        return localeText(context, en: 'Property / Rent name', da: 'Bolig- / lejenavn', de: 'Objekt- / Mietname', es: 'Nombre de vivienda / alquiler');
      case PaymentCategory.insurance:
        return localeText(context, en: 'Insurance plan name', da: 'Navn på forsikringsplan', de: 'Name des Versicherungsplans', es: 'Nombre del plan de seguro');
      case PaymentCategory.utilities:
        return localeText(context, en: 'Utility bill name', da: 'Navn på regning', de: 'Name der Nebenkostenrechnung', es: 'Nombre de la factura de servicios');
      case PaymentCategory.internet:
        return localeText(context, en: 'Internet service name', da: 'Navn på internetservice', de: 'Name des Internetdienstes', es: 'Nombre del servicio de internet');
      case PaymentCategory.phone:
        return localeText(context, en: 'Phone plan name', da: 'Navn på mobilabonnement', de: 'Name des Mobilfunktarifs', es: 'Nombre del plan telefónico');
      case PaymentCategory.gym:
        return localeText(context, en: 'Gym / Membership name', da: 'Navn på fitness / medlemskab', de: 'Name des Fitness- / Mitgliedschaftsplans', es: 'Nombre del gimnasio / membresía');
      case PaymentCategory.loan:
        return localeText(context, en: 'Loan name', da: 'Navn på lån', de: 'Name des Kredits', es: 'Nombre del préstamo');
      case PaymentCategory.contract:
        return localeText(context, en: 'Contract name', da: 'Kontraktnavn', de: 'Vertragsname', es: 'Nombre del contrato');
      default:
        return localeText(context, en: 'Name', da: 'Navn', de: 'Name', es: 'Nombre');
    }
  }

  String _providerLabel(BuildContext context) {
    switch (category) {
      case PaymentCategory.rent:
        return localeText(context, en: 'Landlord / Property', da: 'Udlejer / bolig', de: 'Vermieter / Objekt', es: 'Arrendador / propiedad');
      case PaymentCategory.insurance:
        return localeText(context, en: 'Provider', da: 'Udbyder', de: 'Anbieter', es: 'Proveedor');
      case PaymentCategory.utilities:
        return localeText(context, en: 'Utility provider', da: 'Forsyningsselskab', de: 'Versorger', es: 'Proveedor de servicios');
      case PaymentCategory.internet:
        return localeText(context, en: 'Internet provider', da: 'Internetudbyder', de: 'Internetanbieter', es: 'Proveedor de internet');
      case PaymentCategory.phone:
        return localeText(context, en: 'Phone provider', da: 'Teleudbyder', de: 'Mobilfunkanbieter', es: 'Proveedor telefónico');
      case PaymentCategory.loan:
        return localeText(context, en: 'Lender', da: 'Långiver', de: 'Kreditgeber', es: 'Prestamista');
      case PaymentCategory.contract:
        return localeText(context, en: 'Provider / Counterparty', da: 'Udbyder / modpart', de: 'Anbieter / Vertragspartner', es: 'Proveedor / contraparte');
      default:
        return localeText(context, en: 'Provider / Service name', da: 'Udbyder / servicenavn', de: 'Anbieter / Dienstname', es: 'Proveedor / nombre del servicio');
    }
  }

  String _billingSubtitle(BuildContext context) {
    switch (category) {
      case PaymentCategory.rent:
        return localeText(context, en: 'Track lease timing, due dates, and landlord details alongside your monthly rent.', da: 'Følg lejeperiode, forfaldsdatoer og udlejeroplysninger sammen med din månedlige husleje.', de: 'Behalte Mietlaufzeit, Fälligkeitstermine und Vermieterdetails zusammen mit deiner monatlichen Miete im Blick.', es: 'Sigue el periodo del alquiler, las fechas de vencimiento y los datos del arrendador junto con tu renta mensual.');
      case PaymentCategory.utilities:
        return localeText(context, en: 'Keep bill timing and average utility costs visible in the same place.', da: 'Hold styr på betalingstidspunkt og gennemsnitlige forsyningsudgifter samme sted.', de: 'Behalte Rechnungszeitpunkt und durchschnittliche Nebenkosten an einem Ort im Blick.', es: 'Mantén visibles en un solo lugar las fechas de pago y los costes medios de servicios.');
      case PaymentCategory.insurance:
        return localeText(context, en: 'Track premiums, renewal timing, and provider details before policy rollover.', da: 'Følg præmier, fornyelsestidspunkt og udbyderoplysninger før policen fornyes.', de: 'Behalte Prämien, Verlängerungszeitpunkt und Anbieterdetails vor der Policenverlängerung im Blick.', es: 'Sigue las primas, la fecha de renovación y los datos del proveedor antes de que se renueve la póliza.');
      case PaymentCategory.internet:
      case PaymentCategory.phone:
        return localeText(context, en: 'Stay on top of recurring plans, contract dates, and renewal reminders.', da: 'Behold overblikket over løbende planer, kontraktdatoer og fornyelsespåmindelser.', de: 'Behalte laufende Tarife, Vertragsdaten und Verlängerungserinnerungen im Blick.', es: 'Mantén el control de los planes recurrentes, fechas de contrato y recordatorios de renovación.');
      case PaymentCategory.loan:
        return localeText(context, en: 'Monitor repayment timing, monthly burden, and key account details.', da: 'Overvåg tilbagebetalingstidspunkt, månedlig belastning og vigtige kontooplysninger.', de: 'Überwache Rückzahlungszeitpunkt, monatliche Belastung und wichtige Kontodetails.', es: 'Controla las fechas de pago, la carga mensual y los datos clave de la cuenta.');
      case PaymentCategory.contract:
        return localeText(context, en: 'Keep contract renewals and end dates visible before automatic rollovers.', da: 'Hold kontraktfornyelser og slutdatoer synlige før automatiske forlængelser.', de: 'Behalte Vertragsverlängerungen und Enddaten vor automatischen Verlängerungen im Blick.', es: 'Mantén visibles las renovaciones y fechas de finalización del contrato antes de que se renueve automáticamente.');
      default:
        return localeText(context, en: 'Define how this payment repeats and when you want to hear about it.', da: 'Bestem hvordan betalingen gentages, og hvornår du vil mindes om den.', de: 'Lege fest, wie sich diese Zahlung wiederholt und wann du daran erinnert werden möchtest.', es: 'Define cómo se repite este pago y cuándo quieres recibir recordatorios.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _PremiumSectionCard(
            icon: Icons.wallet_outlined,
            title: localeText(
              context,
              en: 'Billing',
              da: 'Betaling',
              de: 'Abrechnung',
              es: 'Facturación',
            ),
            subtitle: _billingSubtitle(context),
            child: Column(
              children: [
                _buildDropdownField<PaymentCategory>(
                  context: context,
                  value: category,
                  values: PaymentCategory.values,
                  label: localeText(
                    context,
                    en: 'Category',
                    da: 'Kategori',
                    de: 'Kategorie',
                    es: 'Categoría',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                _buildDropdownField<PaymentFrequency>(
                  context: context,
                  value: frequency,
                  values: PaymentFrequency.values,
                  label: localeText(
                    context,
                    en: 'Frequency',
                    da: 'Frekvens',
                    de: 'Häufigkeit',
                    es: 'Frecuencia',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onFrequencyChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                _buildDropdownField<ReminderTiming>(
                  context: context,
                  value: reminderTiming,
                  values: ReminderTiming.values,
                  label: localeText(
                    context,
                    en: 'Reminder timing',
                    da: 'Påmindelsestid',
                    de: 'Erinnerungszeitpunkt',
                    es: 'Momento del recordatorio',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onReminderTimingChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                _DateSelectorTile(
                  icon: Icons.event_outlined,
                  label: localeText(
                    context,
                    en: 'Next payment date',
                    da: 'Næste betalingsdato',
                    de: 'Nächstes Zahlungsdatum',
                    es: 'Próxima fecha de pago',
                  ),
                  value:
                      '${nextDueDate.month}/${nextDueDate.day}/${nextDueDate.year}',
                  onTap: () => onPickDate(false),
                ),
                if (_showsContractEndDate) ...[
                  const SizedBox(height: BizootSpacing.md),
                  _DateSelectorTile(
                    icon: Icons.event_busy_outlined,
                    label: localeText(
                      context,
                      en: 'Contract end date',
                      da: 'Kontraktens slutdato',
                      de: 'Vertragsende',
                      es: 'Fecha de fin del contrato',
                    ),
                    value: contractEndDate == null
                        ? localeText(
                            context,
                            en: 'Choose date',
                            da: 'Vælg dato',
                            de: 'Datum wählen',
                            es: 'Elegir fecha',
                          )
                        : '${contractEndDate!.month}/${contractEndDate!.day}/${contractEndDate!.year}',
                    onTap: onPickContractEndDate,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _PremiumSectionCard(
            icon: Icons.edit_note_outlined,
            title: localeText(
              context,
              en: 'Basic details',
              da: 'Grundoplysninger',
              de: 'Grunddaten',
              es: 'Datos básicos',
            ),
            subtitle: localeText(
              context,
              en: 'Give the payment a clear name, amount, and currency.',
              da: 'Giv betalingen et tydeligt navn, beløb og valuta.',
              de: 'Gib der Zahlung einen klaren Namen, Betrag und eine Währung.',
              es: 'Dale al pago un nombre claro, importe y moneda.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  decoration: InputDecoration(labelText: _nameLabel(context)),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? localeText(
                          context,
                          en: 'Name is required',
                          da: 'Navn er påkrævet',
                          de: 'Name ist erforderlich',
                          es: 'El nombre es obligatorio',
                        )
                      : null,
                ),
                AnimatedSwitcher(
                  duration: BizootDurations.medium,
                  child:
                      knownServiceSuggestions.isEmpty &&
                          customServiceSuggestions.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: BizootSpacing.sm),
                          child: _SuggestionsCard(
                            knownServices: knownServiceSuggestions,
                            customServices: customServiceSuggestions,
                            onSelected: onServiceSuggestionSelected,
                          ),
                        ),
                ),
                if (showKeepTypingHint) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  Text(
                    localeText(
                      context,
                      en: 'Keep typing...',
                      da: 'Fortsæt med at skrive...',
                      de: 'Schreib weiter...',
                      es: 'Sigue escribiendo...',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (autoFilledServiceName != null) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  _InfoBadge(
                    label: localeText(
                      context,
                      en: 'Auto-filled from Bizoot database',
                      da: 'Udfyldt automatisk fra Bizoot-databasen',
                      de: 'Automatisch aus der Bizoot-Datenbank ausgefüllt',
                      es: 'Completado automáticamente desde la base de datos de Bizoot',
                    ),
                    accent: BizootColors.primary,
                  ),
                ] else if (showCreateCustom) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  _InfoBadge(
                    label: localeText(
                      context,
                      en: 'Create custom subscription',
                      da: 'Opret brugerdefineret abonnement',
                      de: 'Benutzerdefiniertes Abo erstellen',
                      es: 'Crear suscripción personalizada',
                    ),
                    accent: BizootColors.textMuted,
                  ),
                ],
                if (duplicateWarning != null) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  Text(
                    duplicateWarning!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: providerNameController,
                  decoration: InputDecoration(labelText: _providerLabel(context)),
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Amount',
                      da: 'Beløb',
                      de: 'Betrag',
                      es: 'Importe',
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? localeText(
                          context,
                          en: 'Amount is required',
                          da: 'Beløb er påkrævet',
                          de: 'Betrag ist erforderlich',
                          es: 'El importe es obligatorio',
                        )
                      : null,
                ),
                const SizedBox(height: BizootSpacing.md),
                _buildCurrencyField(),
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _PremiumSectionCard(
            icon: Icons.bolt_outlined,
            title: localeText(
              context,
              en: 'Trials and reminders',
              da: 'Prøver og påmindelser',
              de: 'Testphasen und Erinnerungen',
              es: 'Pruebas y recordatorios',
            ),
            subtitle: localeText(
              context,
              en: 'Keep upcoming charges visible before they become expensive surprises.',
              da: 'Hold kommende opkrævninger synlige, før de bliver dyre overraskelser.',
              de: 'Behalte kommende Abbuchungen im Blick, bevor sie zu teuren Überraschungen werden.',
              es: 'Mantén visibles los próximos cargos antes de que se conviertan en sorpresas costosas.',
            ),
            child: Column(
              children: [
                _ToggleRow(
                  title: localeText(
                    context,
                    en: 'Payment reminder',
                    da: 'Betalingspåmindelse',
                    de: 'Zahlungserinnerung',
                    es: 'Recordatorio de pago',
                  ),
                  subtitle: localeText(
                    context,
                    en: 'Pre-charge reminders for upcoming payments.',
                    da: 'Påmindelser før opkrævning for kommende betalinger.',
                    de: 'Erinnerungen vor der Abbuchung für bevorstehende Zahlungen.',
                    es: 'Recordatorios previos al cobro para pagos próximos.',
                  ),
                  value: reminderEnabled,
                  onChanged: onReminderEnabledChanged,
                ),
                const SizedBox(height: BizootSpacing.sm),
                _ToggleRow(
                  title: localeText(
                    context,
                    en: 'Free trial',
                    da: 'Gratis prøveperiode',
                    de: 'Kostenlose Testphase',
                    es: 'Prueba gratuita',
                  ),
                  subtitle: localeText(
                    context,
                    en: 'Track trials separately and warn before conversion.',
                    da: 'Følg prøveperioder separat og få en advarsel før konvertering.',
                    de: 'Verfolge Testphasen separat und lass dich vor der Umwandlung warnen.',
                    es: 'Controla las pruebas por separado y recibe aviso antes de la conversión.',
                  ),
                  value: isTrial,
                  onChanged: onTrialChanged,
                ),
                if (isTrial) ...[
                  const SizedBox(height: BizootSpacing.md),
                  _DateSelectorTile(
                    icon: Icons.timer_outlined,
                    label: localeText(
                      context,
                      en: 'Trial end date',
                      da: 'Slutdato for prøveperiode',
                      de: 'Ende der Testphase',
                      es: 'Fecha de fin de la prueba',
                    ),
                    value: trialEndDate == null
                        ? localeText(
                            context,
                            en: 'Choose date',
                            da: 'Vælg dato',
                            de: 'Datum wählen',
                            es: 'Elegir fecha',
                          )
                        : '${trialEndDate!.month}/${trialEndDate!.day}/${trialEndDate!.year}',
                    accent: BizootColors.orange,
                    onTap: () => onPickDate(true),
                  ),
                  const SizedBox(height: BizootSpacing.md),
                  TextFormField(
                    controller: convertsToPaidController,
                    decoration: InputDecoration(
                      labelText: localeText(
                        context,
                        en: 'Converts to paid amount',
                        da: 'Bliver til betalt beløb',
                        de: 'Wird zu kostenpflichtigem Betrag',
                        es: 'Se convierte en importe de pago',
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: BizootSpacing.md),
                  TextFormField(
                    controller: trialNotesController,
                    decoration: InputDecoration(
                      labelText: localeText(
                        context,
                        en: 'Trial notes',
                        da: 'Noter om prøveperiode',
                        de: 'Notizen zur Testphase',
                        es: 'Notas de la prueba',
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: BizootSpacing.sm),
                  _ToggleRow(
                    title: localeText(
                      context,
                      en: 'Trial reminder',
                      da: 'Påmindelse om prøveperiode',
                      de: 'Erinnerung an Testphase',
                      es: 'Recordatorio de prueba',
                    ),
                    subtitle: localeText(
                      context,
                      en: 'Alert me before the trial turns into a paid charge.',
                      da: 'Advar mig før prøveperioden bliver til en betalt opkrævning.',
                      de: 'Benachrichtige mich, bevor die Testphase in eine kostenpflichtige Abbuchung übergeht.',
                      es: 'Avísame antes de que la prueba se convierta en un cargo de pago.',
                    ),
                    value: trialReminderEnabled,
                    onChanged: onTrialReminderChanged,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          _PremiumSectionCard(
            icon: Icons.cancel_outlined,
            title: localeText(
              context,
              en: 'Cancellation assistant',
              da: 'Opsigelseshjælp',
              de: 'Kündigungsassistent',
              es: 'Asistente de cancelación',
            ),
            subtitle: localeText(
              context,
              en: 'Store the exact cancellation path and status before the next charge hits.',
              da: 'Gem den præcise opsigelsesvej og status, før næste opkrævning rammer.',
              de: 'Speichere den genauen Kündigungsweg und Status, bevor die nächste Abbuchung erfolgt.',
              es: 'Guarda la vía exacta de cancelación y el estado antes de que llegue el próximo cobro.',
            ),
            child: Column(
              children: [
                _buildDropdownField<PaymentStatus>(
                  context: context,
                  value: status,
                  values: PaymentStatus.values,
                  label: localeText(
                    context,
                    en: 'Status',
                    da: 'Status',
                    de: 'Status',
                    es: 'Estado',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onStatusChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                _buildDropdownField<CancellationStatus>(
                  context: context,
                  value: cancellationStatus,
                  values: CancellationStatus.values,
                  label: localeText(
                    context,
                    en: 'Cancellation status',
                    da: 'Opsigelsesstatus',
                    de: 'Kündigungsstatus',
                    es: 'Estado de cancelación',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onCancellationStatusChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: cancellationUrlController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Cancellation URL',
                      da: 'Opsigelses-URL',
                      de: 'Kündigungs-URL',
                      es: 'URL de cancelación',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: managementUrlController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Management URL',
                      da: 'Administrations-URL',
                      de: 'Verwaltungs-URL',
                      es: 'URL de gestión',
                    ),
                  ),
                ),
                if (showCancellationUrlAutoFilledBadge) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  _InfoBadge(
                    label: localeText(
                      context,
                      en: 'Cancellation link auto-filled',
                      da: 'Opsigelseslink udfyldt automatisk',
                      de: 'Kündigungslink automatisch ausgefüllt',
                      es: 'Enlace de cancelación completado automáticamente',
                    ),
                    accent: BizootColors.secondary,
                  ),
                ] else if (showMissingCancellationUrlHelper) ...[
                  const SizedBox(height: BizootSpacing.sm),
                  Text(
                    localeText(
                      context,
                      en: 'No cancellation URL found. You can add it manually.',
                      da: 'Ingen opsigelses-URL fundet. Du kan tilføje den manuelt.',
                      de: 'Keine Kündigungs-URL gefunden. Du kannst sie manuell hinzufügen.',
                      es: 'No se encontró ninguna URL de cancelación. Puedes añadirla manualmente.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: cancellationNotesController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Cancellation notes',
                      da: 'Opsigelsesnoter',
                      de: 'Kündigungsnotizen',
                      es: 'Notas de cancelación',
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: BizootSpacing.sm),
                _InfoBadge(
                  label: isCancellable
                      ? localeText(
                          context,
                          en: 'Cancellable item',
                          da: 'Kan opsiges',
                          de: 'Kündbar',
                          es: 'Cancelable',
                        )
                      : localeText(
                          context,
                          en: 'Managed item only',
                          da: 'Kun administreret element',
                          de: 'Nur verwalteter Eintrag',
                          es: 'Solo elemento gestionado',
                        ),
                  accent: isCancellable
                      ? BizootColors.secondary
                      : BizootColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          if (documentsSection != null) ...[
            documentsSection!,
            const SizedBox(height: BizootSpacing.md),
          ],
          _PremiumSectionCard(
            icon: Icons.lock_person_outlined,
            title: localeText(
              context,
              en: 'Login details',
              da: 'Loginoplysninger',
              de: 'Anmeldedaten',
              es: 'Datos de acceso',
            ),
            subtitle: localeText(
              context,
              en: 'Save sign-in details for easy reference.',
              da: 'Gem loginoplysninger for hurtig reference.',
              de: 'Speichere Anmeldedaten zum schnellen Nachschlagen.',
              es: 'Guarda los datos de acceso para consultarlos fácilmente.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: loginEmailController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Login Email',
                      da: 'Loginmail',
                      de: 'Anmelde-E-Mail',
                      es: 'Correo de acceso',
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Username / Account Name',
                      da: 'Brugernavn / kontonavn',
                      de: 'Benutzername / Kontoname',
                      es: 'Usuario / nombre de cuenta',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                _buildDropdownField<SignInMethod>(
                  context: context,
                  value: signInMethod,
                  values: SignInMethod.values,
                  label: localeText(
                    context,
                    en: 'Sign-in Method',
                    da: 'Loginmetode',
                    de: 'Anmeldemethode',
                    es: 'Método de acceso',
                  ),
                  displayLabel: (item) => item.displayLabel,
                  onChanged: onSignInMethodChanged,
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: passwordHintController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Password Hint',
                      da: 'Adgangskodehint',
                      de: 'Passworthinweis',
                      es: 'Pista de contraseña',
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: recoveryEmailController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Recovery Email',
                      da: 'Gendannelsesmail',
                      de: 'Wiederherstellungs-E-Mail',
                      es: 'Correo de recuperación',
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (category == PaymentCategory.insurance ||
                    category == PaymentCategory.loan ||
                    category == PaymentCategory.contract) ...[
                  const SizedBox(height: BizootSpacing.md),
                  TextFormField(
                    controller: policyNumberController,
                    decoration: InputDecoration(
                      labelText: category == PaymentCategory.loan
                          ? localeText(
                              context,
                              en: 'Account / Reference Number',
                              da: 'Konto- / referencenummer',
                              de: 'Konto- / Referenznummer',
                              es: 'Número de cuenta / referencia',
                            )
                          : localeText(
                              context,
                              en: 'Policy / Reference Number',
                              da: 'Policenummer / referencenummer',
                              de: 'Policen- / Referenznummer',
                              es: 'Número de póliza / referencia',
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  controller: accountNotesController,
                  decoration: InputDecoration(
                    labelText: localeText(
                      context,
                      en: 'Private Notes',
                      da: 'Private noter',
                      de: 'Private Notizen',
                      es: 'Notas privadas',
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: BizootSpacing.sm),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _PremiumSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonIconBox(icon: icon, size: 42),
              const SizedBox(width: BizootSpacing.sm),
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
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BizootSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  final List<SubscriptionSuggestionItem> knownServices;
  final List<SubscriptionSuggestionItem> customServices;
  final ValueChanged<SubscriptionSuggestionItem> onSelected;

  const _SuggestionsCard({
    required this.knownServices,
    required this.customServices,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (knownServices.isNotEmpty) {
      items.add(
        _SuggestionSectionLabel(
          label: localeText(
            context,
            en: 'Known services',
            da: 'Kendte tjenester',
            de: 'Bekannte Dienste',
            es: 'Servicios conocidos',
          ),
        ),
      );
      items.addAll(
        knownServices.map(
          (service) => _SuggestionRow(service: service, onSelected: onSelected),
        ),
      );
    }
    if (customServices.isNotEmpty) {
      if (items.isNotEmpty) {
        items.add(const Divider(height: 1, thickness: 1));
      }
      items.add(
        _SuggestionSectionLabel(
          label: localeText(
            context,
            en: 'Your custom services',
            da: 'Dine brugerdefinerede tjenester',
            de: 'Deine benutzerdefinierten Dienste',
            es: 'Tus servicios personalizados',
          ),
        ),
      );
      items.addAll(
        customServices.map(
          (service) => _SuggestionRow(service: service, onSelected: onSelected),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          children: items,
        ),
      ),
    );
  }
}

class _SuggestionSectionLabel extends StatelessWidget {
  final String label;

  const _SuggestionSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: BizootColors.textSecondary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final SubscriptionSuggestionItem service;
  final ValueChanged<SubscriptionSuggestionItem> onSelected;

  const _SuggestionRow({required this.service, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cancelUrl = service.cancellationUrl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          FocusScope.of(context).unfocus();
          onSelected(service);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              BrandIcon(
                serviceId: service.id,
                serviceName: service.name,
                category: service.category,
                iconKey: service.icon,
                size: 42,
              ),
              const SizedBox(width: BizootSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.badgeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: service.isCustom
                            ? BizootColors.orange
                            : BizootColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: BizootSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cancelUrl.trim().isNotEmpty
                      ? BizootColors.secondary.withValues(alpha: 0.14)
                      : BizootColors.textMuted.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: cancelUrl.trim().isNotEmpty
                        ? BizootColors.secondary.withValues(alpha: 0.26)
                        : BizootColors.textMuted.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  cancelUrl.trim().isNotEmpty
                      ? localeText(
                          context,
                          en: 'Cancel link',
                          da: 'Opsigelseslink',
                          de: 'Kündigungslink',
                          es: 'Enlace de cancelación',
                        )
                      : localeText(
                          context,
                          en: 'Manual link',
                          da: 'Manuelt link',
                          de: 'Manueller Link',
                          es: 'Enlace manual',
                        ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color accent;

  const _InfoBadge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: BizootColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? accent;

  const _DateSelectorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (accent ?? BizootColors.border).withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent ?? BizootColors.textSecondary),
            const SizedBox(width: BizootSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: BizootColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: BizootColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.75)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
