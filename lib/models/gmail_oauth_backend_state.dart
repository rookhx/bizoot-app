class GmailOAuthBackendState {
  final String userId;
  final String accountId;
  final String provider;
  final String accountEmail;
  final String? accessToken;
  final String? refreshToken;
  final String? serverAuthCode;
  final DateTime? tokenExpiresAt;
  final List<String> grantedScopes;
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  final String? errorMessage;

  const GmailOAuthBackendState({
    required this.userId,
    required this.accountId,
    required this.provider,
    required this.accountEmail,
    required this.accessToken,
    required this.refreshToken,
    required this.serverAuthCode,
    required this.tokenExpiresAt,
    required this.grantedScopes,
    required this.lastSyncedAt,
    required this.updatedAt,
    required this.errorMessage,
  });

  bool get hasUsableAccessToken =>
      accessToken?.isNotEmpty == true &&
      tokenExpiresAt != null &&
      tokenExpiresAt!.isAfter(DateTime.now());

  GmailOAuthBackendState copyWith({
    String? userId,
    String? accountId,
    String? provider,
    String? accountEmail,
    String? accessToken,
    bool clearAccessToken = false,
    String? refreshToken,
    bool clearRefreshToken = false,
    String? serverAuthCode,
    bool clearServerAuthCode = false,
    DateTime? tokenExpiresAt,
    bool clearTokenExpiresAt = false,
    List<String>? grantedScopes,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    DateTime? updatedAt,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return GmailOAuthBackendState(
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      provider: provider ?? this.provider,
      accountEmail: accountEmail ?? this.accountEmail,
      accessToken: clearAccessToken ? null : (accessToken ?? this.accessToken),
      refreshToken: clearRefreshToken
          ? null
          : (refreshToken ?? this.refreshToken),
      serverAuthCode: clearServerAuthCode
          ? null
          : (serverAuthCode ?? this.serverAuthCode),
      tokenExpiresAt: clearTokenExpiresAt
          ? null
          : (tokenExpiresAt ?? this.tokenExpiresAt),
      grantedScopes: grantedScopes ?? this.grantedScopes,
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
      'user_id': userId,
      'account_id': accountId,
      'provider': provider,
      'account_email': accountEmail,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'server_auth_code': serverAuthCode,
      'token_expires_at': tokenExpiresAt?.toIso8601String(),
      'granted_scopes': grantedScopes,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  factory GmailOAuthBackendState.fromMap(Map<String, dynamic> map) {
    return GmailOAuthBackendState(
      userId: map['user_id'] as String? ?? '',
      accountId: map['account_id'] as String? ?? '',
      provider: map['provider'] as String? ?? 'gmail',
      accountEmail: map['account_email'] as String? ?? '',
      accessToken: map['access_token'] as String?,
      refreshToken: map['refresh_token'] as String?,
      serverAuthCode: map['server_auth_code'] as String?,
      tokenExpiresAt: DateTime.tryParse(
        map['token_expires_at'] as String? ?? '',
      ),
      grantedScopes: (map['granted_scopes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      lastSyncedAt: DateTime.tryParse(map['last_synced_at'] as String? ?? ''),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      errorMessage: map['error_message'] as String?,
    );
  }
}
