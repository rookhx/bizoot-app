import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/connected_email_account.dart';
import '../models/gmail_oauth_backend_state.dart';
import 'connected_email_account_service.dart';
import 'email_import_service.dart';
import 'gmail_oauth_backend_service.dart';

class GmailImportService {
  GmailImportService({
    required this.accountService,
    required this.backendService,
    GoogleSignIn? googleSignIn,
    http.Client? httpClient,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _httpClient = httpClient ?? http.Client();

  final ConnectedEmailAccountService accountService;
  final GmailOAuthBackendService backendService;
  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;

  static const List<String> recommendedScopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
  ];
  static const String _gmailBaseUrl = 'https://gmail.googleapis.com/gmail/v1';
  static const int _maxMessageResults = 80;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize(
      clientId: AppConfig.googleGmailClientId.isEmpty
          ? null
          : AppConfig.googleGmailClientId,
      serverClientId: AppConfig.googleGmailServerClientId.isEmpty
          ? null
          : AppConfig.googleGmailServerClientId,
    );
    _isInitialized = true;
  }

  Future<ConnectedEmailAccount?> restoreConnectedAccount(String userId) async {
    final accounts = await accountService.loadAccounts(userId);
    final savedAccount = accounts
        .where((account) => account.provider == ConnectedEmailProvider.gmail)
        .cast<ConnectedEmailAccount?>()
        .firstWhere((account) => account != null, orElse: () => null);
    if (savedAccount == null) {
      return null;
    }

    if (!AppConfig.isGoogleGmailOAuthConfigured) {
      return savedAccount.copyWith(
        status: EmailConnectionStatus.error,
        updatedAt: DateTime.now(),
        errorMessage: _missingConfigurationMessage,
      );
    }

    try {
      await initialize();
      final GoogleSignInAccount? currentUser =
          await _attemptLightweightAuthentication();
      if (currentUser == null) {
        await _clearSavedConnection(userId);
        return null;
      }

      final GmailOAuthBackendState? backendState = await backendService
          .loadState(userId);
      final GmailOAuthBackendState? refreshedBackendState =
          await _refreshBackendAuthorization(
            userId: userId,
            user: currentUser,
            existingState: backendState,
            allowInteractiveRecovery: false,
          );
      if (refreshedBackendState == null ||
          !refreshedBackendState.hasUsableAccessToken) {
        final account = savedAccount.copyWith(
          emailAddress: currentUser.email,
          displayName: currentUser.displayName ?? 'Gmail',
          status: EmailConnectionStatus.error,
          lastSyncedAt: backendState?.lastSyncedAt,
          updatedAt: DateTime.now(),
          errorMessage: _reauthorizationMessage,
        );
        await _saveSingleAccount(userId, account);
        return account;
      }

      final account = _connectedAccountFromGoogleUser(
        userId: userId,
        user: currentUser,
        lastSyncedAt: refreshedBackendState.lastSyncedAt,
      );
      await _saveSingleAccount(userId, account);
      return account;
    } on GoogleSignInException catch (error) {
      final account = savedAccount.copyWith(
        status: EmailConnectionStatus.error,
        updatedAt: DateTime.now(),
        errorMessage: _userMessageForException(error),
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
    await initialize();

    try {
      final GoogleSignInAccount googleUser = await _authenticateUser(
        fallbackEmail,
      );
      final GmailOAuthBackendState backendState =
          await _refreshBackendAuthorization(
            userId: userId,
            user: googleUser,
            existingState: await backendService.loadState(userId),
            allowInteractiveRecovery: true,
          ) ??
          (throw StateError(_authorizationUnavailableMessage));

      final account = _connectedAccountFromGoogleUser(
        userId: userId,
        user: googleUser,
        lastSyncedAt: backendState.lastSyncedAt,
      );
      await _saveSingleAccount(userId, account);
      return account;
    } on GoogleSignInException catch (error) {
      throw StateError(_userMessageForException(error));
    } on StateError {
      rethrow;
    } catch (_) {
      throw StateError(_fallbackConnectionErrorMessage);
    }
  }

  Future<void> disconnectAccount(String userId) async {
    try {
      if (_isInitialized) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      if (_isInitialized) {
        await _googleSignIn.signOut();
      }
    } finally {
      await backendService.clearState(userId);
      await _clearSavedConnection(userId);
    }
  }

  Future<List<EmailImportMessageSource>> fetchMessages({
    required ConnectedEmailAccount account,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    if (!account.isConnected) {
      throw StateError('gmail_not_connected');
    }

    final GoogleSignInAccount? currentUser =
        await _attemptLightweightAuthentication();
    if (currentUser == null) {
      throw StateError(_authorizationUnavailableMessage);
    }

    GmailOAuthBackendState? backendState = await backendService.loadState(
      account.userId,
    );
    backendState = await _refreshBackendAuthorization(
      userId: account.userId,
      user: currentUser,
      existingState: backendState,
      allowInteractiveRecovery: false,
    );
    if (backendState == null || !backendState.hasUsableAccessToken) {
      throw StateError(_authorizationUnavailableMessage);
    }

    return _fetchMessagesWithRetry(
      account: account,
      user: currentUser,
      backendState: backendState,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }

  Future<List<EmailImportMessageSource>> _fetchMessagesWithRetry({
    required ConnectedEmailAccount account,
    required GoogleSignInAccount user,
    required GmailOAuthBackendState backendState,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    try {
      return await _fetchMessagesFromGmailApi(
        account: account,
        accessToken: backendState.accessToken!,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
    } on _GmailUnauthorizedException {
      await user.authorizationClient.clearAuthorizationToken(
        accessToken: backendState.accessToken!,
      );
      final GmailOAuthBackendState? refreshedState =
          await _refreshBackendAuthorization(
            userId: account.userId,
            user: user,
            existingState: backendState,
            allowInteractiveRecovery: false,
          );
      if (refreshedState == null || !refreshedState.hasUsableAccessToken) {
        throw StateError(_authorizationUnavailableMessage);
      }
      return _fetchMessagesFromGmailApi(
        account: account,
        accessToken: refreshedState.accessToken!,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
    }
  }

  Future<List<EmailImportMessageSource>> _fetchMessagesFromGmailApi({
    required ConnectedEmailAccount account,
    required String accessToken,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final List<String> messageIds = await _listRelevantMessageIds(
      accessToken: accessToken,
      windowStart: windowStart,
    );

    final List<EmailImportMessageSource> messages = [];
    for (final messageId in messageIds) {
      final EmailImportMessageSource? message = await _fetchMessageDetail(
        account: account,
        accessToken: accessToken,
        messageId: messageId,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
      if (message != null) {
        messages.add(message);
      }
    }

    messages.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return messages;
  }

  Future<List<String>> _listRelevantMessageIds({
    required String accessToken,
    required DateTime windowStart,
  }) async {
    final query = _buildGmailSearchQuery(windowStart);
    String? pageToken;
    final List<String> messageIds = [];

    do {
      final uri = Uri.parse('$_gmailBaseUrl/users/me/messages').replace(
        queryParameters: {
          'q': query,
          'maxResults': _maxMessageResults.toString(),
          if (pageToken != null) 'pageToken': pageToken,
          'fields': 'messages/id,nextPageToken',
        },
      );
      final response = await _gmailGet(uri, accessToken);
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> rawMessages =
          data['messages'] as List<dynamic>? ?? const [];
      for (final item in rawMessages) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as String? ?? '';
          if (id.isNotEmpty) {
            messageIds.add(id);
          }
        }
      }
      pageToken = data['nextPageToken'] as String?;
      if (messageIds.length >= _maxMessageResults) {
        break;
      }
    } while (pageToken != null && pageToken.isNotEmpty);

    return messageIds.take(_maxMessageResults).toList(growable: false);
  }

  Future<EmailImportMessageSource?> _fetchMessageDetail({
    required ConnectedEmailAccount account,
    required String accessToken,
    required String messageId,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final uri = Uri.parse('$_gmailBaseUrl/users/me/messages/$messageId').replace(
      queryParameters: {
        'format': 'full',
      },
    );
    final response = await _gmailGet(uri, accessToken);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final payload = data['payload'] as Map<String, dynamic>? ?? const {};
    final headers = _headerMap(
      payload['headers'] as List<dynamic>? ?? const [],
    );
    final sender = headers['from'] ?? '';
    final subject = headers['subject'] ?? '';
    final parsedSender = _parseSender(sender);
    final receivedAt = _parseInternalDate(
      data['internalDate']?.toString(),
      fallback: windowEnd,
    );
    if (receivedAt.isBefore(windowStart) || receivedAt.isAfter(windowEnd)) {
      return null;
    }

    final bodyText = _extractBodyText(payload).trim();
    final attachments = await _extractAttachmentMetadata(
      payload: payload,
      accessToken: accessToken,
      messageId: data['id'] as String? ?? messageId,
    );
    return EmailImportMessageSource(
      id: data['id'] as String? ?? messageId,
      provider: ConnectedEmailProvider.gmail,
      accountId: account.id,
      senderEmail: parsedSender.email,
      senderName: parsedSender.name,
      subject: subject,
      snippet: (data['snippet'] as String? ?? '').trim(),
      bodyText: bodyText,
      receivedAt: receivedAt,
      attachments: attachments,
    );
  }

  Future<http.Response> _gmailGet(Uri uri, String accessToken) async {
    final response = await _httpClient.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const _GmailUnauthorizedException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Gmail API request failed with status ${response.statusCode}.',
      );
    }
    return response;
  }

  Future<GoogleSignInAccount> _authenticateUser(String fallbackEmail) async {
    final GoogleSignInAccount? lightweightUser =
        await _attemptLightweightAuthentication();
    if (lightweightUser != null) {
      return lightweightUser;
    }

    if (_googleSignIn.supportsAuthenticate()) {
      return _googleSignIn.authenticate();
    }

    throw StateError(
      fallbackEmail.isEmpty
          ? _interactiveSignInUnavailableMessage
          : 'Google sign-in is not available on this device right now for $fallbackEmail.',
    );
  }

  ConnectedEmailAccount _connectedAccountFromGoogleUser({
    required String userId,
    required GoogleSignInAccount user,
    DateTime? lastSyncedAt,
  }) {
    return ConnectedEmailAccount(
      id: 'gmail-${user.id}',
      userId: userId,
      provider: ConnectedEmailProvider.gmail,
      emailAddress: user.email,
      displayName: user.displayName ?? 'Gmail',
      status: EmailConnectionStatus.connected,
      grantedScopes: recommendedScopes,
      connectedAt: DateTime.now(),
      lastSyncedAt: lastSyncedAt,
      updatedAt: DateTime.now(),
      errorMessage: null,
    );
  }

  Future<GmailOAuthBackendState?> _refreshBackendAuthorization({
    required String userId,
    required GoogleSignInAccount user,
    required GmailOAuthBackendState? existingState,
    required bool allowInteractiveRecovery,
  }) async {
    GoogleSignInClientAuthorization? authorization = await user
        .authorizationClient
        .authorizationForScopes(recommendedScopes);
    if (authorization == null && allowInteractiveRecovery) {
      authorization = await user.authorizationClient.authorizeScopes(
        recommendedScopes,
      );
    }
    if (authorization == null) {
      return null;
    }

    GoogleSignInServerAuthorization? serverAuthorization;
    try {
      serverAuthorization = await user.authorizationClient.authorizeServer(
        recommendedScopes,
      );
    } catch (_) {
      serverAuthorization = null;
    }

    final refreshedState = GmailOAuthBackendState(
      userId: userId,
      accountId: 'gmail-${user.id}',
      provider: ConnectedEmailProvider.gmail.name,
      accountEmail: user.email,
      accessToken: authorization.accessToken,
      refreshToken: existingState?.refreshToken,
      serverAuthCode:
          serverAuthorization?.serverAuthCode ?? existingState?.serverAuthCode,
      tokenExpiresAt: DateTime.now().add(const Duration(minutes: 55)),
      grantedScopes: recommendedScopes,
      lastSyncedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      errorMessage: null,
    );
    await backendService.saveState(refreshedState);
    return refreshedState;
  }

  Future<void> _saveSingleAccount(
    String userId,
    ConnectedEmailAccount nextAccount,
  ) async {
    final accounts = await accountService.loadAccounts(userId);
    final merged = [
      ...accounts.where(
        (item) => item.provider != ConnectedEmailProvider.gmail,
      ),
      nextAccount,
    ];
    await accountService.saveAccounts(userId, merged);
  }

  Future<void> _clearSavedConnection(String userId) async {
    final accounts = await accountService.loadAccounts(userId);
    final nextAccounts = accounts
        .where((item) => item.provider != ConnectedEmailProvider.gmail)
        .toList(growable: false);
    await accountService.saveAccounts(userId, nextAccounts);
  }

  Future<GoogleSignInAccount?> _attemptLightweightAuthentication() async {
    final Future<GoogleSignInAccount?>? attempt = _googleSignIn
        .attemptLightweightAuthentication(reportAllExceptions: false);
    if (attempt == null) {
      return null;
    }
    return attempt;
  }

  Map<String, String> _headerMap(List<dynamic> rawHeaders) {
    final headers = <String, String>{};
    for (final entry in rawHeaders) {
      if (entry is! Map<String, dynamic>) continue;
      final name = (entry['name'] as String? ?? '').toLowerCase().trim();
      final value = (entry['value'] as String? ?? '').trim();
      if (name.isNotEmpty && value.isNotEmpty) {
        headers[name] = value;
      }
    }
    return headers;
  }

  _SenderInfo _parseSender(String raw) {
    final emailMatch = RegExp(r'<([^>]+)>').firstMatch(raw);
    final email = emailMatch?.group(1)?.trim() ?? raw.trim();
    final cleanedName = raw.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    final name = cleanedName.isEmpty ? email : cleanedName.replaceAll('"', '');
    return _SenderInfo(name: name, email: email);
  }

  DateTime _parseInternalDate(String? value, {required DateTime fallback}) {
    final milliseconds = int.tryParse(value ?? '');
    if (milliseconds == null) return fallback;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  String _extractBodyText(Map<String, dynamic> payload) {
    final plainBodies = <String>[];
    final htmlBodies = <String>[];
    void visitPart(Map<String, dynamic> part) {
      final mimeType = (part['mimeType'] as String? ?? '').toLowerCase();
      final body = part['body'] as Map<String, dynamic>? ?? const {};
      final bodyData = body['data'] as String?;
      if (mimeType.startsWith('text/plain') && bodyData != null) {
        plainBodies.add(_decodeGmailBody(bodyData));
      } else if (mimeType.startsWith('text/html') && bodyData != null) {
        htmlBodies.add(_stripHtml(_decodeGmailBody(bodyData)));
      }
      final parts = part['parts'] as List<dynamic>? ?? const [];
      for (final child in parts) {
        if (child is Map<String, dynamic>) {
          visitPart(child);
        }
      }
    }

    visitPart(payload);
    if (plainBodies.isNotEmpty) {
      return plainBodies.join('\n').trim();
    }
    if (htmlBodies.isNotEmpty) {
      return htmlBodies.join('\n').trim();
    }
    return '';
  }

  Future<List<EmailImportAttachmentSource>> _extractAttachmentMetadata({
    required Map<String, dynamic> payload,
    required String accessToken,
    required String messageId,
  }) async {
    final attachments = <EmailImportAttachmentSource>[];
    Future<void> visitPart(Map<String, dynamic> part) async {
      final filename = (part['filename'] as String? ?? '').trim();
      final body = part['body'] as Map<String, dynamic>? ?? const {};
      final attachmentId = body['attachmentId'] as String? ?? '';
      final mimeType = (part['mimeType'] as String? ?? '').trim();
      final size = (body['size'] as num?)?.toInt() ?? 0;
      List<int>? bytes;
      final extension = _fileExtension(filename, mimeType);
      final shouldFetchBytes =
          attachmentId.isNotEmpty &&
          filename.isNotEmpty &&
          extension == 'pdf' &&
          size > 0 &&
          size <= 2 * 1024 * 1024;
      if (shouldFetchBytes) {
        bytes = await _downloadAttachmentBytes(
          accessToken: accessToken,
          messageId: messageId,
          attachmentId: attachmentId,
        );
      }
      if (filename.isNotEmpty || attachmentId.isNotEmpty) {
        attachments.add(
          EmailImportAttachmentSource(
            id: attachmentId.isNotEmpty
                ? attachmentId
                : '${filename}_${attachments.length}',
            fileName: filename.isEmpty ? 'attachment' : filename,
            mimeType: mimeType.isEmpty ? 'application/octet-stream' : mimeType,
            fileExtension: extension,
            fileSize: size,
            bytes: bytes,
          ),
        );
      }
      final parts = part['parts'] as List<dynamic>? ?? const [];
      for (final child in parts) {
        if (child is Map<String, dynamic>) {
          await visitPart(child);
        }
      }
    }

    await visitPart(payload);
    return attachments;
  }

  Future<List<int>?> _downloadAttachmentBytes({
    required String accessToken,
    required String messageId,
    required String attachmentId,
  }) async {
    try {
      final uri = Uri.parse(
        '$_gmailBaseUrl/users/me/messages/$messageId/attachments/$attachmentId',
      );
      final response = await _gmailGet(uri, accessToken);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final encoded = data['data'] as String?;
      if (encoded == null || encoded.isEmpty) {
        return null;
      }
      final normalized = base64.normalize(
        encoded.replaceAll('-', '+').replaceAll('_', '/'),
      );
      return base64.decode(normalized);
    } catch (_) {
      return null;
    }
  }

  String _decodeGmailBody(String encoded) {
    try {
      final normalized = base64.normalize(
        encoded.replaceAll('-', '+').replaceAll('_', '/'),
      );
      return utf8.decode(base64.decode(normalized), allowMalformed: true);
    } catch (_) {
      return '';
    }
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

  String _buildGmailSearchQuery(DateTime windowStart) {
    final afterDate = _gmailDate(windowStart);
    return [
      'after:$afterDate',
      '-in:chats',
      '('
          'receipt OR invoice OR billed OR payment OR subscription OR renewed OR renewal OR trial OR plan OR membership OR premium'
          ')',
    ].join(' ');
  }

  String _gmailDate(DateTime value) {
    final utc = value.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}/$month/$day';
  }

  void _ensureConfigured() {
    if (!AppConfig.isGoogleGmailOAuthConfigured) {
      throw StateError(_missingConfigurationMessage);
    }
  }

  String _userMessageForException(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Gmail connection was canceled before Bizoot could finish linking your account.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return _missingConfigurationMessage;
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in could not open on this device right now. Please try again.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google returned a different account than expected. Please try connecting again.';
      case GoogleSignInExceptionCode.interrupted:
        return 'The Gmail connection was interrupted. Please try again.';
      case GoogleSignInExceptionCode.unknownError:
        return error.description?.trim().isNotEmpty == true
            ? error.description!.trim()
            : _fallbackConnectionErrorMessage;
    }
  }

  static const String _fallbackConnectionErrorMessage =
      'Bizoot could not connect Gmail right now. Please try again.';
  static const String _interactiveSignInUnavailableMessage =
      'Google sign-in is not available on this device right now.';
  static const String _reauthorizationMessage =
      'Gmail is connected, but Bizoot still needs read-only permission for subscription scanning.';
  static const String _authorizationUnavailableMessage =
      'Bizoot could not refresh Gmail access right now. Please try connecting the inbox again.';
  static const String _missingConfigurationMessage =
      'Google OAuth is not configured for this build yet. Add the Gmail client IDs before connecting an inbox.';
}

class _SenderInfo {
  const _SenderInfo({required this.name, required this.email});

  final String name;
  final String email;
}

class _GmailUnauthorizedException implements Exception {
  const _GmailUnauthorizedException();
}
