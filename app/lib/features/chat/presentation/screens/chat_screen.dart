import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/chat_service.dart';
import '../../domain/models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/empty_chat.dart';
import '../widgets/gradient_background.dart';
import '../widgets/chat_controls.dart';
import '../widgets/date_separator.dart';
import '../widgets/branch_nav_rail.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _controlsFadeController;
  late AnimationController _menuController;
  bool _showControls = true;
  double _lastScrollOffset = 0;
  bool _showMenu = false;
  bool _isWhisperMode = false; // Design only - not implemented yet
  int _lastMessageCount = 0;
  bool _userHasScrolledUp = false;

  @override
  void initState() {
    super.initState();
    _controlsFadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );

    _menuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _menuController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _showMenu = false);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _openMenu() {
    setState(() => _showMenu = true);
    _menuController.forward();
  }

  void _closeMenu() {
    _menuController.reverse();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // Track if user scrolled up (away from bottom)
    if (maxScroll > 0) {
      final distanceFromBottom = maxScroll - offset;
      _userHasScrolledUp = distanceFromBottom > 100; // More than 100px from bottom
    }

    // Hide/show controls based on scroll direction
    if (delta > 10 && _showControls) {
      setState(() => _showControls = false);
      _controlsFadeController.reverse();
    } else if (delta < -10 && !_showControls) {
      setState(() => _showControls = true);
      _controlsFadeController.forward();
    }

    _lastScrollOffset = offset;
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;

    // Don't auto-scroll if user has scrolled up to read history (unless forced)
    if (_userHasScrolledUp && !force) return;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onNewMessage(int currentCount) {
    // Only scroll on new messages
    if (currentCount > _lastMessageCount) {
      _lastMessageCount = currentCount;
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controlsFadeController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            bottom: false,
            child: Consumer<ChatService>(
              builder: (context, chatService, _) {
                // Only auto-scroll when new messages arrive, not on every rebuild
                final messageCount = chatService.messages.length;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _onNewMessage(messageCount);
                });

                return Stack(
                  children: [
                    // Messages - full height, no top padding blocking
                    Column(
                      children: [
                        Expanded(
                          child: chatService.messages.isEmpty
                              ? EmptyChat(
                                  onSuggestionTap: (suggestion) {
                                    chatService.sendMessage(suggestion);
                                  },
                                )
                              : _buildMessageList(chatService),
                        ),
                        ChatInput(
                          onSend: (text) => chatService.sendMessage(text),
                          onStop: chatService.isLoading ? () {} : null,
                          enabled: !chatService.isLoading,
                          isLoading: chatService.isLoading,
                        ),
                      ],
                    ),

                    // Floating Controls (hamburger + Whisper toggle) - always visible
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ChatControls(
                          onMenuTap: _openMenu,
                          isWhisperMode: _isWhisperMode,
                          onWhisperToggle: () {
                            setState(() => _isWhisperMode = !_isWhisperMode);
                            // Show snackbar explaining it's not implemented yet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isWhisperMode
                                      ? 'Whisper mode enabled (coming soon)'
                                      : 'Whisper mode disabled',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: context.surfaceDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ),

                    // Branch Navigation Rail
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => BranchNavRail(
                        scrollController: _scrollController,
                        messageCount: chatService.messages.where((m) => !m.isToolResult).length,
                        branchTree: chatService.branchTree,
                        branchColoringEnabled: settings.branchColoringEnabled,
                      ),
                    ),

                    // Menu Drawer Overlay
                    if (_showMenu)
                      _buildMenuDrawer(context, chatService),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatService chatService) {
    final messages = chatService.messages.where((m) => !m.isToolResult).toList();

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(top: 70, bottom: 20, right: 28), // Top padding for controls, right for nav rail
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;

        // Check if we need a date separator
        final showDateSeparator = shouldShowDateSeparator(
          previousMessage?.timestamp,
          message.timestamp,
        );

        return Column(
          children: [
            if (showDateSeparator)
              DateSeparator(date: message.timestamp),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index % 3) * 100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: MessageBubble(
                message: chatService.messages.firstWhere((m) => m.id == message.id),
                onEdit: message.role == MessageRole.user
                    ? () => _showEditDialog(context, chatService, message)
                    : null,
                onRetry: message.role == MessageRole.assistant
                    ? () => chatService.retryMessage(message.id)
                    : null,
                onSwitchBranch: message.hasSiblings
                    ? (direction) => chatService.switchBranch(message.id, direction)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuDrawer(BuildContext context, ChatService chatService) {
    return ChatMenuDrawer(
      animation: _menuController,
      onClose: _closeMenu,
      onNewChat: () {
        chatService.clearMessages();
      },
      onClearChat: () => _showClearDialog(context, chatService),
      onSettings: () {
        // TODO: Implement settings
      },
      onAbout: () => _showAboutDialog(context),
      hasMessages: chatService.messages.isNotEmpty,
    );
  }

  void _showClearDialog(BuildContext context, ChatService chatService) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: HeyoShadows.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HeyoColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: HeyoColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Clear conversation?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will delete all messages.\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          chatService.clearMessages();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeyoColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutCubic.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: HeyoGradients.primaryButton,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: HeyoShadows.glow(HeyoColors.primary),
                ),
                child: const Center(
                  child: Text(
                    'H',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Heyo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your intelligent AI assistant\npowered by local LLMs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: context.surfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ChatService chatService, Message message) {
    final controller = TextEditingController(text: message.content);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: HeyoShadows.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    minLines: 2,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(color: context.textTertiary),
                      filled: true,
                      fillColor: context.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newContent = controller.text.trim();
                          if (newContent.isNotEmpty && newContent != message.content) {
                            Navigator.pop(dialogContext);
                            chatService.editMessage(message.id, newContent);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeyoColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save & Send',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutCubic.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }
}

extension _ThemeExtension on BuildContext {
  Color get surfaceDark => HeyoColors.surfaceDark;
}
