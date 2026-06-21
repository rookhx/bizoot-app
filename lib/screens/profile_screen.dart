import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../utils/country_currency_data.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/country_autocomplete_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _incomeController;
  late final TextEditingController _countryController;
  late final TextEditingController _currencyController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _didInitialize = false;
  String _financialGoal = 'Save money';
  int _estimatedSubscriptions = 5;
  String? _avatarPath;

  static const _goals = <String>[
    'Save money',
    'Track bills',
    'Avoid surprise charges',
    'Cancel unused subscriptions',
  ];

  static const _subscriptionOptions = <int>[1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _incomeController = TextEditingController();
    _countryController = TextEditingController();
    _currencyController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return const InputDecoration().copyWith(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _applyCountrySelection(CountryCurrency country) {
    setState(() {
      _countryController.text = country.name;
      _currencyController.text = country.currencyCode;
    });
  }

  Future<void> _pickProfileImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (file == null || !mounted) return;
    setState(() => _avatarPath = file.path);
  }

  void _removeProfileImage() {
    setState(() => _avatarPath = null);
  }

  ImageProvider<Object>? _avatarProvider() {
    final path = _avatarPath?.trim();
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!_didInitialize) {
      _fullNameController.text = appState.userProfile.fullName;
      _phoneController.text = appState.userProfile.phone;
      _incomeController.text = appState.userProfile.monthlyIncome <= 0
          ? ''
          : appState.userProfile.monthlyIncome.toStringAsFixed(0);
      _countryController.text = appState.userProfile.country;
      _currencyController.text = appState.userProfile.preferredCurrency;
      _avatarPath = appState.userProfile.avatarUrl;
      _financialGoal = _goals.contains(appState.userProfile.financialGoal)
          ? appState.userProfile.financialGoal
          : _goals.first;
      _estimatedSubscriptions = _subscriptionOptions.contains(appState.userProfile.estimatedSubscriptions)
          ? appState.userProfile.estimatedSubscriptions
          : 5;
      _didInitialize = true;
    }

    return AppScaffold(
      title: localeText(
        context,
        en: 'Profile',
        da: 'Profil',
        de: 'Profil',
        es: 'Perfil',
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 120 + MediaQuery.of(context).padding.bottom),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BizootGradients.main,
                          boxShadow: [
                            BoxShadow(
                              color: BizootColors.primary.withValues(alpha: 0.24),
                              blurRadius: 22,
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: BizootColors.surfaceElevated,
                          backgroundImage: _avatarProvider(),
                          child: _avatarProvider() == null
                              ? Text(
                                  _initials(_fullNameController.text),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: BizootColors.textPrimary,
                                      ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _avatarProvider() == null
                            ? localeText(
                                context,
                                en: 'Choose a profile picture',
                                da: 'Vælg et profilbillede',
                                de: 'Wähle ein Profilbild',
                                es: 'Elige una foto de perfil',
                              )
                            : localeText(
                                context,
                                en: 'Profile picture selected',
                                da: 'Profilbillede valgt',
                                de: 'Profilbild ausgewählt',
                                es: 'Foto de perfil seleccionada',
                              ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickProfileImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _avatarProvider() == null
                                  ? localeText(
                                      context,
                                      en: 'Choose from gallery',
                                      da: 'Vælg fra galleri',
                                      de: 'Aus Galerie wählen',
                                      es: 'Elegir de la galería',
                                    )
                                  : localeText(
                                      context,
                                      en: 'Change photo',
                                      da: 'Skift billede',
                                      de: 'Foto ändern',
                                      es: 'Cambiar foto',
                                    ),
                            ),
                          ),
                          if (_avatarProvider() != null)
                            OutlinedButton.icon(
                              onPressed: _removeProfileImage,
                              icon: const Icon(Icons.delete_outline),
                              label: Text(
                                localeText(
                                  context,
                                  en: 'Remove',
                                  da: 'Fjern',
                                  de: 'Entfernen',
                                  es: 'Quitar',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BizootSpacing.lg),
                TextField(
                  controller: _fullNameController,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Full name',
                      da: 'Fulde navn',
                      de: 'Vollständiger Name',
                      es: 'Nombre completo',
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: BizootSpacing.md),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Phone number (optional)',
                      da: 'Telefonnummer (valgfri)',
                      de: 'Telefonnummer (optional)',
                      es: 'Número de teléfono (opcional)',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  initialValue: appState.authService.currentUser?.email ??
                      localeText(
                        context,
                        en: 'Not signed in',
                        da: 'Ikke logget ind',
                        de: 'Nicht angemeldet',
                        es: 'Sin iniciar sesión',
                      ),
                  readOnly: true,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Email',
                      da: 'E-mail',
                      de: 'E-Mail',
                      es: 'Correo electrónico',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                CountryAutocompleteField(
                  controller: _countryController,
                  label: localeText(
                    context,
                    en: 'Country',
                    da: 'Land',
                    de: 'Land',
                    es: 'País',
                  ),
                  onSelected: _applyCountrySelection,
                ),
                const SizedBox(height: BizootSpacing.md),
                TextFormField(
                  key: ValueKey(_currencyController.text.trim().toUpperCase()),
                  initialValue: _currencyController.text.trim().toUpperCase(),
                  readOnly: true,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Currency from selected country',
                      da: 'Valuta fra valgt land',
                      de: 'Währung aus dem gewählten Land',
                      es: 'Moneda del país seleccionado',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                TextField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Monthly income',
                      da: 'Månedlig indkomst',
                      de: 'Monatliches Einkommen',
                      es: 'Ingresos mensuales',
                    ),
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _financialGoal,
                  isExpanded: true,
                  dropdownColor: BizootColors.surfaceElevated,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Main financial goal',
                      da: 'Vigtigste økonomiske mål',
                      de: 'Wichtigstes finanzielles Ziel',
                      es: 'Objetivo financiero principal',
                    ),
                  ),
                  items: _goals
                      .map(
                        (goal) => DropdownMenuItem<String>(
                          value: goal,
                          child: Text(_localizedGoal(context, goal)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _financialGoal = value);
                  },
                ),
                const SizedBox(height: BizootSpacing.md),
                DropdownButtonFormField<int>(
                  initialValue: _estimatedSubscriptions,
                  isExpanded: true,
                  dropdownColor: BizootColors.surfaceElevated,
                  decoration: _fieldDecoration(
                    localeText(
                      context,
                      en: 'Estimated subscriptions',
                      da: 'Anslåede abonnementer',
                      de: 'Geschätzte Abos',
                      es: 'Suscripciones estimadas',
                    ),
                  ),
                  items: _subscriptionOptions
                      .map(
                        (count) => DropdownMenuItem<int>(
                          value: count,
                          child: Text(
                            localeText(
                              context,
                              en: '$count subscriptions',
                              da: '$count abonnementer',
                              de: '$count Abos',
                              es: '$count suscripciones',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _estimatedSubscriptions = value);
                  },
                ),
                const SizedBox(height: BizootSpacing.lg),
                AppButton(
                  label: appState.isSavingSettings
                      ? localeText(
                          context,
                          en: 'Saving profile...',
                          da: 'Gemmer profil...',
                          de: 'Profil wird gespeichert...',
                          es: 'Guardando perfil...',
                        )
                      : localeText(
                          context,
                          en: 'Save profile',
                          da: 'Gem profil',
                          de: 'Profil speichern',
                          es: 'Guardar perfil',
                        ),
                  icon: Icons.check_circle_outline,
                  isLoading: appState.isSavingSettings,
                  onPressed: () async {
                    AppHaptics.tap();
                    if (_fullNameController.text.trim().isEmpty || _countryController.text.trim().isEmpty) {
                      showErrorSnackBar(
                        context,
                        localeText(
                          context,
                          en: 'Full name and country are required.',
                          da: 'Fulde navn og land er påkrævet.',
                          de: 'Vollständiger Name und Land sind erforderlich.',
                          es: 'El nombre completo y el país son obligatorios.',
                        ),
                      );
                      return;
                    }
                    final matchedCountry = findCountryByName(_countryController.text.trim());
                    if (matchedCountry == null) {
                      showErrorSnackBar(
                        context,
                        localeText(
                          context,
                          en: 'Please select a valid country from the list.',
                          da: 'Vælg venligst et gyldigt land fra listen.',
                          de: 'Bitte wähle ein gültiges Land aus der Liste.',
                          es: 'Selecciona un país válido de la lista.',
                        ),
                      );
                      return;
                    }
                    _currencyController.text = matchedCountry.currencyCode;
                    try {
                      final nextProfile = appState.userProfile.copyWith(
                        fullName: _fullNameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        avatarUrl: _avatarPath == null || _avatarPath!.trim().isEmpty ? null : _avatarPath!.trim(),
                        country: _countryController.text.trim(),
                        preferredLanguage: appState.settings.preferredLanguage,
                        preferredCurrency: _currencyController.text.trim().toUpperCase(),
                        monthlyIncome: double.tryParse(_incomeController.text) ?? 0,
                        financialGoal: _financialGoal,
                        estimatedSubscriptions: _estimatedSubscriptions,
                        onboardingCompleted: true,
                      );
                      await appState.saveProfileAndSettings(
                        nextProfile,
                        appState.settings.copyWith(
                          monthlyIncome: nextProfile.monthlyIncome,
                          currency: nextProfile.preferredCurrency,
                          country: nextProfile.country,
                          preferredLanguage: appState.settings.preferredLanguage,
                          financialGoal: nextProfile.financialGoal,
                          estimatedSubscriptions: nextProfile.estimatedSubscriptions,
                          onboardingCompleted: true,
                        ),
                      );
                      if (!context.mounted) return;
                      AppHaptics.success();
                      showSuccessSnackBar(
                        context,
                        localeText(
                          context,
                          en: 'Profile saved.',
                          da: 'Profil gemt.',
                          de: 'Profil gespeichert.',
                          es: 'Perfil guardado.',
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      showErrorSnackBar(
                        context,
                        localeText(
                          context,
                          en: 'We could not save your profile right now.',
                          da: 'Vi kunne ikke gemme din profil lige nu.',
                          de: 'Dein Profil konnte gerade nicht gespeichert werden.',
                          es: 'No pudimos guardar tu perfil en este momento.',
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (parts.isEmpty) return 'B';
    return parts.map((item) => item[0].toUpperCase()).join();
  }

  String _localizedGoal(BuildContext context, String goal) {
    switch (goal) {
      case 'Save money':
        return localeText(
          context,
          en: 'Save money',
          da: 'Spar penge',
          de: 'Geld sparen',
          es: 'Ahorrar dinero',
        );
      case 'Track bills':
        return localeText(
          context,
          en: 'Track bills',
          da: 'Hold styr på regninger',
          de: 'Rechnungen verfolgen',
          es: 'Controlar facturas',
        );
      case 'Avoid surprise charges':
        return localeText(
          context,
          en: 'Avoid surprise charges',
          da: 'Undgå overraskende gebyrer',
          de: 'Überraschende Gebühren vermeiden',
          es: 'Evitar cargos sorpresa',
        );
      case 'Cancel unused subscriptions':
        return localeText(
          context,
          en: 'Cancel unused subscriptions',
          da: 'Opsig ubrugte abonnementer',
          de: 'Ungenutzte Abos kündigen',
          es: 'Cancelar suscripciones no usadas',
        );
      default:
        return goal;
    }
  }
}
