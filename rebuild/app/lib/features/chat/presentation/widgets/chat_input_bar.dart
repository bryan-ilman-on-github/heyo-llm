import 'package:flutter/material.dart';

import '../../../../core/theme/heyo_theme.dart';
import '../../domain/chat_models.dart';

class ChatInputBar extends StatefulWidget {
  final bool isBusy;
  final List<PendingAttachmentDraft> pendingAttachments;
  final Future<void> Function() onPickAttachments;
  final ValueChanged<String> onRemovePendingAttachment;
  final ValueChanged<String> onSubmit;

  const ChatInputBar({
    super.key,
    required this.isBusy,
    required this.pendingAttachments,
    required this.onPickAttachments,
    required this.onRemovePendingAttachment,
    required this.onSubmit,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _submit() {
    final String text = _textEditingController.text.trim();
    if ((text.isEmpty && widget.pendingAttachments.isEmpty) || widget.isBusy) {
      return;
    }

    _textEditingController.clear();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.surfaceColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: context.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.pendingAttachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.pendingAttachments
                          .map((PendingAttachmentDraft attachment) {
                            return InputChip(
                              avatar: Icon(
                                attachment.kind == ChatAttachmentKind.image
                                    ? Icons.image_outlined
                                    : Icons.description_outlined,
                                size: 16,
                              ),
                              label: Text(
                                attachment.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onDeleted: () => widget.onRemovePendingAttachment(
                                attachment.id,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: widget.isBusy
                          ? null
                          : () {
                              widget.onPickAttachments();
                            },
                      icon: const Icon(Icons.attach_file_rounded),
                      color: context.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Type a memory or ask a question',
                        hintStyle: TextStyle(color: context.textTertiary),
                        contentPadding: const EdgeInsets.fromLTRB(
                          12,
                          16,
                          12,
                          16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: HeyoGradients.primaryButton,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: widget.isBusy ? null : _submit,
                        icon: widget.isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
