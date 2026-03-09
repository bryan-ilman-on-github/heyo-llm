import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/common.dart';
import 'package:uuid/uuid.dart';

import '../../../entities/domain/entity_models.dart';
import '../../domain/chat_models.dart';

part 'app_database.g.dart';

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get pairedMessageId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MessageRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get revisionContent => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get sourceMessageId => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class EmbeddingVectors extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text()();
  TextColumn get modelName => text()();
  BlobColumn get vectorBlob => blob()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isCanon => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MemoryTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memoryId => text()();
  TextColumn get tag => text()();
}

class Entities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get summary => text().nullable()();
  IntColumn get mentionCount => integer().withDefault(const Constant(1))();
  IntColumn get summaryMemoryCount =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isPromoted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get firstMentionedAt => dateTime().nullable()();
  DateTimeColumn get lastMentionedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class EntityAliases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityId => text()();
  TextColumn get alias => text()();
}

class EntityLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memoryId => text()();
  TextColumn get entityId => text()();
  RealColumn get relevance => real().withDefault(const Constant(1.0))();
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()();
  TextColumn get kind => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get byteSize => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get failureReason => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get rawText => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get summaryMemoryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MessagePairs extends Table {
  TextColumn get userMessageId => text()();
  TextColumn get assistantMessageId => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{userMessageId};
}

class LocalExportSnapshot {
  final List<Map<String, Object?>> messages;
  final List<Map<String, Object?>> messageRevisions;
  final List<Map<String, Object?>> memories;
  final List<Map<String, Object?>> embeddingVectors;
  final List<Map<String, Object?>> memoryTags;
  final List<Map<String, Object?>> entities;
  final List<Map<String, Object?>> entityAliases;
  final List<Map<String, Object?>> entityLinks;
  final List<Map<String, Object?>> attachments;
  final List<Map<String, Object?>> messagePairs;

  const LocalExportSnapshot({
    required this.messages,
    required this.messageRevisions,
    required this.memories,
    required this.embeddingVectors,
    required this.memoryTags,
    required this.entities,
    required this.entityAliases,
    required this.entityLinks,
    required this.attachments,
    required this.messagePairs,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'messages': messages,
      'message_revisions': messageRevisions,
      'memories': memories,
      'embedding_vectors': embeddingVectors,
      'memory_tags': memoryTags,
      'entities': entities,
      'entity_aliases': entityAliases,
      'entity_links': entityLinks,
      'attachments': attachments,
      'message_pairs': messagePairs,
    };
  }
}

@DriftDatabase(
  tables: <Type>[
    Messages,
    MessageRevisions,
    Memories,
    EmbeddingVectors,
    MemoryTags,
    Entities,
    EntityAliases,
    EntityLinks,
    Attachments,
    MessagePairs,
  ],
)
class AppDatabase extends _$AppDatabase {
  final Uuid _uuid;

  AppDatabase._(super.executor, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  factory AppDatabase.open(String encryptionKey) {
    return AppDatabase._(_openConnection(encryptionKey));
  }

  factory AppDatabase.inMemory({Uuid? uuid}) {
    return AppDatabase._(NativeDatabase.memory(), uuid: uuid);
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS memory_fts USING fts5(memory_id UNINDEXED, content)',
      );
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.addColumn(entities, entities.summaryMemoryCount);
        await migrator.addColumn(entities, entities.firstMentionedAt);
        await migrator.addColumn(entities, entities.lastMentionedAt);
        await customStatement('''
              UPDATE entities
              SET summary_memory_count = CASE
                WHEN summary IS NULL OR TRIM(summary) = '' THEN 0
                ELSE mention_count
              END
              WHERE summary_memory_count IS NULL
              ''');
        await customStatement('''
              UPDATE entities
              SET first_mentioned_at = created_at
              WHERE first_mentioned_at IS NULL
              ''');
        await customStatement('''
              UPDATE entities
              SET last_mentioned_at = updated_at
              WHERE last_mentioned_at IS NULL
              ''');
      }
      if (from < 3) {
        await migrator.addColumn(attachments, attachments.displayName);
        await migrator.addColumn(attachments, attachments.mimeType);
        await migrator.addColumn(attachments, attachments.byteSize);
        await migrator.addColumn(attachments, attachments.status);
        await migrator.addColumn(attachments, attachments.failureReason);
        await migrator.addColumn(attachments, attachments.summaryMemoryId);
        await customStatement('''
              UPDATE attachments
              SET status = CASE
                WHEN summary IS NULL OR TRIM(summary) = '' THEN 'pending'
                ELSE 'ready'
              END
              WHERE status IS NULL OR TRIM(status) = ''
              ''');
      }
    },
  );

  Future<List<ChatMessageRecord>> fetchVisibleMessages({
    required int limit,
  }) async {
    final List<Message> rows =
        await (select(messages)
              ..where((row) => row.isDeleted.equals(false))
              ..orderBy(<OrderingTerm Function($MessagesTable)>[
                ($MessagesTable row) => OrderingTerm.desc(row.createdAt),
              ])
              ..limit(limit))
            .get();

    final List<ChatMessageRecord> results = <ChatMessageRecord>[];
    for (final Message row in rows.reversed) {
      results.add(_mapMessage(row, await fetchAttachmentsForMessage(row.id)));
    }
    return results;
  }

  Future<LocalExportSnapshot> exportSnapshot() async {
    final List<Message> messageRows = await select(messages).get();
    final List<MessageRevision> revisionRows = await select(
      messageRevisions,
    ).get();
    final List<Memory> memoryRows = await select(memories).get();
    final List<EmbeddingVector> vectorRows = await select(
      embeddingVectors,
    ).get();
    final List<MemoryTag> tagRows = await select(memoryTags).get();
    final List<Entity> entityRows = await select(entities).get();
    final List<EntityAliase> aliasRows = await select(entityAliases).get();
    final List<EntityLink> linkRows = await select(entityLinks).get();
    final List<Attachment> attachmentRows = await select(attachments).get();
    final List<MessagePair> pairRows = await select(messagePairs).get();

    return LocalExportSnapshot(
      messages: messageRows
          .map(
            (Message row) => <String, Object?>{
              'id': row.id,
              'role': row.role,
              'content': row.content,
              'created_at': row.createdAt.toIso8601String(),
              'updated_at': row.updatedAt?.toIso8601String(),
              'is_edited': row.isEdited,
              'is_deleted': row.isDeleted,
              'paired_message_id': row.pairedMessageId,
            },
          )
          .toList(growable: false),
      messageRevisions: revisionRows
          .map(
            (MessageRevision row) => <String, Object?>{
              'id': row.id,
              'message_id': row.messageId,
              'revision_content': row.revisionContent,
              'created_at': row.createdAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      memories: memoryRows
          .map(
            (Memory row) => <String, Object?>{
              'id': row.id,
              'source_message_id': row.sourceMessageId,
              'content': row.content,
              'created_at': row.createdAt.toIso8601String(),
              'is_deleted': row.isDeleted,
            },
          )
          .toList(growable: false),
      embeddingVectors: vectorRows
          .map(
            (EmbeddingVector row) => <String, Object?>{
              'id': row.id,
              'memory_id': row.memoryId,
              'model_name': row.modelName,
              'vector': _decodeEmbedding(row.vectorBlob),
              'dimensions': row.vectorBlob.lengthInBytes ~/ 4,
              'created_at': row.createdAt.toIso8601String(),
              'is_canon': row.isCanon,
            },
          )
          .toList(growable: false),
      memoryTags: tagRows
          .map(
            (MemoryTag row) => <String, Object?>{
              'id': row.id,
              'memory_id': row.memoryId,
              'tag': row.tag,
            },
          )
          .toList(growable: false),
      entities: entityRows
          .map(
            (Entity row) => <String, Object?>{
              'id': row.id,
              'name': row.name,
              'summary': row.summary,
              'mention_count': row.mentionCount,
              'summary_memory_count': row.summaryMemoryCount,
              'is_promoted': row.isPromoted,
              'created_at': row.createdAt.toIso8601String(),
              'updated_at': row.updatedAt.toIso8601String(),
              'first_mentioned_at': row.firstMentionedAt?.toIso8601String(),
              'last_mentioned_at': row.lastMentionedAt?.toIso8601String(),
            },
          )
          .toList(growable: false),
      entityAliases: aliasRows
          .map(
            (EntityAliase row) => <String, Object?>{
              'id': row.id,
              'entity_id': row.entityId,
              'alias': row.alias,
            },
          )
          .toList(growable: false),
      entityLinks: linkRows
          .map(
            (EntityLink row) => <String, Object?>{
              'id': row.id,
              'memory_id': row.memoryId,
              'entity_id': row.entityId,
              'relevance': row.relevance,
            },
          )
          .toList(growable: false),
      attachments: attachmentRows
          .map(
            (Attachment row) => <String, Object?>{
              'id': row.id,
              'message_id': row.messageId,
              'kind': row.kind,
              'display_name': row.displayName,
              'mime_type': row.mimeType,
              'byte_size': row.byteSize,
              'status': row.status,
              'failure_reason': row.failureReason,
              'local_path': row.localPath,
              'raw_text': row.rawText,
              'summary': row.summary,
              'summary_memory_id': row.summaryMemoryId,
              'created_at': row.createdAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      messagePairs: pairRows
          .map(
            (MessagePair row) => <String, Object?>{
              'user_message_id': row.userMessageId,
              'assistant_message_id': row.assistantMessageId,
            },
          )
          .toList(growable: false),
    );
  }

  Future<ChatMessageRecord> insertMessage({
    required ChatMessageRole role,
    required String content,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final String messageId = _uuid.v4();

    await into(messages).insert(
      MessagesCompanion.insert(
        id: messageId,
        role: role.name,
        content: content,
        createdAt: now,
      ),
    );

    return ChatMessageRecord(
      id: messageId,
      role: role,
      content: content,
      createdAt: now.toLocal(),
      isEdited: false,
      isDeleted: false,
      pairedMessageId: null,
      attachments: const <ChatAttachmentRecord>[],
    );
  }

  Future<List<ChatAttachmentRecord>> fetchAttachmentsForMessage(
    String messageId,
  ) async {
    final List<Attachment> rows =
        await (select(attachments)
              ..where((Attachments row) => row.messageId.equals(messageId))
              ..orderBy(<OrderingTerm Function($AttachmentsTable)>[
                ($AttachmentsTable row) => OrderingTerm.asc(row.createdAt),
              ]))
            .get();
    return rows
        .map((Attachment row) => _mapAttachment(row))
        .toList(growable: false);
  }

  Future<void> insertPendingAttachments({
    required String messageId,
    required List<PendingAttachmentDraft> pendingAttachments,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    for (final PendingAttachmentDraft attachment in pendingAttachments) {
      await into(attachments).insert(
        AttachmentsCompanion.insert(
          id: attachment.id,
          messageId: messageId,
          kind: attachment.kind.name,
          displayName: Value<String>(attachment.displayName),
          mimeType: Value<String>(attachment.mimeType),
          byteSize: Value<int>(attachment.byteSize),
          status: const Value<String>('pending'),
          localPath: Value<String>(attachment.localPath),
          createdAt: now,
        ),
      );
    }
  }

  Future<void> markAttachmentReady({
    required String attachmentId,
    required String? rawText,
    required String summary,
    required String summaryMemoryId,
  }) async {
    await (update(
      attachments,
    )..where((Attachments row) => row.id.equals(attachmentId))).write(
      AttachmentsCompanion(
        status: const Value<String>('ready'),
        rawText: Value<String?>(rawText),
        summary: Value<String>(summary),
        summaryMemoryId: Value<String>(summaryMemoryId),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> markAttachmentFailed({
    required String attachmentId,
    required String failureReason,
  }) async {
    await (update(
      attachments,
    )..where((Attachments row) => row.id.equals(attachmentId))).write(
      AttachmentsCompanion(
        status: const Value<String>('failed'),
        failureReason: Value<String>(failureReason),
      ),
    );
  }

  Future<void> updateAssistantDraft({
    required String messageId,
    required String content,
  }) async {
    await (update(messages)..where((row) => row.id.equals(messageId))).write(
      MessagesCompanion(
        content: Value<String>(content),
        updatedAt: Value<DateTime>(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> pairMessages({
    required String userMessageId,
    required String assistantMessageId,
  }) async {
    await into(messagePairs).insertOnConflictUpdate(
      MessagePairsCompanion.insert(
        userMessageId: userMessageId,
        assistantMessageId: assistantMessageId,
      ),
    );

    await (update(
      messages,
    )..where((row) => row.id.equals(userMessageId))).write(
      MessagesCompanion(pairedMessageId: Value<String>(assistantMessageId)),
    );

    await (update(
      messages,
    )..where((row) => row.id.equals(assistantMessageId))).write(
      MessagesCompanion(pairedMessageId: Value<String>(userMessageId)),
    );
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    final Message? currentMessage = await (select(
      messages,
    )..where((row) => row.id.equals(messageId))).getSingleOrNull();
    if (currentMessage == null) {
      return;
    }

    await into(messageRevisions).insert(
      MessageRevisionsCompanion.insert(
        messageId: messageId,
        revisionContent: currentMessage.content,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    await (update(messages)..where((row) => row.id.equals(messageId))).write(
      MessagesCompanion(
        content: Value<String>(newContent),
        updatedAt: Value<DateTime>(DateTime.now().toUtc()),
        isEdited: const Value<bool>(true),
      ),
    );
  }

  Future<void> softDeleteMessage(String messageId) async {
    await (update(messages)..where((row) => row.id.equals(messageId))).write(
      MessagesCompanion(isDeleted: const Value<bool>(true)),
    );
    await deactivateMemoriesForMessage(messageId);
  }

  Future<void> deactivateMemoriesForMessage(String sourceMessageId) async {
    final List<Memory> activeMemories =
        await (select(memories)..where(
              (Memories row) =>
                  row.sourceMessageId.equals(sourceMessageId) &
                  row.isDeleted.equals(false),
            ))
            .get();
    if (activeMemories.isEmpty) {
      return;
    }

    final List<String> memoryIds = activeMemories
        .map((Memory memory) => memory.id)
        .toList(growable: false);
    final Set<String> affectedEntityIds = await _readEntityIdsForMemoryIds(
      memoryIds,
    );

    await (update(memories)..where(
          (Memories row) =>
              row.sourceMessageId.equals(sourceMessageId) &
              row.isDeleted.equals(false),
        ))
        .write(MemoriesCompanion(isDeleted: const Value<bool>(true)));

    await (update(embeddingVectors)
          ..where((EmbeddingVectors row) => row.memoryId.isIn(memoryIds)))
        .write(EmbeddingVectorsCompanion(isCanon: const Value<bool>(false)));

    if (affectedEntityIds.isNotEmpty) {
      await _refreshEntityProjectionForIds(
        affectedEntityIds,
        invalidateSummary: true,
      );
    }
  }

  Future<void> replaceMemoryPlansForMessage({
    required String sourceMessageId,
    required List<MemoryWritePlan> memoryWritePlans,
  }) async {
    await deactivateMemoriesForMessage(sourceMessageId);
    for (final MemoryWritePlan memoryWritePlan in memoryWritePlans) {
      await insertMemoryPlan(
        sourceMessageId: sourceMessageId,
        memoryWritePlan: memoryWritePlan,
      );
    }
  }

  Future<String> insertMemoryPlan({
    required String sourceMessageId,
    required MemoryWritePlan memoryWritePlan,
  }) async {
    final String memoryId = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    final Set<String> linkedEntityIds = <String>{};

    await into(memories).insert(
      MemoriesCompanion.insert(
        id: memoryId,
        sourceMessageId: sourceMessageId,
        content: memoryWritePlan.content,
        createdAt: now,
      ),
    );

    await customStatement(
      'INSERT INTO memory_fts(memory_id, content) VALUES (?, ?)',
      <Object>[memoryId, memoryWritePlan.content],
    );

    for (final String tag in memoryWritePlan.tags) {
      await into(
        memoryTags,
      ).insert(MemoryTagsCompanion.insert(memoryId: memoryId, tag: tag));
    }

    for (final String entityName in memoryWritePlan.entities) {
      final Entity entity = await _resolveOrCreateEntity(entityName, now);
      if (linkedEntityIds.contains(entity.id)) {
        continue;
      }
      linkedEntityIds.add(entity.id);
      await into(entityLinks).insert(
        EntityLinksCompanion.insert(memoryId: memoryId, entityId: entity.id),
      );
    }

    if (memoryWritePlan.embedding != null &&
        memoryWritePlan.embedding!.isNotEmpty) {
      await into(embeddingVectors).insert(
        EmbeddingVectorsCompanion.insert(
          id: _uuid.v4(),
          memoryId: memoryId,
          modelName: 'EmbeddingGemma-300M',
          vectorBlob: _encodeEmbedding(memoryWritePlan.embedding!),
          createdAt: now,
        ),
      );
    }

    if (linkedEntityIds.isNotEmpty) {
      await _refreshEntityProjectionForIds(linkedEntityIds);
    }
    return memoryId;
  }

  Future<List<RetrievedMemory>> retrieveMemories({
    required PrepareDecision prepareDecision,
    int limit = 8,
    bool includeDeleted = false,
  }) async {
    final List<RetrievedMemory> canonMatches = await _retrieveMemoriesOnce(
      prepareDecision: prepareDecision,
      limit: limit,
      includeDeleted: includeDeleted,
    );
    if (canonMatches.isNotEmpty ||
        includeDeleted ||
        !prepareDecision.retrievalPlan.allowDeletedFallback) {
      return canonMatches;
    }

    return _retrieveMemoriesOnce(
      prepareDecision: prepareDecision,
      limit: limit,
      includeDeleted: true,
    );
  }

  Future<List<RetrievedMemory>> _retrieveMemoriesOnce({
    required PrepareDecision prepareDecision,
    required int limit,
    required bool includeDeleted,
  }) async {
    final String strategy = prepareDecision.retrievalPlan.strategy;
    if (strategy.isEmpty || strategy == 'none') {
      return <RetrievedMemory>[];
    }
    final String intentType = _intentTypeFor(prepareDecision);

    final Set<String>? candidateIds = await _prefilterCandidateIds(
      prepareDecision: prepareDecision,
      includeDeleted: includeDeleted,
    );
    final bool canSearchAttachments =
        strategy == 'keyword_only' || strategy == 'keyword_vector_hybrid';
    if (candidateIds != null && candidateIds.isEmpty && !canSearchAttachments) {
      return <RetrievedMemory>[];
    }

    final List<_MemoryCandidate> candidates =
        candidateIds != null && candidateIds.isEmpty
        ? <_MemoryCandidate>[]
        : await _loadMemoryCandidates(
            includeDeleted: includeDeleted,
            memoryIds: candidateIds,
          );

    final List<_RankedMemoryCandidate> rankedCandidates =
        <_RankedMemoryCandidate>[];
    if (candidates.isNotEmpty) {
      final DateTime newestTimestamp = candidates
          .map(((_MemoryCandidate candidate) => candidate.createdAt))
          .reduce(
            (DateTime first, DateTime second) =>
                first.isAfter(second) ? first : second,
          );

      for (final _MemoryCandidate candidate in candidates) {
        final _CandidateScore candidateScore = _scoreCandidate(
          candidate: candidate,
          prepareDecision: prepareDecision,
          newestTimestamp: newestTimestamp,
        );
        if (!_passesRetrievalThresholds(
          strategy: strategy,
          candidateScore: candidateScore,
          prepareDecision: prepareDecision,
        )) {
          continue;
        }

        rankedCandidates.add(
          _RankedMemoryCandidate(
            candidate: candidate,
            score: candidateScore.score,
          ),
        );
      }
    }

    final List<_RankedMemoryCandidate> deduplicatedCandidates =
        _requiresSemanticDeduplication(intentType)
        ? _deduplicateRankedCandidates(rankedCandidates)
        : rankedCandidates;

    deduplicatedCandidates.sort((
      _RankedMemoryCandidate first,
      _RankedMemoryCandidate second,
    ) {
      if (intentType == 'exact_mention_lookup' ||
          intentType == 'thematic_reflection') {
        return first.candidate.createdAt.compareTo(second.candidate.createdAt);
      }
      return second.score.compareTo(first.score);
    });

    final int resultLimit = _resultLimitForIntentType(
      intentType: intentType,
      requestedLimit: limit,
    );

    final List<RetrievedMemory> memoryResults = deduplicatedCandidates
        .take(resultLimit)
        .map(((_RankedMemoryCandidate ranked) {
          return RetrievedMemory(
            id: ranked.candidate.id,
            content: ranked.candidate.content,
            tags: ranked.candidate.tags,
            entities: ranked.candidate.entities,
            score: ranked.score,
            createdAt: ranked.candidate.createdAt.toLocal(),
          );
        }))
        .toList(growable: false);
    final List<RetrievedMemory> attachmentResults =
        await _retrieveAttachmentMatches(
          prepareDecision: prepareDecision,
          includeDeleted: includeDeleted,
        );

    final List<RetrievedMemory> combinedResults = <RetrievedMemory>[
      ...memoryResults,
      ...attachmentResults,
    ];
    combinedResults.sort((RetrievedMemory first, RetrievedMemory second) {
      if (intentType == 'exact_mention_lookup' ||
          intentType == 'thematic_reflection') {
        return first.createdAt.compareTo(second.createdAt);
      }
      return second.score.compareTo(first.score);
    });

    return _deduplicateRetrievedResults(
      combinedResults,
    ).take(resultLimit).toList(growable: false);
  }

  Future<Set<String>?> _prefilterCandidateIds({
    required PrepareDecision prepareDecision,
    required bool includeDeleted,
  }) async {
    final String intentType = _intentTypeFor(prepareDecision);
    final List<String> keywordTerms = _keywordTermsFor(prepareDecision);
    final List<String> entityFilters = _entityFiltersFor(prepareDecision);
    final List<String> tagFilters = _tagFiltersFor(prepareDecision);
    final List<String> timeFilters = _timeFiltersFor(prepareDecision);
    final String strategy = prepareDecision.retrievalPlan.strategy;

    switch (intentType) {
      case 'emotional_recall':
        return _searchMemoryIdsByTags(
          tagFilters: tagFilters,
          includeDeleted: includeDeleted,
        );
      case 'entity_specific_recall':
        final Set<String> entityCandidateIds = await _searchMemoryIdsByEntities(
          entityFilters: entityFilters,
          includeDeleted: includeDeleted,
        );
        if (entityCandidateIds.isNotEmpty) {
          return entityCandidateIds;
        }
        if (entityFilters.isNotEmpty) {
          return <String>{};
        }
        if (keywordTerms.isNotEmpty) {
          return _searchMemoryIdsByKeywords(
            keywordTerms: keywordTerms,
            includeDeleted: includeDeleted,
          );
        }
        return null;
      case 'exact_mention_lookup':
        return _searchMemoryIdsByKeywords(
          keywordTerms: keywordTerms,
          includeDeleted: includeDeleted,
        );
      case 'quoted_text_lookup':
        final Set<String> keywordCandidateIds =
            await _searchMemoryIdsByKeywords(
              keywordTerms: keywordTerms,
              includeDeleted: includeDeleted,
            );
        if (timeFilters.isEmpty) {
          return keywordCandidateIds;
        }
        final Set<String> timeCandidateIds =
            await _searchMemoryIdsByTimeFilters(
              timeFilters: timeFilters,
              includeDeleted: includeDeleted,
            );
        return keywordCandidateIds.intersection(timeCandidateIds);
      case 'thematic_reflection':
        final Set<String> timeCandidateIds =
            await _searchMemoryIdsByTimeFilters(
              timeFilters: timeFilters,
              includeDeleted: includeDeleted,
            );
        final Set<String> tagCandidateIds = await _searchMemoryIdsByTags(
          tagFilters: tagFilters,
          includeDeleted: includeDeleted,
        );
        if (timeCandidateIds.isNotEmpty) {
          return timeCandidateIds;
        }
        if (tagCandidateIds.isNotEmpty) {
          return tagCandidateIds;
        }
        return null;
      case 'open_reflective_query':
        if (entityFilters.isNotEmpty) {
          final Set<String> entityCandidateIds =
              await _searchMemoryIdsByEntities(
                entityFilters: entityFilters,
                includeDeleted: includeDeleted,
              );
          if (entityCandidateIds.isNotEmpty) {
            return entityCandidateIds;
          }
        }
        return null;
      default:
        switch (strategy) {
          case 'keyword_only':
            return _searchMemoryIdsByKeywords(
              keywordTerms: keywordTerms,
              includeDeleted: includeDeleted,
            );
          case 'entity_keyword_hybrid':
            return _searchMemoryIdsByEntities(
              entityFilters: entityFilters,
              includeDeleted: includeDeleted,
            );
          case 'tag_vector':
            return _searchMemoryIdsByTags(
              tagFilters: tagFilters,
              includeDeleted: includeDeleted,
            );
          case 'time_vector':
            return _searchMemoryIdsByTimeFilters(
              timeFilters: timeFilters,
              includeDeleted: includeDeleted,
            );
          default:
            return null;
        }
    }
  }

  _CandidateScore _scoreCandidate({
    required _MemoryCandidate candidate,
    required PrepareDecision prepareDecision,
    required DateTime newestTimestamp,
  }) {
    final List<String> keywordTerms = _keywordTermsFor(prepareDecision);
    final List<String> entityFilters = _entityFiltersFor(prepareDecision);
    final List<String> tagFilters = _tagFiltersFor(prepareDecision);
    final List<String> timeFilters = _timeFiltersFor(prepareDecision);
    final String lowerContent = candidate.content.toLowerCase();
    final Set<String> normalizedCandidateEntities = candidate.entities
        .map(_normalizeEntityReference)
        .toSet();
    final Set<String> normalizedEntityFilters = entityFilters
        .map(_normalizeEntityReference)
        .where((String value) => value.isNotEmpty)
        .toSet();

    int literalMatches = 0;
    for (final String term in keywordTerms) {
      if (_memoryContainsTerm(lowerContent, term)) {
        literalMatches += 1;
      }
    }

    int entityMatches = 0;
    for (final String entityFilter in normalizedEntityFilters) {
      if (normalizedCandidateEntities.contains(entityFilter)) {
        entityMatches += 1;
      }
    }

    int tagMatches = 0;
    for (final String tagFilter in tagFilters) {
      if (candidate.tags.any(
        (String candidateTag) =>
            candidateTag.toLowerCase() == tagFilter.toLowerCase(),
      )) {
        tagMatches += 1;
      }
    }

    int timeMatches = 0;
    for (final String timeFilter in timeFilters) {
      if (_memoryMatchesTimeFilter(candidate, timeFilter)) {
        timeMatches += 1;
      }
    }

    double vectorScore = 0.0;
    if (prepareDecision.queryEmbedding != null && candidate.embedding != null) {
      vectorScore = _cosineSimilarity(
        prepareDecision.queryEmbedding!,
        candidate.embedding!,
      );
    }

    final Duration age = newestTimestamp.difference(candidate.createdAt);
    final double recencyBonus = max(0, 14 - age.inDays).toDouble() * 0.08;
    final double weightedScore = _weightedScoreForStrategy(
      strategy: prepareDecision.retrievalPlan.strategy,
      literalMatches: literalMatches,
      entityMatches: entityMatches,
      tagMatches: tagMatches,
      timeMatches: timeMatches,
      vectorScore: vectorScore,
      recencyBonus: recencyBonus,
    );

    return _CandidateScore(
      score: weightedScore,
      literalMatches: literalMatches,
      entityMatches: entityMatches,
      tagMatches: tagMatches,
      timeMatches: timeMatches,
      vectorScore: vectorScore,
    );
  }

  double _weightedScoreForStrategy({
    required String strategy,
    required int literalMatches,
    required int entityMatches,
    required int tagMatches,
    required int timeMatches,
    required double vectorScore,
    required double recencyBonus,
  }) {
    switch (strategy) {
      case 'keyword_only':
        return (literalMatches * 3.2) + recencyBonus;
      case 'keyword_vector_hybrid':
        return (literalMatches * 2.6) +
            (timeMatches * 1.4) +
            (vectorScore * 2.0) +
            recencyBonus;
      case 'entity_keyword_hybrid':
        return (entityMatches * 2.4) +
            (literalMatches * 1.2) +
            (vectorScore * 1.8) +
            recencyBonus;
      case 'tag_vector':
        return (tagMatches * 2.8) + (vectorScore * 2.2) + recencyBonus;
      case 'time_vector':
        return (timeMatches * 2.6) +
            (tagMatches * 1.2) +
            (vectorScore * 2.0) +
            recencyBonus;
      case 'vector_only':
      default:
        return (vectorScore * 3.0) +
            (entityMatches * 0.8) +
            (tagMatches * 0.6) +
            recencyBonus;
    }
  }

  bool _passesRetrievalThresholds({
    required String strategy,
    required _CandidateScore candidateScore,
    required PrepareDecision prepareDecision,
  }) {
    final bool hasKeywordTerms = _keywordTermsFor(prepareDecision).isNotEmpty;
    final bool hasEntityFilters = _entityFiltersFor(prepareDecision).isNotEmpty;
    final bool hasTagFilters = _tagFiltersFor(prepareDecision).isNotEmpty;
    final bool hasTimeFilters = _timeFiltersFor(prepareDecision).isNotEmpty;

    switch (strategy) {
      case 'keyword_only':
        return candidateScore.literalMatches > 0;
      case 'keyword_vector_hybrid':
        if (hasKeywordTerms) {
          return candidateScore.literalMatches > 0;
        }
        return candidateScore.vectorScore >= 0.2;
      case 'entity_keyword_hybrid':
        if (hasEntityFilters) {
          return candidateScore.entityMatches > 0;
        }
        return candidateScore.literalMatches > 0 ||
            candidateScore.vectorScore >= 0.2;
      case 'tag_vector':
        if (hasTagFilters && candidateScore.tagMatches == 0) {
          return false;
        }
        return candidateScore.tagMatches > 0 ||
            candidateScore.vectorScore >= 0.2;
      case 'time_vector':
        if (hasTimeFilters && candidateScore.timeMatches == 0) {
          return false;
        }
        if (hasTagFilters && candidateScore.tagMatches == 0) {
          return candidateScore.vectorScore >= 0.18;
        }
        return candidateScore.timeMatches > 0 ||
            candidateScore.vectorScore >= 0.2;
      case 'vector_only':
      default:
        return candidateScore.vectorScore >= 0.18 ||
            candidateScore.entityMatches > 0 ||
            candidateScore.tagMatches > 0 ||
            candidateScore.literalMatches > 0;
    }
  }

  List<String> _keywordTermsFor(PrepareDecision prepareDecision) {
    final List<String> keywordTerms =
        prepareDecision.retrievalPlan.keywordTerms;
    if (keywordTerms.isNotEmpty) {
      return keywordTerms;
    }
    return prepareDecision.literalTerms;
  }

  List<String> _entityFiltersFor(PrepareDecision prepareDecision) {
    final List<String> entityFilters =
        prepareDecision.retrievalPlan.entityFilters;
    if (entityFilters.isNotEmpty) {
      return entityFilters;
    }
    return prepareDecision.entities;
  }

  List<String> _tagFiltersFor(PrepareDecision prepareDecision) {
    final List<String> tagFilters = prepareDecision.retrievalPlan.tagFilters;
    if (tagFilters.isNotEmpty) {
      return tagFilters;
    }
    return prepareDecision.tags;
  }

  List<String> _timeFiltersFor(PrepareDecision prepareDecision) {
    final List<String> timeFilters = prepareDecision.retrievalPlan.timeFilters;
    if (timeFilters.isNotEmpty) {
      return timeFilters;
    }
    return prepareDecision.timeFilters;
  }

  String _intentTypeFor(PrepareDecision prepareDecision) {
    return prepareDecision.retrievalPlan.intentType;
  }

  bool _requiresSemanticDeduplication(String intentType) {
    return intentType == 'emotional_recall' ||
        intentType == 'thematic_reflection';
  }

  int _resultLimitForIntentType({
    required String intentType,
    required int requestedLimit,
  }) {
    if (intentType == 'quoted_text_lookup') {
      return min(requestedLimit, 1);
    }
    if (intentType == 'exact_mention_lookup') {
      return min(requestedLimit, 6);
    }
    return requestedLimit;
  }

  List<_RankedMemoryCandidate> _deduplicateRankedCandidates(
    List<_RankedMemoryCandidate> rankedCandidates,
  ) {
    final List<_RankedMemoryCandidate> orderedCandidates =
        List<_RankedMemoryCandidate>.from(rankedCandidates)..sort(
          (_RankedMemoryCandidate first, _RankedMemoryCandidate second) =>
              second.score.compareTo(first.score),
        );
    final List<_RankedMemoryCandidate> uniqueCandidates =
        <_RankedMemoryCandidate>[];
    for (final _RankedMemoryCandidate candidate in orderedCandidates) {
      final bool hasNearDuplicate = uniqueCandidates.any(
        (_RankedMemoryCandidate existingCandidate) => _isNearDuplicateCandidate(
          candidate.candidate,
          existingCandidate.candidate,
        ),
      );
      if (hasNearDuplicate) {
        continue;
      }
      uniqueCandidates.add(candidate);
    }
    return uniqueCandidates;
  }

  bool _isNearDuplicateCandidate(
    _MemoryCandidate firstCandidate,
    _MemoryCandidate secondCandidate,
  ) {
    final String normalizedFirst = _normalizeContentForDedup(
      firstCandidate.content,
    );
    final String normalizedSecond = _normalizeContentForDedup(
      secondCandidate.content,
    );
    if (normalizedFirst == normalizedSecond) {
      return true;
    }

    if (firstCandidate.embedding == null || secondCandidate.embedding == null) {
      return false;
    }
    final double semanticSimilarity = _cosineSimilarity(
      firstCandidate.embedding!,
      secondCandidate.embedding!,
    );
    if (semanticSimilarity < 0.995) {
      return false;
    }

    final Set<String> firstTokens = _dedupTokenSet(normalizedFirst);
    final Set<String> secondTokens = _dedupTokenSet(normalizedSecond);
    if (firstTokens.isEmpty || secondTokens.isEmpty) {
      return false;
    }

    final int sharedTokenCount = firstTokens.intersection(secondTokens).length;
    final int maxTokenCount = max(firstTokens.length, secondTokens.length);
    final double overlapRatio = sharedTokenCount / maxTokenCount;
    return overlapRatio >= 0.8;
  }

  String _normalizeContentForDedup(String content) {
    return content
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _dedupTokenSet(String normalizedContent) {
    return normalizedContent
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toSet();
  }

  Future<Set<String>> _searchMemoryIdsByKeywords({
    required List<String> keywordTerms,
    required bool includeDeleted,
  }) async {
    if (keywordTerms.isEmpty) {
      return <String>{};
    }

    final Set<String> candidateIds = <String>{};
    final List<String> ftsTerms = keywordTerms
        .map(_normalizeKeywordTerm)
        .where(_isFtsFriendlyTerm)
        .toList(growable: false);
    if (ftsTerms.isNotEmpty) {
      final String matchQuery = ftsTerms.map(_buildFtsQueryTerm).join(' OR ');
      final List<QueryRow> rows = await customSelect(
        includeDeleted
            ? '''
              SELECT DISTINCT memories.id
              FROM memory_fts
              INNER JOIN memories ON memories.id = memory_fts.memory_id
              INNER JOIN messages ON messages.id = memories.source_message_id
              WHERE memory_fts MATCH ?
              '''
            : '''
              SELECT DISTINCT memories.id
              FROM memory_fts
              INNER JOIN memories ON memories.id = memory_fts.memory_id
              INNER JOIN messages ON messages.id = memories.source_message_id
              WHERE memory_fts MATCH ?
                AND memories.is_deleted = 0
                AND messages.is_deleted = 0
              ''',
        variables: <Variable<Object>>[Variable<String>(matchQuery)],
        readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
          memories,
          messages,
        },
      ).get();
      for (final QueryRow row in rows) {
        candidateIds.add(row.read<String>('id'));
      }
    }

    candidateIds.addAll(
      await _searchMemoryIdsByLiteralScan(
        keywordTerms: keywordTerms,
        includeDeleted: includeDeleted,
      ),
    );
    return candidateIds;
  }

  Future<Set<String>> _searchMemoryIdsByLiteralScan({
    required List<String> keywordTerms,
    required bool includeDeleted,
  }) async {
    if (keywordTerms.isEmpty) {
      return <String>{};
    }

    final Set<String> matchingIds = <String>{};
    final List<QueryRow> rows = await customSelect(
      includeDeleted
          ? '''
            SELECT memories.id, memories.content
            FROM memories
            INNER JOIN messages ON messages.id = memories.source_message_id
            '''
          : '''
            SELECT memories.id, memories.content
            FROM memories
            INNER JOIN messages ON messages.id = memories.source_message_id
            WHERE memories.is_deleted = 0
              AND messages.is_deleted = 0
            ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        memories,
        messages,
      },
    ).get();
    for (final QueryRow row in rows) {
      final String lowerContent = row.read<String>('content').toLowerCase();
      if (keywordTerms.any(
        (String term) => _memoryContainsTerm(lowerContent, term),
      )) {
        matchingIds.add(row.read<String>('id'));
      }
    }
    return matchingIds;
  }

  Future<Set<String>> _searchMemoryIdsByEntities({
    required List<String> entityFilters,
    required bool includeDeleted,
  }) async {
    if (entityFilters.isEmpty) {
      return <String>{};
    }

    final Set<String> entityIds = <String>{};
    for (final String entityFilter in entityFilters) {
      final String? entityId = await findEntityIdByReference(entityFilter);
      if (entityId != null && entityId.isNotEmpty) {
        entityIds.add(entityId);
      }
    }
    if (entityIds.isEmpty) {
      return <String>{};
    }

    final List<EntityLink> links = await (select(
      entityLinks,
    )..where((EntityLinks row) => row.entityId.isIn(entityIds.toList()))).get();
    final Set<String> memoryIds = links
        .map((EntityLink link) => link.memoryId)
        .toSet();
    if (includeDeleted || memoryIds.isEmpty) {
      return memoryIds;
    }

    final Set<String> activeMemoryIds = await _filterToActiveMemoryIds(
      memoryIds,
    );
    return activeMemoryIds;
  }

  Future<Set<String>> _searchMemoryIdsByTags({
    required List<String> tagFilters,
    required bool includeDeleted,
  }) async {
    if (tagFilters.isEmpty) {
      return <String>{};
    }

    final List<MemoryTag> tagRows = await (select(
      memoryTags,
    )..where((MemoryTags row) => row.tag.isIn(tagFilters))).get();
    final Set<String> memoryIds = tagRows
        .map((MemoryTag row) => row.memoryId)
        .toSet();
    if (includeDeleted || memoryIds.isEmpty) {
      return memoryIds;
    }
    return _filterToActiveMemoryIds(memoryIds);
  }

  Future<Set<String>> _searchMemoryIdsByTimeFilters({
    required List<String> timeFilters,
    required bool includeDeleted,
  }) async {
    if (timeFilters.isEmpty) {
      return <String>{};
    }

    final Set<String> matchingIds = <String>{};
    final List<QueryRow> rows = await customSelect(
      includeDeleted
          ? '''
            SELECT memories.id, memories.content, memories.created_at
            FROM memories
            INNER JOIN messages ON messages.id = memories.source_message_id
            '''
          : '''
            SELECT memories.id, memories.content, memories.created_at
            FROM memories
            INNER JOIN messages ON messages.id = memories.source_message_id
            WHERE memories.is_deleted = 0
              AND messages.is_deleted = 0
            ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        memories,
        messages,
      },
    ).get();
    for (final QueryRow row in rows) {
      final String content = row.read<String>('content');
      final DateTime createdAt = row.read<DateTime>('created_at');
      if (timeFilters.any(
        (String timeFilter) => _matchesTimeFilterValue(
          content: content,
          createdAt: createdAt,
          timeFilter: timeFilter,
        ),
      )) {
        matchingIds.add(row.read<String>('id'));
      }
    }
    return matchingIds;
  }

  Future<Set<String>> _filterToActiveMemoryIds(Set<String> memoryIds) async {
    if (memoryIds.isEmpty) {
      return <String>{};
    }
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT memories.id
      FROM memories
      INNER JOIN messages ON messages.id = memories.source_message_id
      WHERE memories.id IN (${_buildSqlPlaceholderList(memoryIds.length)})
        AND memories.is_deleted = 0
        AND messages.is_deleted = 0
      ''',
      variables: memoryIds
          .map((String memoryId) => Variable<String>(memoryId))
          .toList(growable: false),
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        memories,
        messages,
      },
    ).get();
    return rows.map((QueryRow row) => row.read<String>('id')).toSet();
  }

  Future<List<RetrievedMemory>> _retrieveAttachmentMatches({
    required PrepareDecision prepareDecision,
    required bool includeDeleted,
  }) async {
    final String strategy = prepareDecision.retrievalPlan.strategy;
    if (strategy != 'keyword_only' && strategy != 'keyword_vector_hybrid') {
      return <RetrievedMemory>[];
    }

    final List<String> keywordTerms = _keywordTermsFor(prepareDecision);
    if (keywordTerms.isEmpty) {
      return <RetrievedMemory>[];
    }

    final List<String> timeFilters = _timeFiltersFor(prepareDecision);
    final List<QueryRow> rows = await customSelect(
      includeDeleted
          ? '''
            SELECT
              attachments.id,
              attachments.kind,
              attachments.display_name,
              attachments.raw_text,
              attachments.summary,
              attachments.summary_memory_id,
              attachments.created_at
            FROM attachments
            INNER JOIN messages ON messages.id = attachments.message_id
            WHERE attachments.raw_text IS NOT NULL
              AND TRIM(attachments.raw_text) != ''
            '''
          : '''
            SELECT
              attachments.id,
              attachments.kind,
              attachments.display_name,
              attachments.raw_text,
              attachments.summary,
              attachments.summary_memory_id,
              attachments.created_at
            FROM attachments
            INNER JOIN messages ON messages.id = attachments.message_id
            WHERE attachments.raw_text IS NOT NULL
              AND TRIM(attachments.raw_text) != ''
              AND messages.is_deleted = 0
            ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        attachments,
        messages,
      },
    ).get();

    final List<RetrievedMemory> results = <RetrievedMemory>[];
    for (final QueryRow row in rows) {
      final String rawText = row.read<String>('raw_text');
      final String lowerRawText = rawText.toLowerCase();
      int literalMatches = 0;
      for (final String term in keywordTerms) {
        if (_memoryContainsTerm(lowerRawText, term)) {
          literalMatches += 1;
        }
      }
      if (literalMatches == 0) {
        continue;
      }

      final DateTime createdAt = row.read<DateTime>('created_at');
      int timeMatches = 0;
      for (final String timeFilter in timeFilters) {
        if (_matchesTimeFilterValue(
          content: rawText,
          createdAt: createdAt,
          timeFilter: timeFilter,
        )) {
          timeMatches += 1;
        }
      }
      if (timeFilters.isNotEmpty && timeMatches == 0) {
        continue;
      }

      final String? summaryMemoryId = row.readNullable<String>(
        'summary_memory_id',
      );
      final List<String> tags = summaryMemoryId == null
          ? const <String>[]
          : await _readTags(summaryMemoryId);
      final List<String> entitiesForAttachment = summaryMemoryId == null
          ? const <String>[]
          : await _readEntitiesForMemory(summaryMemoryId);
      final List<double>? embedding = summaryMemoryId == null
          ? null
          : await _loadAttachmentSummaryEmbedding(
              summaryMemoryId: summaryMemoryId,
              includeDeleted: includeDeleted,
            );
      double vectorScore = 0.0;
      if (prepareDecision.queryEmbedding != null && embedding != null) {
        vectorScore = _cosineSimilarity(
          prepareDecision.queryEmbedding!,
          embedding,
        );
      }
      final double score = _weightedScoreForStrategy(
        strategy: strategy,
        literalMatches: literalMatches,
        entityMatches: 0,
        tagMatches: 0,
        timeMatches: timeMatches,
        vectorScore: vectorScore,
        recencyBonus: 0.0,
      );
      final String summary = row.readNullable<String>('summary') ?? '';
      final String attachmentId = row.read<String>('id');
      final String? attachmentName = row.readNullable<String>('display_name');
      results.add(
        RetrievedMemory(
          id: summaryMemoryId ?? attachmentId,
          content: summary.trim().isEmpty ? rawText : summary,
          tags: tags,
          entities: entitiesForAttachment,
          score: score,
          createdAt: createdAt.toLocal(),
          sourceType: row.read<String>('kind') == ChatAttachmentKind.image.name
              ? 'image_attachment'
              : 'document_attachment',
          attachmentId: attachmentId,
          attachmentName: attachmentName,
          snippet: _buildAttachmentSnippet(rawText, keywordTerms),
        ),
      );
    }
    return results;
  }

  Future<List<double>?> _loadAttachmentSummaryEmbedding({
    required String summaryMemoryId,
    required bool includeDeleted,
  }) async {
    final EmbeddingVector? vector =
        await (select(embeddingVectors)
              ..where(
                (EmbeddingVectors row) => row.memoryId.equals(summaryMemoryId),
              )
              ..where(
                (EmbeddingVectors row) => includeDeleted
                    ? const Constant(true)
                    : row.isCanon.equals(true),
              )
              ..orderBy(<OrderingTerm Function($EmbeddingVectorsTable)>[
                ($EmbeddingVectorsTable row) =>
                    OrderingTerm.desc(row.createdAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (vector == null) {
      return null;
    }
    return _decodeEmbedding(vector.vectorBlob);
  }

  List<RetrievedMemory> _deduplicateRetrievedResults(
    List<RetrievedMemory> results,
  ) {
    final Set<String> seenIds = <String>{};
    final List<RetrievedMemory> uniqueResults = <RetrievedMemory>[];
    for (final RetrievedMemory result in results) {
      if (!seenIds.add(result.id)) {
        continue;
      }
      uniqueResults.add(result);
    }
    return uniqueResults;
  }

  String _buildAttachmentSnippet(String rawText, List<String> keywordTerms) {
    final String normalizedRawText = rawText
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalizedRawText.isEmpty) {
      return '';
    }

    int matchIndex = 0;
    final String lowerRawText = normalizedRawText.toLowerCase();
    for (final String term in keywordTerms) {
      final int nextIndex = lowerRawText.indexOf(term.toLowerCase());
      if (nextIndex >= 0) {
        matchIndex = nextIndex;
        break;
      }
    }

    int start = matchIndex - 80;
    if (start < 0) {
      start = 0;
    }
    int end = matchIndex + 160;
    if (end > normalizedRawText.length) {
      end = normalizedRawText.length;
    }

    final String snippet = normalizedRawText.substring(start, end).trim();
    if (snippet.length == normalizedRawText.length) {
      return snippet;
    }

    final String prefix = start == 0 ? '' : '... ';
    final String suffix = end == normalizedRawText.length ? '' : ' ...';
    return '$prefix$snippet$suffix';
  }

  Future<List<MemoryConfirmation>> recentMemoryConfirmations({
    int limit = 3,
  }) async {
    final List<Memory> recentMemories =
        await (select(memories)
              ..where((Memories row) => row.isDeleted.equals(false))
              ..orderBy(<OrderingTerm Function($MemoriesTable)>[
                ($MemoriesTable row) => OrderingTerm.desc(row.createdAt),
              ])
              ..limit(limit))
            .get();

    final List<MemoryConfirmation> results = <MemoryConfirmation>[];
    for (final Memory memory in recentMemories) {
      final List<String> tags = await _readTags(memory.id);
      final List<String> entitiesForMemory = await _readEntitiesForMemory(
        memory.id,
      );
      results.add(
        MemoryConfirmation(
          content: memory.content,
          tags: tags,
          entities: entitiesForMemory,
        ),
      );
    }
    return results;
  }

  Future<List<EntityListItem>> fetchPromotedEntities() async {
    final List<Entity> entityRows = await (select(
      entities,
    )..where((Entities row) => row.isPromoted.equals(true))).get();
    entityRows.sort((Entity first, Entity second) {
      final DateTime firstTimestamp = first.lastMentionedAt ?? first.updatedAt;
      final DateTime secondTimestamp =
          second.lastMentionedAt ?? second.updatedAt;
      return secondTimestamp.compareTo(firstTimestamp);
    });

    return entityRows
        .map(
          (Entity entity) => EntityListItem(
            id: entity.id,
            name: entity.name,
            summary: entity.summary,
            mentionCount: entity.mentionCount,
            firstMentionedAt: entity.firstMentionedAt?.toLocal(),
            lastMentionedAt: entity.lastMentionedAt?.toLocal(),
          ),
        )
        .toList(growable: false);
  }

  Future<String?> findEntityIdByReference(String entityReference) async {
    final Entity? entity = await _findEntityByReference(entityReference);
    return entity?.id;
  }

  Future<EntityDetailRecord?> fetchEntityDetail(String entityId) async {
    final Entity? entity = await (select(
      entities,
    )..where((Entities row) => row.id.equals(entityId))).getSingleOrNull();
    if (entity == null) {
      return null;
    }

    final List<String> aliases = await _readAliasesForEntity(entity.id);
    final List<_ActiveEntityMemory> linkedMemories =
        await _loadActiveLinkedMemoriesForEntity(entity.id);

    return EntityDetailRecord(
      id: entity.id,
      name: entity.name,
      aliases: aliases,
      summary: entity.summary,
      mentionCount: entity.mentionCount,
      summaryMemoryCount: entity.summaryMemoryCount,
      isPromoted: entity.isPromoted,
      firstMentionedAt: entity.firstMentionedAt?.toLocal(),
      lastMentionedAt: entity.lastMentionedAt?.toLocal(),
      linkedMemories: linkedMemories
          .map(
            (_ActiveEntityMemory memory) => EntityLinkedMemoryRecord(
              id: memory.id,
              content: memory.content,
              tags: memory.tags,
              entities: memory.entities,
              createdAt: memory.createdAt.toLocal(),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> updateEntitySummary({
    required String entityId,
    required String summary,
  }) async {
    final Entity? entity = await (select(
      entities,
    )..where((Entities row) => row.id.equals(entityId))).getSingleOrNull();
    if (entity == null) {
      return;
    }

    await (update(
      entities,
    )..where((Entities row) => row.id.equals(entityId))).write(
      EntitiesCompanion(
        summary: Value<String>(summary),
        summaryMemoryCount: Value<int>(entity.mentionCount),
        updatedAt: Value<DateTime>(DateTime.now().toUtc()),
      ),
    );
  }

  Future<Entity> _resolveOrCreateEntity(
    String entityReference,
    DateTime now,
  ) async {
    final String rawReference = _sanitizeEntityReference(entityReference);
    final Entity? existingEntity = await _findEntityByReference(rawReference);
    if (existingEntity != null) {
      await _ensureEntityAlias(
        existingEntity.id,
        existingEntity.name,
        rawReference,
      );
      return existingEntity;
    }

    final String canonicalName = _canonicalizeEntityName(rawReference);
    final String entityId = _uuid.v4();
    await into(entities).insert(
      EntitiesCompanion.insert(
        id: entityId,
        name: canonicalName,
        createdAt: now,
        updatedAt: now,
        mentionCount: const Value<int>(0),
        summaryMemoryCount: const Value<int>(0),
        isPromoted: const Value<bool>(false),
        firstMentionedAt: Value<DateTime?>(now),
        lastMentionedAt: Value<DateTime?>(now),
      ),
    );
    await _ensureEntityAlias(entityId, canonicalName, rawReference);

    final Entity createdEntity = await (select(
      entities,
    )..where((Entities row) => row.id.equals(entityId))).getSingle();
    return createdEntity;
  }

  Future<Entity?> _findEntityByReference(String entityReference) async {
    final String rawReference = _sanitizeEntityReference(entityReference);
    if (rawReference.isEmpty) {
      return null;
    }

    final List<Entity> entityRows =
        await (select(entities)
              ..orderBy(<OrderingTerm Function($EntitiesTable)>[
                ($EntitiesTable row) => OrderingTerm.asc(row.createdAt),
              ]))
            .get();
    final List<EntityAliase> aliasRows = await select(entityAliases).get();
    final Map<String, Entity> entitiesById = <String, Entity>{
      for (final Entity entity in entityRows) entity.id: entity,
    };

    for (final Entity entity in entityRows) {
      if (entity.name == rawReference) {
        return entity;
      }
    }

    for (final EntityAliase alias in aliasRows) {
      if (alias.alias != rawReference) {
        continue;
      }
      return entitiesById[alias.entityId];
    }

    final String normalizedReference = _normalizeEntityReference(rawReference);
    if (normalizedReference.isEmpty) {
      return null;
    }

    for (final Entity entity in entityRows) {
      if (_normalizeEntityReference(entity.name) == normalizedReference) {
        return entity;
      }
    }

    for (final EntityAliase alias in aliasRows) {
      if (_normalizeEntityReference(alias.alias) != normalizedReference) {
        continue;
      }
      return entitiesById[alias.entityId];
    }

    return null;
  }

  Future<void> _ensureEntityAlias(
    String entityId,
    String canonicalName,
    String rawReference,
  ) async {
    final String sanitizedReference = _sanitizeEntityReference(rawReference);
    if (sanitizedReference.isEmpty || sanitizedReference == canonicalName) {
      return;
    }

    final EntityAliase? existingAlias =
        await (select(entityAliases)..where(
              (EntityAliases row) =>
                  row.entityId.equals(entityId) &
                  row.alias.equals(sanitizedReference),
            ))
            .getSingleOrNull();
    if (existingAlias != null) {
      return;
    }

    await into(entityAliases).insert(
      EntityAliasesCompanion.insert(
        entityId: entityId,
        alias: sanitizedReference,
      ),
    );
  }

  Future<void> _refreshEntityProjectionForIds(
    Set<String> entityIds, {
    bool invalidateSummary = false,
  }) async {
    if (entityIds.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now().toUtc();
    for (final String entityId in entityIds) {
      final Entity? entity = await (select(
        entities,
      )..where((Entities row) => row.id.equals(entityId))).getSingleOrNull();
      if (entity == null) {
        continue;
      }

      final List<_ActiveEntityMemory> activeMemories =
          await _loadActiveLinkedMemoriesForEntity(entityId);
      final _ActiveEntityMemory? newestMemory = activeMemories.isEmpty
          ? null
          : activeMemories.first;
      final _ActiveEntityMemory? oldestMemory = activeMemories.isEmpty
          ? null
          : activeMemories.last;

      String? nextSummary = entity.summary;
      int nextSummaryMemoryCount = entity.summaryMemoryCount;
      if (invalidateSummary ||
          nextSummaryMemoryCount > activeMemories.length ||
          activeMemories.isEmpty) {
        nextSummary = null;
        nextSummaryMemoryCount = 0;
      }

      await (update(
        entities,
      )..where((Entities row) => row.id.equals(entityId))).write(
        EntitiesCompanion(
          mentionCount: Value<int>(activeMemories.length),
          summary: Value<String?>(nextSummary),
          summaryMemoryCount: Value<int>(nextSummaryMemoryCount),
          isPromoted: Value<bool>(activeMemories.length >= 2),
          firstMentionedAt: Value<DateTime?>(oldestMemory?.createdAt),
          lastMentionedAt: Value<DateTime?>(newestMemory?.createdAt),
          updatedAt: Value<DateTime>(now),
        ),
      );
    }
  }

  Future<List<_ActiveEntityMemory>> _loadActiveLinkedMemoriesForEntity(
    String entityId,
  ) async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT DISTINCT memories.id, memories.content, memories.created_at
      FROM entity_links
      INNER JOIN memories ON memories.id = entity_links.memory_id
      INNER JOIN messages ON messages.id = memories.source_message_id
      WHERE entity_links.entity_id = ?
        AND memories.is_deleted = 0
        AND messages.is_deleted = 0
      ORDER BY memories.created_at DESC
      ''',
      variables: <Variable<Object>>[Variable<String>(entityId)],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        entityLinks,
        memories,
        messages,
      },
    ).get();

    final List<_ActiveEntityMemory> results = <_ActiveEntityMemory>[];
    for (final QueryRow row in rows) {
      final String memoryId = row.read<String>('id');
      results.add(
        _ActiveEntityMemory(
          id: memoryId,
          content: row.read<String>('content'),
          tags: await _readTags(memoryId),
          entities: await _readEntitiesForMemory(memoryId),
          createdAt: row.read<DateTime>('created_at'),
        ),
      );
    }
    return results;
  }

  Future<List<String>> _readAliasesForEntity(String entityId) async {
    final List<EntityAliase> aliasRows =
        await (select(entityAliases)
              ..where((EntityAliases row) => row.entityId.equals(entityId))
              ..orderBy(<OrderingTerm Function($EntityAliasesTable)>[
                ($EntityAliasesTable row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    return aliasRows
        .map((EntityAliase alias) => alias.alias)
        .toList(growable: false);
  }

  Future<Set<String>> _readEntityIdsForMemoryIds(List<String> memoryIds) async {
    if (memoryIds.isEmpty) {
      return <String>{};
    }

    final List<EntityLink> links = await (select(
      entityLinks,
    )..where((EntityLinks row) => row.memoryId.isIn(memoryIds))).get();
    return links.map((EntityLink link) => link.entityId).toSet();
  }

  String _sanitizeEntityReference(String entityReference) {
    return entityReference.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeEntityReference(String entityReference) {
    String normalized = _sanitizeEntityReference(entityReference).toLowerCase();
    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  String _canonicalizeEntityName(String entityReference) {
    String canonicalName = _sanitizeEntityReference(entityReference);
    if (canonicalName.startsWith('@') && canonicalName.length > 1) {
      canonicalName = canonicalName.substring(1);
    }

    final List<String> tokens = canonicalName
        .split(' ')
        .map(_titleCaseEntityToken)
        .toList(growable: false);
    return tokens.join(' ');
  }

  String _titleCaseEntityToken(String token) {
    if (token.isEmpty) {
      return token;
    }
    if (!RegExp(r'^[a-z]+$').hasMatch(token)) {
      return token;
    }
    return '${token[0].toUpperCase()}${token.substring(1)}';
  }

  String _normalizeKeywordTerm(String term) {
    return term.trim().toLowerCase();
  }

  bool _isFtsFriendlyTerm(String term) {
    return RegExp(r'^[a-z0-9 ]+$').hasMatch(term);
  }

  String _buildFtsQueryTerm(String term) {
    final String escapedTerm = term.replaceAll('"', '""');
    return '"$escapedTerm"';
  }

  bool _memoryContainsTerm(String lowerContent, String term) {
    final String normalizedTerm = _normalizeKeywordTerm(term);
    if (normalizedTerm.isEmpty) {
      return false;
    }
    return lowerContent.contains(normalizedTerm);
  }

  bool _memoryMatchesTimeFilter(_MemoryCandidate candidate, String timeFilter) {
    return _matchesTimeFilterValue(
      content: candidate.content,
      createdAt: candidate.createdAt,
      timeFilter: timeFilter,
    );
  }

  bool _matchesTimeFilterValue({
    required String content,
    required DateTime createdAt,
    required String timeFilter,
  }) {
    final String normalizedFilter = _normalizeKeywordTerm(timeFilter);
    if (normalizedFilter.isEmpty) {
      return false;
    }

    final String lowerContent = content.toLowerCase();
    if (lowerContent.contains(normalizedFilter)) {
      return true;
    }

    final RegExp yearPattern = RegExp(r'^\d{4}$');
    if (yearPattern.hasMatch(normalizedFilter)) {
      return createdAt.year.toString() == normalizedFilter;
    }

    final RegExp isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (isoDatePattern.hasMatch(normalizedFilter)) {
      final String isoDate = createdAt.toUtc().toIso8601String();
      return isoDate.startsWith(normalizedFilter);
    }

    final int? monthNumber = _monthNumberForToken(normalizedFilter);
    if (monthNumber != null) {
      return createdAt.month == monthNumber;
    }

    return false;
  }

  int? _monthNumberForToken(String token) {
    const Map<String, int> monthNumbers = <String, int>{
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'sept': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return monthNumbers[token];
  }

  String _buildSqlPlaceholderList(int count) {
    final List<String> placeholders = <String>[];
    for (int index = 0; index < count; index++) {
      placeholders.add('?');
    }
    return placeholders.join(', ');
  }

  Future<List<_MemoryCandidate>> _loadMemoryCandidates({
    required bool includeDeleted,
    Set<String>? memoryIds,
  }) async {
    if (memoryIds != null && memoryIds.isEmpty) {
      return <_MemoryCandidate>[];
    }

    final JoinedSelectStatement<HasResultSet, dynamic> query = select(memories)
        .join(<Join<HasResultSet, dynamic>>[
          innerJoin(messages, messages.id.equalsExp(memories.sourceMessageId)),
        ]);
    query.orderBy(<OrderingTerm>[OrderingTerm.desc(memories.createdAt)]);

    if (memoryIds != null) {
      query.where(memories.id.isIn(memoryIds.toList(growable: false)));
    }

    if (!includeDeleted) {
      query.where(
        memories.isDeleted.equals(false) & messages.isDeleted.equals(false),
      );
    }

    final List<TypedResult> memoryRows = await query.get();

    final List<_MemoryCandidate> results = <_MemoryCandidate>[];
    for (final TypedResult row in memoryRows) {
      final Memory memory = row.readTable(memories);
      final List<String> tags = await _readTags(memory.id);
      final List<String> entitiesForMemory = await _readEntitiesForMemory(
        memory.id,
      );
      final EmbeddingVector? vector =
          await (select(embeddingVectors)
                ..where((row) => row.memoryId.equals(memory.id))
                ..where(
                  (row) => includeDeleted
                      ? const Constant(true)
                      : row.isCanon.equals(true),
                )
                ..orderBy(<OrderingTerm Function($EmbeddingVectorsTable)>[
                  ($EmbeddingVectorsTable row) =>
                      OrderingTerm.desc(row.createdAt),
                ])
                ..limit(1))
              .getSingleOrNull();

      results.add(
        _MemoryCandidate(
          id: memory.id,
          content: memory.content,
          tags: tags,
          entities: entitiesForMemory,
          embedding: vector == null
              ? null
              : _decodeEmbedding(vector.vectorBlob),
          createdAt: memory.createdAt,
        ),
      );
    }
    return results;
  }

  Future<List<String>> _readTags(String memoryId) async {
    final List<MemoryTag> rows = await (select(
      memoryTags,
    )..where((row) => row.memoryId.equals(memoryId))).get();
    return rows.map((MemoryTag row) => row.tag).toList();
  }

  Future<List<String>> _readEntitiesForMemory(String memoryId) async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT entities.name
      FROM entity_links
      INNER JOIN entities ON entities.id = entity_links.entity_id
      WHERE entity_links.memory_id = ?
      ''',
      variables: <Variable<Object>>[Variable<String>(memoryId)],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        entityLinks,
        entities,
      },
    ).get();

    return rows
        .map((QueryRow row) => row.readNullable<String>('name'))
        .whereType<String>()
        .toList();
  }

  ChatMessageRecord _mapMessage(
    Message row,
    List<ChatAttachmentRecord> attachmentsForMessage,
  ) {
    return ChatMessageRecord(
      id: row.id,
      role: row.role == ChatMessageRole.assistant.name
          ? ChatMessageRole.assistant
          : ChatMessageRole.user,
      content: row.content,
      createdAt: row.createdAt.toLocal(),
      isEdited: row.isEdited,
      isDeleted: row.isDeleted,
      pairedMessageId: row.pairedMessageId,
      attachments: attachmentsForMessage,
    );
  }

  ChatAttachmentRecord _mapAttachment(Attachment row) {
    return ChatAttachmentRecord(
      id: row.id,
      kind: row.kind == ChatAttachmentKind.image.name
          ? ChatAttachmentKind.image
          : ChatAttachmentKind.document,
      displayName: row.displayName,
      mimeType: row.mimeType,
      localPath: row.localPath,
      byteSize: row.byteSize,
      status: _attachmentStatusFromValue(row.status),
      failureReason: row.failureReason,
      rawText: row.rawText,
      summary: row.summary,
      summaryMemoryId: row.summaryMemoryId,
      createdAt: row.createdAt.toLocal(),
    );
  }

  ChatAttachmentStatus _attachmentStatusFromValue(String? value) {
    switch (value) {
      case 'pending':
        return ChatAttachmentStatus.pending;
      case 'failed':
        return ChatAttachmentStatus.failed;
      case 'ready':
      default:
        return ChatAttachmentStatus.ready;
    }
  }

  static QueryExecutor _openConnection(String encryptionKey) {
    return driftDatabase(
      name: 'heyo_rebuild',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        setup: _buildDatabaseSetup(encryptionKey),
      ),
    );
  }

  static void Function(CommonDatabase) _buildDatabaseSetup(
    String encryptionKey,
  ) {
    final String escapedKey = encryptionKey.replaceAll("'", "''");
    return (CommonDatabase database) {
      database.execute("pragma key = '$escapedKey';");
      database.execute('pragma journal_mode = WAL;');
      database.execute('pragma foreign_keys = ON;');
      database.execute('pragma temp_store = MEMORY;');
    };
  }

  static Uint8List _encodeEmbedding(List<double> embedding) {
    final Float32List float32List = Float32List.fromList(embedding);
    return float32List.buffer.asUint8List();
  }

  static List<double> _decodeEmbedding(Uint8List bytes) {
    final ByteBuffer buffer = bytes.buffer;
    final Float32List float32List = buffer.asFloat32List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 4,
    );
    return float32List.map((double value) => value.toDouble()).toList();
  }

  static double _cosineSimilarity(
    List<double> firstVector,
    List<double> secondVector,
  ) {
    if (firstVector.isEmpty || secondVector.isEmpty) {
      return 0.0;
    }

    final int length = min(firstVector.length, secondVector.length);
    double dotProduct = 0.0;
    double firstMagnitude = 0.0;
    double secondMagnitude = 0.0;

    for (int index = 0; index < length; index++) {
      dotProduct += firstVector[index] * secondVector[index];
      firstMagnitude += firstVector[index] * firstVector[index];
      secondMagnitude += secondVector[index] * secondVector[index];
    }

    if (firstMagnitude == 0.0 || secondMagnitude == 0.0) {
      return 0.0;
    }

    return dotProduct / (sqrt(firstMagnitude) * sqrt(secondMagnitude));
  }
}

class _MemoryCandidate {
  final String id;
  final String content;
  final List<String> tags;
  final List<String> entities;
  final List<double>? embedding;
  final DateTime createdAt;

  const _MemoryCandidate({
    required this.id,
    required this.content,
    required this.tags,
    required this.entities,
    required this.embedding,
    required this.createdAt,
  });
}

class _RankedMemoryCandidate {
  final _MemoryCandidate candidate;
  final double score;

  const _RankedMemoryCandidate({required this.candidate, required this.score});
}

class _CandidateScore {
  final double score;
  final int literalMatches;
  final int entityMatches;
  final int tagMatches;
  final int timeMatches;
  final double vectorScore;

  const _CandidateScore({
    required this.score,
    required this.literalMatches,
    required this.entityMatches,
    required this.tagMatches,
    required this.timeMatches,
    required this.vectorScore,
  });
}

class _ActiveEntityMemory {
  final String id;
  final String content;
  final List<String> tags;
  final List<String> entities;
  final DateTime createdAt;

  const _ActiveEntityMemory({
    required this.id,
    required this.content,
    required this.tags,
    required this.entities,
    required this.createdAt,
  });
}
