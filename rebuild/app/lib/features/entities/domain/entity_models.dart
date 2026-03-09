class EntityListItem {
  final String id;
  final String name;
  final String? summary;
  final int mentionCount;
  final DateTime? firstMentionedAt;
  final DateTime? lastMentionedAt;

  const EntityListItem({
    required this.id,
    required this.name,
    required this.summary,
    required this.mentionCount,
    required this.firstMentionedAt,
    required this.lastMentionedAt,
  });

  String get summaryPreview {
    final String trimmedSummary = summary?.trim() ?? '';
    if (trimmedSummary.isEmpty) {
      return 'Open this entity to generate its first grounded summary.';
    }
    return trimmedSummary;
  }
}

class EntityLinkedMemoryRecord {
  final String id;
  final String content;
  final List<String> tags;
  final List<String> entities;
  final DateTime createdAt;

  const EntityLinkedMemoryRecord({
    required this.id,
    required this.content,
    required this.tags,
    required this.entities,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'tags': tags,
      'entities': entities,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class EntityDetailRecord {
  final String id;
  final String name;
  final List<String> aliases;
  final String? summary;
  final int mentionCount;
  final int summaryMemoryCount;
  final bool isPromoted;
  final DateTime? firstMentionedAt;
  final DateTime? lastMentionedAt;
  final List<EntityLinkedMemoryRecord> linkedMemories;

  const EntityDetailRecord({
    required this.id,
    required this.name,
    required this.aliases,
    required this.summary,
    required this.mentionCount,
    required this.summaryMemoryCount,
    required this.isPromoted,
    required this.firstMentionedAt,
    required this.lastMentionedAt,
    required this.linkedMemories,
  });

  bool get isSummaryStale {
    final String trimmedSummary = summary?.trim() ?? '';
    if (trimmedSummary.isEmpty) {
      return true;
    }
    return mentionCount - summaryMemoryCount >= 2;
  }
}
