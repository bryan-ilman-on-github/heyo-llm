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
            _buildAvatar(context),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: _buildBubble(context, isUser),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, bool isUser) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? context.userBubble : context.assistantBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(24),
          topRight: const Radius.circular(24),
          bottomLeft: Radius.circular(isUser ? 24 : 8),
          bottomRight: Radius.circular(isUser ? 8 : 24),
        ),
        boxShadow: isUser
            ? HeyoShadows.glow(HeyoColors.primary)
            : context.softShadow,
        border: isUser
            ? null
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && message.content.isEmpty && message.isStreaming)
            _buildTypingIndicator(context)
          else
            SelectableText(
              message.content,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : context.textPrimary,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (message.isStreaming && message.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildStreamingIndicator(context, isUser),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
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
                    color: context.textTertiary.withValues(alpha: 0.6),
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

  Widget _buildStreamingIndicator(BuildContext context, bool isUser) {
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
            color: isUser ? Colors.white60 : context.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: HeyoGradients.primaryButton,
        borderRadius: BorderRadius.circular(10),
        boxShadow: HeyoShadows.glow(HeyoColors.primary),
      ),
      child: const Center(
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
