import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/detected_subscription.dart';
import '../models/recurring_payment.dart';
import '../services/app_state.dart';
import '../services/gmail_scanner_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/brand_icon.dart';

class EmailScanScreen extends StatefulWidget {
  const EmailScanScreen({super.key});

  @override
  State<EmailScanScreen> createState() => _EmailScanScreenState();
}

class _EmailScanScreenState extends State<EmailScanScreen> {
  _Phase _phase = _Phase.idle;
  String _statusMessage = '';
  List<DetectedSubscription> _detected = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _phase = _Phase.scanning;
      _statusMessage = 'Connecting to Gmail…';
      _errorMessage = null;
    });

    try {
      final results = await GmailScannerService.instance.scanSubscriptions(
        onProgress: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (!mounted) return;
      setState(() {
        _detected = results;
        _phase = _Phase.review;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _importSelected() async {
    final appState = context.read<AppState>();
    final userId = appState.authService.currentUser?.id;
    if (userId == null) return;

    final toImport = _detected.where((d) => d.isSelected).toList();
    if (toImport.isEmpty) {
      showErrorSnackBar(context, 'Select at least one subscription to import.');
      return;
    }

    setState(() => _phase = _Phase.importing);

    int imported = 0;
    for (final d in toImport) {
      try {
        await appState.savePayment(d.toRecurringPayment(userId));
        imported++;
      } catch (_) {
        // continue with others
      }
    }

    if (!mounted) return;
    showSuccessSnackBar(
      context,
      '$imported subscription${imported == 1 ? '' : 's'} imported successfully.',
    );
    Navigator.of(context).pop(true); // signal refresh to caller
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BizootColors.background,
      appBar: AppBar(
        backgroundColor: BizootColors.background,
        foregroundColor: BizootColors.textPrimary,
        title: const Text(
          'Scan Email for Subscriptions',
          style: TextStyle(color: BizootColors.textPrimary, fontSize: 17),
        ),
        actions: _phase == _Phase.review && _detected.isNotEmpty
            ? [
                TextButton(
                  onPressed: _importSelected,
                  child: const Text(
                    'Import',
                    style: TextStyle(
                      color: BizootColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.idle:
      case _Phase.scanning:
        return _buildScanning();
      case _Phase.error:
        return _buildError();
      case _Phase.review:
        return _buildReview();
      case _Phase.importing:
        return _buildImporting();
    }
  }

  Widget _buildScanning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  BizootGradients.main.createShader(bounds),
              child: const Icon(Icons.email_outlined,
                  size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: BizootColors.primary),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: const TextStyle(
                  color: BizootColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'We only read email subjects and bodies\nto find subscription data. '
              'Nothing is stored\noutside this device.',
              style: TextStyle(
                  color: BizootColors.textMuted, fontSize: 12, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: BizootColors.danger),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Something went wrong.',
              style: const TextStyle(
                  color: BizootColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: BizootColors.primary,
                side: const BorderSide(color: BizootColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImporting() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: BizootColors.primary),
          SizedBox(height: 16),
          Text('Importing…',
              style: TextStyle(color: BizootColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildReview() {
    if (_detected.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined,
                  size: 56, color: BizootColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                'No subscriptions detected',
                style: TextStyle(
                    color: BizootColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We couldn\'t find any subscription-related emails in the past year.',
                style: TextStyle(
                    color: BizootColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BizootColors.primary,
                  side: const BorderSide(color: BizootColors.primary),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final selected = _detected.where((d) => d.isSelected).length;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: BizootColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${_detected.length} subscription${_detected.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: BizootColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Review and select which to import. '
                'You can edit details after importing.',
                style: const TextStyle(
                    color: BizootColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _detected.length,
            itemBuilder: (context, i) => _DetectedCard(
              item: _detected[i],
              onToggle: (val) => setState(() => _detected[i].isSelected = val),
            ),
          ),
        ),

        // Bottom bar
        SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: BizootColors.surface,
              border: Border(
                  top: BorderSide(color: BizootColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$selected selected',
                    style: const TextStyle(
                        color: BizootColors.textSecondary, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final allSelected = _detected.every((d) => d.isSelected);
                      for (final d in _detected) {
                        d.isSelected = !allSelected;
                      }
                    });
                  },
                  child: Text(
                    _detected.every((d) => d.isSelected)
                        ? 'Deselect All'
                        : 'Select All',
                    style: const TextStyle(color: BizootColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selected > 0 ? _importSelected : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BizootColors.primary,
                    foregroundColor: BizootColors.background,
                    disabledBackgroundColor: BizootColors.border,
                  ),
                  child: Text('Import $selected'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Detected Subscription Card ──────────────────────────────────────────────

class _DetectedCard extends StatelessWidget {
  final DetectedSubscription item;
  final ValueChanged<bool> onToggle;

  const _DetectedCard({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final hasAmount = item.amount != null && item.amount! > 0;
    final hasDate = item.nextDueDate != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: item.isSelected
            ? BizootColors.surfaceElevated
            : BizootColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isSelected ? BizootColors.primary : BizootColors.border,
          width: item.isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onToggle(!item.isSelected),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: item.isSelected,
                    onChanged: (v) => onToggle(v ?? false),
                    activeColor: BizootColors.primary,
                    side: const BorderSide(color: BizootColors.border),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              SizedBox(
                width: 40,
                height: 40,
                child: item.iconKey != null && item.iconKey!.isNotEmpty
                    ? BrandIcon(iconKey: item.iconKey!, size: 40)
                    : Container(
                        decoration: BoxDecoration(
                          color: BizootColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.subscriptions_outlined,
                            color: BizootColors.textMuted, size: 22),
                      ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: BizootColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (hasAmount) ...[
                          Text(
                            '${item.currency} ${item.amount!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: BizootColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(' · ',
                              style: TextStyle(
                                  color: BizootColors.textMuted,
                                  fontSize: 13)),
                        ],
                        Text(
                          _frequencyLabel(item.frequency),
                          style: const TextStyle(
                              color: BizootColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    if (hasDate) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Renews ${_formatDate(item.nextDueDate!)}',
                        style: const TextStyle(
                            color: BizootColors.textMuted, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      item.sourceEmailSubject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: BizootColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Confidence badge
              _ConfidenceBadge(confidence: item.confidence),
            ],
          ),
        ),
      ),
    );
  }

  String _frequencyLabel(PaymentFrequency f) {
    switch (f) {
      case PaymentFrequency.weekly:
        return 'Weekly';
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
      case PaymentFrequency.yearly:
        return 'Yearly';
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (confidence >= 0.8) {
      color = BizootColors.success;
      label = 'High';
    } else if (confidence >= 0.6) {
      color = BizootColors.yellow;
      label = 'Med';
    } else {
      color = BizootColors.orange;
      label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum _Phase { idle, scanning, review, importing, error }
