import 'dart:convert';

/// Event types from the server
enum StreamEventType {
  content,
  toolCall,
  toolResult,
  error,
  done,
  unknown,
}

/// Parsed stream event
class StreamEvent {
  final StreamEventType type;
  final Map<String, dynamic> data;

  StreamEvent({required this.type, required this.data});

  String? get contentDelta => type == StreamEventType.content ? data['delta'] as String? : null;

  String? get toolCallId =>
      (type == StreamEventType.toolCall || type == StreamEventType.toolResult)
          ? data['id'] as String?
          : null;

  String? get toolName => type == StreamEventType.toolCall ? data['name'] as String? : null;

  Map<String, dynamic>? get toolArgs =>
      type == StreamEventType.toolCall ? data['args'] as Map<String, dynamic>? : null;

  String? get toolResultContent =>
      type == StreamEventType.toolResult ? data['content'] as String? : null;

  String? get toolResultError =>
      type == StreamEventType.toolResult ? data['error'] as String? : null;

  String? get errorMessage => type == StreamEventType.error ? data['error'] as String? : null;
}

/// Parses NDJSON stream from the server
class StreamParser {
  /// Parse a single line of NDJSON into a StreamEvent
  static StreamEvent? parseLine(String line) {
    if (line.trim().isEmpty) return null;

    try {
      final data = jsonDecode(line) as Map<String, dynamic>;

      // New format with explicit type
      if (data.containsKey('type')) {
        return _parseTypedEvent(data);
      }

      // Legacy Ollama format
      return _parseLegacyEvent(data);
    } catch (e) {
      return null;
    }
  }

  static StreamEvent _parseTypedEvent(Map<String, dynamic> data) {
    final typeStr = data['type'] as String?;

    switch (typeStr) {
      case 'content':
        return StreamEvent(type: StreamEventType.content, data: data);
      case 'tool_call':
        return StreamEvent(type: StreamEventType.toolCall, data: data);
      case 'tool_result':
        return StreamEvent(type: StreamEventType.toolResult, data: data);
      case 'error':
        return StreamEvent(type: StreamEventType.error, data: data);
      case 'done':
        return StreamEvent(type: StreamEventType.done, data: data);
      default:
        return StreamEvent(type: StreamEventType.unknown, data: data);
    }
  }

  static StreamEvent _parseLegacyEvent(Map<String, dynamic> data) {
    // Legacy Ollama format: {"message": {"content": "..."}, "done": false}
    if (data.containsKey('message')) {
      final message = data['message'] as Map<String, dynamic>?;
      if (message != null && message.containsKey('content')) {
        return StreamEvent(
          type: StreamEventType.content,
          data: {'delta': message['content']},
        );
      }
    }

    if (data['done'] == true) {
      return StreamEvent(type: StreamEventType.done, data: data);
    }

    return StreamEvent(type: StreamEventType.unknown, data: data);
  }
}
