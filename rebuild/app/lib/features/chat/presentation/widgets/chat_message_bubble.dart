import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/heyo_theme.dart';
import '../../domain/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageRecord message;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == ChatMessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 56 : 16,
        right: isUser ? 16 : 56,
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isUser
                  ? context.userBubbleColor
                  : context.assistantBubbleColor,
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
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.attachments.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: message.content.trim().isEmpty ? 0 : 10,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.attachments
                          .map((ChatAttachmentRecord attachment) {
                            return _AttachmentChip(
                              attachment: attachment,
                              isUser: isUser,
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                if (message.content.trim().isNotEmpty)
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : context.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                if (message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '(edited)',
                      style: TextStyle(
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.8)
                            : context.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(color: context.textTertiary, fontSize: 11),
              ),
              PopupMenuButton<String>(
                onSelected: (String action) async {
                  if (action == 'copy') {
                    await Clipboard.setData(
                      ClipboardData(text: message.content),
                    );
                  }
                  if (action == 'edit') {
                    onEdit?.call();
                  }
                  if (action == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (BuildContext context) {
                  final List<PopupMenuEntry<String>> items =
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'copy',
                          child: Text('Copy'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];

                  if (isUser) {
                    items.insert(
                      1,
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    );
                  }

                  return items;
                },
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.textTertiary,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AttachmentChip extends StatelessWidget {
  final ChatAttachmentRecord attachment;
  final bool isUser;

  const _AttachmentChip({required this.attachment, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final IconData icon = attachment.kind == ChatAttachmentKind.image
        ? Icons.image_outlined
        : Icons.description_outlined;
    final Color backgroundColor;
    final Color foregroundColor;
    switch (attachment.status) {
      case ChatAttachmentStatus.pending:
        backgroundColor = isUser
            ? Colors.white.withValues(alpha: 0.16)
            : HeyoColors.primary.withValues(alpha: 0.12);
        foregroundColor = isUser ? Colors.white : context.textPrimary;
        break;
      case ChatAttachmentStatus.failed:
        backgroundColor = HeyoColors.error.withValues(alpha: 0.14);
        foregroundColor = isUser ? Colors.white : HeyoColors.error;
        break;
      case ChatAttachmentStatus.ready:
        backgroundColor = isUser
            ? Colors.white.withValues(alpha: 0.16)
            : HeyoColors.success.withValues(alpha: 0.12);
        foregroundColor = isUser ? Colors.white : context.textPrimary;
        break;
    }

    final String label = attachment.displayName?.trim().isNotEmpty == true
        ? attachment.displayName!
        : attachment.kind == ChatAttachmentKind.image
        ? 'Image attachment'
        : 'Document attachment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (attachment.status == ChatAttachmentStatus.pending)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Pending',
                style: TextStyle(
                  color: foregroundColor.withValues(alpha: 0.86),
                  fontSize: 11,
                ),
              ),
            ),
          if (attachment.status == ChatAttachmentStatus.ready)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Ready',
                style: TextStyle(
                  color: foregroundColor.withValues(alpha: 0.86),
                  fontSize: 11,
                ),
              ),
            ),
          if (attachment.status == ChatAttachmentStatus.failed)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Failed',
                style: TextStyle(
                  color: foregroundColor.withValues(alpha: 0.92),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
