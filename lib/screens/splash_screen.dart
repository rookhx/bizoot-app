import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bizoot_branding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: false,
      child: Center(
        child: AnimatedOpacity(
          duration: BizootDurations.medium,
          opacity: _visible ? 1 : 0,
          child: AnimatedSlide(
            duration: BizootDurations.medium,
            curve: Curves.easeOut,
            offset: _visible ? Offset.zero : const Offset(0, 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BizootLogo(height: 84),
                const SizedBox(height: 18),
                Text(
                  'Control every recurring charge before it controls your month.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BizootColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
