import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_pressable.dart';

class GlowButton extends StatelessWidget {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final bool outlined;
  final IconData? icon;
  final bool isLoading;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? BizootColors.textPrimary : Colors.white;
    final radius = BorderRadius.circular(BizootRadii.button);

    final buttonChild = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            ),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: foreground,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedPressable(
      onTap: onPressed == null || isLoading ? null : () => onPressed!.call(),
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: outlined ? BizootGradients.surface : BizootGradients.main,
          borderRadius: radius,
          border: Border.all(
            color: outlined ? BizootColors.borderBright : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: (outlined ? BizootColors.secondary : BizootColors.primary).withValues(alpha: 0.18),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: Opacity(
            opacity: onPressed == null ? 0.68 : 1,
            child: Center(child: buttonChild),
          ),
        ),
      ),
    );
  }
}
