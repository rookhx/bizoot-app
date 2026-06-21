import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';
import 'gradient_card.dart';

class PremiumLockCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onPressed;
  final String? previewTitle;
  final String? previewBody;

  const PremiumLockCard({
    super.key,
    required this.title,
    required this.body,
    required this.onPressed,
    this.previewTitle,
    this.previewBody,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Stack(
        children: [
          if (previewTitle != null || previewBody != null)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          BizootColors.surface.withValues(alpha: 0.14),
                          BizootColors.surface.withValues(alpha: 0.34),
                          BizootColors.surface.withValues(alpha: 0.60),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Opacity(
                          opacity: 0.22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                previewTitle ?? title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                previewBody ?? body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: BizootColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.985, end: 1),
            duration: BizootDurations.medium,
            curve: Curves.easeOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: BizootColors.textPrimary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(body),
                const SizedBox(height: 16),
                AppButton(
                  label: localeText(
                    context,
                    en: 'Unlock premium',
                    da: 'Lås op for Premium',
                    de: 'Premium freischalten',
                    es: 'Desbloquear Premium',
                  ),
                  onPressed: onPressed,
                  icon: Icons.workspace_premium_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
