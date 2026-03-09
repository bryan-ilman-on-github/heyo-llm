import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heyo_rebuild_app/core/export/local_data_export_service.dart';
import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';

void main() {
  group('LocalDataExportService', () {
    test('builds preview JSON with raw text and full embeddings', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      final ChatMessageRecord userMessage = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: "Rita's instagram handle is @rita",
      );
      await appDatabase.insertMemoryPlan(
        sourceMessageId: userMessage.id,
        memoryWritePlan: const MemoryWritePlan(
          content: "Rita's instagram handle is @rita",
          tags: <String>['relationship'],
          entities: <String>['Rita'],
          embedding: <double>[0.1, 0.2, 0.3],
        ),
      );
      await appDatabase.into(appDatabase.attachments).insert(
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

      final LocalDataExportService exportService = LocalDataExportService(
        appDatabase: appDatabase,
        clientId: 'client-export',
        exportDirectoryProvider: _TestExportDirectoryProvider(
          await Directory.systemTemp.createTemp('heyo_export_preview'),
        ),
      );

      final LocalExportPreview preview = await exportService.buildPreview();
      final Map<String, Object?> payload = preview.payload;
      final Map<String, Object?> data =
          payload['data'] as Map<String, Object?>;
      final List<dynamic> attachments = data['attachments'] as List<dynamic>;
      final List<dynamic> embeddingVectors =
          data['embedding_vectors'] as List<dynamic>;

      expect(payload['schema_version'], 3);
      expect(payload['client_id'], 'client-export');
      expect((attachments.single as Map<String, Object?>)['raw_text'], 'Rita full note text');
      expect(
        (embeddingVectors.single as Map<String, Object?>)['vector'],
        containsAllInOrder(<Matcher>[
          closeTo(0.1, 0.000001),
          closeTo(0.2, 0.000001),
          closeTo(0.3, 0.000001),
        ]),
      );
      expect(preview.prettyJson, contains('"client_id": "client-export"'));
    });

    test('saves preview to a timestamped json file', () async {
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'heyo_export_save',
      );
      addTearDown(() => tempDirectory.deleteSync(recursive: true));
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);

      final LocalDataExportService exportService = LocalDataExportService(
        appDatabase: appDatabase,
        clientId: 'client-save',
        exportDirectoryProvider: _TestExportDirectoryProvider(tempDirectory),
      );
      final LocalExportPreview preview = await exportService.buildPreview();

      final String savedFilePath = await exportService.savePreview(preview);
      final File outputFile = File(savedFilePath);

      expect(outputFile.existsSync(), isTrue);
      expect(savedFilePath, endsWith('.json'));
      expect(outputFile.readAsStringSync(), preview.prettyJson);
    });
  });
}

class _TestExportDirectoryProvider implements ExportDirectoryProvider {
  final Directory directory;

  const _TestExportDirectoryProvider(this.directory);

  @override
  Future<Directory> resolveDirectory() async {
    return directory;
  }
}
