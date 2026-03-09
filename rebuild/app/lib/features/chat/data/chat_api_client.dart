import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../../../core/config/api_config.dart';
import '../../entities/domain/entity_models.dart';
import '../domain/chat_models.dart';

class ChatApiClient {
  final Client _client;
  final String clientId;
  final bool allowLocalFallbacks;

  ChatApiClient({
    Client? client,
    this.clientId = 'anonymous',
    this.allowLocalFallbacks = false,
  }) : _client = client ?? Client();

  Future<PrepareDecision> prepare({
    required String message,
    required List<ChatMessageRecord> recentMessages,
  }) async {
    try {
      final Response response = await _client.post(
        Uri.parse(ApiConfig.prepareEndpoint),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'client_id': clientId,
          'message': message,
          'recent_messages': recentMessages
              .map(
                (ChatMessageRecord record) => <String, dynamic>{
                  'id': record.id,
                  'role': record.role.name,
                  'content': record.content,
                  'created_at': record.createdAt.toUtc().toIso8601String(),
                },
              )
              .toList(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return PrepareDecision.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw _buildRequestError(
        statusCode: response.statusCode,
        responseBody: response.body,
        fallbackMessage:
            'Prepare request failed with status ${response.statusCode}.',
      );
    } on QuotaExceededChatApiException {
      rethrow;
    } on ChatApiException {
      if (allowLocalFallbacks) {
        return _fallbackPrepare(message);
      }
      rethrow;
    } catch (error) {
      if (allowLocalFallbacks) {
        return _fallbackPrepare(message);
      }
      throw ChatApiException('Prepare request failed: $error');
    }
  }

  Stream<String> respond({
    required String message,
    required PrepareDecision prepareDecision,
    required List<RetrievedMemory> retrievedMemories,
  }) async* {
    try {
      final Request request = Request(
        'POST',
        Uri.parse(ApiConfig.respondEndpoint),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(<String, dynamic>{
        'client_id': clientId,
        'message': message,
        'prepare_result': <String, dynamic>{
          'outcome': prepareDecision.outcome.name,
          'assistant_draft': prepareDecision.assistantDraft,
          'tags': prepareDecision.tags,
          'entities': prepareDecision.entities,
          'literal_terms': prepareDecision.literalTerms,
          'time_filters': prepareDecision.timeFilters,
          'query_embedding': prepareDecision.queryEmbedding,
          'retrieval_plan': prepareDecision.retrievalPlan.toJson(),
          'memory_write_plans': prepareDecision.memoryWritePlans
              .map(
                (MemoryWritePlan plan) => <String, dynamic>{
                  'content': plan.content,
                  'tags': plan.tags,
                  'entities': plan.entities,
                  'embedding': plan.embedding,
                },
              )
              .toList(),
        },
        'retrieved_memories': retrievedMemories
            .map((RetrievedMemory memory) => memory.toJson())
            .toList(),
      });

      final StreamedResponse response = await _client.send(request);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await for (final String chunk in response.stream.transform(
          utf8.decoder,
        )) {
          final List<String> lines = chunk.split('\n');
          for (final String line in lines) {
            if (line.trim().isEmpty) {
              continue;
            }
            final Map<String, dynamic> event =
                jsonDecode(line) as Map<String, dynamic>;
            final String type = event['type'] as String? ?? '';
            if (type == 'content') {
              yield event['delta'] as String? ?? '';
            }
          }
        }
        return;
      }
      final String responseBody = await response.stream.bytesToString();
      throw _buildRequestError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        fallbackMessage:
            'Respond request failed with status ${response.statusCode}.',
      );
    } on QuotaExceededChatApiException {
      rethrow;
    } on ChatApiException {
      if (allowLocalFallbacks) {
        yield* _fallbackResponse(
          message: message,
          prepareDecision: prepareDecision,
          retrievedMemories: retrievedMemories,
        );
        return;
      }
      rethrow;
    } catch (error) {
      if (allowLocalFallbacks) {
        yield* _fallbackResponse(
          message: message,
          prepareDecision: prepareDecision,
          retrievedMemories: retrievedMemories,
        );
        return;
      }
      throw ChatApiException('Respond request failed: $error');
    }
  }

  Future<String> summarizeEntity({
    required String entityName,
    required List<String> aliases,
    required List<EntityLinkedMemoryRecord> linkedMemories,
  }) async {
    try {
      final Response response = await _client.post(
        Uri.parse(ApiConfig.entitySummaryEndpoint),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'client_id': clientId,
          'entity_name': entityName,
          'aliases': aliases,
          'linked_memories': linkedMemories
              .map((EntityLinkedMemoryRecord memory) => memory.toJson())
              .toList(),
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> payload =
            jsonDecode(response.body) as Map<String, dynamic>;
        return payload['summary'] as String? ?? '';
      }
      throw _buildRequestError(
        statusCode: response.statusCode,
        responseBody: response.body,
        fallbackMessage:
            'Entity summary request failed with status ${response.statusCode}.',
      );
    } on QuotaExceededChatApiException {
      rethrow;
    } on ChatApiException {
      if (allowLocalFallbacks) {
        return _fallbackEntitySummary(
          entityName: entityName,
          linkedMemories: linkedMemories,
        );
      }
      rethrow;
    } catch (error) {
      if (allowLocalFallbacks) {
        return _fallbackEntitySummary(
          entityName: entityName,
          linkedMemories: linkedMemories,
        );
      }
      throw ChatApiException('Entity summary request failed: $error');
    }
  }

  Future<List<AttachmentInspectResult>> inspectAttachments({
    required String messageText,
    required List<AttachmentInspectRequestItem> attachments,
  }) async {
    try {
      final Response response = await _client.post(
        Uri.parse(ApiConfig.attachmentInspectEndpoint),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'client_id': clientId,
          'message_text': messageText,
          'attachments': attachments
              .map((AttachmentInspectRequestItem item) => item.toJson())
              .toList(),
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> payload =
            jsonDecode(response.body) as Map<String, dynamic>;
        return (payload['items'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(AttachmentInspectResult.fromJson)
            .toList(growable: false);
      }
      throw _buildRequestError(
        statusCode: response.statusCode,
        responseBody: response.body,
        fallbackMessage:
            'Attachment inspect request failed with status ${response.statusCode}.',
      );
    } on QuotaExceededChatApiException {
      rethrow;
    } on ChatApiException {
      if (allowLocalFallbacks) {
        return _fallbackAttachmentInspectResults(attachments);
      }
      rethrow;
    } catch (error) {
      if (allowLocalFallbacks) {
        return _fallbackAttachmentInspectResults(attachments);
      }
      throw ChatApiException('Attachment inspect request failed: $error');
    }
  }

  Future<QuotaSnapshot> fetchQuota() async {
    try {
      final Uri uri = Uri.parse(
        ApiConfig.quotaEndpoint,
      ).replace(queryParameters: <String, String>{'client_id': clientId});
      final Response response = await _client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return QuotaSnapshot.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw _buildRequestError(
        statusCode: response.statusCode,
        responseBody: response.body,
        fallbackMessage:
            'Quota request failed with status ${response.statusCode}.',
      );
    } on ChatApiException {
      rethrow;
    } catch (error) {
      throw ChatApiException('Quota request failed: $error');
    }
  }

  PrepareDecision _fallbackPrepare(String message) {
    final String trimmedMessage = message.trim();
    final String lowerMessage = trimmedMessage.toLowerCase();
    final bool hasQuestionMark = trimmedMessage.contains('?');
    final bool looksReflectiveQuestion =
        hasQuestionMark ||
        lowerMessage.startsWith('why ') ||
        lowerMessage.startsWith('what ') ||
        lowerMessage.startsWith('when ') ||
        lowerMessage.startsWith('who ') ||
        lowerMessage.startsWith('how ');
    final bool looksScheduleNote = RegExp(
      r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|\d{1,2}[:.]\d{2}|am|pm)',
      caseSensitive: false,
    ).hasMatch(trimmedMessage);
    final bool looksStoredFact =
        trimmedMessage.contains(' is ') ||
        trimmedMessage.contains('@') ||
        trimmedMessage.contains('birthday') ||
        trimmedMessage.contains('address');
    final bool looksMixed =
        looksReflectiveQuestion &&
        (trimmedMessage.contains(',') || lowerMessage.contains('do you know'));
    final bool looksRefusal = lowerMessage.contains('cheat on my partner');

    if (looksRefusal) {
      return PrepareDecision(
        outcome: PrepareOutcome.briefRefusal,
        assistantDraft:
            'I cannot help with that, but I can keep the context if you want to reflect on it safely.',
        tags: _extractTags(trimmedMessage),
        entities: _extractEntities(trimmedMessage),
        literalTerms: _extractLiteralTerms(trimmedMessage),
        timeFilters: _extractTimeFilters(trimmedMessage),
        queryEmbedding: _fakeEmbedding(trimmedMessage),
        clarificationPrompt: null,
        memoryWritePlans: <MemoryWritePlan>[
          MemoryWritePlan(
            content: trimmedMessage,
            tags: _extractTags(trimmedMessage),
            entities: _extractEntities(trimmedMessage),
            embedding: _fakeEmbedding(trimmedMessage),
          ),
        ],
        retrievalPlan: _fallbackRetrievalPlan(
          outcome: PrepareOutcome.briefRefusal,
          tags: _extractTags(trimmedMessage),
          entities: _extractEntities(trimmedMessage),
          literalTerms: _extractLiteralTerms(trimmedMessage),
          timeFilters: _extractTimeFilters(trimmedMessage),
        ),
      );
    }

    if (looksMixed) {
      return PrepareDecision(
        outcome: PrepareOutcome.mixed,
        assistantDraft: '',
        tags: _extractTags(trimmedMessage),
        entities: _extractEntities(trimmedMessage),
        literalTerms: _extractLiteralTerms(trimmedMessage),
        timeFilters: _extractTimeFilters(trimmedMessage),
        queryEmbedding: _fakeEmbedding(trimmedMessage),
        clarificationPrompt: null,
        memoryWritePlans: <MemoryWritePlan>[
          MemoryWritePlan(
            content: trimmedMessage.split('?').first.trim(),
            tags: _extractTags(trimmedMessage),
            entities: _extractEntities(trimmedMessage),
            embedding: _fakeEmbedding(trimmedMessage),
          ),
        ],
        retrievalPlan: _fallbackRetrievalPlan(
          outcome: PrepareOutcome.mixed,
          tags: _extractTags(trimmedMessage),
          entities: _extractEntities(trimmedMessage),
          literalTerms: _extractLiteralTerms(trimmedMessage),
          timeFilters: _extractTimeFilters(trimmedMessage),
        ),
      );
    }

    if (looksScheduleNote && !hasQuestionMark) {
      return PrepareDecision(
        outcome: PrepareOutcome.clarify,
        assistantDraft: '',
        tags: _extractTags(trimmedMessage),
        entities: _extractEntities(trimmedMessage),
        literalTerms: _extractLiteralTerms(trimmedMessage),
        timeFilters: _extractTimeFilters(trimmedMessage),
        queryEmbedding: _fakeEmbedding(trimmedMessage),
        clarificationPrompt: ClarificationPrompt(
          title: 'Store this or answer it?',
          message:
              'This could be a memory to keep or a question that needs an answer.',
          originalText: trimmedMessage,
        ),
        memoryWritePlans: <MemoryWritePlan>[
          MemoryWritePlan(
            content: trimmedMessage,
            tags: _extractTags(trimmedMessage),
            entities: _extractEntities(trimmedMessage),
            embedding: _fakeEmbedding(trimmedMessage),
          ),
        ],
        retrievalPlan: _fallbackRetrievalPlan(
          outcome: PrepareOutcome.clarify,
          tags: _extractTags(trimmedMessage),
          entities: _extractEntities(trimmedMessage),
          literalTerms: _extractLiteralTerms(trimmedMessage),
          timeFilters: _extractTimeFilters(trimmedMessage),
        ),
      );
    }

    if (!looksReflectiveQuestion && looksStoredFact) {
      return PrepareDecision(
        outcome: PrepareOutcome.memoryOnly,
        assistantDraft: '',
        tags: _extractTags(trimmedMessage),
        entities: _extractEntities(trimmedMessage),
        literalTerms: _extractLiteralTerms(trimmedMessage),
        timeFilters: _extractTimeFilters(trimmedMessage),
        queryEmbedding: null,
        clarificationPrompt: null,
        memoryWritePlans: <MemoryWritePlan>[
          MemoryWritePlan(
            content: trimmedMessage,
            tags: _extractTags(trimmedMessage),
            entities: _extractEntities(trimmedMessage),
            embedding: _fakeEmbedding(trimmedMessage),
          ),
        ],
        retrievalPlan: _fallbackRetrievalPlan(
          outcome: PrepareOutcome.memoryOnly,
          tags: _extractTags(trimmedMessage),
          entities: _extractEntities(trimmedMessage),
          literalTerms: _extractLiteralTerms(trimmedMessage),
          timeFilters: _extractTimeFilters(trimmedMessage),
        ),
      );
    }

    return PrepareDecision(
      outcome: PrepareOutcome.query,
      assistantDraft: '',
      tags: _extractTags(trimmedMessage),
      entities: _extractEntities(trimmedMessage),
      literalTerms: _extractLiteralTerms(trimmedMessage),
      timeFilters: _extractTimeFilters(trimmedMessage),
      queryEmbedding: _fakeEmbedding(trimmedMessage),
      clarificationPrompt: null,
      memoryWritePlans: looksReflectiveQuestion
          ? const <MemoryWritePlan>[]
          : <MemoryWritePlan>[
              MemoryWritePlan(
                content: trimmedMessage,
                tags: _extractTags(trimmedMessage),
                entities: _extractEntities(trimmedMessage),
                embedding: _fakeEmbedding(trimmedMessage),
              ),
            ],
      retrievalPlan: _fallbackRetrievalPlan(
        outcome: PrepareOutcome.query,
        tags: _extractTags(trimmedMessage),
        entities: _extractEntities(trimmedMessage),
        literalTerms: _extractLiteralTerms(trimmedMessage),
        timeFilters: _extractTimeFilters(trimmedMessage),
      ),
    );
  }

  List<AttachmentInspectResult> _fallbackAttachmentInspectResults(
    List<AttachmentInspectRequestItem> attachments,
  ) {
    return attachments
        .map((AttachmentInspectRequestItem attachment) {
          final String summary = attachment.kind == ChatAttachmentKind.image
              ? 'Image attachment summary for ${attachment.fileName}'
              : 'Document attachment summary for ${attachment.fileName}';
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
              embedding: _fakeEmbedding(summary),
            ),
          );
        })
        .toList(growable: false);
  }

  RetrievalPlan _fallbackRetrievalPlan({
    required PrepareOutcome outcome,
    required List<String> tags,
    required List<String> entities,
    required List<String> literalTerms,
    required List<String> timeFilters,
  }) {
    return RetrievalPlan.fallback(
      outcome: outcome,
      tags: tags,
      entities: entities,
      literalTerms: literalTerms,
      timeFilters: timeFilters,
    );
  }

  Stream<String> _fallbackResponse({
    required String message,
    required PrepareDecision prepareDecision,
    required List<RetrievedMemory> retrievedMemories,
  }) async* {
    if (prepareDecision.outcome == PrepareOutcome.briefRefusal &&
        prepareDecision.assistantDraft.isNotEmpty) {
      yield prepareDecision.assistantDraft;
      return;
    }

    if (retrievedMemories.isEmpty) {
      yield 'I do not have enough grounded memory yet to answer that well.';
      return;
    }

    final List<String> segments = <String>[];
    if (prepareDecision.entities.isNotEmpty) {
      segments.add(
        'Here is what I remember about ${prepareDecision.entities.join(', ')}.',
      );
    } else {
      segments.add('Here is what stands out from your stored memory.');
    }

    for (final RetrievedMemory memory in retrievedMemories.take(3)) {
      segments.add(memory.content);
    }

    final String response = segments.join(' ');
    final List<String> parts = response.split(' ');
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < parts.length; index++) {
      buffer.write(parts[index]);
      if (index < parts.length - 1) {
        buffer.write(' ');
      }
      if (buffer.length > 35) {
        yield buffer.toString();
        buffer.clear();
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    }

    if (buffer.isNotEmpty) {
      yield buffer.toString();
    }
  }

  String _fallbackEntitySummary({
    required String entityName,
    required List<EntityLinkedMemoryRecord> linkedMemories,
  }) {
    if (linkedMemories.isEmpty) {
      return '';
    }

    final List<EntityLinkedMemoryRecord> orderedMemories =
        List<EntityLinkedMemoryRecord>.from(linkedMemories)..sort((
          EntityLinkedMemoryRecord first,
          EntityLinkedMemoryRecord second,
        ) {
          return first.createdAt.compareTo(second.createdAt);
        });
    final EntityLinkedMemoryRecord earliestMemory = orderedMemories.first;
    final EntityLinkedMemoryRecord latestMemory = orderedMemories.last;
    final Set<String> toneTags = orderedMemories
        .expand((EntityLinkedMemoryRecord memory) => memory.tags)
        .where((String tag) => tag == 'positive' || tag == 'negative')
        .toSet();

    final List<String> parts = <String>[
      '$entityName appears across ${orderedMemories.length} stored memories.',
    ];
    if (orderedMemories.length == 1) {
      parts.add('Current snapshot: ${latestMemory.content}');
    } else {
      parts.add('Earlier: ${earliestMemory.content}');
      parts.add('Current: ${latestMemory.content}');
    }
    if (toneTags.isNotEmpty) {
      parts.add('Tone: ${toneTags.join(', ')}.');
    }

    return parts.join(' ');
  }

  List<String> _extractTags(String message) {
    final String lowerMessage = message.toLowerCase();
    final List<String> tags = <String>[];
    final Map<String, List<String>> tagRules = <String, List<String>>{
      'positive': <String>['happy', 'proud', 'joy', 'grateful'],
      'negative': <String>['sad', 'stuck', 'angry', 'afraid'],
      'travel': <String>['trip', 'travel', 'flight', 'hotel'],
      'relationship': <String>['rita', 'partner', 'friend', 'family'],
      'planning': <String>['march', 'pm', 'am', 'meeting', 'dentist'],
    };

    tagRules.forEach((String tag, List<String> ruleWords) {
      for (final String word in ruleWords) {
        if (lowerMessage.contains(word)) {
          tags.add(tag);
          return;
        }
      }
    });

    if (tags.isEmpty && message.isNotEmpty) {
      tags.add('general');
    }

    return tags.toSet().toList();
  }

  List<String> _extractEntities(String message) {
    final RegExp entityPattern = RegExp(r'\b[A-Z][a-zA-Z0-9_@]+\b');
    return entityPattern
        .allMatches(message)
        .map((Match match) => match.group(0) ?? '')
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _extractLiteralTerms(String message) {
    final List<String> words = message
        .split(RegExp(r'\s+'))
        .map((String part) => part.replaceAll(RegExp(r'[^a-zA-Z0-9@]'), ''))
        .where((String part) => part.length >= 4)
        .toList();
    return words.take(6).toList();
  }

  List<String> _extractTimeFilters(String message) {
    final RegExp timePattern = RegExp(
      r'(today|tomorrow|yesterday|monday|tuesday|wednesday|thursday|friday|saturday|sunday|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|\d{4})',
      caseSensitive: false,
    );
    return timePattern
        .allMatches(message)
        .map((Match match) => match.group(0) ?? '')
        .where((String value) => value.isNotEmpty)
        .toList();
  }

  List<double> _fakeEmbedding(String text) {
    final Random random = Random(
      text.runes.fold<int>(0, (int sum, int rune) => sum + rune),
    );
    return List<double>.generate(24, (_) => random.nextDouble());
  }

  ChatApiException _buildRequestError({
    required int statusCode,
    required String responseBody,
    required String fallbackMessage,
  }) {
    if (statusCode == 429) {
      return _buildQuotaExceededError(
        responseBody: responseBody,
        fallbackMessage: fallbackMessage,
      );
    }
    return ChatApiException(fallbackMessage);
  }

  QuotaExceededChatApiException _buildQuotaExceededError({
    required String responseBody,
    required String fallbackMessage,
  }) {
    final Map<String, dynamic>? payload = _decodeJsonObject(responseBody);
    final Map<String, dynamic>? errorPayload = _extractQuotaErrorPayload(payload);
    final Map<String, dynamic>? quotaJson =
        errorPayload?['quota'] is Map<String, dynamic>
        ? errorPayload!['quota'] as Map<String, dynamic>
        : errorPayload?['quota'] is Map
        ? (errorPayload!['quota'] as Map<dynamic, dynamic>).cast<String, dynamic>()
        : null;
    final QuotaSnapshot quotaSnapshot = QuotaSnapshot.fromJson(
      quotaJson ?? const <String, dynamic>{},
    );
    final String serverMessage =
        errorPayload?['message'] as String? ?? fallbackMessage;
    final String errorCode =
        errorPayload?['error_code'] as String? ?? 'daily_quota_exceeded';
    final String message =
        '$serverMessage ${quotaSnapshot.remainingTotal} remaining of '
        '${quotaSnapshot.dailyLimit} today.';
    return QuotaExceededChatApiException(
      message: message.trim(),
      errorCode: errorCode,
      quotaSnapshot: quotaSnapshot,
    );
  }

  Map<String, dynamic>? _decodeJsonObject(String input) {
    try {
      final dynamic decoded = jsonDecode(input);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _extractQuotaErrorPayload(Map<String, dynamic>? payload) {
    if (payload == null) {
      return null;
    }
    if (payload['quota'] != null) {
      return payload;
    }
    final dynamic detail = payload['detail'];
    if (detail is Map<String, dynamic>) {
      return detail;
    }
    if (detail is Map) {
      return detail.cast<String, dynamic>();
    }
    return null;
  }
}

class ChatApiException implements Exception {
  final String message;

  const ChatApiException(this.message);

  @override
  String toString() {
    return message;
  }
}

class QuotaExceededChatApiException extends ChatApiException {
  final String errorCode;
  final QuotaSnapshot quotaSnapshot;

  const QuotaExceededChatApiException({
    required String message,
    required this.errorCode,
    required this.quotaSnapshot,
  }) : super(message);
}
