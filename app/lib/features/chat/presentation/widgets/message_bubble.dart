import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/message.dart';
import 'tool_result_card.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Tool call messages
    if (message.hasToolCalls) {
      return Column(
        children: message.toolCalls!
            .map((tc) => ToolResultCard(toolCall: tc))
            .toList(),
      );
    }

    // Tool result messages - rendered inline as part of the flow
    if (message.isToolResult) {
      return const SizedBox.shrink(); // Handled by ToolResultCard
    }

    // Regular messages
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? HeyoColors.blue : HeyoColors.greyLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.isNotEmpty || message.isStreaming)
                    SelectableText(
                      message.content.isEmpty && message.isStreaming
                          ? '...'
                          : message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : HeyoColors.black,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  if (message.isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUser ? Colors.white70 : HeyoColors.blue,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: HeyoColors.yellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo_square.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.smart_toy_rounded,
            color: HeyoColors.black,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: HeyoColors.blueDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
