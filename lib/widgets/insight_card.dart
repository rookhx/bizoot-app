import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_pressable.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  const InsightCard({
    super.key,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF161235),
            Color(0xFF1B1642),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BizootRadii.card),
        border: Border.all(color: BizootColors.border.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: BizootColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: -18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0x3316B8FF),
                  Color(0x337C4DFF),
                ],
              ),
              border: Border.all(color: BizootColors.borderBright.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.insights_outlined, color: BizootColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BizootColors.textSecondary,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 16),
                AnimatedPressable(
                  onTap: onPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: BizootGradients.main,
                    ),
                    child: Text(
                      buttonLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
