import 'package:flutter/material.dart';

import 'localized_text_sanitizer.dart';

String localeText(
  BuildContext context, {
  required String en,
  required String da,
  required String de,
  required String es,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'da':
      return sanitizeLocalizedText(da);
    case 'de':
      return sanitizeLocalizedText(de);
    case 'es':
      return sanitizeLocalizedText(es);
    default:
      return sanitizeLocalizedText(en);
  }
}
