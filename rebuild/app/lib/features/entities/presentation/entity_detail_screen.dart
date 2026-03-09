import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/heyo_theme.dart';
import '../../../core/theme/mesh_background.dart';
import '../../chat/data/chat_api_client.dart';
import '../../chat/data/local/app_database.dart';
import '../domain/entity_models.dart';

class EntityDetailScreen extends StatefulWidget {
  final String entityId;

  const EntityDetailScreen({super.key, required this.entityId});

  @override
  State<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends State<EntityDetailScreen> {
  EntityDetailRecord? _entityDetail;
  bool _isLoading = true;
  bool _isRefreshingSummary = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEntityDetail();
  }

  Future<void> _loadEntityDetail() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AppDatabase appDatabase = context.read<AppDatabase>();
      final EntityDetailRecord? entityDetail = await appDatabase
          .fetchEntityDetail(widget.entityId);
      if (!mounted) {
        return;
      }

      setState(() {
        _entityDetail = entityDetail;
        _isLoading = false;
      });

      if (entityDetail != null &&
          entityDetail.linkedMemories.isNotEmpty &&
          entityDetail.isSummaryStale) {
        await _refreshSummary(entityDetail);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSummary(EntityDetailRecord entityDetail) async {
    if (!mounted || _isRefreshingSummary) {
      return;
    }

    setState(() {
      _isRefreshingSummary = true;
    });

    try {
      final ChatApiClient chatApiClient = context.read<ChatApiClient>();
      final AppDatabase appDatabase = context.read<AppDatabase>();
      final String summary = await chatApiClient.summarizeEntity(
        entityName: entityDetail.name,
        aliases: entityDetail.aliases,
        linkedMemories: entityDetail.linkedMemories,
      );

      if (summary.trim().isNotEmpty) {
        await appDatabase.updateEntitySummary(
          entityId: entityDetail.id,
          summary: summary,
        );
        final EntityDetailRecord? refreshedEntity = await appDatabase
            .fetchEntityDetail(entityDetail.id);
        if (!mounted) {
          return;
        }
        setState(() {
          _entityDetail = refreshedEntity;
        });
      }
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
          _isRefreshingSummary = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntityDetailRecord? entityDetail = _entityDetail;

    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _EntityAppBar(title: entityDetail?.name ?? 'Entity'),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : entityDetail == null
                    ? _ErrorState(
                        message:
                            _errorMessage ??
                            'This entity is no longer available.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEntityDetail,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            _SummaryCard(
                              summary: entityDetail.summary,
                              isRefreshing: _isRefreshingSummary,
                              isStale: entityDetail.isSummaryStale,
                            ),
                            const SizedBox(height: 12),
                            _StatGrid(entityDetail: entityDetail),
                            if (entityDetail.aliases.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _AliasCard(aliases: entityDetail.aliases),
                            ],
                            const SizedBox(height: 12),
                            _MemorySection(
                              linkedMemories: entityDetail.linkedMemories,
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

class _EntityAppBar extends StatelessWidget {
  final String title;

  const _EntityAppBar({required this.title});

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
          Expanded(
            child: Text(
              title,
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

class _SummaryCard extends StatelessWidget {
  final String? summary;
  final bool isRefreshing;
  final bool isStale;

  const _SummaryCard({
    required this.summary,
    required this.isRefreshing,
    required this.isStale,
  });

  @override
  Widget build(BuildContext context) {
    final String trimmedSummary = summary?.trim() ?? '';

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
                'Summary',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (isRefreshing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isStale)
                Text(
                  'Refreshing soon',
                  style: TextStyle(color: context.textTertiary, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trimmedSummary.isEmpty
                ? 'A grounded summary will appear here after this entity has enough canon memory.'
                : trimmedSummary,
            style: TextStyle(
              color: trimmedSummary.isEmpty
                  ? context.textSecondary
                  : context.textPrimary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final EntityDetailRecord entityDetail;

  const _StatGrid({required this.entityDetail});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatCard(
          title: 'Mentions',
          value: entityDetail.mentionCount.toString(),
        ),
        _StatCard(
          title: 'First',
          value: _formatDate(entityDetail.firstMentionedAt),
        ),
        _StatCard(
          title: 'Last',
          value: _formatDate(entityDetail.lastMentionedAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Unknown';
    }
    return DateFormat('d MMM y').format(value);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: context.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AliasCard extends StatelessWidget {
  final List<String> aliases;

  const _AliasCard({required this.aliases});

  @override
  Widget build(BuildContext context) {
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
            'Aliases',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: aliases
                .map(
                  (String alias) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: HeyoColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      alias,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  final List<EntityLinkedMemoryRecord> linkedMemories;

  const _MemorySection({required this.linkedMemories});

  @override
  Widget build(BuildContext context) {
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
            'Linked memories',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (linkedMemories.isEmpty)
            Text(
              'No canon memories are linked to this entity yet.',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            )
          else
            ...linkedMemories.map(
              (EntityLinkedMemoryRecord memory) => _MemoryCard(memory: memory),
            ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final EntityLinkedMemoryRecord memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('d MMM y, HH:mm').format(memory.createdAt),
            style: TextStyle(color: context.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            memory.content,
            style: TextStyle(color: context.textPrimary, height: 1.45),
          ),
          if (memory.tags.isNotEmpty || memory.entities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...memory.tags.map((String tag) => _InfoChip(label: tag)),
                  ...memory.entities.map(
                    (String entity) => _InfoChip(label: entity),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HeyoColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSecondary, height: 1.5),
        ),
      ),
    );
  }
}
