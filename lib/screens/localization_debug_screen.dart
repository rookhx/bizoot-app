import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';

class LocalizationDebugScreen extends StatelessWidget {
  const LocalizationDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        AppLocalizations(Localizations.maybeLocaleOf(context) ?? const Locale('en'));
    final appState = context.watch<AppState>();
    final supported = AppLocale.supportedLocales
        .map((locale) => locale.languageCode)
        .join(', ');

    return AppScaffold(
      title: l10n.debugLocalization,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.debugLocalization,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _DebugRow(
                  label: l10n.currentLocale,
                  value: appState.currentLocale.languageCode,
                ),
                const SizedBox(height: 12),
                _DebugRow(label: l10n.supportedLocalesLabel, value: supported),
                const SizedBox(height: 12),
                _DebugRow(
                  label: l10n.fallbackBehavior,
                  value: l10n.fallbackBehaviorValue,
                ),
                const SizedBox(height: 12),
                _DebugRow(
                  label: l10n.missingTranslationFallbackCount,
                  value: '0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;

  const _DebugRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
