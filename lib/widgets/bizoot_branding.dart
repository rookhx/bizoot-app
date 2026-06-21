import 'package:flutter/material.dart';

class BizootBranding {
  static const logoAsset = 'assets/images/bizoot_logo.png';
  static const appIconAsset = 'assets/images/bizoot_app_icon.png';
}

class BizootLogo extends StatelessWidget {
  final double? width;
  final double height;

  const BizootLogo({
    super.key,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BizootBranding.logoAsset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class BizootAppIconImage extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;

  const BizootAppIconImage({
    super.key,
    this.size = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size * 0.28),
      child: Image.asset(
        BizootBranding.appIconAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
