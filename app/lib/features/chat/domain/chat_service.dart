import 'package:flutter/foundation.dart';

import '../../../core/network/stream_parser.dart';
import '../data/chat_api.dart';
import 'models/message.dart';
import 'models/tool_call.dart';

/// Chat service that manages conversation state and tool handling
class ChatService extends ChangeNotifier {
  final ChatApi _api;
  final List<Message> _messages = [];
  bool _isLoading = false;

  ChatService({ChatApi? api}) : _api = api ?? ChatApi();

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  /// Send a message and handle the streaming response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = Message.user(content.trim());
    _messages.add(userMessage);
    notifyListeners();

    // Create assistant message placeholder
    final assistantMessage = Message.assistant(isStreaming: true);
    _messages.add(assistantMessage);
    _isLoading = true;
    notifyListeners();

    try {
      await _processStream(assistantMessage);
    } catch (e) {
      assistantMessage.content = 'Error: $e';
    } finally {
      assistantMessage.isStreaming = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _processStream(Message assistantMessage) async {
    final chatHistory = _buildChatHistory(excludeId: assistantMessage.id);

    final stream = _api.sendMessage(messages: chatHistory);

    List<ToolCall> pendingToolCalls = [];

    await for (final event in stream) {
      switch (event.type) {
        case StreamEventType.content:
          final delta = event.contentDelta;
          if (delta != null && delta.isNotEmpty) {
            assistantMessage.content += delta;
            notifyListeners();
          }
          break;

        case StreamEventType.toolCall:
          final toolCall = ToolCall(
            id: event.toolCallId ?? '',
            name: event.toolName ?? '',
            arguments: event.toolArgs ?? {},
            status: ToolCallStatus.running,
          );
          pendingToolCalls.add(toolCall);

          // Add tool call as a message for display
          _messages.add(Message(
            id: '${DateTime.now().millisecondsSinceEpoch}_toolcall_${toolCall.id}',
            role: MessageRole.assistant,
            content: '',
            timestamp: DateTime.now(),
            toolCalls: [toolCall],
          ));
          notifyListeners();
          break;

        case StreamEventType.toolResult:
          // Find and update the tool call
          final errorStr = event.toolResultError;
          final hasError = errorStr != null && errorStr.isNotEmpty;

          for (final tc in pendingToolCalls) {
            if (tc.id == event.toolCallId) {
              tc.result = event.toolResultContent;
              tc.error = hasError ? errorStr : null;
              tc.status = hasError
                  ? ToolCallStatus.failed
                  : ToolCallStatus.completed;
            }
          }

          // Add tool result message
          _messages.add(Message.toolResult(
            toolCallId: event.toolCallId ?? '',
            content: event.toolResultContent ?? errorStr ?? '',
            toolName: _findToolName(event.toolCallId, pendingToolCalls),
            error: hasError ? errorStr : null,
          ));
          notifyListeners();
          break;

        case StreamEventType.error:
          assistantMessage.content += '\n\nError: ${event.errorMessage}';
          notifyListeners();
          break;

        case StreamEventType.done:
          // Stream completed
          break;

        case StreamEventType.unknown:
          // Ignore unknown events
          break;
      }
    }
  }

  String _findToolName(String? toolCallId, List<ToolCall> toolCalls) {
    for (final tc in toolCalls) {
      if (tc.id == toolCallId) return tc.name;
    }
    return 'unknown';
  }

  List<Map<String, dynamic>> _buildChatHistory({String? excludeId}) {
    return _messages
        .where((m) =>
            m.id != excludeId &&
            m.role != MessageRole.tool &&
            !m.hasToolCalls)
        .map((m) => m.toOllamaFormat())
        .toList();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
