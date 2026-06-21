import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/brand_icon_service.dart';
import '../theme/app_theme.dart';

const double _brandIconFillFactor = 0.88;
const double _brandIconInnerPaddingFactor = 0.06;

class BrandServiceIcon extends StatelessWidget {
  final String? serviceId;
  final String? serviceName;
  final String? category;
  final String? iconKey;
  final double size;

  const BrandServiceIcon({
    super.key,
    this.serviceId,
    this.serviceName,
    this.category,
    this.iconKey,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final match = BrandIconService.instance.resolve(
      serviceId: serviceId,
      serviceName: serviceName,
      iconKey: iconKey,
    );
    final radius = math.max(14.0, math.min(18.0, size * 0.32));
    final borderColor = (match.brandColor ?? BizootColors.borderBright).withValues(alpha: 0.34);
    final glowColor = (match.brandColor ?? BizootColors.primary).withValues(alpha: 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BizootColors.surfaceElevated.withValues(alpha: 0.98),
            BizootColors.surface.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: size * 0.34,
            spreadRadius: -size * 0.12,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: size * 0.22,
            spreadRadius: -size * 0.16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * _brandIconInnerPaddingFactor),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: match.hasAsset ? 0.02 : 0.0),
              borderRadius: BorderRadius.circular(radius - 2),
            ),
            child: match.hasAsset
                ? _AssetIcon(
                    candidates: match.assetCandidates,
                    logoSize: size * _brandIconFillFactor,
                    fallback: _FallbackBrandFace(
                      initials: match.initials,
                      category: category,
                      size: size,
                      accent: match.brandColor,
                    ),
                  )
                : _FallbackBrandFace(
                    initials: match.initials,
                    category: category,
                    size: size,
                    accent: match.brandColor,
                  ),
          ),
        ),
      ),
    );
  }
}

class _AssetIcon extends StatefulWidget {
  final List<String> candidates;
  final Widget fallback;
  final double logoSize;

  const _AssetIcon({
    required this.candidates,
    required this.fallback,
    required this.logoSize,
  });

  @override
  State<_AssetIcon> createState() => _AssetIconState();
}

class _AssetIconState extends State<_AssetIcon> {
  int _candidateIndex = 0;
  Future<bool>? _assetExistsFuture;

  @override
  void initState() {
    super.initState();
    _primeAssetCheck();
  }

  @override
  void didUpdateWidget(covariant _AssetIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidates != widget.candidates) {
      _candidateIndex = 0;
      _primeAssetCheck();
    }
  }

  void _primeAssetCheck() {
    if (_candidateIndex >= widget.candidates.length) {
      _assetExistsFuture = null;
      return;
    }
    final asset = widget.candidates[_candidateIndex];
    _assetExistsFuture = rootBundle.load(asset).then((_) => true).catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_candidateIndex >= widget.candidates.length) {
      return widget.fallback;
    }

    final asset = widget.candidates[_candidateIndex];
    return FutureBuilder<bool>(
      future: _assetExistsFuture,
      builder: (context, snapshot) {
        final exists = snapshot.data ?? false;
        if (!exists) {
          if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _candidateIndex += 1;
                _primeAssetCheck();
              });
            });
          }
          return const SizedBox.shrink();
        }

        if (asset.toLowerCase().endsWith('.svg')) {
          return Center(
            child: SvgPicture.asset(
              asset,
              width: widget.logoSize,
              height: widget.logoSize,
              fit: BoxFit.contain,
            ),
          );
        }

        return Center(
          child: Image.asset(
            asset,
            width: widget.logoSize,
            height: widget.logoSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      },
    );
  }
}

class _FallbackBrandFace extends StatelessWidget {
  final String initials;
  final String? category;
  final double size;
  final Color? accent;

  const _FallbackBrandFace({
    required this.initials,
    required this.category,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _fallbackIcon(category ?? '');
    final showInitials = initials != '?' && initials.trim().isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (accent ?? BizootColors.primary).withValues(alpha: 0.18),
            BizootColors.secondary.withValues(alpha: 0.2),
            BizootColors.surfaceElevated.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: _brandIconFillFactor,
          heightFactor: _brandIconFillFactor,
          child: FittedBox(
            fit: BoxFit.contain,
            child: showInitials
                ? Text(
                    initials,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: BizootColors.textPrimary,
                          fontSize: size * 0.40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                  )
                : Icon(
                    icon,
                    size: size * _brandIconFillFactor,
                    color: BizootColors.textPrimary.withValues(alpha: 0.96),
                  ),
          ),
        ),
      ),
    );
  }

  IconData _fallbackIcon(String rawCategory) {
    final normalized = rawCategory.toLowerCase();
    if (normalized.contains('stream')) return Icons.play_circle_outline_rounded;
    if (normalized.contains('music')) return Icons.music_note_outlined;
    if (normalized.contains('ai')) return Icons.smart_toy_outlined;
    if (normalized.contains('product')) return Icons.work_outline_rounded;
    if (normalized.contains('cloud')) return Icons.cloud_outlined;
    if (normalized.contains('fitness')) return Icons.fitness_center_outlined;
    if (normalized.contains('education')) return Icons.school_outlined;
    if (normalized.contains('gaming')) return Icons.sports_esports_outlined;
    if (normalized.contains('vpn')) return Icons.shield_outlined;
    if (normalized.contains('shop')) return Icons.shopping_bag_outlined;
    if (normalized.contains('finance')) return Icons.account_balance_wallet_outlined;
    if (normalized.contains('news')) return Icons.newspaper_outlined;
    if (normalized.contains('developer')) return Icons.code_rounded;
    if (normalized.contains('utilit') || normalized.contains('bill')) return Icons.bolt_outlined;
    if (normalized.contains('rent') || normalized.contains('home')) return Icons.home_outlined;
    return Icons.credit_card_rounded;
  }
}
