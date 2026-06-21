import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NeonIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const NeonIconBox({
    super.key,
    required this.icon,
    this.size = 52,
    this.gradient = BizootGradients.main,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: [
          BoxShadow(
            color: BizootColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.15),
        decoration: BoxDecoration(
          gradient: BizootGradients.surfaceStrong,
          borderRadius: BorderRadius.circular(size * 0.31),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.42),
      ),
    );
  }
}
