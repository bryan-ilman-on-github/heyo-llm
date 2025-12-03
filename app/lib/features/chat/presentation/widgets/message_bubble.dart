import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/message.dart';
import 'tool_result_card.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.hasToolCalls) {
      return Column(
        children: message.toolCalls!
            .map((tc) => ToolResultCard(toolCall: tc))
            .toList(),
      );
    }

    if (message.isToolResult) {
      return const SizedBox.shrink();
    }

    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 60 : 16,
        right: isUser ? 16 : 60,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: _buildBubble(isUser),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? HeyoColors.userBubble : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(24),
          topRight: const Radius.circular(24),
          bottomLeft: Radius.circular(isUser ? 24 : 8),
          bottomRight: Radius.circular(isUser ? 8 : 24),
        ),
        boxShadow: isUser
            ? HeyoShadows.glow(HeyoColors.primary)
            : HeyoShadows.soft,
        border: isUser
            ? null
            : Border.all(
                color: Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && message.content.isEmpty && message.isStreaming)
            _buildTypingIndicator()
          else
            SelectableText(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : HeyoColors.textPrimary,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (message.isStreaming && message.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildStreamingIndicator(isUser),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300 + index * 150),
                  curve: Curves.easeInOut,
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: HeyoColors.textTertiary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildStreamingIndicator(bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              isUser ? Colors.white60 : HeyoColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            color: isUser ? Colors.white60 : HeyoColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: HeyoShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/logo_square.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            decoration: BoxDecoration(
              gradient: HeyoGradients.accentButton,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
