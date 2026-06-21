import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/country_currency_data.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bizoot_branding.dart';
import '../widgets/country_autocomplete_field.dart';
import '../widgets/glass_gradient_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _incomeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _step = 0;
  String _preferredCurrency = 'USD';
  String _financialGoal = 'Save money';
  int _estimatedSubscriptions = 5;
  String? _avatarPath;

  static const _goals = <String>[
    'Save money',
    'Track bills',
    'Avoid surprise charges',
    'Cancel unused subscriptions',
  ];

  static const _subscriptionOptions = <int>[2, 4, 6, 8, 10];

  AppLocalizations _l10n(BuildContext context) {
    return AppLocalizations.of(context) ??
        AppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AppState>().userProfile;
      _fullNameController.text = profile.fullName;
      _phoneController.text = profile.phone;
      _countryController.text = profile.country;
      _incomeController.text = profile.monthlyIncome <= 0
          ? ''
          : profile.monthlyIncome.toStringAsFixed(0);
      _preferredCurrency = profile.preferredCurrency;
      _avatarPath = profile.avatarUrl;
      _financialGoal = _goals.contains(profile.financialGoal)
          ? profile.financialGoal
          : _goals.first;
      _estimatedSubscriptions =
          _subscriptionOptions.contains(profile.estimatedSubscriptions)
          ? profile.estimatedSubscriptions
          : 6;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _applyCountrySelection(CountryCurrency country) {
    setState(() {
      _countryController.text = country.name;
      _preferredCurrency = country.currencyCode;
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = _l10n(context);

    return AppScaffold(
      useSafeArea: false,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SizedBox(height: 8),
            _ProgressHeader(step: _step),
            const SizedBox(height: 18),
            if (_step == 0)
              _buildProfileStep(context)
            else
              _buildFinancialStep(context),
            const SizedBox(height: BizootSpacing.lg),
            Row(
              children: [
                if (_step == 1)
                  Expanded(
                    child: AppButton(
                      label: l10n.back,
                      icon: Icons.arrow_back_rounded,
                      secondary: true,
                      onPressed: () => setState(() => _step = 0),
                    ),
                  ),
                if (_step == 1) const SizedBox(width: BizootSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: _step == 0
                        ? l10n.continueLabel
                        : (appState.isSavingSettings
                              ? l10n.finishingSetup
                              : l10n.finishSetup),
                    icon: _step == 0
                        ? Icons.arrow_forward_rounded
                        : Icons.check_circle_outline,
                    isLoading: _step == 1 && appState.isSavingSettings,
                    onPressed: () async {
                      if (_step == 0) {
                        if (_fullNameController.text.trim().isEmpty ||
                            _countryController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.fullNameAndCountryRequired),
                            ),
                          );
                          return;
                        }
                        final matchedCountry = findCountryByName(
                          _countryController.text.trim(),
                        );
                        if (matchedCountry == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.validCountryRequired)),
                          );
                          return;
                        }
                        _preferredCurrency = matchedCountry.currencyCode;
                        setState(() => _step = 1);
                        return;
                      }

                      final matchedCountry = findCountryByName(
                        _countryController.text.trim(),
                      );
                      if (matchedCountry != null) {
                        _preferredCurrency = matchedCountry.currencyCode;
                      }
                      final profile = appState.userProfile.copyWith(
                        userId: appState.settings.userId,
                        fullName: _fullNameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        avatarUrl:
                            _avatarPath == null || _avatarPath!.trim().isEmpty
                            ? null
                            : _avatarPath!.trim(),
                        country: _countryController.text.trim(),
                        preferredCurrency: _preferredCurrency,
                        monthlyIncome:
                            double.tryParse(_incomeController.text) ?? 0,
                        financialGoal: _financialGoal,
                        estimatedSubscriptions: _estimatedSubscriptions,
                        onboardingCompleted: true,
                        updatedAt: DateTime.now(),
                      );
                      await appState.completeOnboarding(profile);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep(BuildContext context) {
    final l10n = _l10n(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileSetup,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.profileSetupSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: BizootColors.textSecondary),
        ),
        const SizedBox(height: BizootSpacing.xl),
        GlassGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _pickProfileImage,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BizootGradients.main,
                          boxShadow: [
                            BoxShadow(
                              color: BizootColors.primary.withValues(
                                alpha: 0.24,
                              ),
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: BizootColors.textPrimary,
                                      ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _avatarProvider() == null
                          ? l10n.tapChooseProfilePicture
                          : l10n.profilePictureSelected,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.opensPhoneGallery,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BizootSpacing.lg),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: l10n.fullName),
              ),
              const SizedBox(height: BizootSpacing.md),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumberOptional,
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              CountryAutocompleteField(
                controller: _countryController,
                label: l10n.country,
                onSelected: _applyCountrySelection,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialStep(BuildContext context) {
    final l10n = _l10n(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.financialSetup,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.financialSetupSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: BizootColors.textSecondary),
        ),
        const SizedBox(height: BizootSpacing.xl),
        GlassGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: ValueKey(_preferredCurrency),
                initialValue: _preferredCurrency,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.currency,
                  helperText: l10n.currencyAutoSelected,
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              TextField(
                controller: _incomeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.monthlyIncome,
                  helperText: l10n.monthlyIncomeHelper,
                ),
              ),
              const SizedBox(height: BizootSpacing.md),
              Text(
                l10n.mainFinancialGoal,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BizootColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: BizootSpacing.sm),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _goals.map((goal) {
                  final selected = _financialGoal == goal;
                  return InkWell(
                    onTap: () => setState(() => _financialGoal = goal),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: BizootDurations.medium,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? BizootGradients.main : null,
                        color: selected
                            ? null
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.18)
                              : BizootColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        _localizedGoal(l10n, goal),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: BizootSpacing.md),
              _DropdownField<int>(
                label: l10n.estimatedSubscriptions,
                value: _estimatedSubscriptions,
                values: _subscriptionOptions,
                onChanged: (value) => setState(
                  () => _estimatedSubscriptions =
                      value ?? _estimatedSubscriptions,
                ),
                displayLabel: (item) =>
                    _estimatedSubscriptionsLabel(l10n, item),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int step;

  const _ProgressHeader({required this.step});

  AppLocalizations _l10n(BuildContext context) {
    return AppLocalizations.of(context) ??
        AppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n(context);
    final currentStep = step + 1;
    return Row(
      children: [
        const BizootLogo(height: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _onboardingStepLabel(l10n, currentStep, 2),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BizootColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: currentStep / 2,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    BizootColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T?> onChanged;
  final String Function(T item) displayLabel;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.displayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: BizootColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      itemHeight: 56,
      menuMaxHeight: 320,
      dropdownColor: BizootColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
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
}

String _localizedGoal(AppLocalizations l10n, String goal) {
  switch (goal) {
    case 'Save money':
      return l10n.goalSaveMoney;
    case 'Track bills':
      return l10n.goalTrackBills;
    case 'Avoid surprise charges':
      return l10n.goalAvoidSurpriseCharges;
    case 'Cancel unused subscriptions':
      return l10n.goalCancelUnusedSubscriptions;
    default:
      return goal;
  }
}

String _estimatedSubscriptionsLabel(AppLocalizations l10n, int count) {
  switch (l10n.locale.languageCode) {
    case 'da':
      return '$count abonnementer';
    case 'de':
      return '$count Abonnements';
    case 'es':
      return '$count suscripciones';
    default:
      return '$count subscriptions';
  }
}

String _onboardingStepLabel(AppLocalizations l10n, int current, int total) {
  switch (l10n.locale.languageCode) {
    case 'da':
      return 'Trin $current af $total';
    case 'de':
      return 'Schritt $current von $total';
    case 'es':
      return 'Paso $current de $total';
    default:
      return 'Step $current of $total';
  }
}
