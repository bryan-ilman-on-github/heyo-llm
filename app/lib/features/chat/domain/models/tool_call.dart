enum ToolCallStatus { pending, running, completed, failed }

class ToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  ToolCallStatus status;
  String? result;
  String? error;

  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.status = ToolCallStatus.pending,
    this.result,
    this.error,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arguments: json['args'] ?? json['arguments'] ?? {},
    );
  }

  bool get isCompleted =>
      status == ToolCallStatus.completed || status == ToolCallStatus.failed;

  String get displayName {
    switch (name) {
      case 'calculate':
        return 'Calculator';
      case 'python':
        return 'Python';
      default:
        return name;
    }
  }

  String get argumentsSummary {
    if (name == 'calculate' && arguments.containsKey('expression')) {
      return arguments['expression'].toString();
    }
    if (name == 'python' && arguments.containsKey('code')) {
      final code = arguments['code'].toString();
      return code.length > 50 ? '${code.substring(0, 50)}...' : code;
    }
    return arguments.toString();
  }
}

class ToolResultMetadata {
  final String toolName;
  final String? renderType; // 'code', 'math', 'image', 'table', etc.
  final Map<String, dynamic>? extra;

  ToolResultMetadata({
    required this.toolName,
    this.renderType,
    this.extra,
  });

  factory ToolResultMetadata.forTool(String toolName) {
    switch (toolName) {
      case 'calculate':
        return ToolResultMetadata(toolName: toolName, renderType: 'math');
      case 'python':
        return ToolResultMetadata(toolName: toolName, renderType: 'code');
      default:
        return ToolResultMetadata(toolName: toolName);
    }
  }
}
