import 'package:flutter/material.dart';

import 'premium_scaffold.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: title,
      actions: actions,
      floatingActionButton: floatingActionButton,
      useSafeArea: useSafeArea,
      child: child,
    );
  }
}
