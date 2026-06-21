import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PremiumScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  const PremiumScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth >= 1100
            ? 980.0
            : constraints.maxWidth >= 820
            ? 880.0
            : double.infinity;
        final wrapped = maxWidth.isFinite
            ? Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              )
            : child;
        return useSafeArea ? SafeArea(child: wrapped) : wrapped;
      },
    );
    return Scaffold(
      extendBody: true,
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BizootColors.background,
                    BizootColors.backgroundSecondary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const Positioned(
            top: -120,
            right: -90,
            child: _GlowOrb(color: Color(0x307C4DFF), size: 300),
          ),
          const Positioned(
            top: 140,
            left: -90,
            child: _GlowOrb(color: Color(0x2F16B8FF), size: 250),
          ),
          const Positioned(
            bottom: -140,
            right: -20,
            child: _GlowOrb(color: Color(0x26FF4FD8), size: 260),
          ),
          const Positioned(
            bottom: 120,
            left: -80,
            child: _GlowOrb(color: Color(0x1EFF9A3D), size: 220),
          ),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
