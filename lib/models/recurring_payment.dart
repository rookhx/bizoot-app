enum PaymentCategory {
  subscription,
  rent,
  utilities,
  insurance,
  internet,
  phone,
  gym,
  loan,
  membership,
  contract,
  other,
}

enum PaymentFrequency { weekly, monthly, quarterly, yearly }

enum PaymentStatus { active, inactive, cancelled }

enum ReminderTiming { sameDay, oneDayBefore, threeDaysBefore, sevenDaysBefore }

enum CancellationStatus { active, considering, cancelled }

enum SignInMethod { email, google, apple, facebook, phone, other }

String formatDropdownLabel(String value) {
  switch (value) {
    case 'subscription':
      return 'Subscription';
    case 'rent':
      return 'Rent';
    case 'utilities':
      return 'Utilities';
    case 'insurance':
      return 'Insurance';
    case 'internet':
      return 'Internet';
    case 'phone':
      return 'Phone';
    case 'gym':
      return 'Gym';
    case 'loan':
      return 'Loan';
    case 'membership':
      return 'Membership';
    case 'contract':
      return 'Contract';
    case 'other':
      return 'Other';
    case 'weekly':
      return 'Weekly';
    case 'monthly':
      return 'Monthly';
    case 'quarterly':
      return 'Quarterly';
    case 'yearly':
      return 'Yearly';
    case 'sameDay':
      return 'Same day';
    case 'oneDayBefore':
      return 'One day before';
    case 'threeDaysBefore':
      return 'Three days before';
    case 'sevenDaysBefore':
      return 'Seven days before';
    case 'active':
      return 'Active';
    case 'inactive':
      return 'Inactive';
    case 'cancelled':
      return 'Cancelled';
    case 'considering':
      return 'Considering';
    case 'email':
      return 'Email';
    case 'google':
      return 'Google';
    case 'apple':
      return 'Apple';
    case 'facebook':
      return 'Facebook';
    case 'phoneSignIn':
      return 'Phone';
    default:
      return value
          .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
          .split(' ')
          .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
          .join(' ');
  }
}

String _normalizeEnumValue(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

extension PaymentCategoryDisplay on PaymentCategory {
  String get displayLabel => formatDropdownLabel(name);

  bool get isSubscriptionLike => this == PaymentCategory.subscription || this == PaymentCategory.membership || this == PaymentCategory.gym;

  bool get isEssential => this != PaymentCategory.subscription;
}

extension PaymentFrequencyDisplay on PaymentFrequency {
  String get displayLabel => formatDropdownLabel(name);
}

extension ReminderTimingDisplay on ReminderTiming {
  String get displayLabel => formatDropdownLabel(name);
}

extension PaymentStatusDisplay on PaymentStatus {
  String get displayLabel => formatDropdownLabel(name);
}

extension CancellationStatusDisplay on CancellationStatus {
  String get displayLabel => formatDropdownLabel(name);
}

extension SignInMethodDisplay on SignInMethod {
  String get displayLabel => this == SignInMethod.phone ? 'Phone' : formatDropdownLabel(name);
}

class PriceHistoryEntry {
  final String id;
  final String paymentId;
  final double oldAmount;
  final double newAmount;
  final DateTime changedAt;
  final String? changeReason;

  const PriceHistoryEntry({
    required this.id,
    required this.paymentId,
    required this.oldAmount,
    required this.newAmount,
    required this.changedAt,
    this.changeReason,
  });

  double get monthlyDelta => newAmount - oldAmount;
  double get yearlyDelta => monthlyDelta * 12;
  double get percentageChange => oldAmount <= 0 ? 0 : ((newAmount - oldAmount) / oldAmount) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payment_id': paymentId,
      'old_amount': oldAmount,
      'new_amount': newAmount,
      'changed_at': changedAt.toIso8601String(),
      'change_reason': changeReason,
    };
  }

  static PriceHistoryEntry fromMap(Map<String, dynamic> map) {
    return PriceHistoryEntry(
      id: map['id'] as String? ?? '',
      paymentId: map['payment_id'] as String? ?? '',
      oldAmount: (map['old_amount'] as num?)?.toDouble() ?? 0,
      newAmount: (map['new_amount'] as num?)?.toDouble() ?? 0,
      changedAt: DateTime.tryParse(map['changed_at'] as String? ?? '') ?? DateTime.now(),
      changeReason: map['change_reason'] as String?,
    );
  }
}

class RecurringPayment {
  final String id;
  final String userId;
  final String name;
  final String providerName;
  final double amount;
  final String currency;
  final PaymentCategory category;
  final PaymentFrequency frequency;
  final DateTime nextDueDate;
  final DateTime? renewalDate;
  final DateTime? contractEndDate;
  final bool reminderEnabled;
  final ReminderTiming reminderTiming;
  final PaymentStatus status;
  final bool isTrial;
  final DateTime? trialEndDate;
  final bool trialReminderEnabled;
  final double? convertsToPaidAmount;
  final String trialNotes;
  final String cancellationUrl;
  final String managementUrl;
  final String cancellationNotes;
  final String loginEmail;
  final String username;
  final SignInMethod signInMethod;
  final String passwordHint;
  final String recoveryEmail;
  final String accountNotes;
  final String policyNumber;
  final String documentLabel;
  final bool isEssential;
  final bool isCancellable;
  final CancellationStatus cancellationStatus;
  final DateTime? cancelledAt;
  final String iconKey;
  final List<PriceHistoryEntry> priceHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringPayment({
    required this.id,
    required this.userId,
    required this.name,
    this.providerName = '',
    required this.amount,
    required this.currency,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    this.renewalDate,
    this.contractEndDate,
    required this.reminderEnabled,
    required this.reminderTiming,
    required this.status,
    required this.isTrial,
    required this.trialEndDate,
    required this.trialReminderEnabled,
    required this.convertsToPaidAmount,
    required this.trialNotes,
    required this.cancellationUrl,
    this.managementUrl = '',
    required this.cancellationNotes,
    this.loginEmail = '',
    this.username = '',
    this.signInMethod = SignInMethod.email,
    this.passwordHint = '',
    this.recoveryEmail = '',
    this.accountNotes = '',
    this.policyNumber = '',
    this.documentLabel = '',
    this.isEssential = false,
    this.isCancellable = true,
    required this.cancellationStatus,
    required this.cancelledAt,
    required this.iconKey,
    required this.priceHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == PaymentStatus.active;
  bool get isCancelled => cancellationStatus == CancellationStatus.cancelled || status == PaymentStatus.cancelled;
  bool get hasRenewalOrContractDate => renewalDate != null || contractEndDate != null;
  String get displayProviderName => providerName.trim().isEmpty ? name : providerName.trim();
  String get effectiveManagementUrl => managementUrl.trim().isNotEmpty ? managementUrl.trim() : cancellationUrl.trim();
  PriceHistoryEntry? get latestPriceHistory => priceHistory.isEmpty ? null : priceHistory.first;
  double? get previousAmount => latestPriceHistory?.oldAmount;
  DateTime? get lastAmountChangeDate => latestPriceHistory?.changedAt;
  double get percentageChange => latestPriceHistory?.percentageChange ?? 0;
  String? get lastChangeReason => latestPriceHistory?.changeReason;

  RecurringPayment copyWith({
    String? id,
    String? userId,
    String? name,
    String? providerName,
    double? amount,
    String? currency,
    PaymentCategory? category,
    PaymentFrequency? frequency,
    DateTime? nextDueDate,
    DateTime? renewalDate,
    bool clearRenewalDate = false,
    DateTime? contractEndDate,
    bool clearContractEndDate = false,
    bool? reminderEnabled,
    ReminderTiming? reminderTiming,
    PaymentStatus? status,
    bool? isTrial,
    DateTime? trialEndDate,
    bool? trialReminderEnabled,
    double? convertsToPaidAmount,
    String? trialNotes,
    String? cancellationUrl,
    String? managementUrl,
    String? cancellationNotes,
    String? loginEmail,
    String? username,
    SignInMethod? signInMethod,
    String? passwordHint,
    String? recoveryEmail,
    String? accountNotes,
    String? policyNumber,
    String? documentLabel,
    bool? isEssential,
    bool? isCancellable,
    CancellationStatus? cancellationStatus,
    DateTime? cancelledAt,
    String? iconKey,
    List<PriceHistoryEntry>? priceHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringPayment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      providerName: providerName ?? this.providerName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      renewalDate: clearRenewalDate ? null : (renewalDate ?? this.renewalDate),
      contractEndDate: clearContractEndDate ? null : (contractEndDate ?? this.contractEndDate),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTiming: reminderTiming ?? this.reminderTiming,
      status: status ?? this.status,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      trialReminderEnabled: trialReminderEnabled ?? this.trialReminderEnabled,
      convertsToPaidAmount: convertsToPaidAmount ?? this.convertsToPaidAmount,
      trialNotes: trialNotes ?? this.trialNotes,
      cancellationUrl: cancellationUrl ?? this.cancellationUrl,
      managementUrl: managementUrl ?? this.managementUrl,
      cancellationNotes: cancellationNotes ?? this.cancellationNotes,
      loginEmail: loginEmail ?? this.loginEmail,
      username: username ?? this.username,
      signInMethod: signInMethod ?? this.signInMethod,
      passwordHint: passwordHint ?? this.passwordHint,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      accountNotes: accountNotes ?? this.accountNotes,
      policyNumber: policyNumber ?? this.policyNumber,
      documentLabel: documentLabel ?? this.documentLabel,
      isEssential: isEssential ?? this.isEssential,
      isCancellable: isCancellable ?? this.isCancellable,
      cancellationStatus: cancellationStatus ?? this.cancellationStatus,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      iconKey: iconKey ?? this.iconKey,
      priceHistory: priceHistory ?? this.priceHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'provider_name': providerName,
      'amount': amount,
      'currency': currency,
      'category': category.name,
      'frequency': frequency.name,
      'next_due_date': nextDueDate.toIso8601String(),
      'renewal_date': renewalDate?.toIso8601String(),
      'contract_end_date': contractEndDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled,
      'reminder_timing': reminderTiming.name,
      'status': status.name,
      'is_trial': isTrial,
      'trial_end_date': trialEndDate?.toIso8601String(),
      'trial_reminder_enabled': trialReminderEnabled,
      'converts_to_paid_amount': convertsToPaidAmount,
      'trial_notes': trialNotes,
      'cancellation_url': cancellationUrl,
      'management_url': managementUrl,
      'cancellation_notes': cancellationNotes,
      'login_email': loginEmail,
      'username': username,
      'sign_in_method': signInMethod.name,
      'password_hint': passwordHint,
      'recovery_email': recoveryEmail,
      'account_notes': accountNotes,
      'policy_number': policyNumber,
      'document_label': documentLabel,
      'is_essential': isEssential,
      'is_cancellable': isCancellable,
      'cancellation_status': cancellationStatus.name,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'icon_key': iconKey,
      'price_history': priceHistory.map((item) => item.toMap()).toList(growable: false),
      'last_amount_change_date': lastAmountChangeDate?.toIso8601String(),
      'percentage_change': percentageChange,
      'change_reason': lastChangeReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static PaymentCategory categoryFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'subscription':
        return PaymentCategory.subscription;
      case 'rent':
      case 'apartmentrent':
      case 'houserent':
        return PaymentCategory.rent;
      case 'utility':
      case 'utilities':
      case 'bill':
        return PaymentCategory.utilities;
      case 'insurance':
        return PaymentCategory.insurance;
      case 'internet':
      case 'wifi':
        return PaymentCategory.internet;
      case 'phone':
      case 'mobile':
      case 'cell':
        return PaymentCategory.phone;
      case 'gym':
      case 'fitness':
        return PaymentCategory.gym;
      case 'loan':
      case 'loans':
        return PaymentCategory.loan;
      case 'membership':
      case 'memberships':
        return PaymentCategory.membership;
      case 'contract':
      case 'contracts':
        return PaymentCategory.contract;
      default:
        return PaymentCategory.other;
    }
  }

  static PaymentFrequency frequencyFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'weekly':
        return PaymentFrequency.weekly;
      case 'quarterly':
        return PaymentFrequency.quarterly;
      case 'yearly':
      case 'annual':
        return PaymentFrequency.yearly;
      default:
        return PaymentFrequency.monthly;
    }
  }

  static ReminderTiming reminderTimingFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'sameday':
        return ReminderTiming.sameDay;
      case 'threedaysbefore':
      case '3daysbefore':
        return ReminderTiming.threeDaysBefore;
      case 'sevendaysbefore':
      case '7daysbefore':
        return ReminderTiming.sevenDaysBefore;
      default:
        return ReminderTiming.oneDayBefore;
    }
  }

  static PaymentStatus statusFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'inactive':
      case 'paused':
      case 'completed':
        return PaymentStatus.inactive;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.active;
    }
  }

  static CancellationStatus cancellationStatusFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'considering':
        return CancellationStatus.considering;
      case 'cancelled':
        return CancellationStatus.cancelled;
      default:
        return CancellationStatus.active;
    }
  }

  static SignInMethod signInMethodFromString(String value) {
    switch (_normalizeEnumValue(value)) {
      case 'google':
        return SignInMethod.google;
      case 'apple':
        return SignInMethod.apple;
      case 'facebook':
        return SignInMethod.facebook;
      case 'phone':
      case 'sms':
        return SignInMethod.phone;
      case 'other':
        return SignInMethod.other;
      default:
        return SignInMethod.email;
    }
  }
}
