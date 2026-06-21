String sanitizeLocalizedText(String text) {
  const replacements = <String, String>{
    'Ã¥': '\u00e5',
    'Ã¦': '\u00e6',
    'Ã¸': '\u00f8',
    'Ã…': '\u00c5',
    'Ã†': '\u00c6',
    'Ã˜': '\u00d8',
    'Ã¼': '\u00fc',
    'Ãœ': '\u00dc',
    'Ã¶': '\u00f6',
    'Ã–': '\u00d6',
    'Ã¤': '\u00e4',
    'Ã„': '\u00c4',
    'ÃŸ': '\u00df',
    'Ã©': '\u00e9',
    'Ã‰': '\u00c9',
    'Ã¡': '\u00e1',
    'Ã': '\u00c1',
    'Ã³': '\u00f3',
    'Ã“': '\u00d3',
    'Ãº': '\u00fa',
    'Ãš': '\u00da',
    'Ã±': '\u00f1',
    'Ã‘': '\u00d1',
    'Ã­': '\u00ed',
    'Ã': '\u00cd',
    'Ã²': '\u00f2',
    'Ã§': '\u00e7',
    'â€¢': '\u2022',
    'â€“': '\u2013',
    'â€”': '\u2014',
    'â€™': '\u2019',
    'â€œ': '\u201c',
    'â€': '\u201d',
    'â€¦': '\u2026',
  };

  var normalized = text;
  replacements.forEach((broken, fixed) {
    normalized = normalized.replaceAll(broken, fixed);
  });
  return normalized;
}
