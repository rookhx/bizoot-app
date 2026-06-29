import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/connected_email_account.dart';
import '../models/outlook_oauth_backend_state.dart';
import 'connected_email_account_service.dart';
import 'email_import_service.dart';
import 'outlook_oauth_backend_service.dart';

class OutlookImportService {
  OutlookImportService({
    required this.accountService,
    required this.backendService,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ConnectedEmailAccountService accountService;
  final OutlookOAuthBackendService backendService;
  final http.Client _httpClient;

  static const List<String> recommendedScopes = [
    'openid',
    'offline_access',
    'User.Read',
    'Mail.Read',
  ];

  static final FlutterAppAuth _appAuth = const FlutterAppAuth();
  static const String _graphBaseUrl = 'https://graph.microsoft.com/v1.0';
  static const int _maxMessageResults = 80;
  static const int _maxAttachmentBytes = 2 * 1024 * 1024;

  String get _issuer =>
      'https://login.microsoftonline.com/${AppConfig.microsoftOutlookTenantId}/v2.0';

  Future<ConnectedEmailAccount?> restoreConnectedAccount(String userId) async {
    final accounts = await accountService.loadAccounts(userId);
    final savedAccount = accounts
        .where((account) => account.provider == ConnectedEmailProvider.outlook)
        .cast<ConnectedEmailAccount?>()
        .firstWhere((account) => account != null, orElse: () => null);
    if (savedAccount == null) {
      return null;
    }

    if (!AppConfig.isMicrosoftOutlookOAuthConfigured) {
      return savedAccount.copyWith(
        status: EmailConnectionStatus.error,
        updatedAt: DateTime.now(),
        errorMessage: _missingConfigurationMessage,
      );
    }

    try {
      final existingState = await backendService.loadState(userId);
      final refreshedState = await _refreshAuthorization(
        userId: userId,
        existingState: existingState,
      );
      if (refreshedState == null || !refreshedState.hasUsableAccessToken) {
        final account = savedAccount.copyWith(
          status: EmailConnectionStatus.error,
          updatedAt: DateTime.now(),
          errorMessage: _reauthorizationMessage,
        );
        await _saveSingleAccount(userId, account);
        return account;
      }

      final account = _accountFromBackendState(refreshedState);
      await _saveSingleAccount(userId, account);
      return account;
    } on FlutterAppAuthUserCancelledException {
      final account = savedAccount.copyWith(
        status: EmailConnectionStatus.error,
        updatedAt: DateTime.now(),
        errorMessage: _consentCancelledMessage,
      );
      await _saveSingleAccount(userId, account);
      return account;
    } catch (_) {
      final account = savedAccount.copyWith(
        status: EmailConnectionStatus.error,
        updatedAt: DateTime.now(),
        errorMessage: _fallbackConnectionErrorMessage,
      );
      await _saveSingleAccount(userId, account);
      return account;
    }
  }

  Future<ConnectedEmailAccount> connectAccount({
    required String userId,
    required String fallbackEmail,
  }) async {
    _ensureConfigured();

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConfig.microsoftOutlookClientId,
          AppConfig.microsoftOutlookRedirectUri,
          issuer: _issuer,
          scopes: recommendedScopes,
          promptValues: const ['select_account'],
        ),
      );
      final accountEmail = result.accessToken == null
          ? fallbackEmail
          : (_extractEmailFromIdToken(result.idToken) ?? fallbackEmail);
      final displayName =
          _extractNameFromIdToken(result.idToken) ??
          (accountEmail.isEmpty ? 'Outlook' : accountEmail);
      final backendState = OutlookOAuthBackendState(
        userId: userId,
        accountId: _buildAccountId(accountEmail),
        provider: ConnectedEmailProvider.outlook.name,
        accountEmail: accountEmail,
        displayName: displayName,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        tokenExpiresAt: result.accessTokenExpirationDateTime,
        grantedScopes: result.scopes ?? recommendedScopes,
        lastSyncedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        errorMessage: null,
      );
      await backendService.saveState(backendState);

      final account = _accountFromBackendState(backendState);
      await _saveSingleAccount(userId, account);
      return account;
    } on FlutterAppAuthUserCancelledException {
      throw StateError(_consentCancelledMessage);
    } on FlutterAppAuthPlatformException catch (error) {
      throw StateError(error.message ?? _fallbackConnectionErrorMessage);
    } on StateError {
      rethrow;
    } catch (_) {
      throw StateError(_fallbackConnectionErrorMessage);
    }
  }

  Future<void> disconnectAccount(String userId) async {
    await backendService.clearState(userId);
    await _clearSavedConnection(userId);
  }

  Future<List<EmailImportMessageSource>> fetchMessages({
    required ConnectedEmailAccount account,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    if (!account.isConnected) {
      throw StateError('outlook_not_connected');
    }

    OutlookOAuthBackendState? backendState = await backendService.loadState(
      account.userId,
    );
    backendState = await _refreshAuthorization(
      userId: account.userId,
      existingState: backendState,
    );
    if (backendState == null || !backendState.hasUsableAccessToken) {
      throw StateError(_authorizationUnavailableMessage);
    }

    return _fetchMessagesWithRetry(
      account: account,
      backendState: backendState,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }

  Future<List<EmailImportMessageSource>> _fetchMessagesWithRetry({
    required ConnectedEmailAccount account,
    required OutlookOAuthBackendState backendState,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    try {
      return await _fetchMessagesFromGraph(
        account: account,
        accessToken: backendState.accessToken!,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
    } on _OutlookUnauthorizedException {
      final refreshedState = await _refreshAuthorization(
        userId: account.userId,
        existingState: backendState.copyWith(
          clearAccessToken: true,
          clearTokenExpiresAt: true,
        ),
      );
      if (refreshedState == null || !refreshedState.hasUsableAccessToken) {
        throw StateError(_authorizationUnavailableMessage);
      }
      return _fetchMessagesFromGraph(
        account: account,
        accessToken: refreshedState.accessToken!,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
    }
  }

  Future<List<EmailImportMessageSource>> _fetchMessagesFromGraph({
    required ConnectedEmailAccount account,
    required String accessToken,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final messages = <EmailImportMessageSource>[];
    String? nextUrl = Uri.parse('$_graphBaseUrl/me/messages')
        .replace(
          queryParameters: {
            r'$select':
                'id,subject,bodyPreview,body,receivedDateTime,hasAttachments,from,sender',
            r'$top': '25',
            r'$orderby': 'receivedDateTime desc',
            r'$filter':
                "receivedDateTime ge ${_graphDate(windowStart)} and receivedDateTime le ${_graphDate(windowEnd)}",
          },
        )
        .toString();

    while (nextUrl != null &&
        nextUrl.isNotEmpty &&
        messages.length < _maxMessageResults) {
      final response = await _graphGet(Uri.parse(nextUrl), accessToken);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final values = data['value'] as List<dynamic>? ?? const [];

      for (final raw in values) {
        if (raw is! Map<String, dynamic>) {
          continue;
        }
        final message = await _messageFromGraph(
          account: account,
          accessToken: accessToken,
          raw: raw,
          windowStart: windowStart,
          windowEnd: windowEnd,
        );
        if (message != null) {
          messages.add(message);
          if (messages.length >= _maxMessageResults) {
            break;
          }
        }
      }

      nextUrl = data['@odata.nextLink'] as String?;
    }

    messages.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return messages;
  }

  Future<EmailImportMessageSource?> _messageFromGraph({
    required ConnectedEmailAccount account,
    required String accessToken,
    required Map<String, dynamic> raw,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final receivedAt =
        DateTime.tryParse(raw['receivedDateTime'] as String? ?? '') ??
        windowEnd;
    if (receivedAt.isBefore(windowStart) || receivedAt.isAfter(windowEnd)) {
      return null;
    }

    final senderPayload =
        (raw['from'] as Map<String, dynamic>?) ??
        (raw['sender'] as Map<String, dynamic>?) ??
        const {};
    final emailAddressPayload =
        senderPayload['emailAddress'] as Map<String, dynamic>? ?? const {};
    final senderEmail = (emailAddressPayload['address'] as String? ?? '')
        .trim();
    final senderName = (emailAddressPayload['name'] as String? ?? '').trim();
    final bodyPreview = (raw['bodyPreview'] as String? ?? '').trim();
    final bodyPayload = raw['body'] as Map<String, dynamic>? ?? const {};
    final bodyText = _stripHtml(
      (bodyPayload['content'] as String? ?? '').trim(),
    );
    final attachments = raw['hasAttachments'] == true
        ? await _fetchAttachmentMetadata(
            accessToken: accessToken,
            messageId: raw['id'] as String? ?? '',
          )
        : const <EmailImportAttachmentSource>[];

    return EmailImportMessageSource(
      id: raw['id'] as String? ?? '',
      provider: ConnectedEmailProvider.outlook,
      accountId: account.id,
      senderEmail: senderEmail,
      senderName: senderName,
      subject: (raw['subject'] as String? ?? '').trim(),
      snippet: bodyPreview,
      bodyText: bodyText,
      receivedAt: receivedAt,
      attachments: attachments,
    );
  }

  Future<List<EmailImportAttachmentSource>> _fetchAttachmentMetadata({
    required String accessToken,
    required String messageId,
  }) async {
    if (messageId.isEmpty) {
      return const [];
    }

    final response = await _graphGet(
      Uri.parse(
        '$_graphBaseUrl/me/messages/$messageId/attachments'
        '?\$select=id,name,contentType,size',
      ),
      accessToken,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final values = data['value'] as List<dynamic>? ?? const [];
    final attachments = <EmailImportAttachmentSource>[];

    for (final raw in values) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }

      final attachmentId = (raw['id'] as String? ?? '').trim();
      final fileName = (raw['name'] as String? ?? 'attachment').trim();
      final mimeType =
          (raw['contentType'] as String? ?? 'application/octet-stream').trim();
      final fileSize = (raw['size'] as num?)?.toInt() ?? 0;
      final extension = _fileExtension(fileName, mimeType);
      List<int>? bytes;

      if (extension == 'pdf' &&
          fileSize > 0 &&
          fileSize <= _maxAttachmentBytes &&
          attachmentId.isNotEmpty) {
        bytes = await _fetchAttachmentBytes(
          accessToken: accessToken,
          messageId: messageId,
          attachmentId: attachmentId,
        );
      }

      attachments.add(
        EmailImportAttachmentSource(
          id: attachmentId.isEmpty
              ? '$messageId-${attachments.length}'
              : attachmentId,
          fileName: fileName.isEmpty ? 'attachment' : fileName,
          mimeType: mimeType,
          fileExtension: extension,
          fileSize: fileSize,
          bytes: bytes,
        ),
      );
    }

    return attachments;
  }

  Future<List<int>?> _fetchAttachmentBytes({
    required String accessToken,
    required String messageId,
    required String attachmentId,
  }) async {
    try {
      final response = await _graphGet(
        Uri.parse(
          '$_graphBaseUrl/me/messages/$messageId/attachments/$attachmentId'
          '?\$select=contentBytes',
        ),
        accessToken,
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final contentBytes = data['contentBytes'] as String?;
      if (contentBytes == null || contentBytes.isEmpty) {
        return null;
      }
      return base64.decode(contentBytes);
    } catch (_) {
      return null;
    }
  }

  Future<http.Response> _graphGet(Uri uri, String accessToken) async {
    final response = await _httpClient.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
        'Prefer': 'outlook.body-content-type="text"',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const _OutlookUnauthorizedException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Microsoft Graph request failed with status ${response.statusCode}.',
      );
    }
    return response;
  }

  Future<OutlookOAuthBackendState?> _refreshAuthorization({
    required String userId,
    required OutlookOAuthBackendState? existingState,
  }) async {
    if (existingState == null) {
      return null;
    }
    if (existingState.hasUsableAccessToken) {
      return existingState;
    }
    final refreshToken = existingState.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final result = await _appAuth.token(
        TokenRequest(
          AppConfig.microsoftOutlookClientId,
          AppConfig.microsoftOutlookRedirectUri,
          issuer: _issuer,
          refreshToken: refreshToken,
          scopes: recommendedScopes,
        ),
      );
      final refreshedState = existingState.copyWith(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken ?? existingState.idToken,
        tokenExpiresAt: result.accessTokenExpirationDateTime,
        grantedScopes: result.scopes ?? existingState.grantedScopes,
        lastSyncedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        clearErrorMessage: true,
      );
      await backendService.saveState(refreshedState);
      return refreshedState;
    } catch (_) {
      return existingState.copyWith(
        errorMessage: _authorizationUnavailableMessage,
        updatedAt: DateTime.now(),
      );
    }
  }

  ConnectedEmailAccount _accountFromBackendState(
    OutlookOAuthBackendState state,
  ) {
    return ConnectedEmailAccount(
      id: state.accountId,
      userId: state.userId,
      provider: ConnectedEmailProvider.outlook,
      emailAddress: state.accountEmail,
      displayName: state.displayName,
      status: state.hasUsableAccessToken
          ? EmailConnectionStatus.connected
          : EmailConnectionStatus.error,
      grantedScopes: state.grantedScopes,
      connectedAt: state.updatedAt,
      lastSyncedAt: state.lastSyncedAt,
      updatedAt: state.updatedAt,
      errorMessage: state.errorMessage,
    );
  }

  String _buildAccountId(String email) {
    final normalized = email.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '-',
    );
    return 'outlook-$normalized';
  }

  String? _extractEmailFromIdToken(String? idToken) {
    final claims = _decodeIdTokenClaims(idToken);
    return claims?['preferred_username']?.toString() ??
        claims?['email']?.toString() ??
        claims?['upn']?.toString();
  }

  String? _extractNameFromIdToken(String? idToken) {
    final claims = _decodeIdTokenClaims(idToken);
    return claims?['name']?.toString();
  }

  Map<String, dynamic>? _decodeIdTokenClaims(String? idToken) {
    if (idToken == null || idToken.isEmpty) {
      return null;
    }
    final parts = idToken.split('.');
    if (parts.length < 2) {
      return null;
    }
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final dynamic json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) {
        return json;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _saveSingleAccount(
    String userId,
    ConnectedEmailAccount nextAccount,
  ) async {
    final accounts = await accountService.loadAccounts(userId);
    final merged = [
      ...accounts.where(
        (item) => item.provider != ConnectedEmailProvider.outlook,
      ),
      nextAccount,
    ];
    await accountService.saveAccounts(userId, merged);
  }

  Future<void> _clearSavedConnection(String userId) async {
    final accounts = await accountService.loadAccounts(userId);
    final nextAccounts = accounts
        .where((item) => item.provider != ConnectedEmailProvider.outlook)
        .toList(growable: false);
    await accountService.saveAccounts(userId, nextAccounts);
  }

  void _ensureConfigured() {
    if (!AppConfig.isMicrosoftOutlookOAuthConfigured) {
      throw StateError(_missingConfigurationMessage);
    }
  }

  String _graphDate(DateTime value) => value.toUtc().toIso8601String();

  String _fileExtension(String filename, String mimeType) {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex >= 0 && dotIndex < filename.length - 1) {
      return filename.substring(dotIndex + 1).toLowerCase();
    }
    if (mimeType.contains('/')) {
      return mimeType.split('/').last.toLowerCase();
    }
    return 'bin';
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const String _fallbackConnectionErrorMessage =
      'Bizoot could not connect Outlook right now. Please try again.';
  static const String _consentCancelledMessage =
      'Outlook connection was canceled before Bizoot could finish linking your account.';
  static const String _reauthorizationMessage =
      'Outlook is connected, but Bizoot still needs read-only permission for subscription scanning.';
  static const String _authorizationUnavailableMessage =
      'Bizoot could not refresh Outlook access right now. Please try connecting the inbox again.';
  static const String _missingConfigurationMessage =
      'Microsoft OAuth is not configured for this build yet. Add the Outlook client details before connecting an inbox.';
}

class _OutlookUnauthorizedException implements Exception {
  const _OutlookUnauthorizedException();
}
