import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? borderColor;
  final bool glow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BizootSpacing.lg),
    this.radius = BizootRadii.card,
    this.gradient,
    this.borderColor,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? BizootGradients.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? BizootColors.border.withValues(alpha: 0.9),
              width: 1,
            ),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: BizootColors.secondary.withValues(alpha: 0.16),
                      blurRadius: 30,
                      spreadRadius: -10,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 34,
                      spreadRadius: -16,
                      offset: const Offset(0, 20),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
