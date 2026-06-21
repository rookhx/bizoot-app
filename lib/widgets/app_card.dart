import 'package:flutter/material.dart';

import 'glass_gradient_card.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassGradientCard(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}
