import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../models/user_document.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

class DocumentCard extends StatelessWidget {
  final UserDocument document;
  final String? linkedItemName;
  final VoidCallback? onOpen;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;
  final VoidCallback? onLink;
  final String? linkLabel;

  const DocumentCard({
    super.key,
    required this.document,
    this.linkedItemName,
    this.onOpen,
    this.onReplace,
    this.onDelete,
    this.onLink,
    this.linkLabel,
  });

  Color _accentForCategory() {
    switch (document.documentCategory) {
      case UserDocumentCategory.contract:
        return BizootColors.orange;
      case UserDocumentCategory.insurance:
        return const Color(0xFF4DA3FF);
      case UserDocumentCategory.property:
        return BizootColors.primary;
      case UserDocumentCategory.bill:
        return BizootColors.secondary;
      case UserDocumentCategory.loan:
        return const Color(0xFFFF7A59);
      case UserDocumentCategory.membership:
        return const Color(0xFF31D17C);
      case UserDocumentCategory.warranty:
        return const Color(0xFFFFD166);
      case UserDocumentCategory.other:
        return BizootColors.textMuted;
    }
  }

  IconData _iconForDocument() {
    if (document.isPdf) {
      return Icons.picture_as_pdf_outlined;
    }
    if (document.isImage) {
      return Icons.image_outlined;
    }
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForCategory();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      BizootColors.surfaceElevated.withValues(alpha: 0.96),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 20,
                      spreadRadius: -8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(_iconForDocument(), color: accent),
              ),
              const SizedBox(width: BizootSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      linkedItemName == null || linkedItemName!.trim().isEmpty
                          ? document.documentCategory.singularLabel
                          : '$linkedItemName • ${document.documentCategory.singularLabel}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BizootColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BizootSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: document.documentCategory.singularLabel,
                accent: accent,
              ),
              _MetaChip(label: document.fileExtension.toUpperCase()),
              _MetaChip(label: _formatFileSize(document.fileSize)),
              _MetaChip(label: formatShortDate(document.uploadedAt)),
            ],
          ),
          const SizedBox(height: BizootSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onOpen != null)
                _ActionChip(
                  label: localeText(
                    context,
                    en: 'Open',
                    da: 'Abn',
                    de: 'Öffnen',
                    es: 'Abrir',
                  ),
                  icon: Icons.open_in_new_rounded,
                  onTap: onOpen!,
                ),
              if (onReplace != null)
                _ActionChip(
                  label: localeText(
                    context,
                    en: 'Replace',
                    da: 'Erstat',
                    de: 'Ersetzen',
                    es: 'Reemplazar',
                  ),
                  icon: Icons.swap_horiz_rounded,
                  onTap: onReplace!,
                ),
              if (onLink != null)
                _ActionChip(
                  label: linkLabel ??
                      localeText(
                        context,
                        en: 'Link item',
                        da: 'Knyt element',
                        de: 'Element verknüpfen',
                        es: 'Vincular elemento',
                      ),
                  icon: Icons.link_rounded,
                  onTap: onLink!,
                ),
              if (onDelete != null)
                _ActionChip(
                  label: localeText(
                    context,
                    en: 'Delete',
                    da: 'Slet',
                    de: 'Löschen',
                    es: 'Eliminar',
                  ),
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  onTap: onDelete!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color? accent;

  const _MetaChip({required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (accent ?? BizootColors.surfaceElevated).withValues(
          alpha: accent == null ? 0.92 : 0.14,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (accent ?? BizootColors.border).withValues(
            alpha: accent == null ? 0.7 : 0.28,
          ),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent == null
              ? BizootColors.textSecondary
              : BizootColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = danger ? BizootColors.orange : BizootColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BizootColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
