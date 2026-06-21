import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

class GlassGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final double radius;
  final bool glow;
  final Color? borderColor;

  const GlassGradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BizootSpacing.lg),
    this.gradient,
    this.radius = BizootRadii.card,
    this.glow = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      radius: radius,
      gradient: gradient ?? BizootGradients.surface,
      borderColor: borderColor ?? BizootColors.border,
      glow: glow,
      child: child,
    );
  }
}
