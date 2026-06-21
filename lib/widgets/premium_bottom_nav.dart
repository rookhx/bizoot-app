import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_pressable.dart';

class PremiumNavItem {
  final IconData icon;
  final String label;

  const PremiumNavItem({required this.icon, required this.label});
}

class PremiumBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<PremiumNavItem> items;

  const PremiumBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTabletWidth = screenWidth >= 700;
    final isCompactWidth = screenWidth < 390;
    final maxNavWidth = isTabletWidth ? 760.0 : 560.0;
    final iconSize = isTabletWidth
        ? 22.0
        : isCompactWidth
        ? 18.0
        : 20.0;
    final labelFontSize = isTabletWidth
        ? 12.0
        : isCompactWidth
        ? 9.0
        : 10.5;
    final itemVerticalPadding = isTabletWidth
        ? 12.0
        : isCompactWidth
        ? 8.0
        : 10.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxNavWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: BizootGradients.glass,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: BizootColors.borderBright.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactWidth ? 2 : 6,
                  vertical: isCompactWidth ? 6 : 7,
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final selected = index == selectedIndex;
                    final item = items[index];
                    return Expanded(
                      child: AnimatedPressable(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(22),
                        child: AnimatedContainer(
                          duration: BizootDurations.medium,
                          curve: Curves.easeOut,
                          padding: EdgeInsets.symmetric(
                            vertical: itemVerticalPadding,
                            horizontal: isCompactWidth ? 1 : 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected ? BizootGradients.main : null,
                            color: selected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            border: selected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  )
                                : Border.all(color: Colors.transparent),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: BizootColors.primary.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: -10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                color: selected
                                    ? Colors.white
                                    : BizootColors.textSecondary,
                                size: iconSize,
                              ),
                              SizedBox(height: isCompactWidth ? 4 : 5),
                              SizedBox(
                                width: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: selected
                                              ? Colors.white
                                              : BizootColors.textSecondary,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          fontSize: labelFontSize,
                                          height: 1.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
