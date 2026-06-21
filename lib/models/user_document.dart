enum UserDocumentCategory {
  contract,
  insurance,
  property,
  bill,
  loan,
  membership,
  warranty,
  other,
}

enum LinkedItemType { recurringPayment }

String _normalizeDocumentValue(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

extension UserDocumentCategoryDisplay on UserDocumentCategory {
  String get displayLabel {
    switch (this) {
      case UserDocumentCategory.contract:
        return 'Contracts';
      case UserDocumentCategory.insurance:
        return 'Insurance';
      case UserDocumentCategory.property:
        return 'Property';
      case UserDocumentCategory.bill:
        return 'Bills';
      case UserDocumentCategory.loan:
        return 'Loans';
      case UserDocumentCategory.membership:
        return 'Memberships';
      case UserDocumentCategory.warranty:
        return 'Warranty';
      case UserDocumentCategory.other:
        return 'Other';
    }
  }

  String get singularLabel {
    switch (this) {
      case UserDocumentCategory.contract:
        return 'Contract';
      case UserDocumentCategory.insurance:
        return 'Insurance';
      case UserDocumentCategory.property:
        return 'Property';
      case UserDocumentCategory.bill:
        return 'Bill';
      case UserDocumentCategory.loan:
        return 'Loan';
      case UserDocumentCategory.membership:
        return 'Membership';
      case UserDocumentCategory.warranty:
        return 'Warranty';
      case UserDocumentCategory.other:
        return 'Other';
    }
  }
}

extension LinkedItemTypeDisplay on LinkedItemType {
  String get storageValue {
    switch (this) {
      case LinkedItemType.recurringPayment:
        return 'recurring_payment';
    }
  }
}

class UserDocument {
  final String id;
  final String userId;
  final String? linkedItemId;
  final LinkedItemType? linkedItemType;
  final String title;
  final String originalFileName;
  final String filePath;
  final String mimeType;
  final String fileExtension;
  final int fileSize;
  final UserDocumentCategory documentCategory;
  final String notes;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  const UserDocument({
    required this.id,
    required this.userId,
    required this.linkedItemId,
    required this.linkedItemType,
    required this.title,
    required this.originalFileName,
    required this.filePath,
    required this.mimeType,
    required this.fileExtension,
    required this.fileSize,
    required this.documentCategory,
    this.notes = '',
    required this.uploadedAt,
    required this.updatedAt,
  });

  bool get isImage {
    final normalized = fileExtension.toLowerCase();
    return normalized == 'jpg' ||
        normalized == 'jpeg' ||
        normalized == 'png' ||
        normalized == 'webp' ||
        normalized == 'heic';
  }

  bool get isPdf => fileExtension.toLowerCase() == 'pdf';

  String get linkedItemTypeValue => linkedItemType?.storageValue ?? '';

  UserDocument copyWith({
    String? id,
    String? userId,
    String? linkedItemId,
    bool clearLinkedItemId = false,
    LinkedItemType? linkedItemType,
    bool clearLinkedItemType = false,
    String? title,
    String? originalFileName,
    String? filePath,
    String? mimeType,
    String? fileExtension,
    int? fileSize,
    UserDocumentCategory? documentCategory,
    String? notes,
    DateTime? uploadedAt,
    DateTime? updatedAt,
  }) {
    return UserDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      linkedItemId: clearLinkedItemId
          ? null
          : (linkedItemId ?? this.linkedItemId),
      linkedItemType: clearLinkedItemType
          ? null
          : (linkedItemType ?? this.linkedItemType),
      title: title ?? this.title,
      originalFileName: originalFileName ?? this.originalFileName,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      documentCategory: documentCategory ?? this.documentCategory,
      notes: notes ?? this.notes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'linked_item_id': linkedItemId,
      'linked_item_type': linkedItemType?.storageValue,
      'title': title,
      'original_file_name': originalFileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'file_extension': fileExtension,
      'file_size': fileSize,
      'document_category': documentCategory.name,
      'notes': notes.isEmpty ? null : notes,
      'uploaded_at': uploadedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserDocument fromMap(Map<String, dynamic> map) {
    return UserDocument(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      linkedItemId: map['linked_item_id'] as String?,
      linkedItemType: linkedItemTypeFromString(
        map['linked_item_type'] as String?,
      ),
      title: map['title'] as String? ?? '',
      originalFileName: map['original_file_name'] as String? ?? '',
      filePath: map['file_path'] as String? ?? '',
      mimeType: map['mime_type'] as String? ?? '',
      fileExtension: map['file_extension'] as String? ?? '',
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      documentCategory: categoryFromString(map['document_category'] as String?),
      notes: map['notes'] as String? ?? '',
      uploadedAt:
          DateTime.tryParse(map['uploaded_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static UserDocumentCategory categoryFromString(String? value) {
    switch (_normalizeDocumentValue(value ?? '')) {
      case 'contract':
      case 'contracts':
        return UserDocumentCategory.contract;
      case 'insurance':
        return UserDocumentCategory.insurance;
      case 'property':
      case 'rent':
      case 'lease':
        return UserDocumentCategory.property;
      case 'bill':
      case 'bills':
      case 'utilitybill':
        return UserDocumentCategory.bill;
      case 'loan':
      case 'loans':
        return UserDocumentCategory.loan;
      case 'membership':
      case 'memberships':
      case 'gym':
        return UserDocumentCategory.membership;
      case 'warranty':
      case 'warranties':
        return UserDocumentCategory.warranty;
      default:
        return UserDocumentCategory.other;
    }
  }

  static LinkedItemType? linkedItemTypeFromString(String? value) {
    switch (_normalizeDocumentValue(value ?? '')) {
      case 'recurringpayment':
        return LinkedItemType.recurringPayment;
      default:
        return null;
    }
  }
}
