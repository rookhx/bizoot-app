enum ConnectedEmailProvider { gmail, outlook }

enum EmailConnectionStatus { disconnected, connecting, connected, error }

class ConnectedEmailAccount {
  final String id;
  final String userId;
  final ConnectedEmailProvider provider;
  final String emailAddress;
  final String displayName;
  final EmailConnectionStatus status;
  final List<String> grantedScopes;
  final DateTime? connectedAt;
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  final String? errorMessage;

  const ConnectedEmailAccount({
    required this.id,
    required this.userId,
    required this.provider,
    required this.emailAddress,
    required this.displayName,
    required this.status,
    required this.grantedScopes,
    required this.connectedAt,
    required this.lastSyncedAt,
    required this.updatedAt,
    required this.errorMessage,
  });

  bool get isConnected => status == EmailConnectionStatus.connected;

  ConnectedEmailAccount copyWith({
    String? id,
    String? userId,
    ConnectedEmailProvider? provider,
    String? emailAddress,
    String? displayName,
    EmailConnectionStatus? status,
    List<String>? grantedScopes,
    DateTime? connectedAt,
    bool clearConnectedAt = false,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    DateTime? updatedAt,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ConnectedEmailAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      emailAddress: emailAddress ?? this.emailAddress,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      grantedScopes: grantedScopes ?? this.grantedScopes,
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      lastSyncedAt: clearLastSyncedAt
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider.name,
      'email_address': emailAddress,
      'display_name': displayName,
      'status': status.name,
      'granted_scopes': grantedScopes,
      'connected_at': connectedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  factory ConnectedEmailAccount.fromMap(Map<String, dynamic> map) {
    return ConnectedEmailAccount(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      provider: _providerFromString(map['provider'] as String?),
      emailAddress: map['email_address'] as String? ?? '',
      displayName: map['display_name'] as String? ?? '',
      status: _statusFromString(map['status'] as String?),
      grantedScopes: (map['granted_scopes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      connectedAt: DateTime.tryParse(map['connected_at'] as String? ?? ''),
      lastSyncedAt: DateTime.tryParse(map['last_synced_at'] as String? ?? ''),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      errorMessage: map['error_message'] as String?,
    );
  }

  static ConnectedEmailProvider _providerFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'outlook':
        return ConnectedEmailProvider.outlook;
      default:
        return ConnectedEmailProvider.gmail;
    }
  }

  static EmailConnectionStatus _statusFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'connecting':
        return EmailConnectionStatus.connecting;
      case 'connected':
        return EmailConnectionStatus.connected;
      case 'error':
        return EmailConnectionStatus.error;
      default:
        return EmailConnectionStatus.disconnected;
    }
  }
}
