class SupportedCurrency {
  final String code;
  final String symbol;
  final String label;

  const SupportedCurrency({
    required this.code,
    required this.symbol,
    required this.label,
  });
}

const supportedCurrencies = <SupportedCurrency>[
  SupportedCurrency(code: 'USD', symbol: r'$', label: 'US Dollar'),
  SupportedCurrency(code: 'GBP', symbol: '\u00A3', label: 'British Pound'),
  SupportedCurrency(code: 'EUR', symbol: '\u20AC', label: 'Euro'),
  SupportedCurrency(code: 'DKK', symbol: 'kr', label: 'Danish Krone'),
  SupportedCurrency(code: 'CAD', symbol: r'C$', label: 'Canadian Dollar'),
  SupportedCurrency(code: 'AUD', symbol: r'A$', label: 'Australian Dollar'),
  SupportedCurrency(code: 'NZD', symbol: r'NZ$', label: 'New Zealand Dollar'),
];

SupportedCurrency? findSupportedCurrency(String code) {
  final normalized = code.trim().toUpperCase();
  for (final currency in supportedCurrencies) {
    if (currency.code == normalized) {
      return currency;
    }
  }
  return null;
}

String formatSupportedCurrencyLabel(String code) {
  final currency = findSupportedCurrency(code);
  if (currency == null) {
    return code.trim().toUpperCase();
  }
  return '${currency.label} (${currency.symbol})';
}
