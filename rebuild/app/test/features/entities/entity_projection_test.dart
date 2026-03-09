import 'package:flutter_test/flutter_test.dart';

import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';
import 'package:heyo_rebuild_app/features/entities/domain/entity_models.dart';

void main() {
  group('Entity projection', () {
    test(
      'first canon memory creates a soft entity and second promotes it',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemory(
          appDatabase,
          content: "Rita's instagram handle is @rita",
          entities: const <String>['Rita'],
        );

        final String entityId = (await appDatabase.findEntityIdByReference(
          'Rita',
        ))!;
        EntityDetailRecord? detail = await appDatabase.fetchEntityDetail(
          entityId,
        );

        expect(detail, isNotNull);
        expect(detail!.mentionCount, 1);
        expect(detail.isPromoted, isFalse);
        expect(await appDatabase.fetchPromotedEntities(), isEmpty);

        await _storeMemory(
          appDatabase,
          content: 'Rita is planning a trip next month',
          entities: const <String>['Rita'],
        );

        detail = await appDatabase.fetchEntityDetail(entityId);
        final promoted = await appDatabase.fetchPromotedEntities();

        expect(detail, isNotNull);
        expect(detail!.mentionCount, 2);
        expect(detail.isPromoted, isTrue);
        expect(promoted, hasLength(1));
        expect(promoted.single.name, 'Rita');
      },
    );

    test(
      'two new canon memories after a saved summary mark the entity stale',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        await _storeMemory(
          appDatabase,
          content: 'Rita started a new job in January',
          entities: const <String>['Rita'],
        );
        await _storeMemory(
          appDatabase,
          content: 'Rita met her new team last week',
          entities: const <String>['Rita'],
        );

        final String entityId = (await appDatabase.findEntityIdByReference(
          'Rita',
        ))!;
        await appDatabase.updateEntitySummary(
          entityId: entityId,
          summary: 'Rita started a new job and is settling in.',
        );

        await _storeMemory(
          appDatabase,
          content: 'Rita got her first big project assignment',
          entities: const <String>['Rita'],
        );
        await _storeMemory(
          appDatabase,
          content: 'Rita is waiting to hear back from the project lead',
          entities: const <String>['Rita'],
        );

        final detail = await appDatabase.fetchEntityDetail(entityId);

        expect(detail, isNotNull);
        expect(detail!.summary, 'Rita started a new job and is settling in.');
        expect(detail.summaryMemoryCount, 2);
        expect(detail.mentionCount, 4);
        expect(detail.isSummaryStale, isTrue);
      },
    );

    test(
      'edit replacement removes the old canon memory from entity projection',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        final ChatMessageRecord message = await _storeMemory(
          appDatabase,
          content: "Rita's instagram handle is @rita",
          entities: const <String>['Rita'],
        );

        await appDatabase.replaceMemoryPlansForMessage(
          sourceMessageId: message.id,
          memoryWritePlans: const <MemoryWritePlan>[
            MemoryWritePlan(
              content: "Rita's instagram handle is @riya",
              tags: <String>['relationship'],
              entities: <String>['Rita'],
              embedding: <double>[0.2, 0.3, 0.4],
            ),
          ],
        );

        final String entityId = (await appDatabase.findEntityIdByReference(
          'Rita',
        ))!;
        final detail = await appDatabase.fetchEntityDetail(entityId);

        expect(detail, isNotNull);
        expect(detail!.mentionCount, 1);
        expect(detail.linkedMemories, hasLength(1));
        expect(
          detail.linkedMemories.single.content,
          "Rita's instagram handle is @riya",
        );
        expect(
          detail.linkedMemories.any(
            (EntityLinkedMemoryRecord memory) =>
                memory.content.contains('@rita'),
          ),
          isFalse,
        );
      },
    );

    test(
      'soft delete removes linked memories from entity detail and canon state',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);

        final ChatMessageRecord firstMessage = await _storeMemory(
          appDatabase,
          content: 'Rita started a new job',
          entities: const <String>['Rita'],
        );
        final ChatMessageRecord secondMessage = await _storeMemory(
          appDatabase,
          content: 'Rita is waiting to hear back from her manager',
          entities: const <String>['Rita'],
        );

        final String entityId = (await appDatabase.findEntityIdByReference(
          'Rita',
        ))!;
        await appDatabase.updateEntitySummary(
          entityId: entityId,
          summary:
              'Rita recently changed jobs and is waiting on a manager update.',
        );

        await appDatabase.softDeleteMessage(secondMessage.id);

        final detail = await appDatabase.fetchEntityDetail(entityId);

        expect(firstMessage.id, isNot(secondMessage.id));
        expect(detail, isNotNull);
        expect(detail!.mentionCount, 1);
        expect(detail.isPromoted, isFalse);
        expect(detail.linkedMemories, hasLength(1));
        expect(detail.linkedMemories.single.content, 'Rita started a new job');
        expect(detail.summary?.trim() ?? '', isEmpty);
      },
    );

    test('alias resolution maps Rita, rita, and @rita to one entity', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      await _storeMemory(
        appDatabase,
        content: "Rita's instagram handle is @rita",
        entities: const <String>['@rita'],
      );
      await _storeMemory(
        appDatabase,
        content: 'rita moved to Penang',
        entities: const <String>['rita'],
      );
      await _storeMemory(
        appDatabase,
        content: 'Rita likes the quieter pace there',
        entities: const <String>['Rita'],
      );

      final String? canonicalId = await appDatabase.findEntityIdByReference(
        'Rita',
      );
      final String? lowercaseId = await appDatabase.findEntityIdByReference(
        'rita',
      );
      final String? handleId = await appDatabase.findEntityIdByReference(
        '@rita',
      );
      final detail = await appDatabase.fetchEntityDetail(canonicalId!);

      expect(canonicalId, isNotNull);
      expect(lowercaseId, canonicalId);
      expect(handleId, canonicalId);
      expect(detail, isNotNull);
      expect(detail!.aliases, containsAll(<String>['@rita', 'rita']));
      expect(await appDatabase.fetchPromotedEntities(), hasLength(1));
    });
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
