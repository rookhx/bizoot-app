import 'dart:convert';

String sanitizeLocalizedText(String text) {
  const replacements = <String, String>{
    'ÃƒÂ¥': '\u00e5',
    'ÃƒÂ¦': '\u00e6',
    'ÃƒÂ¸': '\u00f8',
    'Ãƒâ€¦': '\u00c5',
    'Ãƒâ€ ': '\u00c6',
    'ÃƒËœ': '\u00d8',
    'ÃƒÂ¼': '\u00fc',
    'ÃƒÅ“': '\u00dc',
    'ÃƒÂ¶': '\u00f6',
    'Ãƒâ€“': '\u00d6',
    'ÃƒÂ¤': '\u00e4',
    'Ãƒâ€ž': '\u00c4',
    'ÃƒÅ¸': '\u00df',
    'ÃƒÂ©': '\u00e9',
    'Ãƒâ€°': '\u00c9',
    'ÃƒÂ¡': '\u00e1',
    'ÃƒÂ': '\u00c1',
    'ÃƒÂ³': '\u00f3',
    'Ãƒâ€œ': '\u00d3',
    'ÃƒÂº': '\u00fa',
    'ÃƒÅ¡': '\u00da',
    'ÃƒÂ±': '\u00f1',
    'Ãƒâ€˜': '\u00d1',
    'ÃƒÂ­': '\u00ed',
    'ÃƒÂ': '\u00cd',
    'ÃƒÂ²': '\u00f2',
    'ÃƒÂ§': '\u00e7',
    'Ã¢â‚¬Â¢': '\u2022',
    'Ã¢â‚¬â€œ': '\u2013',
    'Ã¢â‚¬â€': '\u2014',
    'Ã¢â‚¬â„¢': '\u2019',
    'Ã¢â‚¬Å“': '\u201c',
    'Ã¢â‚¬Â': '\u201d',
    'Ã¢â‚¬Â¦': '\u2026',
  };

  var normalized = text;
  for (var i = 0; i < 3; i++) {
    final before = normalized;
    replacements.forEach((broken, fixed) {
      normalized = normalized.replaceAll(broken, fixed);
    });
    normalized = _repairCommonMojibake(normalized);
    if (normalized == before) {
      break;
    }
  }

  return normalized;
}

String _repairCommonMojibake(String text) {
  const cp1252 = <int, int>{
    0x20AC: 0x80,
    0x201A: 0x82,
    0x0192: 0x83,
    0x201E: 0x84,
    0x2026: 0x85,
    0x2020: 0x86,
    0x2021: 0x87,
    0x02C6: 0x88,
    0x2030: 0x89,
    0x0160: 0x8A,
    0x2039: 0x8B,
    0x0152: 0x8C,
    0x017D: 0x8E,
    0x2018: 0x91,
    0x2019: 0x92,
    0x201C: 0x93,
    0x201D: 0x94,
    0x2022: 0x95,
    0x2013: 0x96,
    0x2014: 0x97,
    0x02DC: 0x98,
    0x2122: 0x99,
    0x0161: 0x9A,
    0x203A: 0x9B,
    0x0153: 0x9C,
    0x017E: 0x9E,
    0x0178: 0x9F,
  };

  final bytes = <int>[];
  for (final rune in text.runes) {
    if (rune <= 0xFF) {
      bytes.add(rune);
      continue;
    }
    final mapped = cp1252[rune];
    if (mapped == null) {
      return text;
    }
    bytes.add(mapped);
  }

  try {
    return utf8.decode(bytes, allowMalformed: false);
  } catch (_) {
    return text;
  }
}
