import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_text.dart';
import '../models/recurring_payment.dart';
import '../models/user_document.dart';
import '../screens/document_viewer_screen.dart';
import '../screens/payment_detail_screen.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import 'app_card.dart';
import 'document_card.dart';
import 'empty_state.dart';

class DocumentVaultPanel extends StatefulWidget {
  const DocumentVaultPanel({super.key});

  @override
  State<DocumentVaultPanel> createState() => _DocumentVaultPanelState();
}

class _DocumentVaultPanelState extends State<DocumentVaultPanel> {
  final TextEditingController _searchController = TextEditingController();
  UserDocumentCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final query = _searchController.text.trim().toLowerCase();
    final allDocuments = appState.documents;
    final filtered = allDocuments
        .where((document) {
          final inCategory =
              _selectedCategory == null ||
              document.documentCategory == _selectedCategory;
          final inSearch =
              query.isEmpty ||
              document.title.toLowerCase().contains(query) ||
              document.originalFileName.toLowerCase().contains(query) ||
              _linkedItemName(
                    appState.payments,
                    document,
                  )?.toLowerCase().contains(query) ==
                  true;
          return inCategory && inSearch;
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
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
                      gradient: BizootGradients.main,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: BizootColors.primary.withValues(alpha: 0.2),
                          blurRadius: 22,
                          spreadRadius: -10,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: BizootSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localeText(
                            context,
                            en: 'Document Vault',
                            da: 'Dokumenthvelv',
                            de: 'Dokumentenablage',
                            es: 'Bóveda de documentos',
                          ),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localeText(
                            context,
                            en: 'Keep contracts, policies, bills, and agreements close to the recurring items they support.',
                            da: 'Hold kontrakter, policer, regninger og aftaler tæt på de tilbagevendende poster, de understøtter.',
                            de: 'Halte Verträge, Policen, Rechnungen und Vereinbarungen in der Nähe der wiederkehrenden Einträge, die sie betreffen.',
                            es: 'Mantén contratos, pólizas, facturas y acuerdos cerca de los elementos recurrentes a los que respaldan.',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: BizootColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BizootSpacing.md),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: _VaultStatChip(
                      label: localeText(
                        context,
                        en: 'Documents',
                        da: 'Dokumenter',
                        de: 'Dokumente',
                        es: 'Documentos',
                      ),
                      value: '${allDocuments.length}',
                      emphasized: true,
                    ),
                  ),
                ),
              ),
              if (!appState.hasPremiumFeatureAccess) ...[
                const SizedBox(height: BizootSpacing.sm),
                Text(
                  localeText(
                    context,
                    en: 'Document storage: ${allDocuments.length} / ${appState.documentLimit} used',
                    da: 'Dokumentlager: ${allDocuments.length} / ${appState.documentLimit} brugt',
                    de: 'Dokumentspeicher: ${allDocuments.length} / ${appState.documentLimit} genutzt',
                    es: 'Almacenamiento de documentos: ${allDocuments.length} / ${appState.documentLimit} usado',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BizootColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: localeText(
              context,
              en: 'Search documents...',
              da: 'Søg dokumenter...',
              de: 'Dokumente suchen...',
              es: 'Buscar documentos...',
            ),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: _selectedCategory == null,
                label: Text(
                  localeText(
                    context,
                    en: 'All',
                    da: 'Alle',
                    de: 'Alle',
                    es: 'Todos',
                  ),
                ),
                onSelected: (_) => setState(() => _selectedCategory = null),
              ),
              const SizedBox(width: 8),
              ...UserDocumentCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == category,
                    label: Text(category.displayLabel),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BizootSpacing.md),
        if (filtered.isEmpty)
          EmptyState(
            title: localeText(
              context,
              en: 'No documents yet.',
              da: 'Ingen dokumenter endnu.',
              de: 'Noch keine Dokumente.',
              es: 'Aún no hay documentos.',
            ),
            body: localeText(
              context,
              en: 'Attach contracts, policies, bills, or agreements to keep everything organized.',
              da: 'Vedhæft kontrakter, policer, regninger eller aftaler for at holde alt organiseret.',
              de: 'Füge Verträge, Policen, Rechnungen oder Vereinbarungen hinzu, um alles organisiert zu halten.',
              es: 'Adjunta contratos, pólizas, facturas o acuerdos para mantenerlo todo organizado.',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: BizootSpacing.sm),
            itemBuilder: (context, index) {
              final document = filtered[index];
              RecurringPayment? linkedPayment;
              for (final payment in appState.payments) {
                if (payment.id == document.linkedItemId) {
                  linkedPayment = payment;
                  break;
                }
              }
              return DocumentCard(
                document: document,
                linkedItemName: linkedPayment?.name,
                onOpen: () =>
                    _openDocument(context, appState, document, linkedPayment),
                onLink: () => linkedPayment == null
                    ? _promptLinkItem(context, appState, document)
                    : _openPaymentDetail(context, linkedPayment),
                linkLabel: linkedPayment == null
                    ? localeText(
                        context,
                        en: 'Link item',
                        da: 'Tilknyt post',
                        de: 'Eintrag verknüpfen',
                        es: 'Vincular elemento',
                      )
                    : localeText(
                        context,
                        en: 'View item',
                        da: 'Se post',
                        de: 'Eintrag ansehen',
                        es: 'Ver elemento',
                      ),
                onDelete: () => _deleteDocument(context, appState, document),
              );
            },
          ),
      ],
    );
  }

  String? _linkedItemName(
    List<RecurringPayment> payments,
    UserDocument document,
  ) {
    for (final payment in payments) {
      if (payment.id == document.linkedItemId) {
        return payment.name;
      }
    }
    return null;
  }

  Future<void> _openDocument(
    BuildContext context,
    AppState appState,
    UserDocument document,
    RecurringPayment? linkedPayment,
  ) async {
    try {
      final signedUrl = await appState.getSignedDocumentUrl(document);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentViewerScreen(
            document: document,
            signedUrl: signedUrl,
            linkedItemName: linkedPayment?.name,
            onDelete: () async {
              Navigator.of(context).pop();
              await _deleteDocument(context, appState, document);
            },
            onReplace: () async {
              Navigator.of(context).pop();
              await _replaceDocument(context, appState, document);
            },
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not open that document right now.',
          da: 'Vi kunne ikke åbne dokumentet lige nu.',
          de: 'Das Dokument konnte gerade nicht geöffnet werden.',
          es: 'No pudimos abrir ese documento ahora mismo.',
        ),
      );
    }
  }

  Future<void> _replaceDocument(
    BuildContext context,
    AppState appState,
    UserDocument document,
  ) async {
    try {
      await appState.replaceDocument(document);
      if (!context.mounted) return;
      showSuccessSnackBar(
        context,
        localeText(
          context,
          en: 'Document replaced successfully.',
          da: 'Dokument erstattet.',
          de: 'Dokument erfolgreich ersetzt.',
          es: 'Documento reemplazado correctamente.',
        ),
      );
    } on StateError catch (error) {
      if (!context.mounted || error.message == 'document_pick_cancelled') {
        return;
      }
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not replace that document right now.',
          da: 'Vi kunne ikke erstatte dokumentet lige nu.',
          de: 'Das Dokument konnte gerade nicht ersetzt werden.',
          es: 'No pudimos reemplazar ese documento ahora mismo.',
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      showErrorSnackBar(
        context,
        localeText(
          context,
          en: 'We could not replace that document right now.',
          da: 'Vi kunne ikke erstatte dokumentet lige nu.',
          de: 'Das Dokument konnte gerade nicht ersetzt werden.',
          es: 'No pudimos reemplazar ese documento ahora mismo.',
        ),
      );
    }
  }

  Future<void> _deleteDocument(
    BuildContext context,
    AppState appState,
    UserDocument document,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              localeText(
                context,
                en: 'Delete document?',
                da: 'Slet dokument?',
                de: 'Dokument löschen?',
                es: '¿Eliminar documento?',
              ),
            ),
            content: Text(
              localeText(
                context,
                en: 'This will remove the document from your Bizoot vault.',
                da: 'Dette fjerner dokumentet fra dit Bizoot-hvelv.',
                de: 'Dadurch wird das Dokument aus deiner Bizoot-Ablage entfernt.',
                es: 'Esto eliminará el documento de tu bóveda de Bizoot.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localeText(
                    context,
                    en: 'Keep',
                    da: 'Behold',
                    de: 'Behalten',
                    es: 'Conservar',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localeText(
                    context,
                    en: 'Delete',
                    da: 'Slet',
                    de: 'Löschen',
                    es: 'Eliminar',
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await appState.deleteDocument(document);
    if (!context.mounted) return;
    showSuccessSnackBar(
      context,
      localeText(
        context,
        en: 'Document deleted successfully.',
        da: 'Dokument slettet.',
        de: 'Dokument erfolgreich gelöscht.',
        es: 'Documento eliminado correctamente.',
      ),
    );
  }

  void _openPaymentDetail(BuildContext context, RecurringPayment payment) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentDetailScreen(payment: payment)),
    );
  }

  Future<void> _promptLinkItem(
    BuildContext context,
    AppState appState,
    UserDocument document,
  ) async {
    final selected = await showModalBottomSheet<RecurringPayment>(
      context: context,
      backgroundColor: BizootColors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              localeText(
                context,
                en: 'Link document',
                da: 'Tilknyt dokument',
                de: 'Dokument verknüpfen',
                es: 'Vincular documento',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              localeText(
                context,
                en: 'Choose the recurring item this document belongs to.',
                da: 'Vælg den tilbagevendende post, dokumentet hører til.',
                de: 'Wähle den wiederkehrenden Eintrag, zu dem dieses Dokument gehört.',
                es: 'Elige el elemento recurrente al que pertenece este documento.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BizootColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...appState.payments.map(
              (payment) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(payment.name),
                subtitle: Text(payment.category.displayLabel),
                onTap: () => Navigator.of(context).pop(payment),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await appState.linkDocumentToPayment(document, selected);
    if (!context.mounted) return;
    showSuccessSnackBar(
      context,
      localeText(
        context,
        en: 'Document linked to ${selected.name}.',
        da: 'Dokument tilknyttet ${selected.name}.',
        de: 'Dokument mit ${selected.name} verknüpft.',
        es: 'Documento vinculado a ${selected.name}.',
      ),
    );
  }
}

class _VaultStatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _VaultStatChip({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: emphasized ? 16 : 14,
          vertical: emphasized ? 18 : 14,
        ),
        decoration: BoxDecoration(
          gradient: emphasized ? BizootGradients.surfaceStrong : null,
          color: emphasized
              ? null
              : BizootColors.surfaceElevated.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(emphasized ? 22 : 18),
          border: Border.all(
            color: emphasized
                ? BizootColors.primary.withValues(alpha: 0.28)
                : BizootColors.border.withValues(alpha: 0.75),
          ),
          boxShadow: emphasized
              ? [
                  BoxShadow(
                    color: BizootColors.primary.withValues(alpha: 0.16),
                    blurRadius: 22,
                    spreadRadius: -10,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: emphasized
                    ? BizootColors.textPrimary
                    : BizootColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: emphasized ? 24 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
