import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/export/local_data_export_service.dart';
import '../../../core/theme/heyo_theme.dart';
import '../../../core/theme/mesh_background.dart';
import '../../../core/widgets/heyo_logo_badge.dart';
import '../data/chat_api_client.dart';
import '../domain/chat_models.dart';

class QuotaAndExportScreen extends StatefulWidget {
  const QuotaAndExportScreen({super.key});

  @override
  State<QuotaAndExportScreen> createState() => _QuotaAndExportScreenState();
}

class _QuotaAndExportScreenState extends State<QuotaAndExportScreen> {
  QuotaSnapshot? _quotaSnapshot;
  LocalExportPreview? _exportPreview;
  String? _savedFilePath;
  String? _errorMessage;
  bool _isLoadingQuota = true;
  bool _isGeneratingPreview = false;
  bool _isSavingPreview = false;

  @override
  void initState() {
    super.initState();
    _refreshQuota();
  }

  Future<void> _refreshQuota() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingQuota = true;
      _errorMessage = null;
    });

    try {
      final ChatApiClient chatApiClient = context.read<ChatApiClient>();
      final QuotaSnapshot quotaSnapshot = await chatApiClient.fetchQuota();
      if (!mounted) {
        return;
      }
      setState(() {
        _quotaSnapshot = quotaSnapshot;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuota = false;
        });
      }
    }
  }

  Future<void> _generatePreview() async {
    if (!mounted || _isGeneratingPreview) {
      return;
    }

    setState(() {
      _isGeneratingPreview = true;
      _savedFilePath = null;
      _errorMessage = null;
    });

    try {
      final LocalDataExportService exportService =
          context.read<LocalDataExportService>();
      final LocalExportPreview exportPreview = await exportService.buildPreview();
      if (!mounted) {
        return;
      }
      setState(() {
        _exportPreview = exportPreview;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
      }
    }
  }

  Future<void> _savePreview() async {
    final LocalExportPreview? exportPreview = _exportPreview;
    if (!mounted || exportPreview == null || _isSavingPreview) {
      return;
    }

    setState(() {
      _isSavingPreview = true;
      _errorMessage = null;
    });

    try {
      final LocalDataExportService exportService =
          context.read<LocalDataExportService>();
      final String savedFilePath = await exportService.savePreview(exportPreview);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedFilePath = savedFilePath;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPreview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuotaSnapshot? quotaSnapshot = _quotaSnapshot;
    final LocalExportPreview? exportPreview = _exportPreview;

    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _QuotaAndExportAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshQuota,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _QuotaCard(
                        quotaSnapshot: quotaSnapshot,
                        isLoading: _isLoadingQuota,
                        onRefresh: _refreshQuota,
                      ),
                      const SizedBox(height: 12),
                      _ExportCard(
                        exportPreview: exportPreview,
                        savedFilePath: _savedFilePath,
                        isGeneratingPreview: _isGeneratingPreview,
                        isSavingPreview: _isSavingPreview,
                        onGeneratePreview: _generatePreview,
                        onSavePreview: _savePreview,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: HeyoColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaAndExportAppBar extends StatelessWidget {
  const _QuotaAndExportAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const HeyoLogoBadge(size: 34, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Quota & Export',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  final QuotaSnapshot? quotaSnapshot;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _QuotaCard({
    required this.quotaSnapshot,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final QuotaSnapshot? quotaSnapshot = this.quotaSnapshot;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daily quota',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (quotaSnapshot == null) ...[
            Text(
              isLoading
                  ? 'Loading current usage...'
                  : 'Quota information is not available yet.',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
          ] else ...[
            Text(
              '${quotaSnapshot.remainingTotal} remaining of ${quotaSnapshot.dailyLimit}',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Used ${quotaSnapshot.totalUsed} requests on ${quotaSnapshot.quotaDay}.',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuotaChip(
                  label: 'Prepare',
                  value: quotaSnapshot.prepareCount,
                ),
                _QuotaChip(
                  label: 'Respond',
                  value: quotaSnapshot.respondCount,
                ),
                _QuotaChip(
                  label: 'Entity summary',
                  value: quotaSnapshot.entitySummaryCount,
                ),
                _QuotaChip(
                  label: 'Attachment inspect',
                  value: quotaSnapshot.attachmentInspectCount,
                ),
              ],
            ),
            if (quotaSnapshot.updatedAt != null) ...[
              const SizedBox(height: 10),
              Text(
                'Last updated ${DateFormat('y-MM-dd HH:mm').format(quotaSnapshot.updatedAt!)}',
                style: TextStyle(color: context.textTertiary, fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _QuotaChip extends StatelessWidget {
  final String label;
  final int value;

  const _QuotaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: context.textPrimary, fontSize: 13),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final LocalExportPreview? exportPreview;
  final String? savedFilePath;
  final bool isGeneratingPreview;
  final bool isSavingPreview;
  final VoidCallback onGeneratePreview;
  final VoidCallback onSavePreview;

  const _ExportCard({
    required this.exportPreview,
    required this.savedFilePath,
    required this.isGeneratingPreview,
    required this.isSavingPreview,
    required this.onGeneratePreview,
    required this.onSavePreview,
  });

  @override
  Widget build(BuildContext context) {
    final LocalExportPreview? exportPreview = this.exportPreview;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local export',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Preview the full local JSON first, then save it to this device.',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: isGeneratingPreview ? null : onGeneratePreview,
                child: isGeneratingPreview
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate preview'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed:
                    exportPreview == null || isSavingPreview ? null : onSavePreview,
                child: isSavingPreview
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save JSON'),
              ),
            ],
          ),
          if (exportPreview != null) ...[
            const SizedBox(height: 14),
            Text(
              'Client ${exportPreview.payload['client_id']} • Exported ${DateFormat('y-MM-dd HH:mm').format(exportPreview.exportedAt)}',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exportPreview.tableCounts.entries.map((
                MapEntry<String, int> entry,
              ) {
                return _QuotaChip(label: entry.key, value: entry.value);
              }).toList(growable: false),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  exportPreview.prettyJson,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
          if (savedFilePath != null) ...[
            const SizedBox(height: 12),
            Text(
              'Saved to: $savedFilePath',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
