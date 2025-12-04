import 'tool_call.dart';

enum MessageRole { user, assistant, tool, system }

class Message {
  final String id;
  final MessageRole role;
  String content;
  final DateTime timestamp;
  final List<ToolCall>? toolCalls;
  final String? toolCallId;
  final ToolResultMetadata? metadata;
  bool isStreaming;

  // Branching support
  final String? parentId;
  final List<String> childrenIds;
  int siblingIndex; // Which branch this is (0, 1, 2...)
  int siblingsCount; // Total siblings at this branch point

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.toolCalls,
    this.toolCallId,
    this.metadata,
    this.isStreaming = false,
    this.parentId,
    List<String>? childrenIds,
    this.siblingIndex = 0,
    this.siblingsCount = 1,
  }) : childrenIds = childrenIds ?? [];

  factory Message.user(String content, {String? parentId}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      parentId: parentId,
    );
  }

  factory Message.assistant({
    String content = '',
    bool isStreaming = false,
    String? parentId,
  }) {
    return Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_assistant',
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
      parentId: parentId,
    );
  }

  factory Message.toolResult({
    required String toolCallId,
    required String content,
    required String toolName,
    String? error,
    String? parentId,
  }) {
    return Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_tool',
      role: MessageRole.tool,
      content: content,
      timestamp: DateTime.now(),
      toolCallId: toolCallId,
      metadata: ToolResultMetadata.forTool(toolName),
      parentId: parentId,
    );
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    List<ToolCall>? toolCalls,
    String? toolCallId,
    ToolResultMetadata? metadata,
    bool? isStreaming,
    String? parentId,
    List<String>? childrenIds,
    int? siblingIndex,
    int? siblingsCount,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      toolCalls: toolCalls ?? this.toolCalls,
      toolCallId: toolCallId ?? this.toolCallId,
      metadata: metadata ?? this.metadata,
      isStreaming: isStreaming ?? this.isStreaming,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? List.from(this.childrenIds),
      siblingIndex: siblingIndex ?? this.siblingIndex,
      siblingsCount: siblingsCount ?? this.siblingsCount,
    );
  }

  void addChild(String childId) {
    if (!childrenIds.contains(childId)) {
      childrenIds.add(childId);
    }
  }

  Map<String, dynamic> toOllamaFormat() {
    final map = <String, dynamic>{
      'role': _roleToString(role),
      'content': content,
    };

    if (toolCallId != null) {
      map['tool_call_id'] = toolCallId;
    }

    return map;
  }

  String _roleToString(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.tool:
        return 'tool';
      case MessageRole.system:
        return 'system';
    }
  }

  bool get hasToolCalls => toolCalls != null && toolCalls!.isNotEmpty;
  bool get isToolResult => role == MessageRole.tool;
  bool get isEmpty => content.isEmpty && !hasToolCalls;
  bool get hasBranches => childrenIds.length > 1;
  bool get hasSiblings => siblingsCount > 1;
}
