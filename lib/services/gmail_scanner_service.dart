import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/detected_subscription.dart';
import '../models/recurring_payment.dart';
import 'subscription_database_service.dart';

class GmailScannerService {
  static final GmailScannerService instance = GmailScannerService._();
  GmailScannerService._();

  static const _gmailScope = 'https://www.googleapis.com/auth/gmail.readonly';
  static const _baseUrl = 'https://gmail.googleapis.com/gmail/v1/users/me';

  // Provide your Web OAuth 2.0 Client ID from Google Cloud Console.
  // Required for Gmail scope access. See: https://console.cloud.google.com/apis/credentials
  static const String? _serverClientId = null; // TODO: set your Web Client ID

  final _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<List<DetectedSubscription>> scanSubscriptions({
    void Function(String status)? onProgress,
  }) async {
    onProgress?.call('Connecting to Gmail…');
    final headers = await _authenticate();

    onProgress?.call('Searching subscription emails…');
    final messageIds = await _fetchMessageIds(headers);

    if (messageIds.isEmpty) return [];

    final results = <DetectedSubscription>[];
    final seen = <String>{}; // deduplicate by normalized service name

    for (var i = 0; i < messageIds.length; i++) {
      onProgress?.call(
        'Reading email ${i + 1} of ${messageIds.length}…',
      );
      try {
        final msg = await _fetchMessage(headers, messageIds[i]);
        final detected = _parseMessage(msg);
        if (detected != null) {
          final key = detected.name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
          if (!seen.contains(key)) {
            seen.add(key);
            results.add(detected);
          }
        }
      } catch (_) {
        // skip unreadable messages
      }
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  // ─── Gmail API ─────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authenticate() async {
    await _ensureInitialized();

    // Try silent sign-in first so the user doesn't have to re-auth every time.
    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.attemptLightweightAuthentication();
    } catch (_) {
      account = null;
    }
    account ??= await _googleSignIn.authenticate(scopeHint: [_gmailScope]);

    final headers = await account.authorizationClient.authorizationHeaders(
      [_gmailScope],
      promptIfNecessary: true,
    );
    if (headers == null) {
      throw Exception('Could not obtain Gmail authorization.');
    }
    return headers;
  }

  Future<List<String>> _fetchMessageIds(Map<String, String> headers) async {
    // Search for billing / subscription-related emails in the last year.
    const query =
        '(subject:subscription OR subject:receipt OR subject:invoice '
        'OR subject:renewal OR subject:billing OR subject:payment '
        'OR subject:charge OR subject:membership OR subject:"your plan" '
        'OR subject:"thank you for your purchase") newer_than:365d';

    final ids = <String>[];
    String? pageToken;

    do {
      final uri = Uri.parse('$_baseUrl/messages').replace(queryParameters: {
        'q': query,
        'maxResults': '200',
        if (pageToken != null) 'pageToken': pageToken,
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) break;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>? ?? [];
      ids.addAll(messages.map((m) => m['id'] as String));

      pageToken = body['nextPageToken'] as String?;
      // Cap at 500 messages to keep scan time reasonable.
    } while (pageToken != null && ids.length < 500);

    return ids;
  }

  Future<Map<String, dynamic>> _fetchMessage(
    Map<String, String> headers,
    String messageId,
  ) async {
    final uri = Uri.parse('$_baseUrl/messages/$messageId')
        .replace(queryParameters: {'format': 'full'});

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) throw Exception('Failed to fetch message');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─── Parsing ───────────────────────────────────────────────────────────────

  DetectedSubscription? _parseMessage(Map<String, dynamic> msg) {
    final payload = msg['payload'] as Map<String, dynamic>? ?? {};
    final headers = (payload['headers'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final subject = _headerValue(headers, 'Subject') ?? '';
    final from = _headerValue(headers, 'From') ?? '';
    final dateStr = _headerValue(headers, 'Date') ?? '';
    final emailDate = _parseRfc2822Date(dateStr) ?? DateTime.now();

    final body = _extractBody(payload);

    // Identify the service from sender domain + subject
    final senderDomain = _extractDomain(from);
    final dbEntry = _matchServiceDatabase(senderDomain, subject);

    String? serviceName = dbEntry?.name;
    String? iconKey = dbEntry?.id;
    String? cancelUrl = dbEntry?.cancelUrl;
    PaymentCategory category =
        _categoryFromDb(dbEntry?.category) ?? PaymentCategory.subscription;

    // Fall back to heuristic name extraction from sender
    serviceName ??= _nameFromSender(from, senderDomain);

    if (serviceName == null || serviceName.isEmpty) return null;

    // Extract price and currency
    final priceResult = _extractPrice(body.isNotEmpty ? body : subject);
    final double? amount = priceResult?.$1;
    final String currency = priceResult?.$2 ?? 'USD';

    // Extract renewal / next-charge date
    final nextDueDate = _extractDate(body);

    // Infer billing frequency
    final frequency = _inferFrequency(body, subject);

    // Confidence score
    double confidence = 0.3;
    if (dbEntry != null) confidence += 0.3;
    if (amount != null) confidence += 0.2;
    if (nextDueDate != null) confidence += 0.1;
    if (_isSubscriptionSubject(subject)) confidence += 0.1;
    confidence = confidence.clamp(0.0, 1.0);

    // Skip very low-confidence matches and free/zero-amount emails
    if (confidence < 0.4) return null;
    if (amount != null && amount == 0.0) return null;

    return DetectedSubscription(
      name: serviceName,
      providerName: dbEntry?.name ?? serviceName,
      amount: amount,
      currency: currency,
      frequency: frequency,
      nextDueDate: nextDueDate,
      category: category,
      iconKey: iconKey,
      cancellationUrl: cancelUrl,
      sourceEmailSubject: subject,
      senderEmail: _extractEmail(from),
      emailDate: emailDate,
      confidence: confidence,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String? _headerValue(List<Map<String, dynamic>> headers, String name) {
    for (final h in headers) {
      if ((h['name'] as String?)?.toLowerCase() == name.toLowerCase()) {
        return h['value'] as String?;
      }
    }
    return null;
  }

  String _extractBody(Map<String, dynamic> payload) {
    // Try simple body first
    final data = payload['body']?['data'] as String?;
    if (data != null && data.isNotEmpty) {
      return _decodeBase64(data);
    }

    // Walk parts recursively
    final parts = payload['parts'] as List<dynamic>? ?? [];
    final buffer = StringBuffer();
    for (final part in parts) {
      final p = part as Map<String, dynamic>;
      final mimeType = p['mimeType'] as String? ?? '';
      if (mimeType == 'text/plain' || mimeType == 'text/html') {
        final partData = p['body']?['data'] as String?;
        if (partData != null) buffer.write(_decodeBase64(partData));
      } else if (p.containsKey('parts')) {
        buffer.write(_extractBody(p));
      }
    }
    return buffer.toString();
  }

  String _decodeBase64(String data) {
    try {
      final normalized = data.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = base64.decode(normalized);
      return utf8.decode(decoded, allowMalformed: true);
    } catch (_) {
      return '';
    }
  }

  String _extractDomain(String from) {
    final emailMatch = RegExp(r'[\w.+-]+@([\w.-]+\.[a-z]{2,})').firstMatch(from);
    return emailMatch?.group(1)?.toLowerCase() ?? '';
  }

  String _extractEmail(String from) {
    final match = RegExp(r'[\w.+-]+@[\w.-]+\.[a-z]{2,}').firstMatch(from);
    return match?.group(0) ?? from;
  }

  SubscriptionServiceEntry? _matchServiceDatabase(
      String domain, String subject) {
    final db = SubscriptionDatabaseService.instance;
    if (!db.isLoaded) return null;

    final domainRoot = domain.split('.').reversed.take(2).toList().reversed.join('.');
    final subjectLower = subject.toLowerCase();

    for (final entry in db.allServices) {
      // Match by website domain
      final website = entry.website.toLowerCase();
      if (website.contains(domainRoot) && domainRoot.length > 4) return entry;

      // Match by name / aliases in subject
      final nameLower = entry.name.toLowerCase();
      if (subjectLower.contains(nameLower) && nameLower.length > 3) return entry;

      for (final alias in entry.aliases) {
        if (subjectLower.contains(alias.toLowerCase()) &&
            alias.length > 3) {
          return entry;
        }
      }
    }
    return null;
  }

  String? _nameFromSender(String from, String domain) {
    // Try "Display Name <email>" pattern
    final displayMatch = RegExp(r'^"?([^"<@\n]+)"?\s*<').firstMatch(from);
    if (displayMatch != null) {
      final display = displayMatch.group(1)?.trim() ?? '';
      if (display.isNotEmpty && !display.contains('@')) {
        // Clean up common suffixes like "Billing", "No-Reply", "Support"
        return display
            .replaceAll(RegExp(r'\b(billing|no.?reply|support|noreply|hello|team|info)\b',
                caseSensitive: false), '')
            .trim();
      }
    }

    // Derive from domain: stripe.com → Stripe
    if (domain.isEmpty) return null;
    final domainParts = domain.split('.');
    final base = domainParts.length >= 2
        ? domainParts[domainParts.length - 2]
        : domainParts.first;
    return base.isNotEmpty
        ? base[0].toUpperCase() + base.substring(1)
        : null;
  }

  (double, String)? _extractPrice(String text) {
    // Matches: $9.99, USD 9.99, 9.99 USD, £9.99, €9.99, etc.
    final patterns = [
      RegExp(r'[\$£€]\s*(\d{1,4}(?:[.,]\d{2,3})*(?:[.,]\d{2})?)'),
      RegExp(r'(\d{1,4}(?:[.,]\d{2,3})*(?:[.,]\d{2})?)\s*(USD|EUR|GBP|CAD|AUD)',
          caseSensitive: false),
      RegExp(r'USD\s*(\d{1,4}(?:[.,]\d{2,3})*(?:[.,]\d{2})?)',
          caseSensitive: false),
    ];

    final currencyMap = {'\$': 'USD', '£': 'GBP', '€': 'EUR'};

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = (match.group(1) ?? '').replaceAll(',', '');
        final amount = double.tryParse(raw);
        if (amount != null && amount > 0 && amount < 10000) {
          String currency = 'USD';
          if (match.pattern.pattern.contains(r'[\$£€]')) {
            currency = currencyMap[match.group(0)![0]] ?? 'USD';
          } else if (match.groupCount >= 2) {
            currency = (match.group(2) ?? 'USD').toUpperCase();
          }
          return (amount, currency);
        }
      }
    }
    return null;
  }

  DateTime? _extractDate(String text) {
    // Common patterns: "renews on January 15, 2025", "next billing: 15 Jan 2025"
    final patterns = [
      RegExp(
          r'(?:renew|renewal|next.{0,15}(?:charge|billing|payment|due)|billed.{0,10}on|expires?)\D{0,20}'
          r'(\d{1,2}[\s\/\-]\w+[\s\/\-]\d{2,4}|\w+\s+\d{1,2},?\s+\d{4})',
          caseSensitive: false),
      RegExp(r'(\d{4}-\d{2}-\d{2})'), // ISO
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1) ?? '';
        final parsed = _tryParseDate(raw);
        if (parsed != null && parsed.isAfter(DateTime.now())) return parsed;
      }
    }

    // Fall back to 30 days from now
    return null;
  }

  DateTime? _tryParseDate(String raw) {
    // Try ISO first
    final iso = DateTime.tryParse(raw.trim());
    if (iso != null) return iso;

    // Month name patterns
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };

    // "January 15, 2025" or "15 January 2025"
    final longMatch = RegExp(
            r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})|([A-Za-z]+)\s+(\d{1,2}),?\s+(\d{4})')
        .firstMatch(raw);
    if (longMatch != null) {
      int? day, month, year;
      if (longMatch.group(1) != null) {
        day = int.tryParse(longMatch.group(1)!);
        month = months[longMatch.group(2)!.toLowerCase().substring(0, 3)];
        year = int.tryParse(longMatch.group(3)!);
      } else {
        month = months[longMatch.group(4)!.toLowerCase().substring(0, 3)];
        day = int.tryParse(longMatch.group(5)!);
        year = int.tryParse(longMatch.group(6)!);
      }
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  PaymentFrequency _inferFrequency(String body, String subject) {
    final combined = '${body.toLowerCase()} ${subject.toLowerCase()}';
    if (combined.contains('annual') ||
        combined.contains('yearly') ||
        combined.contains('per year') ||
        combined.contains('/year')) {
      return PaymentFrequency.yearly;
    }
    if (combined.contains('quarterly') || combined.contains('every 3 month')) {
      return PaymentFrequency.quarterly;
    }
    if (combined.contains('weekly') || combined.contains('per week')) {
      return PaymentFrequency.weekly;
    }
    return PaymentFrequency.monthly;
  }

  bool _isSubscriptionSubject(String subject) {
    final lower = subject.toLowerCase();
    return lower.contains('subscription') ||
        lower.contains('renewal') ||
        lower.contains('receipt') ||
        lower.contains('invoice') ||
        lower.contains('billing') ||
        lower.contains('membership') ||
        lower.contains('payment') ||
        lower.contains('charge');
  }

  PaymentCategory? _categoryFromDb(String? category) {
    if (category == null) return null;
    final lower = category.toLowerCase();
    if (lower.contains('music') || lower.contains('streaming') ||
        lower.contains('video') || lower.contains('entertain')) {
      return PaymentCategory.subscription;
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return PaymentCategory.gym;
    }
    if (lower.contains('insurance')) return PaymentCategory.insurance;
    if (lower.contains('internet') || lower.contains('vpn')) {
      return PaymentCategory.internet;
    }
    if (lower.contains('phone') || lower.contains('mobile')) {
      return PaymentCategory.phone;
    }
    if (lower.contains('utilities') || lower.contains('utility')) {
      return PaymentCategory.utilities;
    }
    if (lower.contains('software') || lower.contains('productivity') ||
        lower.contains('cloud') || lower.contains('storage')) {
      return PaymentCategory.subscription;
    }
    return PaymentCategory.subscription;
  }

  DateTime? _parseRfc2822Date(String dateStr) {
    try {
      // Strip day-of-week prefix if present, e.g. "Mon, 12 Jun 2023 ..."
      final cleaned = dateStr.replaceAll(RegExp(r'^\w+,\s*'), '').trim();
      return DateTime.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
