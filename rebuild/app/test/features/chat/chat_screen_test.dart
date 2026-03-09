import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:heyo_rebuild_app/core/export/local_data_export_service.dart';
import 'package:heyo_rebuild_app/features/chat/data/chat_api_client.dart';
import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';
import 'package:heyo_rebuild_app/features/chat/presentation/chat_controller.dart';
import 'package:heyo_rebuild_app/features/chat/presentation/chat_screen.dart';
import 'package:heyo_rebuild_app/features/entities/domain/entity_models.dart';

void main() {
  group('ChatController', () {
    test('editMessage keeps only the latest canon content', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareDecisionsByMessage: <String, PrepareDecision>{
          "Rita's instagram handle is @rita": _memoryOnlyDecision(
            content: "Rita's instagram handle is @rita",
            tags: const <String>['relationship'],
            entities: const <String>['Rita'],
            literalTerms: const <String>['instagram', '@rita'],
            embedding: const <double>[0.1, 0.2, 0.3],
          ),
          "Rita's instagram handle is @riya": _memoryOnlyDecision(
            content: "Rita's instagram handle is @riya",
            tags: const <String>['relationship'],
            entities: const <String>['Rita'],
            literalTerms: const <String>['instagram', '@riya'],
            embedding: const <double>[0.4, 0.5, 0.6],
          ),
        },
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await chatController.submitMessage("Rita's instagram handle is @rita");

      final String messageId = chatController.messages.single.id;
      await chatController.editMessage(
        messageId: messageId,
        newContent: "Rita's instagram handle is @riya",
      );

      final List<RetrievedMemory> oldMatches = await appDatabase
          .retrieveMemories(
            prepareDecision: _queryDecision(
              literalTerms: const <String>['@rita'],
            ),
          );
      final List<RetrievedMemory> newMatches = await appDatabase
          .retrieveMemories(
            prepareDecision: _queryDecision(
              literalTerms: const <String>['@riya'],
            ),
          );

      expect(
        chatController.messages.single.content,
        "Rita's instagram handle is @riya",
      );
      expect(chatController.messages.single.isEdited, isTrue);
      expect(
        oldMatches.any(
          (RetrievedMemory memory) => memory.content.contains('@rita'),
        ),
        isFalse,
      );
      expect(newMatches, hasLength(1));
      expect(newMatches.single.content, "Rita's instagram handle is @riya");
    });

    test('deleteMessage removes memories from canon retrieval', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareDecisionsByMessage: <String, PrepareDecision>{
          'Bhutan trip was amazing': _memoryOnlyDecision(
            content: 'Bhutan trip was amazing',
            tags: const <String>['travel', 'positive'],
            entities: const <String>['Bhutan'],
            literalTerms: const <String>['Bhutan'],
            embedding: const <double>[0.7, 0.8, 0.9],
          ),
        },
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await chatController.submitMessage('Bhutan trip was amazing');

      final String messageId = chatController.messages.single.id;
      await chatController.deleteMessage(messageId);

      final List<RetrievedMemory> matches = await appDatabase.retrieveMemories(
        prepareDecision: _queryDecision(literalTerms: const <String>['Bhutan']),
      );

      expect(
        matches.any(
          (RetrievedMemory memory) => memory.content.contains('Bhutan'),
        ),
        isFalse,
      );
      expect(chatController.messages, isEmpty);
    });

    test('addPendingAttachments rejects the eleventh image', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.addPendingAttachments(
        List<PendingAttachmentDraft>.generate(11, (int index) {
          return PendingAttachmentDraft(
            id: 'image-$index',
            kind: ChatAttachmentKind.image,
            displayName: 'image_$index.png',
            mimeType: 'image/png',
            localPath: 'images/image_$index.png',
            byteSize: 1024,
          );
        }),
      );

      expect(chatController.pendingAttachments, isEmpty);
      expect(
        chatController.errorMessage,
        'You can attach up to 10 images in one message.',
      );
    });

    test('submitMessage supports attachment only messages', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'heyo_chat_attachment_controller',
      );
      addTearDown(() => tempDirectory.deleteSync(recursive: true));
      final File textFile = File('${tempDirectory.path}/note.txt');
      await textFile.writeAsString('Rita mentioned Bhutan in this note.');

      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.addPendingAttachments(<PendingAttachmentDraft>[
        PendingAttachmentDraft(
          id: 'attachment-note',
          kind: ChatAttachmentKind.document,
          displayName: 'note.txt',
          mimeType: 'text/plain',
          localPath: textFile.path,
          byteSize: textFile.lengthSync(),
        ),
      ]);
      await chatController.loadInitialState();
      await chatController.submitMessage('');

      expect(chatController.messages, hasLength(1));
      expect(chatController.messages.single.attachments, hasLength(1));
      expect(
        chatController.messages.single.attachments.single.displayName,
        'note.txt',
      );
      expect(chatController.memoryConfirmations, isNotEmpty);
      expect(fakeChatApiClient.inspectedAttachments, hasLength(1));
    });

    test('submitMessage surfaces quota exhaustion from attachment inspect', () async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'heyo_chat_attachment_quota',
      );
      addTearDown(() => tempDirectory.deleteSync(recursive: true));
      final File textFile = File('${tempDirectory.path}/note.txt');
      await textFile.writeAsString('Rita mentioned Bhutan in this note.');

      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        inspectError: _quotaExceededError(),
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.addPendingAttachments(<PendingAttachmentDraft>[
        PendingAttachmentDraft(
          id: 'attachment-note',
          kind: ChatAttachmentKind.document,
          displayName: 'note.txt',
          mimeType: 'text/plain',
          localPath: textFile.path,
          byteSize: textFile.lengthSync(),
        ),
      ]);

      await chatController.submitMessage('');

      expect(chatController.errorMessage, contains('Daily quota exhausted'));
    });
  });

  group('ChatScreen', () {
    testWidgets('shows the empty state before messages exist', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));
      await tester.pumpAndSettle();

      expect(find.text('Heyo'), findsAtLeastNWidgets(1));
      expect(
        find.text('One continuous chat for memory, recall, and reflection.'),
        findsOneWidget,
      );
      expect(find.text("Rita's instagram handle is @rita"), findsOneWidget);
    });

    testWidgets('stores a memory only message and shows confirmation', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareDecision: PrepareDecision(
          outcome: PrepareOutcome.memoryOnly,
          assistantDraft: '',
          tags: const <String>['relationship'],
          entities: const <String>['Rita'],
          literalTerms: const <String>['instagram', '@rita'],
          timeFilters: const <String>[],
          queryEmbedding: null,
          clarificationPrompt: null,
          memoryWritePlans: const <MemoryWritePlan>[
            MemoryWritePlan(
              content: "Rita's instagram handle is @rita",
              tags: <String>['relationship'],
              entities: <String>['Rita'],
              embedding: <double>[0.1, 0.2, 0.3],
            ),
          ],
          retrievalPlan: _retrievalPlan(
            outcome: PrepareOutcome.memoryOnly,
            tags: const <String>['relationship'],
            entities: const <String>['Rita'],
            literalTerms: const <String>['instagram', '@rita'],
          ),
        ),
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));

      await tester.enterText(
        find.byType(TextField).first,
        "Rita's instagram handle is @rita",
      );
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text("Rita's instagram handle is @rita"), findsWidgets);
      expect(find.text('Memory stored'), findsOneWidget);
    });

    testWidgets('opens quota and export from the header overflow', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quota & export'));
      await tester.pumpAndSettle();

      expect(find.text('Quota & Export'), findsOneWidget);
      expect(find.textContaining('remaining of'), findsOneWidget);
    });

    testWidgets('shows quota exhaustion when prepare is blocked', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareError: _quotaExceededError(),
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));

      await tester.enterText(find.byType(TextField).first, 'Do you remember Rita?');
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('Daily quota exhausted'), findsOneWidget);
    });

    testWidgets('renders attachment chips for loaded messages', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      final ChatMessageRecord message = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: '',
      );
      await appDatabase
          .into(appDatabase.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'attachment-note',
              messageId: message.id,
              kind: 'document',
              displayName: const Value<String>('note.txt'),
              mimeType: const Value<String>('text/plain'),
              byteSize: const Value<int>(128),
              status: const Value<String>('ready'),
              localPath: const Value<String>('attachments/note.txt'),
              rawText: const Value<String>(
                'Rita mentioned Bhutan in this note.',
              ),
              summary: const Value<String>('Summary for note.txt'),
              createdAt: DateTime.now().toUtc(),
            ),
          );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));
      await tester.pumpAndSettle();

      expect(find.text('note.txt'), findsOneWidget);
    });

    testWidgets(
      'opens the entity directory from the header with promoted entities',
      (WidgetTester tester) async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);
        final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
        final ChatController chatController = ChatController(
          appDatabase: appDatabase,
          chatApiClient: fakeChatApiClient,
        );

        await _storeMemory(
          appDatabase,
          content: 'Rita started a new job in January',
          entities: const <String>['Rita'],
        );
        await _storeMemory(
          appDatabase,
          content: 'Rita is waiting to hear back about her first project',
          entities: const <String>['Rita'],
        );

        await chatController.loadInitialState();
        await tester.pumpWidget(_TestHarness(chatController: chatController));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Entities'));
        await tester.pumpAndSettle();

        expect(find.text('Entities'), findsOneWidget);
        expect(find.text('Rita'), findsWidgets);
        expect(find.textContaining('2 mentions'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a confirmation entity opens detail and fetches a summary',
      (WidgetTester tester) async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);
        final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
          prepareDecisionsByMessage: <String, PrepareDecision>{
            "Rita's instagram handle is @rita": _memoryOnlyDecision(
              content: "Rita's instagram handle is @rita",
              tags: const <String>['relationship'],
              entities: const <String>['Rita'],
              literalTerms: const <String>['instagram', '@rita'],
              embedding: const <double>[0.1, 0.2, 0.3],
            ),
          },
          entitySummariesByName: const <String, String>{
            'Rita':
                'Rita appears in 1 canon memory. Chronology: Rita\'s instagram handle is @rita. Current status: the latest grounded update is Rita\'s instagram handle is @rita. Emotional tone: neutral or factual. Open loops: No explicit open loop is recorded.',
          },
        );
        final ChatController chatController = ChatController(
          appDatabase: appDatabase,
          chatApiClient: fakeChatApiClient,
        );

        await chatController.loadInitialState();
        await tester.pumpWidget(_TestHarness(chatController: chatController));

        await tester.enterText(
          find.byType(TextField).first,
          "Rita's instagram handle is @rita",
        );
        await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ActionChip, 'Rita'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Rita'), findsWidgets);
        expect(find.text('Linked memories'), findsOneWidget);
        expect(
          find.textContaining('Rita appears in 1 canon memory.'),
          findsOneWidget,
        );
        expect(find.text("Rita's instagram handle is @rita"), findsWidgets);
        expect(fakeChatApiClient.summarizedEntities, contains('Rita'));
      },
    );

    testWidgets(
      'entity detail surfaces quota exhaustion during summary refresh',
      (WidgetTester tester) async {
        final AppDatabase appDatabase = AppDatabase.inMemory();
        addTearDown(appDatabase.close);
        final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
          prepareDecisionsByMessage: <String, PrepareDecision>{
            "Rita's instagram handle is @rita": _memoryOnlyDecision(
              content: "Rita's instagram handle is @rita",
              tags: const <String>['relationship'],
              entities: const <String>['Rita'],
              literalTerms: const <String>['instagram', '@rita'],
              embedding: const <double>[0.1, 0.2, 0.3],
            ),
          },
          entitySummaryError: _quotaExceededError(),
        );
        final ChatController chatController = ChatController(
          appDatabase: appDatabase,
          chatApiClient: fakeChatApiClient,
        );

        await chatController.loadInitialState();
        await tester.pumpWidget(_TestHarness(chatController: chatController));

        await tester.enterText(
          find.byType(TextField).first,
          "Rita's instagram handle is @rita",
        );
        await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ActionChip, 'Rita'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.textContaining('Daily quota exhausted'), findsOneWidget);
      },
    );

    testWidgets('renders edited user messages', (WidgetTester tester) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      final ChatMessageRecord message = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: "Rita's instagram handle is @rita",
      );
      await appDatabase.editMessage(
        messageId: message.id,
        newContent: "Rita's instagram handle is @riya",
      );
      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));
      await tester.pumpAndSettle();

      expect(find.text("Rita's instagram handle is @riya"), findsWidgets);
      expect(find.text('(edited)'), findsOneWidget);
      expect(find.text("Rita's instagram handle is @rita"), findsNothing);
    });

    testWidgets('does not render soft deleted messages from loaded history', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient();
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      final ChatMessageRecord message = await appDatabase.insertMessage(
        role: ChatMessageRole.user,
        content: 'Bhutan trip was amazing',
      );
      await appDatabase.softDeleteMessage(message.id);
      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));
      await tester.pumpAndSettle();

      expect(find.text('Bhutan trip was amazing'), findsNothing);
      expect(chatController.messages, isEmpty);
    });

    testWidgets('persists paired assistant message ids across reload', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareDecisionsByMessage: <String, PrepareDecision>{
          'Do you know Rita\'s instagram handle?': _queryDecision(
            entities: const <String>['Rita'],
            literalTerms: const <String>['instagram', '@rita'],
            queryEmbedding: const <double>[0.2, 0.3, 0.4],
          ),
        },
        responseChunksByMessage: <String, List<String>>{
          'Do you know Rita\'s instagram handle?': const <String>[
            'Rita uses @rita on instagram.',
          ],
        },
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));

      await tester.enterText(
        find.byType(TextField).first,
        'Do you know Rita\'s instagram handle?',
      );
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pumpAndSettle();

      ChatMessageRecord userMessage = chatController.messages.first;
      ChatMessageRecord assistantMessage = chatController.messages.last;

      expect(userMessage.pairedMessageId, assistantMessage.id);
      expect(assistantMessage.pairedMessageId, userMessage.id);

      await chatController.loadInitialState();
      await tester.pump();
      await tester.pumpAndSettle();

      userMessage = chatController.messages.first;
      assistantMessage = chatController.messages.last;

      expect(userMessage.pairedMessageId, assistantMessage.id);
      expect(assistantMessage.pairedMessageId, userMessage.id);
    });

    testWidgets('shows clarification choices when prepare asks for it', (
      WidgetTester tester,
    ) async {
      final AppDatabase appDatabase = AppDatabase.inMemory();
      addTearDown(appDatabase.close);
      final _FakeChatApiClient fakeChatApiClient = _FakeChatApiClient(
        prepareDecision: PrepareDecision(
          outcome: PrepareOutcome.clarify,
          assistantDraft: '',
          tags: const <String>['planning'],
          entities: const <String>[],
          literalTerms: const <String>['March', 'dentist'],
          timeFilters: const <String>['March'],
          queryEmbedding: const <double>[0.2, 0.3, 0.4],
          clarificationPrompt: const ClarificationPrompt(
            title: 'Store this or answer it?',
            message:
                'This could be a memory to keep or a question that needs an answer.',
            originalText: 'March 12, 3pm dentist.',
          ),
          memoryWritePlans: const <MemoryWritePlan>[
            MemoryWritePlan(
              content: 'March 12, 3pm dentist.',
              tags: <String>['planning'],
              entities: <String>[],
              embedding: <double>[0.2, 0.3, 0.4],
            ),
          ],
          retrievalPlan: _retrievalPlan(
            outcome: PrepareOutcome.clarify,
            tags: const <String>['planning'],
            literalTerms: const <String>['March', 'dentist'],
            timeFilters: const <String>['March'],
          ),
        ),
      );
      final ChatController chatController = ChatController(
        appDatabase: appDatabase,
        chatApiClient: fakeChatApiClient,
      );

      await chatController.loadInitialState();
      await tester.pumpWidget(_TestHarness(chatController: chatController));

      await tester.enterText(
        find.byType(TextField).first,
        'March 12, 3pm dentist.',
      );
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Store this or answer it?'), findsOneWidget);
      expect(find.text('Store memory'), findsOneWidget);
      expect(find.text('Ask question'), findsOneWidget);
    });
  });
}

class _TestHarness extends StatelessWidget {
  final ChatController chatController;

  const _TestHarness({required this.chatController});

  @override
  Widget build(BuildContext context) {
    final LocalDataExportService resolvedExportService = LocalDataExportService(
      appDatabase: chatController.appDatabase,
      clientId: chatController.chatApiClient.clientId,
    );

    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: chatController.appDatabase),
        Provider<ChatApiClient>.value(value: chatController.chatApiClient),
        Provider<LocalDataExportService>.value(value: resolvedExportService),
        ChangeNotifierProvider<ChatController>.value(value: chatController),
      ],
      child: const MaterialApp(home: ChatScreen()),
    );
  }
}

class _FakeChatApiClient extends ChatApiClient {
  final PrepareDecision? prepareDecision;
  final Map<String, PrepareDecision> prepareDecisionsByMessage;
  final Map<String, List<String>> responseChunksByMessage;
  final Map<String, String> entitySummariesByName;
  final Object? prepareError;
  final Object? inspectError;
  final Object? entitySummaryError;
  final List<String> summarizedEntities = <String>[];
  final List<AttachmentInspectRequestItem> inspectedAttachments =
      <AttachmentInspectRequestItem>[];

  _FakeChatApiClient({
    this.prepareDecision,
    this.prepareDecisionsByMessage = const <String, PrepareDecision>{},
    this.responseChunksByMessage = const <String, List<String>>{},
    this.entitySummariesByName = const <String, String>{},
    this.prepareError,
    this.inspectError,
    this.entitySummaryError,
  });

  @override
  Future<PrepareDecision> prepare({
    required String message,
    required List<ChatMessageRecord> recentMessages,
  }) async {
    if (prepareError != null) {
      throw prepareError!;
    }
    if (prepareDecisionsByMessage.containsKey(message)) {
      return prepareDecisionsByMessage.getValue(message);
    }

    return prepareDecision ??
        PrepareDecision(
          outcome: PrepareOutcome.query,
          assistantDraft: '',
          tags: const <String>[],
          entities: const <String>[],
          literalTerms: const <String>[],
          timeFilters: const <String>[],
          queryEmbedding: const <double>[0.1, 0.2, 0.3],
          clarificationPrompt: null,
          memoryWritePlans: const <MemoryWritePlan>[],
          retrievalPlan: _retrievalPlan(outcome: PrepareOutcome.query),
        );
  }

  @override
  Stream<String> respond({
    required String message,
    required PrepareDecision prepareDecision,
    required List<RetrievedMemory> retrievedMemories,
  }) async* {
    final List<String> chunks =
        responseChunksByMessage[message] ??
        const <String>['Here is a grounded answer.'];
    for (final String chunk in chunks) {
      yield chunk;
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Future<List<AttachmentInspectResult>> inspectAttachments({
    required String messageText,
    required List<AttachmentInspectRequestItem> attachments,
  }) async {
    if (inspectError != null) {
      throw inspectError!;
    }
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
              embedding: const <double>[0.3, 0.2, 0.1],
            ),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<String> summarizeEntity({
    required String entityName,
    required List<String> aliases,
    required List<EntityLinkedMemoryRecord> linkedMemories,
  }) async {
    if (entitySummaryError != null) {
      throw entitySummaryError!;
    }
    summarizedEntities.add(entityName);
    return entitySummariesByName[entityName] ??
        'Summary for $entityName based on ${linkedMemories.length} linked memories.';
  }

  @override
  Future<QuotaSnapshot> fetchQuota() async {
    return const QuotaSnapshot(
      clientId: 'quota-client',
      quotaDay: '2026-03-09',
      dailyLimit: 200,
      totalUsed: 4,
      remainingTotal: 196,
      prepareCount: 1,
      respondCount: 1,
      entitySummaryCount: 1,
      attachmentInspectCount: 1,
      updatedAt: null,
      remainingPrepare: 196,
      remainingRespond: 196,
    );
  }
}

PrepareDecision _memoryOnlyDecision({
  required String content,
  required List<String> tags,
  required List<String> entities,
  required List<String> literalTerms,
  required List<double> embedding,
}) {
  return PrepareDecision(
    outcome: PrepareOutcome.memoryOnly,
    assistantDraft: '',
    tags: tags,
    entities: entities,
    literalTerms: literalTerms,
    timeFilters: const <String>[],
    queryEmbedding: null,
    clarificationPrompt: null,
    memoryWritePlans: <MemoryWritePlan>[
      MemoryWritePlan(
        content: content,
        tags: tags,
        entities: entities,
        embedding: embedding,
      ),
    ],
    retrievalPlan: _retrievalPlan(
      outcome: PrepareOutcome.memoryOnly,
      tags: tags,
      entities: entities,
      literalTerms: literalTerms,
    ),
  );
}

PrepareDecision _queryDecision({
  List<String> tags = const <String>[],
  List<String> entities = const <String>[],
  List<String> literalTerms = const <String>[],
  List<double>? queryEmbedding,
}) {
  return PrepareDecision(
    outcome: PrepareOutcome.query,
    assistantDraft: '',
    tags: tags,
    entities: entities,
    literalTerms: literalTerms,
    timeFilters: const <String>[],
    queryEmbedding: queryEmbedding,
    clarificationPrompt: null,
    memoryWritePlans: const <MemoryWritePlan>[],
    retrievalPlan: _retrievalPlan(
      outcome: PrepareOutcome.query,
      tags: tags,
      entities: entities,
      literalTerms: literalTerms,
    ),
  );
}

RetrievalPlan _retrievalPlan({
  required PrepareOutcome outcome,
  List<String> tags = const <String>[],
  List<String> entities = const <String>[],
  List<String> literalTerms = const <String>[],
  List<String> timeFilters = const <String>[],
}) {
  return RetrievalPlan.fallback(
    outcome: outcome,
    tags: tags,
    entities: entities,
    literalTerms: literalTerms,
    timeFilters: timeFilters,
  );
}

extension _MapGetValue<K, V> on Map<K, V> {
  V getValue(K key) {
    return this[key] as V;
  }
}

QuotaExceededChatApiException _quotaExceededError() {
  const QuotaSnapshot quotaSnapshot = QuotaSnapshot(
    clientId: 'quota-client',
    quotaDay: '2026-03-09',
    dailyLimit: 200,
    totalUsed: 200,
    remainingTotal: 0,
    prepareCount: 60,
    respondCount: 60,
    entitySummaryCount: 40,
    attachmentInspectCount: 40,
    updatedAt: null,
    remainingPrepare: 0,
    remainingRespond: 0,
  );
  return const QuotaExceededChatApiException(
    message: 'Daily quota exhausted for this client. 0 remaining of 200 today.',
    errorCode: 'daily_quota_exceeded',
    quotaSnapshot: quotaSnapshot,
  );
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
