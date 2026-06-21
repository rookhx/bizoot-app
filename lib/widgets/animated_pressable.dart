import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';

class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool enableHaptics;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.enableHaptics = true,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(BizootRadii.card);
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _setPressed(false);
              if (widget.enableHaptics) {
                AppHaptics.tap();
              }
              widget.onTap?.call();
            },
      child: AnimatedScale(
        duration: BizootDurations.press,
        scale: _pressed ? 0.97 : 1,
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: radius,
          child: widget.child,
        ),
      ),
    );
  }
}
