import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/heyo_theme.dart';
import '../../../core/theme/mesh_background.dart';
import '../../chat/data/local/app_database.dart';
import '../domain/entity_models.dart';
import 'entity_detail_screen.dart';

class EntityDirectoryScreen extends StatefulWidget {
  const EntityDirectoryScreen({super.key});

  @override
  State<EntityDirectoryScreen> createState() => _EntityDirectoryScreenState();
}

class _EntityDirectoryScreenState extends State<EntityDirectoryScreen> {
  List<EntityListItem> _entities = const <EntityListItem>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AppDatabase appDatabase = context.read<AppDatabase>();
      final List<EntityListItem> entities = await appDatabase
          .fetchPromotedEntities();
      if (!mounted) {
        return;
      }
      setState(() {
        _entities = entities;
        _isLoading = false;
      });
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

  Future<void> _openEntityDetail(EntityListItem entity) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            EntityDetailScreen(entityId: entity.id),
      ),
    );
    await _loadEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Entities',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ),
                      )
                    : _entities.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Promoted entities will appear here after they are mentioned in at least two canon memories.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEntities,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _entities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final EntityListItem entity = _entities[index];
                            return _EntityRow(
                              entity: entity,
                              onTap: () => _openEntityDetail(entity),
                            );
                          },
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

class _EntityRow extends StatelessWidget {
  final EntityListItem entity;
  final VoidCallback onTap;

  const _EntityRow({required this.entity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
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
                    Expanded(
                      child: Text(
                        entity.name,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entity.summaryPreview,
                  style: TextStyle(
                    color: context.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _EntityMeta(label: '${entity.mentionCount} mentions'),
                    _EntityMeta(
                      label: entity.lastMentionedAt == null
                          ? 'Last mentioned unknown'
                          : 'Last mentioned ${DateFormat('d MMM y').format(entity.lastMentionedAt!)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntityMeta extends StatelessWidget {
  final String label;

  const _EntityMeta({required this.label});

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
