import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heyo_rebuild_app/features/chat/application/attachment_ingestion_service.dart';
import 'package:heyo_rebuild_app/features/chat/data/chat_api_client.dart';
import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';

void main() {
  group('AttachmentIngestionService', () {
    test('extracts txt and stores a ready attachment', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'heyo_attachment_txt',
      );
      addTearDown(() => tempDirectory.deleteSync(recursive: true));
      final File textFile = File('${tempDirectory.path}/rita.txt');
      await textFile.writeAsString('Rita keeps a Bhutan note here.');

      final ChatMessageRecord message = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: '',
      );
      final _FakeAttachmentApiClient fakeChatApiClient =
          _FakeAttachmentApiClient();
      final AttachmentIngestionService service = AttachmentIngestionService(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await service.ingestAttachments(
        messageId: message.id,
        messageText: '',
        pendingAttachments: <PendingAttachmentDraft>[
          PendingAttachmentDraft(
            id: 'attachment-txt',
            kind: ChatAttachmentKind.document,
            displayName: 'rita.txt',
            mimeType: 'text/plain',
            localPath: textFile.path,
            byteSize: textFile.lengthSync(),
          ),
        ],
      );

      final List<ChatAttachmentRecord> attachments = await appDatabase
          .fetchAttachmentsForMessage(message.id);
      expect(attachments, hasLength(1));
      expect(attachments.single.status, ChatAttachmentStatus.ready);
      expect(attachments.single.rawText, 'Rita keeps a Bhutan note here.');
      expect(attachments.single.summaryMemoryId, isNotNull);
    });

    test('extracts markdown and docx locally before inspect', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'heyo_attachment_docx',
      );
      addTearDown(() => tempDirectory.deleteSync(recursive: true));

      final File markdownFile = File('${tempDirectory.path}/notes.md');
      await markdownFile.writeAsString(
        '## Rita\nBhutan appeared in the notes.',
      );

      final File docxFile = File('${tempDirectory.path}/notes.docx');
      await docxFile.writeAsBytes(
        _buildDocxBytes('Rita also wrote about Bhutan in the docx file.'),
      );

      final ChatMessageRecord message = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: '',
      );
      final _FakeAttachmentApiClient fakeChatApiClient =
          _FakeAttachmentApiClient();
      final AttachmentIngestionService service = AttachmentIngestionService(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await service.ingestAttachments(
        messageId: message.id,
        messageText: '',
        pendingAttachments: <PendingAttachmentDraft>[
          PendingAttachmentDraft(
            id: 'attachment-md',
            kind: ChatAttachmentKind.document,
            displayName: 'notes.md',
            mimeType: 'text/markdown',
            localPath: markdownFile.path,
            byteSize: markdownFile.lengthSync(),
          ),
          PendingAttachmentDraft(
            id: 'attachment-docx',
            kind: ChatAttachmentKind.document,
            displayName: 'notes.docx',
            mimeType:
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            localPath: docxFile.path,
            byteSize: docxFile.lengthSync(),
          ),
        ],
      );

      expect(fakeChatApiClient.inspectedAttachments, hasLength(2));
      expect(
        fakeChatApiClient.inspectedAttachments.first.documentText,
        contains('Bhutan'),
      );
      expect(
        fakeChatApiClient.inspectedAttachments.last.documentText,
        contains('Bhutan in the docx file'),
      );
    });

    test(
      'uses the pdf extractor seam and stores a ready pdf attachment',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);
        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'heyo_attachment_pdf',
        );
        addTearDown(() => tempDirectory.deleteSync(recursive: true));
        final File pdfFile = File('${tempDirectory.path}/notes.pdf');
        await pdfFile.writeAsBytes(const <int>[1, 2, 3, 4]);

        final ChatMessageRecord message = await appDatabase.insertMessage(
          role: ChatMessageRole.user,
          content: '',
        );
        final AttachmentIngestionService service = AttachmentIngestionService(
          appDatabase: appDatabase,
          chatApiClient: _FakeAttachmentApiClient(),
          pdfEmbeddedTextExtractor: const _FakePdfEmbeddedTextExtractor(
            'Embedded PDF text about Rita and Bhutan.',
          ),
        );

        await service.ingestAttachments(
          messageId: message.id,
          messageText: '',
          pendingAttachments: <PendingAttachmentDraft>[
            PendingAttachmentDraft(
              id: 'attachment-pdf',
              kind: ChatAttachmentKind.document,
              displayName: 'notes.pdf',
              mimeType: 'application/pdf',
              localPath: pdfFile.path,
              byteSize: pdfFile.lengthSync(),
            ),
          ],
        );

        final List<ChatAttachmentRecord> attachments = await appDatabase
            .fetchAttachmentsForMessage(message.id);
        expect(attachments.single.status, ChatAttachmentStatus.ready);
        expect(
          attachments.single.rawText,
          'Embedded PDF text about Rita and Bhutan.',
        );
      },
    );

    test(
      'failed extraction stores a failed attachment without memory',
      () async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);
        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'heyo_attachment_fail',
        );
        addTearDown(() => tempDirectory.deleteSync(recursive: true));
        final File pdfFile = File('${tempDirectory.path}/empty.pdf');
        await pdfFile.writeAsBytes(const <int>[9, 8, 7, 6]);

        final ChatMessageRecord message = await appDatabase.insertMessage(
          role: ChatMessageRole.user,
          content: '',
        );
        final AttachmentIngestionService service = AttachmentIngestionService(
          appDatabase: appDatabase,
          chatApiClient: _FakeAttachmentApiClient(),
          pdfEmbeddedTextExtractor: const _FakePdfEmbeddedTextExtractor(''),
        );

        await service.ingestAttachments(
          messageId: message.id,
          messageText: '',
          pendingAttachments: <PendingAttachmentDraft>[
            PendingAttachmentDraft(
              id: 'attachment-empty-pdf',
              kind: ChatAttachmentKind.document,
              displayName: 'empty.pdf',
              mimeType: 'application/pdf',
              localPath: pdfFile.path,
              byteSize: pdfFile.lengthSync(),
            ),
          ],
        );

        final List<ChatAttachmentRecord> attachments = await appDatabase
            .fetchAttachmentsForMessage(message.id);
        expect(attachments.single.status, ChatAttachmentStatus.failed);
        expect(attachments.single.summaryMemoryId, isNull);

        final List<RetrievedMemory> matches = await appDatabase
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
                  allowDeletedFallback: false,
                  keywordTerms: <String>['Bhutan'],
                  entityFilters: <String>[],
                  tagFilters: <String>[],
                  timeFilters: <String>[],
                ),
              ),
            );
        expect(matches, isEmpty);
      },
    );
  });
}

class _FakeAttachmentApiClient extends ChatApiClient {
  final List<AttachmentInspectRequestItem> inspectedAttachments =
      <AttachmentInspectRequestItem>[];

  @override
  Future<List<AttachmentInspectResult>> inspectAttachments({
    required String messageText,
    required List<AttachmentInspectRequestItem> attachments,
  }) async {
    inspectedAttachments.addAll(attachments);
    return attachments
        .map((AttachmentInspectRequestItem attachment) {
          final String summary = 'Summary for ${attachment.fileName}';
          return AttachmentInspectResult(
            clientAttachmentId: attachment.clientAttachmentId,
            kind: attachment.kind,
            status: ChatAttachmentStatus.ready,
            summary: summary,
            failureReason: null,
            memoryWritePlan: MemoryWritePlan(
              content: summary,
              tags: attachment.kind == ChatAttachmentKind.image
                  ? const <String>['image']
                  : const <String>['document'],
              entities: const <String>[],
              embedding: const <double>[1.0, 0.0, 0.0],
            ),
          );
        })
        .toList(growable: false);
  }
}

class _FakePdfEmbeddedTextExtractor implements PdfEmbeddedTextExtractor {
  final String text;

  const _FakePdfEmbeddedTextExtractor(this.text);

  @override
  Future<String> extractText(String filePath) async {
    return text;
  }
}

List<int> _buildDocxBytes(String textContent) {
  final Archive archive = Archive();
  final List<int> xmlBytes = utf8.encode(
    '<document><body><p><r><t>$textContent</t></r></p></body></document>',
  );
  archive.addFile(ArchiveFile('word/document.xml', xmlBytes.length, xmlBytes));
  return ZipEncoder().encode(archive);
}
