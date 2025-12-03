import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onStop;
  final bool enabled;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onStop,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeOut),
    );
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSend(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.surface.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Row
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? HeyoColors.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Attachment button
                    _buildIconButton(
                      icon: Icons.add_rounded,
                      onTap: () {},
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                    ),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 5,
                        minLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(
                            color: context.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),

                    // Send / Stop button
                    Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 6),
                      child: widget.isLoading
                          ? _buildStopButton()
                          : _buildSendButton(),
                    ),
                  ],
                ),
              ),

              // Feature buttons row
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureChip(
                    icon: Icons.calculate_rounded,
                    label: 'Math',
                    color: HeyoColors.accent,
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureChip(
                    icon: Icons.code_rounded,
                    label: 'Code',
                    color: HeyoColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Create',
                    color: HeyoColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _sendButtonScale,
      child: GestureDetector(
        onTap: _hasText && widget.enabled ? _handleSend : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: _hasText && widget.enabled
                ? HeyoGradients.primaryButton
                : null,
            color: _hasText && widget.enabled
                ? null
                : context.textTertiary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(22),
            boxShadow: _hasText && widget.enabled
                ? HeyoShadows.glow(HeyoColors.primary)
                : null,
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            color: _hasText && widget.enabled
                ? Colors.white
                : context.textTertiary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: widget.onStop,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: HeyoColors.error,
          borderRadius: BorderRadius.circular(22),
          boxShadow: HeyoShadows.glow(HeyoColors.error),
        ),
        child: const Icon(
          Icons.stop_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: context.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
