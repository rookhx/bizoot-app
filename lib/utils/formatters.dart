import 'package:intl/intl.dart';

import 'supported_currencies.dart';

String formatCurrency(double amount, String currency) {
  final supported = findSupportedCurrency(currency);
  final locale = Intl.getCurrentLocale();
  final formatter = supported != null
      ? NumberFormat.currency(
          locale: locale,
          name: supported.code,
          symbol: supported.symbol,
          decimalDigits: 2,
        )
      : NumberFormat.simpleCurrency(locale: locale, name: currency);
  return _insertCurrencySpacing(formatter.format(amount));
}

String _insertCurrencySpacing(String value) {
  final leadingSymbol = RegExp(r'^(-?)([^\d\s-]+)(\d)');
  if (leadingSymbol.hasMatch(value)) {
    return value.replaceFirstMapped(leadingSymbol, (match) {
      final sign = match.group(1) ?? '';
      final symbol = match.group(2) ?? '';
      final digit = match.group(3) ?? '';
      return '$sign$symbol $digit';
    });
  }

  final trailingSymbol = RegExp(r'^(-?\d[\d,.\s]*)([^\d\s]+)$');
  if (trailingSymbol.hasMatch(value)) {
    return value.replaceFirstMapped(trailingSymbol, (match) {
      final amountPart = match.group(1) ?? '';
      final symbol = match.group(2) ?? '';
      return '$amountPart $symbol';
    });
  }

  return value;
}

String formatDate(DateTime date) {
  return DateFormat.yMMMd(Intl.getCurrentLocale()).format(date);
}

String formatShortDate(DateTime date) {
  return DateFormat.MMMEd(Intl.getCurrentLocale()).format(date);
}
