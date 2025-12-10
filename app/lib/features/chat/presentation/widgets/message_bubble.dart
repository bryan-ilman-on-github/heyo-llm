import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/message.dart';
import 'tool_result_card.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onEdit;
  final VoidCallback? onRetry;
  final Function(int)? onSwitchBranch;

  const MessageBubble({
    super.key,
    required this.message,
    this.onEdit,
    this.onRetry,
    this.onSwitchBranch,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    if (widget.message.hasToolCalls) {
      return Column(
        children: widget.message.toolCalls!
            .map((tc) => ToolResultCard(toolCall: tc))
            .toList(),
      );
    }

    if (widget.message.isToolResult) {
      return const SizedBox.shrink();
    }

    final isUser = widget.message.role == MessageRole.user;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        setState(() => _showActions = !_showActions);
      },
      onTap: () {
        if (_showActions) setState(() => _showActions = false);
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: isUser ? 56 : 16,
          right: isUser ? 16 : 56,
          top: 10,
          bottom:
              2, // Reduced bottom padding as reserved action row provides spacing
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: _buildBubble(context, isUser),
            ),
            // Action row below message (branch nav + action buttons)
            // Always built to reserve space and prevent layout shifts
            _buildActionRow(context, isUser),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, bool isUser) {
    final hasActions = _showActions && !widget.message.isStreaming;
    final hasBranchNav = widget.message.hasSiblings;

    return SizedBox(
      height: 28, // Reserved height for actions/spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Branch navigation on the left
          if (hasBranchNav)
            _buildBranchNav(context)
          else
            const SizedBox.shrink(),

          // Action buttons on the right
          if (hasActions)
            _buildActionButtons(context, isUser)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBranchNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left arrow
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            isEnabled: widget.message.siblingIndex > 0,
            onTap: () => widget.onSwitchBranch?.call(-1),
          ),
          // Branch indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '${widget.message.siblingIndex + 1}/${widget.message.siblingsCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textTertiary,
              ),
            ),
          ),
          // Right arrow
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            isEnabled:
                widget.message.siblingIndex < widget.message.siblingsCount - 1,
            onTap: () => widget.onSwitchBranch?.call(1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Copy button for all messages
          _ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.message.content));
              setState(() => _showActions = false);
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 4),
          if (isUser && widget.onEdit != null)
            _ActionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              onTap: () {
                setState(() => _showActions = false);
                widget.onEdit?.call();
              },
            ),
          if (!isUser && widget.onRetry != null)
            _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'Retry',
              onTap: () {
                setState(() => _showActions = false);
                widget.onRetry?.call();
              },
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
          if (!isUser &&
              widget.message.content.isEmpty &&
              widget.message.isStreaming)
            _buildTypingIndicator(context)
          else
            Text(
              widget.message.content,
              style: TextStyle(
                color: isUser ? Colors.white : context.textPrimary,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (widget.message.isStreaming && widget.message.content.isNotEmpty)
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: context.textTertiary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? context.textSecondary
                : context.textTertiary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
