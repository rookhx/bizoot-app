import 'package:flutter/material.dart';

import 'gradient_text.dart';
import 'neon_icon_box.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String body;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NeonIconBox(icon: Icons.savings_outlined, size: 72),
            const SizedBox(height: 16),
            GradientText(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
