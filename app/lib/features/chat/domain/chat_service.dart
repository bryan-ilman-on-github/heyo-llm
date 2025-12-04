import 'package:flutter/foundation.dart';

import '../../../core/network/stream_parser.dart';
import '../data/chat_api.dart';
import 'models/branch_tree.dart';
import 'models/message.dart';
import 'models/tool_call.dart';

/// Represents a branch point in the conversation tree
class BranchPoint {
  final String messageId;
  final int currentIndex;
  final int totalBranches;

  BranchPoint({
    required this.messageId,
    required this.currentIndex,
    required this.totalBranches,
  });
}

/// Chat service that manages conversation state with branching support
class ChatService extends ChangeNotifier {
  final ChatApi _api;

  // All messages in the conversation tree (keyed by id)
  final Map<String, Message> _messageTree = {};

  // Currently selected branch path (list of message IDs from root to leaf)
  List<String> _currentPath = [];

  bool _isLoading = false;

  ChatService({ChatApi? api}) : _api = api ?? ChatApi();

  /// Get messages in the current branch path
  List<Message> get messages {
    return _currentPath
        .map((id) => _messageTree[id])
        .whereType<Message>()
        .toList();
  }

  /// Get all messages including all branches (for visualization)
  Map<String, Message> get allMessages => Map.unmodifiable(_messageTree);

  bool get isLoading => _isLoading;

  /// Get branch points in current path (messages with multiple children)
  List<BranchPoint> get branchPoints {
    final points = <BranchPoint>[];
    for (final id in _currentPath) {
      final msg = _messageTree[id];
      if (msg != null && msg.hasSiblings) {
        points.add(BranchPoint(
          messageId: id,
          currentIndex: msg.siblingIndex,
          totalBranches: msg.siblingsCount,
        ));
      }
    }
    return points;
  }

  /// Get the complete branch tree model for visualization
  BranchTreeModel get branchTree {
    return BranchTreeModel.fromMessageTree(_messageTree, _currentPath);
  }

  /// Send a new message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Find parent (last message in current path)
    final parentId = _currentPath.isNotEmpty ? _currentPath.last : null;

    // Create user message
    final userMessage = Message.user(content.trim(), parentId: parentId);
    _addMessage(userMessage);

    // Create assistant message placeholder
    final assistantMessage = Message.assistant(
      isStreaming: true,
      parentId: userMessage.id,
    );
    _addMessage(assistantMessage);

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

  /// Edit a user message and create a new branch
  Future<void> editMessage(String messageId, String newContent) async {
    if (newContent.trim().isEmpty) return;

    final originalMessage = _messageTree[messageId];
    if (originalMessage == null || originalMessage.role != MessageRole.user) {
      return;
    }

    // Find the parent of the original message
    final parentId = originalMessage.parentId;

    // Create new user message as sibling
    final newUserMessage = Message.user(newContent.trim(), parentId: parentId);

    // Update sibling info
    if (parentId != null) {
      final parent = _messageTree[parentId];
      if (parent != null) {
        final siblingCount = parent.childrenIds.length + 1;
        newUserMessage.siblingIndex = siblingCount - 1;
        newUserMessage.siblingsCount = siblingCount;

        // Update all siblings' count
        for (final siblingId in parent.childrenIds) {
          final sibling = _messageTree[siblingId];
          if (sibling != null) {
            sibling.siblingsCount = siblingCount;
          }
        }
      }
    }

    _addMessage(newUserMessage);

    // Switch to the new branch
    _switchToBranch(newUserMessage.id);

    // Create assistant response
    final assistantMessage = Message.assistant(
      isStreaming: true,
      parentId: newUserMessage.id,
    );
    _addMessage(assistantMessage);

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

  /// Retry an assistant message (regenerate response)
  Future<void> retryMessage(String messageId) async {
    final originalMessage = _messageTree[messageId];
    if (originalMessage == null ||
        originalMessage.role != MessageRole.assistant) {
      return;
    }

    // Find the parent (user message) of the original assistant message
    final parentId = originalMessage.parentId;
    if (parentId == null) return;

    final parentMessage = _messageTree[parentId];
    if (parentMessage == null) return;

    // Create new assistant message as sibling
    final newAssistantMessage = Message.assistant(
      isStreaming: true,
      parentId: parentId,
    );

    // Update sibling info
    final siblingCount = parentMessage.childrenIds.length + 1;
    newAssistantMessage.siblingIndex = siblingCount - 1;
    newAssistantMessage.siblingsCount = siblingCount;

    // Update all siblings' count
    for (final siblingId in parentMessage.childrenIds) {
      final sibling = _messageTree[siblingId];
      if (sibling != null) {
        sibling.siblingsCount = siblingCount;
      }
    }

    _addMessage(newAssistantMessage);

    // Switch to the new branch
    _switchToBranch(newAssistantMessage.id);

    _isLoading = true;
    notifyListeners();

    try {
      await _processStream(newAssistantMessage);
    } catch (e) {
      newAssistantMessage.content = 'Error: $e';
    } finally {
      newAssistantMessage.isStreaming = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Switch to a different branch at a given message
  void switchBranch(String messageId, int direction) {
    final message = _messageTree[messageId];
    if (message == null || !message.hasSiblings) return;

    // Find parent to get siblings
    final parentId = message.parentId;
    if (parentId == null) return;

    final parent = _messageTree[parentId];
    if (parent == null) return;

    // Calculate new sibling index
    final currentIndex = parent.childrenIds.indexOf(messageId);
    final newIndex = (currentIndex + direction).clamp(0, parent.childrenIds.length - 1);

    if (newIndex == currentIndex) return;

    // Get the new sibling message
    final newSiblingId = parent.childrenIds[newIndex];
    _switchToBranch(newSiblingId);
    notifyListeners();
  }

  /// Switch to view a specific branch
  void _switchToBranch(String messageId) {
    final message = _messageTree[messageId];
    if (message == null) return;

    // Rebuild path from root to this message
    final newPath = <String>[];
    String? currentId = messageId;

    while (currentId != null) {
      newPath.insert(0, currentId);
      currentId = _messageTree[currentId]?.parentId;
    }

    // Now extend path to the deepest child (following first child)
    currentId = messageId;
    while (true) {
      final current = _messageTree[currentId];
      if (current == null || current.childrenIds.isEmpty) break;
      currentId = current.childrenIds.first;
      newPath.add(currentId);
    }

    _currentPath = newPath;
  }

  /// Add a message to the tree
  void _addMessage(Message message) {
    _messageTree[message.id] = message;

    // Link to parent
    if (message.parentId != null) {
      final parent = _messageTree[message.parentId];
      parent?.addChild(message.id);
    }

    // Update current path
    if (message.parentId == null) {
      // Root message
      _currentPath = [message.id];
    } else {
      // Find where parent is in path and add after it
      final parentIndex = _currentPath.indexOf(message.parentId!);
      if (parentIndex >= 0) {
        // Truncate path after parent and add new message
        _currentPath = _currentPath.sublist(0, parentIndex + 1);
        _currentPath.add(message.id);
      } else {
        // Parent not in current path, rebuild path
        _switchToBranch(message.id);
      }
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
          final toolCallMessage = Message(
            id: '${DateTime.now().millisecondsSinceEpoch}_toolcall_${toolCall.id}',
            role: MessageRole.assistant,
            content: '',
            timestamp: DateTime.now(),
            toolCalls: [toolCall],
            parentId: assistantMessage.id,
          );
          _addMessage(toolCallMessage);
          notifyListeners();
          break;

        case StreamEventType.toolResult:
          final errorStr = event.toolResultError;
          final hasError = errorStr != null && errorStr.isNotEmpty;

          for (final tc in pendingToolCalls) {
            if (tc.id == event.toolCallId) {
              tc.result = event.toolResultContent;
              tc.error = hasError ? errorStr : null;
              tc.status =
                  hasError ? ToolCallStatus.failed : ToolCallStatus.completed;
            }
          }

          // Add tool result message
          final lastToolCallId = _currentPath.isNotEmpty ? _currentPath.last : null;
          final toolResultMessage = Message.toolResult(
            toolCallId: event.toolCallId ?? '',
            content: event.toolResultContent ?? errorStr ?? '',
            toolName: _findToolName(event.toolCallId, pendingToolCalls),
            error: hasError ? errorStr : null,
            parentId: lastToolCallId,
          );
          _addMessage(toolResultMessage);
          notifyListeners();
          break;

        case StreamEventType.error:
          assistantMessage.content += '\n\nError: ${event.errorMessage}';
          notifyListeners();
          break;

        case StreamEventType.done:
          break;

        case StreamEventType.unknown:
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
    return messages
        .where((m) =>
            m.id != excludeId &&
            m.role != MessageRole.tool &&
            !m.hasToolCalls)
        .map((m) => m.toOllamaFormat())
        .toList();
  }

  void clearMessages() {
    _messageTree.clear();
    _currentPath.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
