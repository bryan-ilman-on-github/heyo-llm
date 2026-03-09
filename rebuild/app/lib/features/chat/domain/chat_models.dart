enum ChatMessageRole { user, assistant }

enum PrepareOutcome { memoryOnly, query, clarify, mixed, briefRefusal }

enum ChatAttachmentKind { document, image }

enum ChatAttachmentStatus { pending, ready, failed }

class PendingAttachmentDraft {
  final String id;
  final ChatAttachmentKind kind;
  final String displayName;
  final String mimeType;
  final String localPath;
  final int byteSize;

  const PendingAttachmentDraft({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.mimeType,
    required this.localPath,
    required this.byteSize,
  });
}

class ChatAttachmentRecord {
  final String id;
  final ChatAttachmentKind kind;
  final String? displayName;
  final String? mimeType;
  final String? localPath;
  final int? byteSize;
  final ChatAttachmentStatus status;
  final String? failureReason;
  final String? rawText;
  final String? summary;
  final String? summaryMemoryId;
  final DateTime createdAt;

  const ChatAttachmentRecord({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.mimeType,
    required this.localPath,
    required this.byteSize,
    required this.status,
    required this.failureReason,
    required this.rawText,
    required this.summary,
    required this.summaryMemoryId,
    required this.createdAt,
  });

  ChatAttachmentRecord copyWith({
    ChatAttachmentKind? kind,
    String? displayName,
    String? mimeType,
    String? localPath,
    int? byteSize,
    ChatAttachmentStatus? status,
    String? failureReason,
    String? rawText,
    String? summary,
    String? summaryMemoryId,
    DateTime? createdAt,
  }) {
    return ChatAttachmentRecord(
      id: id,
      kind: kind ?? this.kind,
      displayName: displayName ?? this.displayName,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      byteSize: byteSize ?? this.byteSize,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      rawText: rawText ?? this.rawText,
      summary: summary ?? this.summary,
      summaryMemoryId: summaryMemoryId ?? this.summaryMemoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AttachmentInspectRequestItem {
  final String clientAttachmentId;
  final ChatAttachmentKind kind;
  final String fileName;
  final String mimeType;
  final String? documentText;
  final String? imageBase64;

  const AttachmentInspectRequestItem({
    required this.clientAttachmentId,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.documentText,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'client_attachment_id': clientAttachmentId,
      'kind': kind.name,
      'file_name': fileName,
      'mime_type': mimeType,
      'document_text': documentText,
      'image_base64': imageBase64,
    };
  }
}

class AttachmentInspectResult {
  final String clientAttachmentId;
  final ChatAttachmentKind kind;
  final ChatAttachmentStatus status;
  final String summary;
  final String? failureReason;
  final MemoryWritePlan? memoryWritePlan;

  const AttachmentInspectResult({
    required this.clientAttachmentId,
    required this.kind,
    required this.status,
    required this.summary,
    required this.failureReason,
    required this.memoryWritePlan,
  });

  factory AttachmentInspectResult.fromJson(Map<String, dynamic> json) {
    return AttachmentInspectResult(
      clientAttachmentId: json['client_attachment_id'] as String? ?? '',
      kind: _parseAttachmentKind(json['kind'] as String?),
      status: _parseAttachmentStatus(json['status'] as String?),
      summary: json['summary'] as String? ?? '',
      failureReason: json['failure_reason'] as String?,
      memoryWritePlan: json['memory_write_plan'] is Map<String, dynamic>
          ? MemoryWritePlan.fromJson(
              json['memory_write_plan'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class RetrievalPlan {
  final String intentType;
  final String strategy;
  final bool allowDeletedFallback;
  final List<String> keywordTerms;
  final List<String> entityFilters;
  final List<String> tagFilters;
  final List<String> timeFilters;

  const RetrievalPlan({
    required this.intentType,
    required this.strategy,
    required this.allowDeletedFallback,
    required this.keywordTerms,
    required this.entityFilters,
    required this.tagFilters,
    required this.timeFilters,
  });

  factory RetrievalPlan.fromJson(Map<String, dynamic> json) {
    return RetrievalPlan(
      intentType: json['intent_type'] as String? ?? 'query',
      strategy: json['strategy'] as String? ?? 'vector_only',
      allowDeletedFallback: json['allow_deleted_fallback'] as bool? ?? false,
      keywordTerms:
          (json['keyword_terms'] as List<dynamic>? ?? const <dynamic>[])
              .map((dynamic entry) => entry.toString())
              .toList(),
      entityFilters:
          (json['entity_filters'] as List<dynamic>? ?? const <dynamic>[])
              .map((dynamic entry) => entry.toString())
              .toList(),
      tagFilters: (json['tag_filters'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
      timeFilters: (json['time_filters'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
    );
  }

  factory RetrievalPlan.fallback({
    required PrepareOutcome outcome,
    required List<String> tags,
    required List<String> entities,
    required List<String> literalTerms,
    required List<String> timeFilters,
  }) {
    final bool hasQuotedPhrase = literalTerms.any(
      (String term) => term.contains(' '),
    );
    final bool hasEmotionalTag =
        tags.contains('positive') || tags.contains('negative');
    final bool hasEntity = entities.isNotEmpty;
    final bool hasExactTerms = literalTerms.isNotEmpty;
    final bool hasTimeFilters = timeFilters.isNotEmpty;
    final bool looksLikeThematic =
        hasTimeFilters && hasEmotionalTag && !hasEntity;

    if (hasQuotedPhrase) {
      return RetrievalPlan(
        intentType: 'quoted_text_lookup',
        strategy: 'keyword_vector_hybrid',
        allowDeletedFallback: false,
        keywordTerms: literalTerms,
        entityFilters: entities,
        tagFilters: tags,
        timeFilters: timeFilters,
      );
    }

    if (looksLikeThematic || outcome == PrepareOutcome.clarify) {
      return RetrievalPlan(
        intentType: 'thematic_reflection',
        strategy: 'time_vector',
        allowDeletedFallback: false,
        keywordTerms: literalTerms,
        entityFilters: entities,
        tagFilters: tags,
        timeFilters: timeFilters,
      );
    }

    if (hasEntity) {
      return RetrievalPlan(
        intentType: 'entity_specific_recall',
        strategy: 'entity_keyword_hybrid',
        allowDeletedFallback: false,
        keywordTerms: literalTerms,
        entityFilters: entities,
        tagFilters: tags,
        timeFilters: timeFilters,
      );
    }

    if (hasExactTerms) {
      return RetrievalPlan(
        intentType: 'exact_mention_lookup',
        strategy: 'keyword_only',
        allowDeletedFallback: false,
        keywordTerms: literalTerms,
        entityFilters: entities,
        tagFilters: tags,
        timeFilters: timeFilters,
      );
    }

    if (hasEmotionalTag &&
        outcome != PrepareOutcome.memoryOnly &&
        outcome != PrepareOutcome.briefRefusal) {
      return RetrievalPlan(
        intentType: 'emotional_recall',
        strategy: 'tag_vector',
        allowDeletedFallback: false,
        keywordTerms: literalTerms,
        entityFilters: entities,
        tagFilters: tags,
        timeFilters: timeFilters,
      );
    }

    return RetrievalPlan(
      intentType: 'open_reflective_query',
      strategy: 'vector_only',
      allowDeletedFallback: false,
      keywordTerms: literalTerms,
      entityFilters: entities,
      tagFilters: tags,
      timeFilters: timeFilters,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'intent_type': intentType,
      'strategy': strategy,
      'allow_deleted_fallback': allowDeletedFallback,
      'keyword_terms': keywordTerms,
      'entity_filters': entityFilters,
      'tag_filters': tagFilters,
      'time_filters': timeFilters,
    };
  }
}

class ChatMessageRecord {
  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime createdAt;
  final bool isEdited;
  final bool isDeleted;
  final String? pairedMessageId;
  final List<ChatAttachmentRecord> attachments;

  const ChatMessageRecord({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.isEdited,
    required this.isDeleted,
    required this.pairedMessageId,
    required this.attachments,
  });

  ChatMessageRecord copyWith({
    String? content,
    DateTime? createdAt,
    bool? isEdited,
    bool? isDeleted,
    String? pairedMessageId,
    List<ChatAttachmentRecord>? attachments,
  }) {
    return ChatMessageRecord(
      id: id,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      pairedMessageId: pairedMessageId ?? this.pairedMessageId,
      attachments: attachments ?? this.attachments,
    );
  }
}

class MemoryWritePlan {
  final String content;
  final List<String> tags;
  final List<String> entities;
  final List<double>? embedding;

  const MemoryWritePlan({
    required this.content,
    required this.tags,
    required this.entities,
    required this.embedding,
  });

  factory MemoryWritePlan.fromJson(Map<String, dynamic> json) {
    return MemoryWritePlan(
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
      entities:
          ((json['entities'] ?? json['entity_names']) as List<dynamic>? ??
                  const <dynamic>[])
              .map((dynamic entry) => entry.toString())
              .toList(),
      embedding: (json['embedding'] as List<dynamic>?)
          ?.map((dynamic entry) => (entry as num).toDouble())
          .toList(),
    );
  }
}

class ClarificationPrompt {
  final String title;
  final String message;
  final String originalText;

  const ClarificationPrompt({
    required this.title,
    required this.message,
    required this.originalText,
  });

  factory ClarificationPrompt.fromJson(Map<String, dynamic> json) {
    return ClarificationPrompt(
      title: json['title'] as String? ?? 'Clarify this message',
      message: json['message'] as String? ?? '',
      originalText: json['original_text'] as String? ?? '',
    );
  }
}

class PrepareDecision {
  final PrepareOutcome outcome;
  final String assistantDraft;
  final List<String> tags;
  final List<String> entities;
  final List<String> literalTerms;
  final List<String> timeFilters;
  final List<double>? queryEmbedding;
  final ClarificationPrompt? clarificationPrompt;
  final List<MemoryWritePlan> memoryWritePlans;
  final RetrievalPlan retrievalPlan;

  const PrepareDecision({
    required this.outcome,
    required this.assistantDraft,
    required this.tags,
    required this.entities,
    required this.literalTerms,
    required this.timeFilters,
    required this.queryEmbedding,
    required this.clarificationPrompt,
    required this.memoryWritePlans,
    required this.retrievalPlan,
  });

  bool get requiresResponse {
    return outcome == PrepareOutcome.query ||
        outcome == PrepareOutcome.mixed ||
        outcome == PrepareOutcome.briefRefusal;
  }

  factory PrepareDecision.fromJson(Map<String, dynamic> json) {
    return PrepareDecision(
      outcome: _parseOutcome(json['outcome'] as String?),
      assistantDraft: json['assistant_draft'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
      entities: (json['entities'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
      literalTerms:
          (json['literal_terms'] as List<dynamic>? ?? const <dynamic>[])
              .map((dynamic entry) => entry.toString())
              .toList(),
      timeFilters: (json['time_filters'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic entry) => entry.toString())
          .toList(),
      queryEmbedding: (json['query_embedding'] as List<dynamic>?)
          ?.map((dynamic entry) => (entry as num).toDouble())
          .toList(),
      clarificationPrompt: json['clarification'] is Map<String, dynamic>
          ? ClarificationPrompt.fromJson(
              json['clarification'] as Map<String, dynamic>,
            )
          : null,
      memoryWritePlans:
          ((json['memory_write_plans'] ?? json['memory_items'])
                      as List<dynamic>? ??
                  const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(MemoryWritePlan.fromJson)
              .toList(),
      retrievalPlan: json['retrieval_plan'] is Map<String, dynamic>
          ? RetrievalPlan.fromJson(
              json['retrieval_plan'] as Map<String, dynamic>,
            )
          : RetrievalPlan.fallback(
              outcome: _parseOutcome(json['outcome'] as String?),
              tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
                  .map((dynamic entry) => entry.toString())
                  .toList(),
              entities:
                  (json['entities'] as List<dynamic>? ?? const <dynamic>[])
                      .map((dynamic entry) => entry.toString())
                      .toList(),
              literalTerms:
                  (json['literal_terms'] as List<dynamic>? ?? const <dynamic>[])
                      .map((dynamic entry) => entry.toString())
                      .toList(),
              timeFilters:
                  (json['time_filters'] as List<dynamic>? ?? const <dynamic>[])
                      .map((dynamic entry) => entry.toString())
                      .toList(),
            ),
    );
  }

  static PrepareOutcome _parseOutcome(String? value) {
    switch (value) {
      case 'memory_only':
        return PrepareOutcome.memoryOnly;
      case 'query':
        return PrepareOutcome.query;
      case 'clarify':
        return PrepareOutcome.clarify;
      case 'mixed':
        return PrepareOutcome.mixed;
      case 'brief_refusal':
        return PrepareOutcome.briefRefusal;
      default:
        return PrepareOutcome.query;
    }
  }
}

class MemoryConfirmation {
  final String content;
  final List<String> tags;
  final List<String> entities;

  const MemoryConfirmation({
    required this.content,
    required this.tags,
    required this.entities,
  });
}

class RetrievedMemory {
  final String id;
  final String content;
  final List<String> tags;
  final List<String> entities;
  final double score;
  final DateTime createdAt;
  final String? sourceType;
  final String? attachmentId;
  final String? attachmentName;
  final String? snippet;

  const RetrievedMemory({
    required this.id,
    required this.content,
    required this.tags,
    required this.entities,
    required this.score,
    required this.createdAt,
    this.sourceType,
    this.attachmentId,
    this.attachmentName,
    this.snippet,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'tags': tags,
      'entities': entities,
      'score': score,
      'created_at': createdAt.toIso8601String(),
      'source_type': sourceType,
      'attachment_id': attachmentId,
      'attachment_name': attachmentName,
      'snippet': snippet,
    };
  }
}

class QuotaSnapshot {
  final String clientId;
  final String quotaDay;
  final int dailyLimit;
  final int totalUsed;
  final int remainingTotal;
  final int prepareCount;
  final int respondCount;
  final int entitySummaryCount;
  final int attachmentInspectCount;
  final DateTime? updatedAt;
  final int remainingPrepare;
  final int remainingRespond;

  const QuotaSnapshot({
    required this.clientId,
    required this.quotaDay,
    required this.dailyLimit,
    required this.totalUsed,
    required this.remainingTotal,
    required this.prepareCount,
    required this.respondCount,
    required this.entitySummaryCount,
    required this.attachmentInspectCount,
    required this.updatedAt,
    required this.remainingPrepare,
    required this.remainingRespond,
  });

  factory QuotaSnapshot.fromJson(Map<String, dynamic> json) {
    final int dailyLimit =
        json['daily_limit'] as int? ?? json['default_daily_quota'] as int? ?? 0;
    final int remainingTotal =
        json['remaining_total'] as int? ??
        json['remaining_prepare'] as int? ??
        json['remaining_respond'] as int? ??
        0;
    return QuotaSnapshot(
      clientId: json['client_id'] as String? ?? 'anonymous',
      quotaDay: json['quota_day'] as String? ?? '',
      dailyLimit: dailyLimit,
      totalUsed: json['total_used'] as int? ?? 0,
      remainingTotal: remainingTotal,
      prepareCount: json['prepare_count'] as int? ?? 0,
      respondCount: json['respond_count'] as int? ?? 0,
      entitySummaryCount: json['entity_summary_count'] as int? ?? 0,
      attachmentInspectCount: json['attachment_inspect_count'] as int? ?? 0,
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at'] as String)?.toLocal()
          : null,
      remainingPrepare: json['remaining_prepare'] as int? ?? remainingTotal,
      remainingRespond: json['remaining_respond'] as int? ?? remainingTotal,
    );
  }

  int get defaultDailyQuota => dailyLimit;
}

ChatAttachmentKind _parseAttachmentKind(String? value) {
  switch (value) {
    case 'image':
      return ChatAttachmentKind.image;
    case 'document':
    default:
      return ChatAttachmentKind.document;
  }
}

ChatAttachmentStatus _parseAttachmentStatus(String? value) {
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
