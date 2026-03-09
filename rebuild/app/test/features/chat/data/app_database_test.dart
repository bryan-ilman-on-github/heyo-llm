import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';

void main() {
  group('AppDatabase export', () {
    test('exportSnapshot includes all expected local tables', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      final ChatMessageRecord userMessage = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: "Rita's instagram handle is @rita",
      );
      await appDatabase.editMessage(
        messageId: userMessage.id,
        newContent: "Rita's instagram handle is @riya",
      );
      await appDatabase.insertMemoryPlan(
        sourceMessageId: userMessage.id,
        memoryWritePlan: const MemoryWritePlan(
          content: "Rita's instagram handle is @riya",
          tags: <String>['relationship'],
          entities: <String>['Rita'],
          embedding: <double>[0.1, 0.2, 0.3],
        ),
      );

      final ChatMessageRecord assistantMessage = await appDatabase
          .insertMessage(
            role: ChatMessageRole.assistant,
            content: 'Rita uses @riya now.',
          );
      await appDatabase.pairMessages(
        userMessageId: userMessage.id,
        assistantMessageId: assistantMessage.id,
      );
      await appDatabase
          .into(appDatabase.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'attachment-1',
              messageId: userMessage.id,
              kind: 'document',
              localPath: const Value<String>('notes/rita.txt'),
              rawText: const Value<String>('Rita full note text'),
              summary: const Value<String>('Rita note summary'),
              createdAt: DateTime.now().toUtc(),
            ),
          );

      final LocalExportSnapshot snapshot = await appDatabase.exportSnapshot();
      final Map<String, Object?> payload = snapshot.toJson();

      expect(
        payload.keys,
        containsAll(<String>[
          'messages',
          'message_revisions',
          'memories',
          'embedding_vectors',
          'memory_tags',
          'entities',
          'entity_aliases',
          'entity_links',
          'attachments',
          'message_pairs',
        ]),
      );
      expect(snapshot.messages, hasLength(2));
      expect(snapshot.messageRevisions, hasLength(1));
      expect(snapshot.memories, hasLength(1));
      expect(snapshot.embeddingVectors, hasLength(1));
      expect(snapshot.memoryTags, isNotEmpty);
      expect(snapshot.entities, hasLength(1));
      expect(snapshot.entityLinks, hasLength(1));
      expect(snapshot.attachments, hasLength(1));
      expect(snapshot.messagePairs, hasLength(1));
      expect(
        (snapshot.attachments.single['raw_text'] as String?),
        'Rita full note text',
      );
      expect(
        snapshot.embeddingVectors.single['vector'],
        containsAllInOrder(<Matcher>[
          closeTo(0.1, 0.000001),
          closeTo(0.2, 0.000001),
          closeTo(0.3, 0.000001),
        ]),
      );
    });
  });

  group('AppDatabase retrieval', () {
    test(
      'emotional recall favors positive memories and drops duplicates',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemory(
          appDatabase,
          content: 'I felt happy after the trip',
          entities: const <String>[],
          tags: const <String>['positive', 'travel'],
          embedding: const <double>[1.0, 0.0, 0.0],
        );
        await _storeMemory(
          appDatabase,
          content: 'I felt happy after the trip.',
          entities: const <String>[],
          tags: const <String>['positive', 'travel'],
          embedding: const <double>[1.0, 0.0, 0.0],
        );
        await _storeMemory(
          appDatabase,
          content: 'I was proud after finishing the launch',
          entities: const <String>[],
          tags: const <String>['positive'],
          embedding: const <double>[0.9, 0.1, 0.0],
        );
        await _storeMemory(
          appDatabase,
          content: 'I felt stuck at work',
          entities: const <String>[],
          tags: const <String>['negative'],
          embedding: const <double>[1.0, 0.0, 0.0],
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>[],
                tags: const <String>['positive'],
                strategy: 'tag_vector',
                intentType: 'emotional_recall',
                queryEmbedding: const <double>[1.0, 0.0, 0.0],
              ),
            );

        expect(matches, hasLength(2));
        expect(
          matches.every(
            (RetrievedMemory memory) => memory.tags.contains('positive'),
          ),
          isTrue,
        );
        expect(
          matches.where(
            (RetrievedMemory memory) =>
                memory.content.toLowerCase().contains('happy after the trip'),
          ),
          hasLength(1),
        );
      },
    );

    test(
      'entity recall excludes unrelated memories even with similar embeddings',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemory(
          appDatabase,
          content: 'Rita started a new job',
          entities: const <String>['Rita'],
          embedding: const <double>[1.0, 0.0, 0.0],
        );
        await _storeMemory(
          appDatabase,
          content: 'Bhutan trip was amazing',
          entities: const <String>['Bhutan'],
          tags: const <String>['travel', 'positive'],
          embedding: const <double>[1.0, 0.0, 0.0],
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                entities: const <String>['Rita'],
                literalTerms: const <String>['life'],
                strategy: 'entity_keyword_hybrid',
                intentType: 'entity_specific_recall',
                queryEmbedding: const <double>[1.0, 0.0, 0.0],
              ),
            );

        expect(matches, hasLength(1));
        expect(matches.single.entities, contains('Rita'));
        expect(matches.single.content, 'Rita started a new job');
      },
    );

    test('exact mention lookup does not return unrelated memories', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      await _storeMemory(
        appDatabase,
        content: 'Bhutan trip was amazing',
        entities: const <String>['Bhutan'],
        tags: const <String>['travel', 'positive'],
      );
      await _storeMemory(
        appDatabase,
        content: 'Rita moved to Penang',
        entities: const <String>['Rita'],
      );

      final List<RetrievedMemory> matches = await appDatabase.retrieveMemories(
        prepareDecision: _queryDecision(
          literalTerms: const <String>['Bhutan'],
          strategy: 'keyword_only',
          intentType: 'exact_mention_lookup',
        ),
      );

      expect(matches, hasLength(1));
      expect(matches.single.content, 'Bhutan trip was amazing');
    });

    test(
      'exact mention lookup returns literal matches in chronological order',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemoryAt(
          appDatabase,
          content: 'Bhutan came up during the 2024 travel plan',
          entities: const <String>['Bhutan'],
          tags: const <String>['travel'],
          createdAt: DateTime.utc(2024, 1, 5),
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'Bhutan came up again while planning a return trip',
          entities: const <String>['Bhutan'],
          tags: const <String>['travel'],
          createdAt: DateTime.utc(2026, 2, 1),
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>['Bhutan'],
                strategy: 'keyword_only',
                intentType: 'exact_mention_lookup',
              ),
            );

        expect(matches, hasLength(2));
        expect(
          matches.first.createdAt.isBefore(matches.last.createdAt),
          isTrue,
        );
        expect(matches.first.content, contains('2024'));
        expect(matches.last.content, contains('return trip'));
      },
    );

    test(
      'exact mention lookup can surface a document snippet from attachment raw text',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeDocumentAttachment(
          appDatabase,
          displayName: 'rita-note.docx',
          rawText:
              'Rita mentioned Bhutan during the archived travel planning notes.',
          summary: 'Document summary about Rita and archived travel planning.',
          createdAt: DateTime.utc(2025, 4, 12),
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>['Bhutan'],
                strategy: 'keyword_only',
                intentType: 'exact_mention_lookup',
              ),
            );

        expect(matches, hasLength(1));
        expect(matches.single.sourceType, 'document_attachment');
        expect(matches.single.attachmentName, 'rita-note.docx');
        expect(matches.single.snippet, contains('Bhutan'));
      },
    );

    test('quoted lookup honors the quoted phrase and year filter', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      await _storeMemoryAt(
        appDatabase,
        content: 'Fire in the rain, we kept moving anyway.',
        entities: const <String>[],
        createdAt: DateTime.utc(2025, 6, 11),
        embedding: const <double>[1.0, 0.0, 0.0],
      );
      await _storeMemoryAt(
        appDatabase,
        content: 'Fire in the rain became the chorus this year.',
        entities: const <String>[],
        createdAt: DateTime.utc(2026, 6, 11),
        embedding: const <double>[0.95, 0.05, 0.0],
      );

      final List<RetrievedMemory> matches = await appDatabase.retrieveMemories(
        prepareDecision: _queryDecision(
          literalTerms: const <String>['fire in the rain'],
          timeFilters: const <String>['2025'],
          strategy: 'keyword_vector_hybrid',
          intentType: 'quoted_text_lookup',
          queryEmbedding: const <double>[1.0, 0.0, 0.0],
        ),
      );

      expect(matches, hasLength(1));
      expect(matches.single.createdAt.year, 2025);
      expect(
        matches.single.content,
        'Fire in the rain, we kept moving anyway.',
      );
    });

    test(
      'quoted lookup can surface a document snippet from attachment raw text',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeDocumentAttachment(
          appDatabase,
          displayName: 'lyrics.md',
          rawText: 'We wrote: fire in the rain and kept moving anyway.',
          summary: 'Document summary for the lyrics draft.',
          createdAt: DateTime.utc(2025, 6, 11),
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>['fire in the rain'],
                timeFilters: const <String>['2025'],
                strategy: 'keyword_vector_hybrid',
                intentType: 'quoted_text_lookup',
                queryEmbedding: const <double>[1.0, 0.0, 0.0],
              ),
            );

        expect(matches, hasLength(1));
        expect(matches.single.sourceType, 'document_attachment');
        expect(matches.single.snippet, contains('fire in the rain'));
      },
    );

    test(
      'thematic reflection keeps time relevant memories and excludes recent noise',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemoryAt(
          appDatabase,
          content: 'I felt unsure before the presentation.',
          entities: const <String>[],
          tags: const <String>['negative'],
          createdAt: DateTime.utc(2026, 1, 10),
          embedding: const <double>[1.0, 0.0, 0.0],
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'I felt confident leading the meeting.',
          entities: const <String>[],
          tags: const <String>['positive'],
          createdAt: DateTime.utc(2026, 9, 18),
          embedding: const <double>[0.98, 0.02, 0.0],
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'Bhutan trip photos looked great.',
          entities: const <String>['Bhutan'],
          tags: const <String>['travel'],
          createdAt: DateTime.utc(2026, 12, 12),
          embedding: const <double>[0.0, 1.0, 0.0],
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'I felt confident during last year’s workshop.',
          entities: const <String>[],
          tags: const <String>['positive'],
          createdAt: DateTime.utc(2025, 8, 10),
          embedding: const <double>[0.95, 0.05, 0.0],
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>[],
                tags: const <String>['positive'],
                timeFilters: const <String>['2026'],
                strategy: 'time_vector',
                intentType: 'thematic_reflection',
                queryEmbedding: const <double>[1.0, 0.0, 0.0],
              ),
            );

        expect(matches, hasLength(2));
        expect(
          matches.every(
            (RetrievedMemory memory) => memory.createdAt.year == 2026,
          ),
          isTrue,
        );
        expect(
          matches.any(
            (RetrievedMemory memory) =>
                memory.content.contains('Bhutan trip photos'),
          ),
          isFalse,
        );
      },
    );

    test(
      'open reflective query uses vector ranking and recency without keywords',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemoryAt(
          appDatabase,
          content: 'I keep putting off the work that matters most.',
          entities: const <String>[],
          tags: const <String>['negative'],
          createdAt: DateTime.utc(2026, 3, 8),
          embedding: const <double>[1.0, 0.0, 0.0],
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'I feel tired after long meetings.',
          entities: const <String>[],
          tags: const <String>['negative'],
          createdAt: DateTime.utc(2026, 3, 3),
          embedding: const <double>[0.7, 0.3, 0.0],
        );
        await _storeMemoryAt(
          appDatabase,
          content: 'The cafe music was relaxing.',
          entities: const <String>[],
          tags: const <String>['general'],
          createdAt: DateTime.utc(2026, 3, 9),
          embedding: const <double>[0.0, 1.0, 0.0],
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>[],
                tags: const <String>['negative'],
                strategy: 'vector_only',
                intentType: 'open_reflective_query',
                queryEmbedding: const <double>[1.0, 0.0, 0.0],
              ),
            );

        expect(matches, isNotEmpty);
        expect(
          matches.first.content,
          'I keep putting off the work that matters most.',
        );
        expect(
          matches.any(
            (RetrievedMemory memory) => memory.content.contains('cafe music'),
          ),
          isFalse,
        );
      },
    );

    test('deleted memories stay excluded by default', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      final ChatMessageRecord deletedMessage = await _storeMemory(
        appDatabase,
        content: 'Deleted Rita note',
        entities: const <String>['Rita'],
      );
      await appDatabase.softDeleteMessage(deletedMessage.id);

      final List<RetrievedMemory> matches = await appDatabase.retrieveMemories(
        prepareDecision: _queryDecision(
          literalTerms: const <String>['Deleted'],
          strategy: 'keyword_only',
          intentType: 'exact_mention_lookup',
        ),
      );

      expect(matches, isEmpty);
    });

    test(
      'deleted memories are included only when the plan allows fallback',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        final ChatMessageRecord deletedMessage = await _storeMemory(
          appDatabase,
          content: 'Deleted Rita note',
          entities: const <String>['Rita'],
        );
        await appDatabase.softDeleteMessage(deletedMessage.id);

        final PrepareDecision prepareDecision = PrepareDecision(
          outcome: PrepareOutcome.query,
          assistantDraft: '',
          tags: const <String>[],
          entities: const <String>['Rita'],
          literalTerms: const <String>['Deleted'],
          timeFilters: const <String>[],
          queryEmbedding: null,
          clarificationPrompt: null,
          memoryWritePlans: const <MemoryWritePlan>[],
          retrievalPlan: const RetrievalPlan(
            intentType: 'exact_mention_lookup',
            strategy: 'keyword_only',
            allowDeletedFallback: true,
            keywordTerms: <String>['Deleted'],
            entityFilters: <String>['Rita'],
            tagFilters: <String>[],
            timeFilters: <String>[],
          ),
        );

        final List<RetrievedMemory> matches = await appDatabase
            .retrieveMemories(prepareDecision: prepareDecision);

        expect(matches, hasLength(1));
        expect(matches.single.content, 'Deleted Rita note');
      },
    );

    test(
      'deleted document attachments stay excluded unless fallback is allowed',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        final ChatMessageRecord message = await _storeDocumentAttachment(
          appDatabase,
          displayName: 'deleted-note.txt',
          rawText: 'Deleted Bhutan attachment note.',
          summary: 'Document summary for a deleted travel attachment.',
          createdAt: DateTime.utc(2026, 1, 20),
        );
        await appDatabase.softDeleteMessage(message.id);

        final List<RetrievedMemory> excludedMatches = await appDatabase
            .retrieveMemories(
              prepareDecision: _queryDecision(
                literalTerms: const <String>['Bhutan'],
                strategy: 'keyword_only',
                intentType: 'exact_mention_lookup',
              ),
            );
        expect(excludedMatches, isEmpty);

        final List<RetrievedMemory> fallbackMatches = await appDatabase
            .retrieveMemories(
              prepareDecision: const PrepareDecision(
                outcome: PrepareOutcome.query,
                assistantDraft: '',
                tags: <String>[],
                entities: <String>[],
                literalTerms: <String>['Bhutan'],
                timeFilters: <String>[],
                queryEmbedding: null,
                clarificationPrompt: null,
                memoryWritePlans: <MemoryWritePlan>[],
                retrievalPlan: RetrievalPlan(
                  intentType: 'exact_mention_lookup',
                  strategy: 'keyword_only',
                  allowDeletedFallback: true,
                  keywordTerms: <String>['Bhutan'],
                  entityFilters: <String>[],
                  tagFilters: <String>[],
                  timeFilters: <String>[],
                ),
              ),
            );

        expect(fallbackMatches, hasLength(1));
        expect(fallbackMatches.single.sourceType, 'document_attachment');
      },
    );
  });
}

Future<ChatMessageRecord> _storeMemory(
  AppDatabase appDatabase, {
  required String content,
  required List<String> entities,
  List<String> tags = const <String>['relationship'],
  List<double> embedding = const <double>[0.1, 0.2, 0.3],
}) async {
  final ChatMessageRecord message = await appDatabase.insertMessage(
    role: ChatMessageRole.user,
    content: content,
  );
  await appDatabase.insertMemoryPlan(
    sourceMessageId: message.id,
    memoryWritePlan: MemoryWritePlan(
      content: content,
      tags: tags,
      entities: entities,
      embedding: embedding,
    ),
  );
  return message;
}

PrepareDecision _queryDecision({
  required List<String> literalTerms,
  required String strategy,
  required String intentType,
  List<String> tags = const <String>[],
  List<String> entities = const <String>[],
  List<String> timeFilters = const <String>[],
  List<double>? queryEmbedding,
}) {
  return PrepareDecision(
    outcome: PrepareOutcome.query,
    assistantDraft: '',
    tags: tags,
    entities: entities,
    literalTerms: literalTerms,
    timeFilters: timeFilters,
    queryEmbedding: queryEmbedding,
    clarificationPrompt: null,
    memoryWritePlans: const <MemoryWritePlan>[],
    retrievalPlan: RetrievalPlan(
      intentType: intentType,
      strategy: strategy,
      allowDeletedFallback: false,
      keywordTerms: literalTerms,
      entityFilters: entities,
      tagFilters: tags,
      timeFilters: timeFilters,
    ),
  );
}

Future<ChatMessageRecord> _storeMemoryAt(
  AppDatabase appDatabase, {
  required String content,
  required List<String> entities,
  required DateTime createdAt,
  List<String> tags = const <String>['relationship'],
  List<double> embedding = const <double>[0.1, 0.2, 0.3],
}) async {
  final ChatMessageRecord message = await _storeMemory(
    appDatabase,
    content: content,
    entities: entities,
    tags: tags,
    embedding: embedding,
  );

  await (appDatabase.update(appDatabase.messages)
        ..where((Messages row) => row.id.equals(message.id)))
      .write(MessagesCompanion(createdAt: Value<DateTime>(createdAt.toUtc())));

  final Memory memory =
      await (appDatabase.select(appDatabase.memories)
            ..where((Memories row) => row.sourceMessageId.equals(message.id)))
          .getSingle();
  await (appDatabase.update(appDatabase.memories)
        ..where((Memories row) => row.id.equals(memory.id)))
      .write(MemoriesCompanion(createdAt: Value<DateTime>(createdAt.toUtc())));

  return message.copyWith(createdAt: createdAt.toLocal());
}

Future<ChatMessageRecord> _storeDocumentAttachment(
  AppDatabase appDatabase, {
  required String displayName,
  required String rawText,
  required String summary,
  required DateTime createdAt,
}) async {
  final ChatMessageRecord message = await appDatabase.insertMessage(
    role: ChatMessageRole.user,
    content: '',
  );
  final String summaryMemoryId = await appDatabase.insertMemoryPlan(
    sourceMessageId: message.id,
    memoryWritePlan: MemoryWritePlan(
      content: summary,
      tags: const <String>['document'],
      entities: const <String>[],
      embedding: const <double>[1.0, 0.0, 0.0],
    ),
  );
  await appDatabase
      .into(appDatabase.attachments)
      .insert(
        AttachmentsCompanion.insert(
          id: '${displayName}_attachment',
          messageId: message.id,
          kind: 'document',
          displayName: Value<String>(displayName),
          mimeType: const Value<String>('text/plain'),
          byteSize: Value<int>(rawText.length),
          status: const Value<String>('ready'),
          localPath: Value<String>('attachments/$displayName'),
          rawText: Value<String>(rawText),
          summary: Value<String>(summary),
          summaryMemoryId: Value<String>(summaryMemoryId),
          createdAt: createdAt.toUtc(),
        ),
      );

  await (appDatabase.update(appDatabase.messages)
        ..where((Messages row) => row.id.equals(message.id)))
      .write(MessagesCompanion(createdAt: Value<DateTime>(createdAt.toUtc())));

  await (appDatabase.update(appDatabase.memories)
        ..where((Memories row) => row.id.equals(summaryMemoryId)))
      .write(MemoriesCompanion(createdAt: Value<DateTime>(createdAt.toUtc())));

  return message.copyWith(createdAt: createdAt.toLocal());
}
