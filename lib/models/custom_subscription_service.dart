import 'recurring_payment.dart';

class CustomSubscriptionService {
  final String id;
  final String userId;
  final String name;
  final String normalizedName;
  final PaymentCategory category;
  final PaymentFrequency frequency;
  final double? amount;
  final String cancellationUrl;
  final String website;
  final String icon;
  final List<String> aliases;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;
  final bool isUserCreated;

  const CustomSubscriptionService({
    required this.id,
    required this.userId,
    required this.name,
    required this.normalizedName,
    required this.category,
    required this.frequency,
    required this.amount,
    required this.cancellationUrl,
    required this.website,
    required this.icon,
    required this.aliases,
    required this.createdAt,
    required this.updatedAt,
    required this.usageCount,
    required this.isUserCreated,
  });

  CustomSubscriptionService copyWith({
    String? id,
    String? userId,
    String? name,
    String? normalizedName,
    PaymentCategory? category,
    PaymentFrequency? frequency,
    double? amount,
    String? cancellationUrl,
    String? website,
    String? icon,
    List<String>? aliases,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
    bool? isUserCreated,
  }) {
    return CustomSubscriptionService(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      amount: amount ?? this.amount,
      cancellationUrl: cancellationUrl ?? this.cancellationUrl,
      website: website ?? this.website,
      icon: icon ?? this.icon,
      aliases: aliases ?? this.aliases,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
      isUserCreated: isUserCreated ?? this.isUserCreated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'normalized_name': normalizedName,
      'category': category.name,
      'frequency': frequency.name,
      'amount': amount,
      'cancellation_url': cancellationUrl,
      'website': website,
      'icon': icon,
      'aliases': aliases,
      'usage_count': usageCount,
      'is_user_created': isUserCreated,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CustomSubscriptionService.fromMap(Map<String, dynamic> map) {
    return CustomSubscriptionService(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      normalizedName: map['normalized_name'] as String? ?? '',
      category: RecurringPayment.categoryFromString(map['category'] as String? ?? 'other'),
      frequency: RecurringPayment.frequencyFromString(map['frequency'] as String? ?? 'monthly'),
      amount: (map['amount'] as num?)?.toDouble(),
      cancellationUrl: map['cancellation_url'] as String? ?? '',
      website: map['website'] as String? ?? '',
      icon: map['icon'] as String? ?? 'credit_card',
      aliases: (map['aliases'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      usageCount: (map['usage_count'] as num?)?.toInt() ?? 1,
      isUserCreated: map['is_user_created'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
