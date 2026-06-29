import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../models/custom_subscription_service.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../services/app_state.dart';
import '../services/custom_subscription_database_service.dart';
import '../services/document_storage_service.dart';
import '../services/subscription_database_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_haptics.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand_icon.dart';
import '../widgets/document_card.dart';
import '../widgets/glass_gradient_card.dart';
import '../widgets/payment_form.dart';
import 'email_import_flow_screen.dart';
import 'subscription_limit_paywall_screen.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _cancellationUrlController = TextEditingController();
  final _managementUrlController = TextEditingController();
  final _cancellationNotesController = TextEditingController();
  final _trialNotesController = TextEditingController();
  final _convertsToPaidController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordHintController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _accountNotesController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _documentLabelController = TextEditingController();
  final _subscriptionDatabase = SubscriptionDatabaseService.instance;
  static const List<SubscriptionServiceEntry> _fallbackServices = [
    SubscriptionServiceEntry(
      id: 'spotify',
      name: 'Spotify',
      category: 'Music',
      aliases: ['spotify premium', 'spotify family'],
      website: 'https://spotify.com',
      cancelUrl: 'https://www.spotify.com/account/subscription',
      cancelUrlType: 'direct',
      icon: 'music',
      color: '#1DB954',
      commonBilling: 'monthly',
      averageMonthlyCost: 10.99,
      tags: ['music', 'streaming', 'audio'],
    ),
    SubscriptionServiceEntry(
      id: 'netflix',
      name: 'Netflix',
      category: 'Streaming',
      aliases: ['netflix standard', 'netflix premium'],
      website: 'https://www.netflix.com',
      cancelUrl: 'https://www.netflix.com/cancelplan',
      cancelUrlType: 'direct',
      icon: 'movie',
      color: '#E50914',
      commonBilling: 'monthly',
      averageMonthlyCost: 15.99,
      tags: ['video', 'streaming', 'movies'],
    ),
    SubscriptionServiceEntry(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      category: 'Streaming',
      aliases: ['youtube', 'yt premium'],
      website: 'https://www.youtube.com',
      cancelUrl: 'https://www.youtube.com/paid_memberships',
      cancelUrlType: 'direct',
      icon: 'video',
      color: '#FF0000',
      commonBilling: 'monthly',
      averageMonthlyCost: 13.99,
      tags: ['video', 'streaming', 'youtube'],
    ),
    SubscriptionServiceEntry(
      id: 'youtube_music',
      name: 'YouTube Music',
      category: 'Music',
      aliases: ['yt music'],
      website: 'https://music.youtube.com',
      cancelUrl: 'https://www.youtube.com/paid_memberships',
      cancelUrlType: 'direct',
      icon: 'music',
      color: '#FF0000',
      commonBilling: 'monthly',
      averageMonthlyCost: 10.99,
      tags: ['music', 'audio', 'youtube'],
    ),
    SubscriptionServiceEntry(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      category: 'Shopping & Delivery',
      aliases: ['prime', 'amazon', 'amazon membership', 'prime video'],
      website: 'https://www.amazon.com',
      cancelUrl: 'https://www.amazon.com/gp/primecentral',
      cancelUrlType: 'direct',
      icon: 'shopping',
      color: '#00A8E1',
      commonBilling: 'monthly',
      averageMonthlyCost: 14.99,
      tags: ['shopping', 'delivery', 'video', 'amazon'],
    ),
    SubscriptionServiceEntry(
      id: 'canva_pro',
      name: 'Canva Pro',
      category: 'Design',
      aliases: ['canva', 'canva premium'],
      website: 'https://www.canva.com',
      cancelUrl: 'https://www.canva.com/settings/billing-and-plans/',
      cancelUrlType: 'billing_page',
      icon: 'design',
      color: '#00C4CC',
      commonBilling: 'monthly',
      averageMonthlyCost: 12.99,
      tags: ['design', 'productivity', 'graphics'],
    ),
    SubscriptionServiceEntry(
      id: 'chatgpt_plus',
      name: 'ChatGPT Plus',
      category: 'AI',
      aliases: ['chatgpt', 'openai', 'gpt plus'],
      website: 'https://chatgpt.com',
      cancelUrl: 'https://chatgpt.com/#settings/Subscription',
      cancelUrlType: 'billing_page',
      icon: 'ai',
      color: '#10A37F',
      commonBilling: 'monthly',
      averageMonthlyCost: 20,
      tags: ['ai', 'assistant', 'writing'],
    ),
    SubscriptionServiceEntry(
      id: 'google_one',
      name: 'Google One',
      category: 'Cloud Storage',
      aliases: ['google storage', 'google drive'],
      website: 'https://one.google.com',
      cancelUrl: 'https://one.google.com/settings',
      cancelUrlType: 'billing_page',
      icon: 'cloud',
      color: '#4285F4',
      commonBilling: 'monthly',
      averageMonthlyCost: 9.99,
      tags: ['cloud', 'storage', 'backup'],
    ),
    SubscriptionServiceEntry(
      id: 'apple_icloud',
      name: 'Apple iCloud',
      category: 'Cloud Storage',
      aliases: ['icloud', 'icloud+', 'apple storage'],
      website: 'https://www.icloud.com',
      cancelUrl: 'https://support.apple.com/en-us/108314',
      cancelUrlType: 'billing_page',
      icon: 'cloud',
      color: '#5AC8FA',
      commonBilling: 'monthly',
      averageMonthlyCost: 2.99,
      tags: ['cloud', 'storage', 'apple'],
    ),
    SubscriptionServiceEntry(
      id: 'microsoft_365',
      name: 'Microsoft 365',
      category: 'Productivity & Software',
      aliases: ['office 365', 'microsoft office'],
      website: 'https://www.microsoft.com/microsoft-365',
      cancelUrl: 'https://account.microsoft.com/services',
      cancelUrlType: 'billing_page',
      icon: 'briefcase',
      color: '#2563EB',
      commonBilling: 'monthly',
      averageMonthlyCost: 9.99,
      tags: ['productivity', 'office', 'software'],
    ),
  ];

  PaymentCategory _category = PaymentCategory.subscription;
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  ReminderTiming _reminderTiming = ReminderTiming.oneDayBefore;
  PaymentStatus _status = PaymentStatus.active;
  CancellationStatus _cancellationStatus = CancellationStatus.active;
  SignInMethod _signInMethod = SignInMethod.email;
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _renewalDate;
  DateTime? _contractEndDate;
  DateTime? _trialEndDate;
  bool _reminderEnabled = true;
  bool _isTrial = false;
  bool _trialReminderEnabled = true;
  String? _duplicateWarning;
  String _selectedIcon = 'credit_card';
  String? _autoFilledServiceName;
  bool _showCreateCustom = false;
  bool _showKeepTypingHint = false;
  bool _showCancellationUrlAutoFilledBadge = false;
  bool _showMissingCancellationUrlHelper = false;
  bool _isApplyingAutofill = false;
  bool _didInitializeCurrencyFromSettings = false;
  bool? _selectedServiceFromMainDatabase;
  List<SubscriptionServiceEntry> _loadedServices = const [];
  List<SubscriptionSuggestionItem> _knownServiceSuggestions = const [];
  List<SubscriptionSuggestionItem> _customServiceSuggestions = const [];
  List<PickedDocumentAsset> _pendingDocuments = const [];

  List<SubscriptionServiceEntry> get _availableServices {
    return _loadedServices.isNotEmpty ? _loadedServices : _fallbackServices;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleNameControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceDatabase();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeCurrencyFromSettings) return;
    final savedCurrency = context
        .read<AppState>()
        .settings
        .currency
        .trim()
        .toUpperCase();
    _currencyController.text = savedCurrency.isEmpty ? 'USD' : savedCurrency;
    _didInitializeCurrencyFromSettings = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.removeListener(_handleNameControllerChanged);
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

  void _handleNameControllerChanged() {
    if (_isApplyingAutofill) return;
    _handleNameChanged(_nameController.text);
  }

  Future<void> _loadServiceDatabase() async {
    try {
      final services = await _subscriptionDatabase.loadDatabase();

      final merged = <SubscriptionServiceEntry>[];
      final seen = <String>{};
      for (final service in [...services, ..._fallbackServices]) {
        final key = _subscriptionDatabase.normalize(
          '${service.id}-${service.name}',
        );
        if (seen.add(key)) {
          merged.add(service);
        }
      }

      _loadedServices = merged;
    } catch (error, stackTrace) {
      debugPrint('Failed to load subscription database: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (!mounted) return;
    final trimmed = _nameController.text.trim();
    setState(() {
      if (trimmed.length >= 2) {
        _knownServiceSuggestions = _searchKnownServices(trimmed)
            .map(
              (service) => SubscriptionSuggestionItem(
                id: service.id,
                name: service.name,
                category: service.category,
                cancellationUrl: service.cancelUrl ?? '',
                website: service.website,
                icon: service.icon,
                commonBilling: service.commonBilling,
                amount: service.averageMonthlyCost,
                aliases: service.aliases,
                isCustom: false,
              ),
            )
            .toList(growable: false);
        _showCreateCustom =
            trimmed.length >= 3 &&
            _knownServiceSuggestions.isEmpty &&
            _customServiceSuggestions.isEmpty;
      }
    });
  }

  List<SubscriptionServiceEntry> _searchKnownServices(String query) {
    final normalizedQuery = _subscriptionDatabase.normalize(query.trim());
    if (normalizedQuery.length < 2) {
      return const [];
    }

    final ranked = <({SubscriptionServiceEntry service, int score})>[];
    for (final service in _availableServices) {
      final score = _scoreService(service, normalizedQuery);
      if (score > 0) {
        ranked.add((service: service, score: score));
      }
    }

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.service.name.compareTo(b.service.name);
    });

    final results = <SubscriptionServiceEntry>[];
    final seenIds = <String>{};
    for (final item in ranked) {
      if (seenIds.add(item.service.id)) {
        results.add(item.service);
      }
      if (results.length >= 8) break;
    }

    return results;
  }

  SubscriptionServiceEntry? _findExactKnownServiceMatch(String query) {
    final normalizedQuery = _subscriptionDatabase.normalize(query.trim());
    if (normalizedQuery.isEmpty) return null;
    for (final service in _availableServices) {
      final candidates = <String>{
        _subscriptionDatabase.normalize(service.id),
        _subscriptionDatabase.normalize(service.name),
        ...service.aliases.map(_subscriptionDatabase.normalize),
        ...service.tags.map(_subscriptionDatabase.normalize),
      };
      if (candidates.contains(normalizedQuery)) {
        return service;
      }
    }
    return null;
  }

  CustomSubscriptionService? _findExactCustomServiceMatch(
    AppState appState,
    String query,
  ) {
    final normalizedQuery = appState.customSubscriptionDatabaseService
        .normalize(query.trim());
    if (normalizedQuery.isEmpty) return null;
    for (final service in appState.customServices) {
      if (service.normalizedName == normalizedQuery ||
          service.aliases
              .map(appState.customSubscriptionDatabaseService.normalize)
              .contains(normalizedQuery)) {
        return service;
      }
    }
    return null;
  }

  int _scoreService(SubscriptionServiceEntry service, String normalizedQuery) {
    final normalizedName = _subscriptionDatabase.normalize(service.name);
    final normalizedId = _subscriptionDatabase.normalize(service.id);
    final normalizedAliases = service.aliases
        .map(_subscriptionDatabase.normalize)
        .toList(growable: false);
    final normalizedTags = service.tags
        .map(_subscriptionDatabase.normalize)
        .toList(growable: false);

    if (normalizedName == normalizedQuery || normalizedId == normalizedQuery) {
      return 1000;
    }
    if (normalizedAliases.contains(normalizedQuery)) {
      return 950;
    }

    var score = 0;
    if (normalizedName.startsWith(normalizedQuery)) {
      score = score < 900 ? 900 : score;
    }
    if (normalizedId.startsWith(normalizedQuery)) {
      score = score < 880 ? 880 : score;
    }
    if (normalizedAliases.any((alias) => alias.startsWith(normalizedQuery))) {
      score = score < 860 ? 860 : score;
    }
    if (normalizedName.contains(normalizedQuery)) {
      score = score < 760 ? 760 : score;
    }
    if (normalizedAliases.any((alias) => alias.contains(normalizedQuery))) {
      score = score < 720 ? 720 : score;
    }
    if (normalizedTags.any(
      (tag) => tag.startsWith(normalizedQuery) || tag.contains(normalizedQuery),
    )) {
      score = score < 620 ? 620 : score;
    }
    return score;
  }

  void applyServiceAutofill(SubscriptionSuggestionItem service) {
    if (_isApplyingAutofill) return;
    _isApplyingAutofill = true;
    try {
      setState(() {
        _nameController.text = service.name;
        _nameController.selection = TextSelection.collapsed(
          offset: _nameController.text.length,
        );
        _cancellationUrlController.text = service.cancellationUrl;
        _managementUrlController.text = service.website;
        _providerNameController.text = service.name;
        _category = RecurringPayment.categoryFromString(
          service.category.toLowerCase().contains('rent')
              ? 'rent'
              : service.category.toLowerCase().contains('utility')
              ? 'utilities'
              : service.category.toLowerCase().contains('insurance')
              ? 'insurance'
              : service.category.toLowerCase().contains('internet')
              ? 'internet'
              : service.category.toLowerCase().contains('phone')
              ? 'phone'
              : service.category.toLowerCase().contains('loan')
              ? 'loan'
              : service.category.toLowerCase().contains('contract')
              ? 'contract'
              : service.category.toLowerCase().contains('membership') ||
                    service.category.toLowerCase().contains('fitness')
              ? 'gym'
              : 'subscription',
        );
        _frequency = RecurringPayment.frequencyFromString(
          service.commonBilling,
        );
        _renewalDate = _frequency == PaymentFrequency.yearly
            ? _nextDueDate
            : null;
        _selectedIcon = service.id.isNotEmpty
            ? service.id
            : (service.icon.isNotEmpty ? service.icon : 'credit_card');
        _selectedServiceFromMainDatabase = !service.isCustom;

        _autoFilledServiceName = service.name;
        _knownServiceSuggestions = const [];
        _customServiceSuggestions = const [];
        _showCreateCustom = false;
        _showKeepTypingHint = false;
        _showCancellationUrlAutoFilledBadge = _cancellationUrlController.text
            .trim()
            .isNotEmpty;
        _showMissingCancellationUrlHelper = _cancellationUrlController.text
            .trim()
            .isEmpty;
      });

      FocusScope.of(context).unfocus();
    } finally {
      _isApplyingAutofill = false;
    }
  }

  void _handleNameChanged(String value) {
    if (_isApplyingAutofill) return;
    final trimmed = value.trim();
    _selectedServiceFromMainDatabase = null;
    _runSuggestionSearch(trimmed);
  }

  Future<void> _runSuggestionSearch(String trimmed) async {
    final appState = context.read<AppState>();
    final known = _searchKnownServices(trimmed);
    final merged = await appState.customSubscriptionDatabaseService
        .mergeWithMainDatabaseResults(
          trimmed,
          userId: appState.settings.userId,
          mainServices: _availableServices,
          customServices: appState.customServices,
        );
    if (!mounted || _nameController.text.trim() != trimmed) return;

    final knownSuggestions = merged.knownServices;
    final customSuggestions = merged.customServices;
    final exactKnown = _findExactKnownServiceMatch(trimmed);
    final exactCustom = _findExactCustomServiceMatch(appState, trimmed);

    setState(() {
      _knownServiceSuggestions = known.isNotEmpty
          ? known
                .map(
                  (service) => SubscriptionSuggestionItem(
                    id: service.id,
                    name: service.name,
                    category: service.category,
                    cancellationUrl: service.cancelUrl ?? '',
                    website: service.website,
                    icon: service.icon,
                    commonBilling: service.commonBilling,
                    amount: service.averageMonthlyCost,
                    aliases: service.aliases,
                    isCustom: false,
                  ),
                )
                .toList(growable: false)
          : knownSuggestions;
      _customServiceSuggestions = customSuggestions;
      _showKeepTypingHint = trimmed.length == 1;
      _showCreateCustom =
          trimmed.length >= 3 &&
          _knownServiceSuggestions.isEmpty &&
          _customServiceSuggestions.isEmpty;
      if (_knownServiceSuggestions.isNotEmpty ||
          _customServiceSuggestions.isNotEmpty) {
        _autoFilledServiceName = null;
      }
    });

    if (exactKnown != null &&
        _subscriptionDatabase.normalize(exactKnown.name) ==
            _subscriptionDatabase.normalize(trimmed)) {
      applyServiceAutofill(
        SubscriptionSuggestionItem(
          id: exactKnown.id,
          name: exactKnown.name,
          category: exactKnown.category,
          cancellationUrl: exactKnown.cancelUrl ?? '',
          website: exactKnown.website,
          icon: exactKnown.icon,
          commonBilling: exactKnown.commonBilling,
          amount: exactKnown.averageMonthlyCost,
          aliases: exactKnown.aliases,
          isCustom: false,
        ),
      );
      return;
    }
    if (exactCustom != null) {
      applyServiceAutofill(
        SubscriptionSuggestionItem(
          id: exactCustom.id,
          name: exactCustom.name,
          category: exactCustom.category.displayLabel,
          cancellationUrl: exactCustom.cancellationUrl,
          website: exactCustom.website,
          icon: exactCustom.icon,
          commonBilling: exactCustom.frequency.name,
          amount: exactCustom.amount,
          aliases: exactCustom.aliases,
          isCustom: true,
        ),
      );
      return;
    }
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

  Future<void> _attachDocument(AppState appState) async {
    final plannedCount = appState.documents.length + _pendingDocuments.length;
    if (!appState.hasPremiumFeatureAccess &&
        plannedCount >= appState.documentLimit) {
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Upgrade to Bizoot Premium to store unlimited documents.',
          da: 'Opgrader til Bizoot Premium for at gemme ubegrænsede dokumenter.',
          de: 'Upgrade auf Bizoot Premium, um unbegrenzt Dokumente zu speichern.',
          es: 'Actualiza a Bizoot Premium para guardar documentos ilimitados.',
        ),
      );
      return;
    }
    try {
      final asset = await appState.documentStorageService.pickDocument();
      if (asset == null || !mounted) return;
      setState(() {
        _pendingDocuments = [..._pendingDocuments, asset];
      });
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Document attached to this draft item.',
          da: 'Dokument vedhæftet dette kladdeelement.',
          de: 'Dokument an diesen Entwurf angehängt.',
          es: 'Documento adjuntado a este borrador.',
        ),
      );
    } on StateError catch (error) {
      if (!mounted) return;
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

  SubscriptionServiceEntry _serviceFromPreset(QuickPreset preset) {
    final exactMatch = _findExactKnownServiceMatch(preset.name);
    final searchResults = _searchKnownServices(preset.name);
    final matched =
        exactMatch ?? (searchResults.isNotEmpty ? searchResults.first : null);
    if (matched != null) {
      return matched;
    }

    return SubscriptionServiceEntry(
      id: preset.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
      name: preset.name,
      category: preset.category.displayLabel,
      aliases: const [],
      website: '',
      cancelUrl: null,
      cancelUrlType: 'billing_page',
      icon: preset.iconKey,
      color: '#7C4DFF',
      commonBilling: preset.frequency.name,
      averageMonthlyCost: preset.suggestedAmount,
      tags: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.canAddSubscription) {
      return SubscriptionLimitPaywallScreen(
        activeCount: appState.activeSubscriptionCount,
        limit: appState.subscriptionLimit,
        trialActive: appState.isTrialActive,
        trialDaysRemaining: appState.trialDaysRemaining,
        onMaybeLater: () => Navigator.of(context).maybePop(),
      );
    }
    return AppScaffold(
      title: localeText(
        context,
        en: 'Add Payment',
        da: 'Tilføj betaling',
        de: 'Zahlung hinzufügen',
        es: 'Agregar pago',
      ),
      child: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom > 0 ? 32 : 40,
        ),
        children: [
          GlassGradientCard(
            gradient: BizootGradients.surfaceStrong,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Quick add presets',
                    da: 'Hurtige forhåndsvalg',
                    de: 'Schnelle Vorlagen',
                    es: 'Ajustes rápidos',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: BizootSpacing.xs),
                Text(
                  localeText(
                    context,
                    en: 'Jumpstart the form with popular services, then fine-tune the details below.',
                    da: 'Start formularen med populære tjenester, og finjuster derefter detaljerne nedenfor.',
                    de: 'Starte das Formular mit beliebten Diensten und passe die Details darunter an.',
                    es: 'Empieza el formulario con servicios populares y ajusta los detalles abajo.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                if (_loadedServices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BizootSpacing.sm),
                    child: Text(
                      localeText(
                        context,
                        en: 'Bizoot is using its built-in fallback catalog while the full service database loads.',
                        da: 'Bizoot bruger sit indbyggede reservekatalog, mens den fulde servicedatabase indlæses.',
                        de: 'Bizoot verwendet seinen integrierten Ersatzkatalog, während die vollständige Servicedatenbank geladen wird.',
                        es: 'Bizoot está usando su catálogo de respaldo mientras se carga la base de datos completa de servicios.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: appState.presets
                      .map(
                        (preset) => _PresetChip(
                          label: preset.name,
                          iconKey: preset.iconKey,
                          onTap: () {
                            AppHaptics.tap();
                            final service = _serviceFromPreset(preset);
                            applyServiceAutofill(
                              SubscriptionSuggestionItem(
                                id: service.id,
                                name: service.name,
                                category: service.category,
                                cancellationUrl: service.cancelUrl ?? '',
                                website: service.website,
                                icon: service.icon,
                                commonBilling: service.commonBilling,
                                amount: service.averageMonthlyCost,
                                aliases: service.aliases,
                                isCustom: false,
                              ),
                            );
                            setState(() {
                              _reminderTiming = preset.reminderTiming;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: BizootSpacing.md),
          GlassGradientCard(
            gradient: BizootGradients.surfaceStrong,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeText(
                    context,
                    en: 'Import from email',
                    da: 'Importer fra e-mail',
                    de: 'Aus E-Mail importieren',
                    es: 'Importar desde correo',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: BizootSpacing.xs),
                Text(
                  localeText(
                    context,
                    en: 'Connect Gmail or Outlook to detect recurring payments from billing emails before anything is saved.',
                    da: 'Forbind Gmail eller Outlook for at finde tilbagevendende betalinger fra faktureringsmails, før noget gemmes.',
                    de: 'Verbinde Gmail oder Outlook, um wiederkehrende Zahlungen aus Abrechnungs-E-Mails zu erkennen, bevor etwas gespeichert wird.',
                    es: 'Conecta Gmail u Outlook para detectar pagos recurrentes desde correos de facturación antes de guardar nada.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BizootColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BizootSpacing.md),
                AppButton(
                  label: localeText(
                    context,
                    en: 'Connect email',
                    da: 'Forbind e-mail',
                    de: 'E-Mail verbinden',
                    es: 'Conectar correo',
                  ),
                  icon: Icons.mark_email_read_outlined,
                  secondary: true,
                  onPressed: () {
                    AppHaptics.tap();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmailImportFlowScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_autoFilledServiceName != null) ...[
            const SizedBox(height: BizootSpacing.md),
            GlassGradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeText(
                      context,
                      en: 'Bizoot recognized $_autoFilledServiceName',
                      da: 'Bizoot genkendte $_autoFilledServiceName',
                      de: 'Bizoot hat $_autoFilledServiceName erkannt',
                      es: 'Bizoot reconoció $_autoFilledServiceName',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: BizootSpacing.xs),
                  Text(
                    localeText(
                      context,
                      en: 'Service metadata and cancellation link are ready to use.',
                      da: 'Tjenestemetadata og opsigelseslink er klar til brug.',
                      de: 'Servicemetadaten und Kündigungslink sind einsatzbereit.',
                      es: 'Los metadatos del servicio y el enlace de cancelación ya están listos.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: BizootSpacing.md),
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
            isEssential: _category != PaymentCategory.subscription,
            isCancellable:
                _category != PaymentCategory.rent &&
                _category != PaymentCategory.loan,
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
            knownServiceSuggestions: _knownServiceSuggestions,
            customServiceSuggestions: _customServiceSuggestions,
            autoFilledServiceName: _autoFilledServiceName,
            showCreateCustom: _showCreateCustom,
            showKeepTypingHint: _showKeepTypingHint,
            showCancellationUrlAutoFilledBadge:
                _showCancellationUrlAutoFilledBadge,
            showMissingCancellationUrlHelper: _showMissingCancellationUrlHelper,
            onNameChanged: (_) {},
            onServiceSuggestionSelected: applyServiceAutofill,
            documentsSection: _DocumentsDraftSection(
              assets: _pendingDocuments,
              suggestedCategory: _suggestedDocumentCategory,
              isUploading: appState.isUploadingDocument,
              onAttach: () => _attachDocument(appState),
              onDeleteAsset: (asset) {
                setState(() {
                  _pendingDocuments = _pendingDocuments
                      .where((item) => item != asset)
                      .toList(growable: false);
                });
              },
            ),
          ),
          const SizedBox(height: BizootSpacing.lg),
          AppButton(
            label: appState.isSavingPayment
                ? localeText(
                    context,
                    en: 'Saving payment...',
                    da: 'Gemmer betaling...',
                    de: 'Zahlung wird gespeichert...',
                    es: 'Guardando pago...',
                  )
                : localeText(
                    context,
                    en: 'Save payment',
                    da: 'Gem betaling',
                    de: 'Zahlung speichern',
                    es: 'Guardar pago',
                  ),
            icon: Icons.check_circle_outline,
            isLoading: appState.isSavingPayment,
            onPressed: () async {
              AppHaptics.tap();
              setState(() {
                _duplicateWarning =
                    appState.isDuplicate(_nameController.text, _category)
                    ? localeText(
                        context,
                        en: 'You may already be tracking this.',
                        da: 'Det ser ud til, at du allerede følger denne.',
                        de: 'Möglicherweise verfolgst du dies bereits.',
                        es: 'Es posible que ya estés siguiendo esto.',
                      )
                    : null;
              });
              if (!_formKey.currentState!.validate()) return;
              final rememberAsCustom = _selectedServiceFromMainDatabase != true;
              final payment = RecurringPayment(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                userId: appState.settings.userId,
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
                    ? DateTime.now()
                    : null,
                iconKey: _selectedIcon,
                priceHistory: const [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              try {
                if (!appState.canAddSubscription) {
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubscriptionLimitPaywallScreen(
                        activeCount: appState.activeSubscriptionCount,
                        limit: appState.subscriptionLimit,
                        trialActive: appState.isTrialActive,
                        trialDaysRemaining: appState.trialDaysRemaining,
                      ),
                    ),
                  );
                  return;
                }
                await appState.savePayment(
                  payment,
                  rememberAsCustom: rememberAsCustom,
                );
                if (_pendingDocuments.isNotEmpty) {
                  try {
                    await appState.uploadPendingDocumentsForItem(
                      payment.id,
                      _pendingDocuments,
                      category: _suggestedDocumentCategory,
                    );
                    _pendingDocuments = const [];
                  } catch (_) {
                    if (context.mounted) {
                      showSuccessSnackBar(
                        context,
                        localeText(
                          context,
                          en: 'Payment saved. We could not upload the document right now.',
                          da: 'Betalingen blev gemt. Vi kunne ikke uploade dokumentet lige nu.',
                          de: 'Zahlung gespeichert. Das Dokument konnte gerade nicht hochgeladen werden.',
                          es: 'Pago guardado. No pudimos subir el documento en este momento.',
                        ),
                        icon: Icons.info_outline,
                      );
                    }
                  }
                }
                if (rememberAsCustom &&
                    payment.cancellationUrl.isNotEmpty &&
                    context.mounted) {
                  final share = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        localeText(
                          context,
                          en: 'Help improve Bizoot?',
                          da: 'Hjælp med at forbedre Bizoot?',
                          de: 'Bizoot verbessern helfen?',
                          es: 'Ayudar a mejorar Bizoot?',
                        ),
                      ),
                      content: Text(
                        localeText(
                          context,
                          en: 'Share this service suggestion anonymously so we can improve future autofill for everyone?',
                          da: 'Del dette serviceforslag anonymt, så vi kan forbedre fremtidig autofyld for alle?',
                          de: 'Möchtest du diesen Dienstvorschlag anonym teilen, damit wir die künftige Autovervollständigung für alle verbessern können?',
                          es: '¿Quieres compartir esta sugerencia de servicio de forma anónima para mejorar el autocompletado futuro para todos?',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            localeText(
                              context,
                              en: 'Not now',
                              da: 'Ikke nu',
                              de: 'Jetzt nicht',
                              es: 'Ahora no',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            localeText(
                              context,
                              en: 'Share',
                              da: 'Del',
                              de: 'Teilen',
                              es: 'Compartir',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (share == true) {
                    await appState.submitServiceSuggestionForPayment(payment);
                  }
                }
                if (!context.mounted) return;
                AppHaptics.success();
                showSuccessSnackBar(
                  context,
                  rememberAsCustom
                      ? localeText(
                          context,
                          en: 'Payment added. Bizoot saved this custom service for future autofill.',
                          da: 'Betaling tilføjet. Bizoot gemte denne brugerdefinerede tjeneste til fremtidig autofyld.',
                          de: 'Zahlung hinzugefügt. Bizoot hat diesen benutzerdefinierten Dienst für zukünftiges Autofill gespeichert.',
                          es: 'Pago añadido. Bizoot guardó este servicio personalizado para futuros autocompletados.',
                        )
                      : localeText(
                          context,
                          en: 'Payment added successfully.',
                          da: 'Betaling tilføjet.',
                          de: 'Zahlung erfolgreich hinzugefügt.',
                          es: 'Pago añadido correctamente.',
                        ),
                  icon: Icons.check_circle_outline,
                );
                Navigator.of(context).pop();
              } catch (_) {
                if (!context.mounted) return;
                AppHaptics.warning();
                showErrorSnackBar(
                  context,
                  localeText(
                    context,
                    en: 'We could not save this payment right now. Please check the details and try again.',
                    da: 'Vi kunne ikke gemme denne betaling lige nu. Tjek detaljerne og prøv igen.',
                    de: 'Diese Zahlung konnte gerade nicht gespeichert werden. Bitte prüfe die Angaben und versuche es erneut.',
                    es: 'No pudimos guardar este pago en este momento. Revisa los datos e inténtalo de nuevo.',
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String iconKey;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.iconKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: BrandIcon(
        serviceId: label,
        serviceName: label,
        iconKey: iconKey,
        size: 24,
      ),
      label: Text(label),
      side: BorderSide(color: BizootColors.border.withValues(alpha: 0.8)),
      backgroundColor: BizootColors.surfaceElevated.withValues(alpha: 0.95),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: BizootColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

class _DocumentsDraftSection extends StatelessWidget {
  final List<PickedDocumentAsset> assets;
  final UserDocumentCategory suggestedCategory;
  final bool isUploading;
  final VoidCallback onAttach;
  final ValueChanged<PickedDocumentAsset> onDeleteAsset;

  const _DocumentsDraftSection({
    required this.assets,
    required this.suggestedCategory,
    required this.isUploading,
    required this.onAttach,
    required this.onDeleteAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GlassGradientCard(
      gradient: BizootGradients.surfaceStrong,
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
            localeText(
              context,
              en: 'Attach contracts, policies, bills, or agreements related to this item.',
              da: 'Vedhæft kontrakter, policer, regninger eller aftaler, der hører til dette element.',
              de: 'Füge Verträge, Policen, Rechnungen oder Vereinbarungen zu diesem Eintrag hinzu.',
              es: 'Adjunta contratos, pólizas, facturas o acuerdos relacionados con este elemento.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
          ),
          const SizedBox(height: BizootSpacing.md),
          AppButton(
            label: isUploading
                ? localeText(
                    context,
                    en: 'Attaching...',
                    da: 'Vedhæfter...',
                    de: 'Wird angehängt...',
                    es: 'Adjuntando...',
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
            isLoading: isUploading,
            onPressed: isUploading ? null : onAttach,
          ),
          if (assets.isNotEmpty) ...[
            const SizedBox(height: BizootSpacing.md),
            ...assets.map(
              (asset) => Padding(
                padding: const EdgeInsets.only(bottom: BizootSpacing.sm),
                child: DocumentCard(
                  document: UserDocument(
                    id: asset.fileName,
                    userId: '',
                    linkedItemId: null,
                    linkedItemType: null,
                    title: asset.fileName.contains('.')
                        ? asset.fileName.substring(
                            0,
                            asset.fileName.lastIndexOf('.'),
                          )
                        : asset.fileName,
                    originalFileName: asset.fileName,
                    filePath: '',
                    mimeType: asset.mimeType,
                    fileExtension: asset.fileExtension,
                    fileSize: asset.fileSize,
                    documentCategory: suggestedCategory,
                    uploadedAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  linkedItemName: localeText(
                    context,
                    en: 'Ready to attach',
                    da: 'Klar til vedhæftning',
                    de: 'Bereit zum Anhängen',
                    es: 'Listo para adjuntar',
                  ),
                  onDelete: () => onDeleteAsset(asset),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
