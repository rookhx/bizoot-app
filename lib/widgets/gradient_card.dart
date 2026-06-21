import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final double radius;

  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.gradient = BizootGradients.main,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: radius,
      padding: EdgeInsets.zero,
      borderColor: BizootColors.borderBright,
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius - 4),
          boxShadow: [
            BoxShadow(
              color: BizootColors.primary.withValues(alpha: 0.20),
              blurRadius: 34,
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 4),
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xF0141136),
                    Color(0xED120F31),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(radius - 5),
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
