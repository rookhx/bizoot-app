import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_text.dart';
import '../models/user_document.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/document_card.dart';

class DocumentViewerScreen extends StatelessWidget {
  final UserDocument document;
  final String? linkedItemName;
  final String signedUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onReplace;

  const DocumentViewerScreen({
    super.key,
    required this.document,
    required this.signedUrl,
    this.linkedItemName,
    this.onDelete,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: localeText(
        context,
        en: 'Document',
        da: 'Dokument',
        de: 'Dokument',
        es: 'Documento',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          DocumentCard(document: document, linkedItemName: linkedItemName),
          const SizedBox(height: BizootSpacing.md),
          if (document.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  signedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: BizootColors.surfaceElevated,
                    alignment: Alignment.center,
                    child: Text(
                      localeText(
                        context,
                        en: 'Preview unavailable',
                        da: 'Forhåndsvisning er ikke tilgængelig',
                        de: 'Vorschau nicht verfügbar',
                        es: 'Vista previa no disponible',
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BizootColors.surfaceElevated.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: BizootColors.border.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    linkedItemName == null
                        ? localeText(
                            context,
                            en: 'Uploaded ${formatShortDate(document.uploadedAt)}',
                            da: 'Uploadet ${formatShortDate(document.uploadedAt)}',
                            de: 'Hochgeladen ${formatShortDate(document.uploadedAt)}',
                            es: 'Subido ${formatShortDate(document.uploadedAt)}',
                          )
                        : localeText(
                            context,
                            en: '$linkedItemName • Uploaded ${formatShortDate(document.uploadedAt)}',
                            da: '$linkedItemName • Uploadet ${formatShortDate(document.uploadedAt)}',
                            de: '$linkedItemName • Hochgeladen ${formatShortDate(document.uploadedAt)}',
                            es: '$linkedItemName • Subido ${formatShortDate(document.uploadedAt)}',
                          ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localeText(
                      context,
                      en: 'Open this file using your device viewer to review the full document.',
                      da: 'Åbn filen i enhedens fremviser for at se hele dokumentet.',
                      de: 'Öffne diese Datei mit dem Viewer deines Geräts, um das vollständige Dokument zu prüfen.',
                      es: 'Abre este archivo con el visor de tu dispositivo para revisar el documento completo.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BizootColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: BizootSpacing.lg),
          AppButton(
            label: localeText(
              context,
              en: 'Open externally',
              da: 'Åbn eksternt',
              de: 'Extern öffnen',
              es: 'Abrir externamente',
            ),
            icon: Icons.open_in_new_rounded,
            onPressed: () async {
              final uri = Uri.tryParse(signedUrl);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          if (onReplace != null) ...[
            const SizedBox(height: BizootSpacing.sm),
            AppButton(
              label: localeText(
                context,
                en: 'Replace document',
                da: 'Erstat dokument',
                de: 'Dokument ersetzen',
                es: 'Reemplazar documento',
              ),
              icon: Icons.swap_horiz_rounded,
              secondary: true,
              onPressed: onReplace,
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(height: BizootSpacing.sm),
            AppButton(
              label: localeText(
                context,
                en: 'Delete document',
                da: 'Slet dokument',
                de: 'Dokument löschen',
                es: 'Eliminar documento',
              ),
              icon: Icons.delete_outline_rounded,
              secondary: true,
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
