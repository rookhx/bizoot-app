import 'dart:async';

import 'package:flutter/material.dart';

import 'glow_button.dart';

class AppButton extends StatelessWidget {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final bool secondary;
  final IconData? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.secondary = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlowButton(
      label: label,
      onPressed: onPressed,
      outlined: secondary,
      icon: icon,
      isLoading: isLoading,
    );
  }
}
