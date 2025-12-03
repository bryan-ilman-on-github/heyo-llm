import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/tool_call.dart';

class ToolResultCard extends StatefulWidget {
  final ToolCall toolCall;

  const ToolResultCard({super.key, required this.toolCall});

  @override
  State<ToolResultCard> createState() => _ToolResultCardState();
}

class _ToolResultCardState extends State<ToolResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getAccentColor().withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: context.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                if (widget.toolCall.status == ToolCallStatus.running)
                  _buildLoading(context),
                if (widget.toolCall.isCompleted) _buildResult(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: _getHeaderGradient(),
      ),
      child: Row(
        children: [
          // Tool icon with glow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Tool name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.toolCall.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getToolDescription(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;
    bool isAnimated = false;

    switch (widget.toolCall.status) {
      case ToolCallStatus.pending:
        bgColor = Colors.white.withValues(alpha: 0.2);
        textColor = Colors.white;
        text = 'Pending';
        break;
      case ToolCallStatus.running:
        bgColor = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        text = 'Running';
        isAnimated = true;
        break;
      case ToolCallStatus.completed:
        bgColor = HeyoColors.success.withValues(alpha: 0.9);
        textColor = Colors.white;
        text = 'Done';
        icon = Icons.check_rounded;
        break;
      case ToolCallStatus.failed:
        bgColor = HeyoColors.error.withValues(alpha: 0.9);
        textColor = Colors.white;
        text = 'Failed';
        icon = Icons.close_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else if (icon != null)
            Icon(icon, size: 14, color: textColor),
          if (icon != null || isAnimated) const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getAccentColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getAccentColor()),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing...',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.toolCall.argumentsSummary,
                  style: TextStyle(
                    color: context.textTertiary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final hasError = widget.toolCall.error != null;
    final content = hasError ? widget.toolCall.error! : widget.toolCall.result ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input expression
          Row(
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: context.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.toolCall.argumentsSummary,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Result container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: hasError
                  ? LinearGradient(
                      colors: [
                        HeyoColors.error.withValues(alpha: 0.1),
                        HeyoColors.error.withValues(alpha: 0.05),
                      ],
                    )
                  : _getResultGradient(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? HeyoColors.error.withValues(alpha: 0.2)
                    : _getAccentColor().withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasError && widget.toolCall.name == 'calculate')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Result',
                      style: TextStyle(
                        color: _getAccentColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                SelectableText(
                  content,
                  style: TextStyle(
                    color: hasError ? HeyoColors.error : _getResultTextColor(context),
                    fontSize: widget.toolCall.name == 'calculate' ? 20 : 13,
                    fontFamily: widget.toolCall.name == 'python' ? 'monospace' : null,
                    fontWeight: widget.toolCall.name == 'calculate'
                        ? FontWeight.w700
                        : FontWeight.w400,
                    height: 1.5,
                    letterSpacing: widget.toolCall.name == 'calculate' ? -0.5 : 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.toolCall.name) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'python':
        return Icons.code_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  String _getToolDescription() {
    switch (widget.toolCall.name) {
      case 'calculate':
        return 'Mathematical calculation';
      case 'python':
        return 'Python code execution';
      default:
        return 'Tool execution';
    }
  }

  Color _getAccentColor() {
    switch (widget.toolCall.name) {
      case 'calculate':
        return HeyoColors.accent;
      case 'python':
        return HeyoColors.primary;
      default:
        return HeyoColors.textSecondary;
    }
  }

  LinearGradient _getHeaderGradient() {
    switch (widget.toolCall.name) {
      case 'calculate':
        return HeyoGradients.accentButton;
      case 'python':
        return HeyoGradients.primaryButton;
      default:
        return const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        );
    }
  }

  LinearGradient _getResultGradient(BuildContext context) {
    final isDark = context.isDarkMode;

    switch (widget.toolCall.name) {
      case 'calculate':
        return LinearGradient(
          colors: [
            HeyoColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
            HeyoColors.accent.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
        );
      case 'python':
        return const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        );
      default:
        return LinearGradient(
          colors: [
            context.surfaceVariant,
            context.surfaceVariant.withValues(alpha: 0.5),
          ],
        );
    }
  }

  Color _getResultTextColor(BuildContext context) {
    switch (widget.toolCall.name) {
      case 'python':
        return const Color(0xFF4ADE80); // Green text for code output
      case 'calculate':
        return context.textPrimary;
      default:
        return context.textPrimary;
    }
  }
}
