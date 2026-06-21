import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_gradient_card.dart';
import 'gradient_text.dart';
import 'neon_icon_box.dart';

class PremiumMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final bool emphasize;
  final Widget? trailing;

  const PremiumMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.hint,
    this.emphasize = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassGradientCard(
      padding: const EdgeInsets.all(BizootSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeonIconBox(icon: icon, size: 42),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: BizootSpacing.md),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.0,
                  color: BizootColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: BizootSpacing.sm),
          if (emphasize)
            GradientText(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          if (hint != null) ...[
            const SizedBox(height: BizootSpacing.xs),
            Text(
              hint!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BizootColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
