import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bizoot_branding.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_text.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  AppLocalizations _l10n(BuildContext context) {
    return AppLocalizations.of(context) ??
        AppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = _l10n(context);
    return AppScaffold(
      useSafeArea: false,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 0),
            const Center(child: BizootLogo(height: 208)),
            const SizedBox(height: 10),
            Text(
              _isSignUp ? l10n.authCreateAccount : l10n.authWelcomeBack,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              _isSignUp ? l10n.authCreateSubtitle : l10n.authWelcomeSubtitle,
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GradientText(
                    l10n.authHero,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                  ),
                  if (appState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      appState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: _isSignUp ? l10n.createAccount : l10n.logIn,
              icon: _isSignUp ? Icons.person_add_alt_1_outlined : Icons.login,
              isLoading: appState.isAuthLoading,
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.enterEmailPassword)),
                    );
                  return;
                }
                appState.signIn(email, password, signUp: _isSignUp);
              },
            ),
            TextButton(
              onPressed: appState.isAuthLoading
                  ? null
                  : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp ? l10n.alreadyHaveAccount : l10n.needAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
