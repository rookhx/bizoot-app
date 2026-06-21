import 'package:flutter/material.dart';

class BrandIconMatch {
  final String canonicalSlug;
  final List<String> assetCandidates;
  final Color? brandColor;
  final String initials;

  const BrandIconMatch({
    required this.canonicalSlug,
    required this.assetCandidates,
    required this.brandColor,
    required this.initials,
  });

  bool get hasAsset => assetCandidates.isNotEmpty;
}

class BrandIconService {
  const BrandIconService._();

  static const instance = BrandIconService._();

  static const List<String> _knownAssetPaths = [
    'assets/brand_icons/adobe-creative-cloud.png.png',
    'assets/brand_icons/amazon-prime-video.png.png',
    'assets/brand_icons/apple-arcade.png.png',
    'assets/brand_icons/apple-icloud.png.png',
    'assets/brand_icons/apple-music.png.png',
    'assets/brand_icons/asana-logo.png.png',
    'assets/brand_icons/aura-laboratories.png.png',
    'assets/brand_icons/aws.png.png',
    'assets/brand_icons/box.png.png',
    'assets/brand_icons/buffer.png.png',
    'assets/brand_icons/calm.png.png',
    'assets/brand_icons/canva.png.png',
    'assets/brand_icons/clickup.png',
    'assets/brand_icons/codecademy.png.png',
    'assets/brand_icons/contract.png.png',
    'assets/brand_icons/coursera.png.png',
    'assets/brand_icons/crunchyroll.png.png',
    'assets/brand_icons/dashlane.png.png',
    'assets/brand_icons/dazn.png.png',
    'assets/brand_icons/deezer.png.png',
    'assets/brand_icons/deliveroo.png.png',
    'assets/brand_icons/digitalocean.png.png',
    'assets/brand_icons/disney+.png.png',
    'assets/brand_icons/doordash.png.png',
    'assets/brand_icons/dropbox.png.png',
    'assets/brand_icons/duolingo.png.png',
    'assets/brand_icons/edx.png.png',
    'assets/brand_icons/evernote.png.png',
    'assets/brand_icons/figma.png.png',
    'assets/brand_icons/freshbooks.png.png',
    'assets/brand_icons/fubotv.png.png',
    'assets/brand_icons/google-cloud-storage.png.png',
    'assets/brand_icons/google-one.png.png',
    'assets/brand_icons/google-workspace.png.png',
    'assets/brand_icons/gym.png.png',
    'assets/brand_icons/hbo-max.png.png',
    'assets/brand_icons/house rent.png.png',
    'assets/brand_icons/hulu.png.png',
    'assets/brand_icons/ifttt.png.png',
    'assets/brand_icons/insurance.png.png',
    'assets/brand_icons/internet.png.png',
    'assets/brand_icons/justeat.png.png',
    'assets/brand_icons/keeper.png.png',
    'assets/brand_icons/lastpass.png.png',
    'assets/brand_icons/linear.png.png',
    'assets/brand_icons/loan.png.png',
    'assets/brand_icons/mailchimp.png.png',
    'assets/brand_icons/malwarebytes.png.png',
    'assets/brand_icons/masterclass.png.png',
    'assets/brand_icons/mcafee.png.png',
    'assets/brand_icons/medium.png.png',
    'assets/brand_icons/mega.png.png',
    'assets/brand_icons/membership.png.png',
    'assets/brand_icons/Microsoft-365.png.png',
    'assets/brand_icons/miro.png.png',
    'assets/brand_icons/myfitnesspal.png.png',
    'assets/brand_icons/napster.png.png',
    'assets/brand_icons/netflix.png.png',
    'assets/brand_icons/nordvpn.png.png',
    'assets/brand_icons/notion.png.png',
    'assets/brand_icons/onlyfans.png.png',
    'assets/brand_icons/pandora,png.png',
    'assets/brand_icons/patreon.png.png',
    'assets/brand_icons/peacock.png.png',
    'assets/brand_icons/phone.png.png',
    'assets/brand_icons/poe.png.png',
    'assets/brand_icons/proton-drive.png.png',
    'assets/brand_icons/proton-mail.png.png',
    'assets/brand_icons/proton-pass.png.png',
    'assets/brand_icons/rent.png.png',
    'assets/brand_icons/sage.png.png',
    'assets/brand_icons/siriusxm.png.png',
    'assets/brand_icons/slack.png.png',
    'assets/brand_icons/spotify.png.png',
    'assets/brand_icons/starz.png.png',
    'assets/brand_icons/strava.png.png',
    'assets/brand_icons/substack.png.png',
    'assets/brand_icons/the-new-york-times.png.png',
    'assets/brand_icons/the-wall-street-journal.png.png',
    'assets/brand_icons/the-washington-post.png.png',
    'assets/brand_icons/tidal.png.png',
    'assets/brand_icons/todoist.png.png',
    'assets/brand_icons/trello.png.png',
    'assets/brand_icons/typeform.png.png',
    'assets/brand_icons/udemy.png.png',
    'assets/brand_icons/utilities.png.png',
    'assets/brand_icons/windows-cursor.png.png',
    'assets/brand_icons/wolt.png.png',
    'assets/brand_icons/world-of-warcraft.png.png',
    'assets/brand_icons/xbox-game-pass.png.png',
    'assets/brand_icons/xero.png.png',
    'assets/brand_icons/youtube-music.png.png',
    'assets/brand_icons/youtube-tv.png.png',
    'assets/brand_icons/youtube.png.png',
    'assets/brand_icons/zapier.png.png',
    'assets/brand_icons/zoom-app.png.png',
  ];

  static const Map<String, List<String>> _assetCandidatesBySlug = {
    'netflix': [
      'assets/brand_icons/netflix.png',
      'assets/brand_icons/netflix.svg',
      'assets/brand_icons/netflix.png.png',
    ],
    'spotify': [
      'assets/brand_icons/spotify.png',
      'assets/brand_icons/spotify.svg',
      'assets/brand_icons/spotify.png.png',
    ],
    'youtube': [
      'assets/brand_icons/youtube.png',
      'assets/brand_icons/youtube.svg',
      'assets/brand_icons/youtube.png.png',
    ],
    'disneyplus': [
      'assets/brand_icons/disneyplus.png',
      'assets/brand_icons/disneyplus.svg',
    ],
    'amazonprime': [
      'assets/brand_icons/amazonprime.png',
      'assets/brand_icons/amazonprime.svg',
      'assets/brand_icons/amazon.png',
      'assets/brand_icons/amazon.svg',
    ],
    'notion': [
      'assets/brand_icons/notion.png',
      'assets/brand_icons/notion.svg',
    ],
    'canva': [
      'assets/brand_icons/canva.png',
      'assets/brand_icons/canva.svg',
      'assets/brand_icons/canva.png.png',
    ],
    'apartmentrent': [
      'assets/brand_icons/apartment rent.png',
      'assets/brand_icons/apartment rent.svg',
      'assets/brand_icons/apartment rent.png.png',
    ],
    'houserent': [
      'assets/brand_icons/house rent.png',
      'assets/brand_icons/house rent.svg',
      'assets/brand_icons/house rent.png.png',
    ],
    'gym': [
      'assets/brand_icons/gym.png',
      'assets/brand_icons/gym.svg',
      'assets/brand_icons/gym.png.png',
    ],
    'insurance': [
      'assets/brand_icons/insurance.png',
      'assets/brand_icons/insurance.svg',
      'assets/brand_icons/insurance.png.png',
    ],
    'internet': [
      'assets/brand_icons/internet.png',
      'assets/brand_icons/internet.svg',
      'assets/brand_icons/internet.png.png',
    ],
    'phone': [
      'assets/brand_icons/phone.png',
      'assets/brand_icons/phone.svg',
      'assets/brand_icons/phone.png.png',
    ],
    'rent': [
      'assets/brand_icons/rent.png',
      'assets/brand_icons/rent.svg',
      'assets/brand_icons/rent.png.png',
    ],
    'utilities': [
      'assets/brand_icons/utilities.png',
      'assets/brand_icons/utilities.svg',
      'assets/brand_icons/utilities.png.png',
    ],
    'openai': [
      'assets/brand_icons/openai.png',
      'assets/brand_icons/openai.svg',
      'assets/brand_icons/chatgpt.png',
      'assets/brand_icons/chatgpt.svg',
    ],
    'googleone': [
      'assets/brand_icons/googleone.png',
      'assets/brand_icons/googleone.svg',
      'assets/brand_icons/google-one.png.png',
    ],
    'icloud': [
      'assets/brand_icons/icloud.png',
      'assets/brand_icons/icloud.svg',
      'assets/brand_icons/apple-icloud.png.png',
    ],
    'dropbox': [
      'assets/brand_icons/dropbox.png',
      'assets/brand_icons/dropbox.svg',
    ],
    'microsoft365': [
      'assets/brand_icons/microsoft365.png',
      'assets/brand_icons/microsoft365.svg',
      'assets/brand_icons/microsoft.png',
      'assets/brand_icons/microsoft.svg',
    ],
    'adobe': [
      'assets/brand_icons/adobe.png',
      'assets/brand_icons/adobe.svg',
    ],
    'figma': [
      'assets/brand_icons/figma.png',
      'assets/brand_icons/figma.svg',
    ],
    'slack': [
      'assets/brand_icons/slack.png',
      'assets/brand_icons/slack.svg',
    ],
    'zoom': [
      'assets/brand_icons/zoom.png',
      'assets/brand_icons/zoom.svg',
    ],
    'wolt': [
      'assets/brand_icons/wolt.png',
      'assets/brand_icons/wolt.svg',
      'assets/brand_icons/wolt.png.png',
    ],
    'justeat': [
      'assets/brand_icons/justeat.png',
      'assets/brand_icons/justeat.svg',
      'assets/brand_icons/justeat.png.png',
    ],
    'loan': [
      'assets/brand_icons/loan.png',
      'assets/brand_icons/loan.svg',
      'assets/brand_icons/loan.png.png',
    ],
    'membership': [
      'assets/brand_icons/membership.png',
      'assets/brand_icons/membership.svg',
      'assets/brand_icons/membership.png.png',
    ],
    'contract': [
      'assets/brand_icons/contract.png',
      'assets/brand_icons/contract.svg',
      'assets/brand_icons/contract.png.png',
    ],
  };

  static const Map<String, Color> _brandColorBySlug = {
    'netflix': Color(0xFFE50914),
    'spotify': Color(0xFF1DB954),
    'youtube': Color(0xFFFF0000),
    'disneyplus': Color(0xFF113CCF),
    'amazonprime': Color(0xFF00A8E1),
    'notion': Color(0xFFFFFFFF),
    'canva': Color(0xFF7D2AE8),
    'apartmentrent': Color(0xFF8B5CF6),
    'houserent': Color(0xFF8B5CF6),
    'gym': Color(0xFF22C55E),
    'insurance': Color(0xFF4A93FF),
    'internet': Color(0xFF3B82F6),
    'phone': Color(0xFFFACC15),
    'rent': Color(0xFFF8B44C),
    'utilities': Color(0xFF3B82F6),
    'openai': Color(0xFF10A37F),
    'googleone': Color(0xFF4285F4),
    'icloud': Color(0xFFFFFFFF),
    'dropbox': Color(0xFF0061FF),
    'microsoft365': Color(0xFFF25022),
    'adobe': Color(0xFFFF0000),
    'figma': Color(0xFFF24E1E),
    'slack': Color(0xFF4A154B),
    'zoom': Color(0xFF2D8CFF),
    'wolt': Color(0xFF00C2E8),
    'justeat': Color(0xFFFF5A00),
    'loan': Color(0xFFFF8E52),
    'membership': Color(0xFF9B6DFF),
    'contract': Color(0xFFFF7A59),
  };

  static const Map<String, String> _aliasToSlug = {
    'netflix': 'netflix',
    'netflixstandard': 'netflix',
    'netflixpremium': 'netflix',
    'spotify': 'spotify',
    'spotifypremium': 'spotify',
    'spotifyfamily': 'spotify',
    'youtube': 'youtube',
    'youtubepremium': 'youtube',
    'youtubemusic': 'youtube',
    'youtubepremiumfamily': 'youtube',
    'amazon': 'amazonprime',
    'amazonprime': 'amazonprime',
    'primevideo': 'amazonprime',
    'prime': 'amazonprime',
    'disney': 'disneyplus',
    'disneyplus': 'disneyplus',
    'notion': 'notion',
    'canva': 'canva',
    'canvapro': 'canva',
    'apartmentrent': 'apartmentrent',
    'apartment': 'apartmentrent',
    'houserent': 'houserent',
    'house': 'houserent',
    'gym': 'gym',
    'fitness': 'gym',
    'insurance': 'insurance',
    'internet': 'internet',
    'wifi': 'internet',
    'phone': 'phone',
    'rent': 'rent',
    'utilities': 'utilities',
    'utility': 'utilities',
    'chatgpt': 'openai',
    'chatgptplus': 'openai',
    'openai': 'openai',
    'googleone': 'googleone',
    'googlestorage': 'googleone',
    'googledrive': 'googleone',
    'icloud': 'icloud',
    'icloudplus': 'icloud',
    'appleicloud': 'icloud',
    'dropbox': 'dropbox',
    'microsoft365': 'microsoft365',
    'office365': 'microsoft365',
    'microsoftoffice': 'microsoft365',
    'microsoft': 'microsoft365',
    'adobe': 'adobe',
    'adobecreativecloud': 'adobe',
    'figma': 'figma',
    'slack': 'slack',
    'zoom': 'zoom',
    'wolt': 'wolt',
    'woltplus': 'wolt',
    'justeat': 'justeat',
    'justeatplus': 'justeat',
    'loan': 'loan',
    'loans': 'loan',
    'membership': 'membership',
    'memberships': 'membership',
    'contract': 'contract',
    'contracts': 'contract',
  };

  BrandIconMatch resolve({
    String? serviceId,
    String? serviceName,
    String? iconKey,
  }) {
    final normalizedName = _normalize(serviceName ?? '');
    final normalizedId = _normalize(serviceId ?? '');
    final normalizedIconKey = _normalize(iconKey ?? '');

    final canonicalSlug = _resolveCanonicalSlug(
      serviceId: normalizedId,
      serviceName: normalizedName,
      iconKey: normalizedIconKey,
    );
    final rawCandidates = [
      normalizedId,
      normalizedName,
      normalizedIconKey,
      ..._candidateFragments(normalizedName),
      ..._candidateFragments(normalizedId),
      ..._candidateFragments(normalizedIconKey),
    ];
    final discoveredExactCandidates = _discoverExactAssetCandidates(rawCandidates);
    final discoveredFuzzyCandidates = canonicalSlug.isEmpty ? _discoverFuzzyAssetCandidates(rawCandidates) : const <String>[];
    final effectiveSlug = canonicalSlug.isNotEmpty
        ? canonicalSlug
        : (discoveredExactCandidates.isNotEmpty ? _normalize(_assetStem(discoveredExactCandidates.first)) : '');
    final assetCandidates = _mergeCandidates(
      effectiveSlug.isEmpty ? const [] : _assetCandidatesForSlug(effectiveSlug),
      _mergeCandidates(discoveredExactCandidates, discoveredFuzzyCandidates),
    );

    return BrandIconMatch(
      canonicalSlug: effectiveSlug,
      assetCandidates: assetCandidates,
      brandColor: effectiveSlug.isEmpty ? null : _brandColorBySlug[effectiveSlug],
      initials: _buildInitials(serviceName ?? serviceId ?? iconKey ?? ''),
    );
  }

  String canonicalDisplayName(String? rawName, {String? serviceId, String? iconKey}) {
    final fallback = (rawName ?? '').trim();
    final match = resolve(
      serviceId: serviceId,
      serviceName: rawName,
      iconKey: iconKey,
    );

    switch (match.canonicalSlug) {
      case 'spotify':
        return 'Spotify';
      case 'houserent':
        return 'House Rent';
      case 'apartmentrent':
        return 'Apartment Rent';
      case 'justeat':
        return 'Just Eat';
      case 'wolt':
        return 'Wolt';
      case 'loan':
        return 'Loan';
      case 'membership':
        return 'Membership';
      case 'contract':
        return 'Contract';
      default:
        return fallback.isEmpty ? (rawName ?? '') : fallback;
    }
  }

  String _resolveCanonicalSlug({
    required String serviceId,
    required String serviceName,
    required String iconKey,
  }) {
    final candidates = [
      serviceId,
      serviceName,
      iconKey,
      ..._candidateFragments(serviceName),
      ..._candidateFragments(serviceId),
      ..._candidateFragments(iconKey),
    ];

    for (final candidate in candidates) {
      if (candidate.isEmpty) continue;
      final mapped = _aliasToSlug[candidate];
      if (mapped != null) return mapped;
      for (final entry in _aliasToSlug.entries) {
        if (candidate.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return '';
  }

  List<String> _assetCandidatesForSlug(String slug) {
    final explicit = _assetCandidatesBySlug[slug] ?? const <String>[];
    final heuristic = <String>[];
    for (final assetPath in _knownAssetPaths) {
      final stem = _normalize(_assetStem(assetPath));
      if (_slugMatchesStem(slug, stem)) {
        heuristic.add(assetPath);
      }
    }
    return _mergeCandidates(explicit, heuristic);
  }

  List<String> _discoverExactAssetCandidates(List<String> candidates) {
    final exactMatches = <String>[];
    for (final assetPath in _knownAssetPaths) {
      final stem = _normalize(_assetStem(assetPath));
      for (final candidate in candidates) {
        if (candidate.isEmpty) continue;
        if (stem == candidate) {
          exactMatches.add(assetPath);
          break;
        }
      }
    }
    return exactMatches;
  }

  List<String> _discoverFuzzyAssetCandidates(List<String> candidates) {
    final fuzzyMatches = <String>[];
    for (final assetPath in _knownAssetPaths) {
      final stem = _normalize(_assetStem(assetPath));
      for (final candidate in candidates) {
        if (candidate.isEmpty || candidate.length < 4) continue;
        if (stem.contains(candidate) || candidate.contains(stem)) {
          fuzzyMatches.add(assetPath);
          break;
        }
      }
    }
    return fuzzyMatches;
  }

  bool _slugMatchesStem(String slug, String stem) {
    if (slug == stem) return true;
    if (stem.contains(slug) || slug.contains(stem)) return true;
    final aliasCandidates = _aliasToSlug.entries
        .where((entry) => entry.value == slug)
        .map((entry) => entry.key)
        .where((alias) => alias.length >= 4);
    for (final alias in aliasCandidates) {
      if (stem == alias || stem.contains(alias) || alias.contains(stem)) {
        return true;
      }
    }
    return false;
  }

  List<String> _mergeCandidates(List<String> primary, List<String> secondary) {
    final merged = <String>[];
    for (final candidate in [...primary, ...secondary]) {
      if (!merged.contains(candidate)) merged.add(candidate);
    }
    return merged;
  }

  String _assetStem(String assetPath) {
    final filename = assetPath.split('/').last;
    final lowercase = filename.toLowerCase();
    if (lowercase.endsWith('.png.png')) {
      return filename.substring(0, filename.length - '.png.png'.length);
    }
    if (lowercase.endsWith('.svg')) {
      return filename.substring(0, filename.length - '.svg'.length);
    }
    if (lowercase.endsWith('.png')) {
      return filename.substring(0, filename.length - '.png'.length);
    }
    return filename;
  }

  Iterable<String> _candidateFragments(String value) sync* {
    if (value.isEmpty) return;
    yield value;
    final words = value.split(RegExp(r'(?<=.)(?=[A-Z])|[^a-z0-9]+')).where((item) => item.isNotEmpty).toList();
    if (words.isEmpty) return;
    for (final word in words) {
      yield _normalize(word);
    }
    if (words.length >= 2) {
      yield _normalize('${words.first}${words.last}');
      yield _normalize(words.join());
    }
  }

  String _buildInitials(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed
        .split(RegExp(r'[\s\-_+/]+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final part = parts.first;
      return part.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1);
    final second = parts[1].substring(0, 1);
    return '$first$second'.toUpperCase();
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
