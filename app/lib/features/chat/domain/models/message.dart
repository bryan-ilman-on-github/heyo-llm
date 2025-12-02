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

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.toolCalls,
    this.toolCallId,
    this.metadata,
    this.isStreaming = false,
  });

  factory Message.user(String content) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory Message.assistant({String content = '', bool isStreaming = false}) {
    return Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_assistant',
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
    );
  }

  factory Message.toolResult({
    required String toolCallId,
    required String content,
    required String toolName,
    String? error,
  }) {
    return Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_tool',
      role: MessageRole.tool,
      content: content,
      timestamp: DateTime.now(),
      toolCallId: toolCallId,
      metadata: ToolResultMetadata.forTool(toolName),
    );
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
}
