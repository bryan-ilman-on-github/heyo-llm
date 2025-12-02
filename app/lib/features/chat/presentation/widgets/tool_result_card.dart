import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/tool_call.dart';

class ToolResultCard extends StatelessWidget {
  final ToolCall toolCall;

  const ToolResultCard({super.key, required this.toolCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          if (toolCall.status == ToolCallStatus.running) _buildLoading(),
          if (toolCall.isCompleted) _buildResult(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getHeaderColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(11),
          topRight: Radius.circular(11),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            toolCall.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData? icon;

    switch (toolCall.status) {
      case ToolCallStatus.pending:
        color = HeyoColors.grey;
        text = 'Pending';
        break;
      case ToolCallStatus.running:
        color = HeyoColors.yellow;
        text = 'Running';
        break;
      case ToolCallStatus.completed:
        color = HeyoColors.successGreen;
        text = 'Done';
        icon = Icons.check;
        break;
      case ToolCallStatus.failed:
        color = HeyoColors.errorRed;
        text = 'Failed';
        icon = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(HeyoColors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              toolCall.argumentsSummary,
              style: TextStyle(
                color: HeyoColors.black.withOpacity(0.6),
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final hasError = toolCall.error != null;
    final content = hasError ? toolCall.error! : toolCall.result ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input
          Text(
            toolCall.argumentsSummary,
            style: TextStyle(
              color: HeyoColors.greyDark,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          // Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasError
                  ? HeyoColors.errorRed.withOpacity(0.1)
                  : _getResultBackgroundColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              content,
              style: TextStyle(
                color: hasError ? HeyoColors.errorRed : _getResultTextColor(),
                fontSize: 14,
                fontFamily: toolCall.name == 'python' ? 'monospace' : null,
                fontWeight: toolCall.name == 'calculate' ? FontWeight.w600 : null,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (toolCall.name) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'python':
        return Icons.code_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color _getHeaderColor() {
    switch (toolCall.name) {
      case 'calculate':
        return HeyoColors.yellow;
      case 'python':
        return HeyoColors.blue;
      default:
        return HeyoColors.grey;
    }
  }

  Color _getBackgroundColor() {
    return HeyoColors.white;
  }

  Color _getBorderColor() {
    switch (toolCall.name) {
      case 'calculate':
        return HeyoColors.yellow.withOpacity(0.3);
      case 'python':
        return HeyoColors.blue.withOpacity(0.3);
      default:
        return HeyoColors.grey.withOpacity(0.3);
    }
  }

  Color _getResultBackgroundColor() {
    switch (toolCall.name) {
      case 'calculate':
        return HeyoColors.mathBackground;
      case 'python':
        return HeyoColors.codeBackground;
      default:
        return HeyoColors.greyLight;
    }
  }

  Color _getResultTextColor() {
    switch (toolCall.name) {
      case 'python':
        return Colors.white;
      default:
        return HeyoColors.black;
    }
  }
}
