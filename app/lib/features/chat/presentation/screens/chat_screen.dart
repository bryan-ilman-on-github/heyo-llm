import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/empty_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo_square.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: HeyoColors.yellow,
                    child: const Icon(Icons.smart_toy_rounded, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Heyo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Consumer<ChatService>(
            builder: (context, chatService, _) {
              if (chatService.messages.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Clear chat',
                onPressed: () => _showClearDialog(context, chatService),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          // Scroll to bottom when messages change
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: chatService.messages.isEmpty
                    ? const EmptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: chatService.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatService.messages[index];
                          // Skip tool result messages as they're rendered in ToolResultCard
                          if (message.isToolResult) {
                            return const SizedBox.shrink();
                          }
                          return MessageBubble(message: message);
                        },
                      ),
              ),
              ChatInput(
                onSend: (text) => chatService.sendMessage(text),
                enabled: !chatService.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, ChatService chatService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              chatService.clearMessages();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: HeyoColors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
