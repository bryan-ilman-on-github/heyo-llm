import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:heyo_rebuild_app/features/chat/data/chat_api_client.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';
import 'package:heyo_rebuild_app/features/entities/domain/entity_models.dart';

void main() {
  group('ChatApiClient', () {
    test('prepare sends client_id in the request body', () async {
      final _RecordingClient recordingClient = _RecordingClient(
        requestHandler: (BaseRequest request, String body) async {
          return Response(
            jsonEncode(<String, Object?>{
              'outcome': 'query',
              'assistant_draft': '',
              'tags': <String>[],
              'entities': <String>['Rita'],
              'literal_terms': <String>['instagram'],
              'time_filters': <String>[],
              'query_embedding': <double>[0.1, 0.2, 0.3],
              'memory_write_plans': <Object>[],
              'retrieval_plan': <String, Object?>{
                'intent_type': 'entity_specific_recall',
                'strategy': 'entity_keyword_hybrid',
                'allow_deleted_fallback': false,
                'keyword_terms': <String>['instagram'],
                'entity_filters': <String>['Rita'],
                'tag_filters': <String>[],
                'time_filters': <String>[],
              },
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        },
      );
      final ChatApiClient chatApiClient = ChatApiClient(
        client: recordingClient,
        clientId: 'client-123',
      );

      final PrepareDecision decision = await chatApiClient.prepare(
        message: "Do you know Rita's instagram handle?",
        recentMessages: const <ChatMessageRecord>[],
      );

      final Map<String, dynamic> payload =
          jsonDecode(recordingClient.recordedBodies.single)
              as Map<String, dynamic>;
      expect(payload['client_id'], 'client-123');
      expect(decision.retrievalPlan.strategy, 'entity_keyword_hybrid');
    });

    test('respond sends client_id and retrieval_plan', () async {
      final _RecordingClient recordingClient = _RecordingClient(
        requestHandler: (BaseRequest request, String body) async {
          return Response.bytes(
            utf8.encode(
              '{"type":"content","delta":"Rita uses @rita."}\n{"type":"done"}\n',
            ),
            200,
            headers: <String, String>{'content-type': 'application/x-ndjson'},
          );
        },
      );
      final ChatApiClient chatApiClient = ChatApiClient(
        client: recordingClient,
        clientId: 'client-456',
      );

      final List<String> deltas = await chatApiClient
          .respond(
            message: "Do you know Rita's instagram handle?",
            prepareDecision: PrepareDecision(
              outcome: PrepareOutcome.query,
              assistantDraft: '',
              tags: const <String>[],
              entities: const <String>['Rita'],
              literalTerms: const <String>['instagram'],
              timeFilters: const <String>[],
              queryEmbedding: const <double>[0.1, 0.2, 0.3],
              clarificationPrompt: null,
              memoryWritePlans: const <MemoryWritePlan>[],
              retrievalPlan: const RetrievalPlan(
                intentType: 'entity_specific_recall',
                strategy: 'entity_keyword_hybrid',
                allowDeletedFallback: false,
                keywordTerms: <String>['instagram'],
                entityFilters: <String>['Rita'],
                tagFilters: <String>[],
                timeFilters: <String>[],
              ),
            ),
            retrievedMemories: <RetrievedMemory>[
              RetrievedMemory(
                id: 'memory-1',
                content: "Rita's instagram handle is @rita",
                tags: <String>['relationship'],
                entities: <String>['Rita'],
                score: 1.0,
                createdAt: DateTime(2026, 3, 8),
              ),
            ],
          )
          .toList();

      final Map<String, dynamic> payload =
          jsonDecode(recordingClient.recordedBodies.single)
              as Map<String, dynamic>;
      expect(payload['client_id'], 'client-456');
      expect(
        (payload['prepare_result'] as Map<String, dynamic>)['retrieval_plan'],
        <String, Object?>{
          'intent_type': 'entity_specific_recall',
          'strategy': 'entity_keyword_hybrid',
          'allow_deleted_fallback': false,
          'keyword_terms': <String>['instagram'],
          'entity_filters': <String>['Rita'],
          'tag_filters': <String>[],
          'time_filters': <String>[],
        },
      );
      expect(deltas, <String>['Rita uses @rita.']);
    });

    test('summarizeEntity sends client_id in the request body', () async {
      final _RecordingClient recordingClient = _RecordingClient(
        requestHandler: (BaseRequest request, String body) async {
          return Response(
            jsonEncode(<String, String>{'summary': 'Grounded entity summary'}),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        },
      );
      final ChatApiClient chatApiClient = ChatApiClient(
        client: recordingClient,
        clientId: 'client-789',
      );

      final String summary = await chatApiClient.summarizeEntity(
        entityName: 'Rita',
        aliases: const <String>['@rita'],
        linkedMemories: <EntityLinkedMemoryRecord>[
          EntityLinkedMemoryRecord(
            id: 'memory-1',
            content: "Rita's instagram handle is @rita",
            tags: <String>['relationship'],
            entities: <String>['Rita'],
            createdAt: DateTime(2026, 3, 8),
          ),
        ],
      );

      final Map<String, dynamic> payload =
          jsonDecode(recordingClient.recordedBodies.single)
              as Map<String, dynamic>;
      expect(payload['client_id'], 'client-789');
      expect(summary, 'Grounded entity summary');
    });

    test('fetchQuota sends client_id as a query parameter', () async {
      final _RecordingClient recordingClient = _RecordingClient(
        requestHandler: (BaseRequest request, String body) async {
          return Response(
            jsonEncode(<String, Object?>{
              'client_id': 'quota-client',
              'quota_day': '2026-03-08',
              'daily_limit': 200,
              'total_used': 4,
              'remaining_total': 196,
              'prepare_count': 1,
              'respond_count': 1,
              'entity_summary_count': 1,
              'attachment_inspect_count': 1,
              'updated_at': '2026-03-08T12:30:00Z',
              'remaining_prepare': 196,
              'remaining_respond': 196,
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        },
      );
      final ChatApiClient chatApiClient = ChatApiClient(
        client: recordingClient,
        clientId: 'quota-client',
      );

      final QuotaSnapshot snapshot = await chatApiClient.fetchQuota();

      expect(
        recordingClient.recordedUris.single.queryParameters['client_id'],
        'quota-client',
      );
      expect(snapshot.clientId, 'quota-client');
      expect(snapshot.dailyLimit, 200);
      expect(snapshot.totalUsed, 4);
      expect(snapshot.remainingTotal, 196);
      expect(snapshot.entitySummaryCount, 1);
      expect(snapshot.attachmentInspectCount, 1);
    });

    test('inspectAttachments sends client_id and attachment payload', () async {
      final _RecordingClient recordingClient = _RecordingClient(
        requestHandler: (BaseRequest request, String body) async {
          return Response(
            jsonEncode(<String, Object?>{
              'items': <Object?>[
                <String, Object?>{
                  'client_attachment_id': 'attachment-1',
                  'kind': 'document',
                  'status': 'ready',
                  'summary': 'Grounded document summary',
                  'failure_reason': null,
                  'memory_write_plan': <String, Object?>{
                    'content': 'Grounded document summary',
                    'tags': <String>['document'],
                    'entities': <String>[],
                    'embedding': <double>[0.4, 0.5, 0.6],
                  },
                },
              ],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        },
      );
      final ChatApiClient chatApiClient = ChatApiClient(
        client: recordingClient,
        clientId: 'client-attachment',
      );

      final List<AttachmentInspectResult> results = await chatApiClient
          .inspectAttachments(
            messageText: 'remember this note',
            attachments: const <AttachmentInspectRequestItem>[
              AttachmentInspectRequestItem(
                clientAttachmentId: 'attachment-1',
                kind: ChatAttachmentKind.document,
                fileName: 'note.txt',
                mimeType: 'text/plain',
                documentText: 'Rita mentioned Bhutan here.',
                imageBase64: null,
              ),
            ],
          );

      final Map<String, dynamic> payload =
          jsonDecode(recordingClient.recordedBodies.single)
              as Map<String, dynamic>;
      expect(payload['client_id'], 'client-attachment');
      expect(payload['message_text'], 'remember this note');
      expect(
        ((payload['attachments'] as List<dynamic>).single
            as Map<String, dynamic>)['file_name'],
        'note.txt',
      );
      expect(results, hasLength(1));
      expect(results.single.status, ChatAttachmentStatus.ready);
      expect(
        results.single.memoryWritePlan?.content,
        'Grounded document summary',
      );
    });

    test(
      'prepare surfaces an explicit error when fallback stubs are disabled',
      () async {
        final _RecordingClient recordingClient = _RecordingClient(
          shouldThrow: true,
        );
        final ChatApiClient chatApiClient = ChatApiClient(
          client: recordingClient,
          clientId: 'offline-client',
        );

        expect(
          () => chatApiClient.prepare(
            message: 'Do you remember Rita?',
            recentMessages: const <ChatMessageRecord>[],
          ),
          throwsA(isA<ChatApiException>()),
        );
      },
    );

    test(
      'prepare parses quota exceeded responses into a structured exception',
      () async {
        final _RecordingClient recordingClient = _RecordingClient(
          requestHandler: (BaseRequest request, String body) async {
            return Response(
              jsonEncode(<String, Object?>{
                'error_code': 'daily_quota_exceeded',
                'message': 'Daily quota exhausted for this client.',
                'quota': <String, Object?>{
                  'client_id': 'quota-client',
                  'quota_day': '2026-03-08',
                  'daily_limit': 200,
                  'total_used': 200,
                  'remaining_total': 0,
                  'prepare_count': 60,
                  'respond_count': 60,
                  'entity_summary_count': 40,
                  'attachment_inspect_count': 40,
                  'updated_at': '2026-03-08T18:45:00Z',
                  'remaining_prepare': 0,
                  'remaining_respond': 0,
                },
              }),
              429,
              headers: <String, String>{'content-type': 'application/json'},
            );
          },
        );
        final ChatApiClient chatApiClient = ChatApiClient(
          client: recordingClient,
          clientId: 'quota-client',
        );

        await expectLater(
          () => chatApiClient.prepare(
            message: 'Do you remember Rita?',
            recentMessages: const <ChatMessageRecord>[],
          ),
          throwsA(
            isA<QuotaExceededChatApiException>().having(
              (
                QuotaExceededChatApiException error,
              ) => error.quotaSnapshot.remainingTotal,
              'remainingTotal',
              0,
            ),
          ),
        );
      },
    );
  });
}

class _RecordingClient extends BaseClient {
  final Future<Response> Function(BaseRequest request, String body)?
  requestHandler;
  final bool shouldThrow;
  final List<String> recordedBodies = <String>[];
  final List<Uri> recordedUris = <Uri>[];

  _RecordingClient({this.requestHandler, this.shouldThrow = false});

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (shouldThrow) {
      throw Exception('network down');
    }

    final Uint8List requestBytes = await request.finalize().toBytes();
    final String body = utf8.decode(requestBytes);
    recordedBodies.add(body);
    recordedUris.add(request.url);

    final Response response = await requestHandler!(request, body);
    return StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[response.bodyBytes]),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
