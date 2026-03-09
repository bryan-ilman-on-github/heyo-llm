import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/heyo_theme.dart';
import '../../../core/theme/mesh_background.dart';
import '../../../core/widgets/heyo_logo_badge.dart';
import '../../entities/presentation/entity_detail_screen.dart';
import '../../entities/presentation/entity_directory_screen.dart';
import '../data/local/app_database.dart';
import '../domain/chat_models.dart';
import 'chat_controller.dart';
import 'quota_and_export_screen.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/clarification_card.dart';
import 'widgets/memory_confirmation_panel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastAutoScrolledMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels < 120) {
      context.read<ChatController>().loadMoreHistory();
    }
  }

  Future<void> _openEntityDirectory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const EntityDirectoryScreen(),
      ),
    );
  }

  Future<void> _openEntityDetailByReference(String entityReference) async {
    final AppDatabase appDatabase = context.read<AppDatabase>();
    final String? entityId = await appDatabase.findEntityIdByReference(
      entityReference,
    );
    if (!mounted || entityId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            EntityDetailScreen(entityId: entityId),
      ),
    );
  }

  Future<void> _openQuotaAndExport() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const QuotaAndExportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Consumer<ChatController>(
            builder:
                (
                  BuildContext context,
                  ChatController chatController,
                  Widget? child,
                ) {
                  WidgetsBinding.instance.addPostFrameCallback((Duration _) {
                    if (!mounted) {
                      return;
                    }
                    final int messageCount = chatController.messages.length;
                    if (_lastAutoScrolledMessageCount == messageCount) {
                      return;
                    }
                    if (_scrollController.hasClients &&
                        _scrollController.position.maxScrollExtent > 0) {
                      _lastAutoScrolledMessageCount = messageCount;
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                      );
                      return;
                    }
                    _lastAutoScrolledMessageCount = messageCount;
                  });

                  return Column(
                    children: [
                      _Header(
                        isBusy: chatController.isBusy,
                        hasMessages: chatController.hasMessages,
                        onOpenEntities: _openEntityDirectory,
                        onOpenQuotaAndExport: _openQuotaAndExport,
                      ),
                      if (chatController.clarificationPrompt != null)
                        ClarificationCard(
                          clarificationPrompt:
                              chatController.clarificationPrompt!,
                          onStoreMemory:
                              chatController.resolveClarificationAsMemory,
                          onAskQuestion:
                              chatController.resolveClarificationAsQuestion,
                        ),
                      MemoryConfirmationPanel(
                        confirmations: chatController.memoryConfirmations,
                        onEntitySelected: _openEntityDetailByReference,
                      ),
                      Expanded(
                        child: chatController.messages.isEmpty
                            ? ChatEmptyState(
                                onSuggestionSelected:
                                    chatController.submitMessage,
                              )
                            : _MessageList(
                                scrollController: _scrollController,
                                messages: chatController.messages,
                              ),
                      ),
                      if (chatController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            chatController.errorMessage!,
                            style: const TextStyle(
                              color: HeyoColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ChatInputBar(
                        isBusy: chatController.isBusy,
                        pendingAttachments: chatController.pendingAttachments,
                        onPickAttachments: chatController.pickAttachments,
                        onRemovePendingAttachment:
                            chatController.removePendingAttachment,
                        onSubmit: chatController.submitMessage,
                      ),
                    ],
                  );
                },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isBusy;
  final bool hasMessages;
  final VoidCallback onOpenEntities;
  final VoidCallback onOpenQuotaAndExport;

  const _Header({
    required this.isBusy,
    required this.hasMessages,
    required this.onOpenEntities,
    required this.onOpenQuotaAndExport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          const HeyoLogoBadge(size: 40, borderRadius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heyo',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  hasMessages
                      ? 'Linear chat with local memory'
                      : 'Store memories or ask grounded questions',
                  style: TextStyle(color: context.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onOpenEntities,
            icon: const Icon(Icons.people_alt_outlined, size: 18),
            label: const Text('Entities'),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (String value) {
              if (value == 'quota_export') {
                onOpenQuotaAndExport();
              }
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'quota_export',
                child: Text('Quota & export'),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isBusy
                ? const SizedBox(
                    key: ValueKey<String>('busy'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const SizedBox(
                    key: ValueKey<String>('idle'),
                    width: 20,
                    height: 20,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessageRecord> messages;

  const _MessageList({required this.scrollController, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: messages.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(height: 8);
        }

        final ChatMessageRecord message = messages[index - 1];

        return ChatMessageBubble(
          message: message,
          onEdit: message.role == ChatMessageRole.user
              ? () => _showEditSheet(context, message)
              : null,
          onDelete: () =>
              context.read<ChatController>().deleteMessage(message.id),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, ChatMessageRecord message) {
    final TextEditingController textEditingController = TextEditingController(
      text: message.content,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            top: 20,
            right: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit message',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textEditingController,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    await context.read<ChatController>().editMessage(
                      messageId: message.id,
                      newContent: textEditingController.text,
                    );
                    if (bottomSheetContext.mounted) {
                      Navigator.of(bottomSheetContext).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
