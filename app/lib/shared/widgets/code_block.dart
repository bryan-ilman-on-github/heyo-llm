import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

import '../theme/heyo_theme.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  final bool showCopyButton;
  final bool showLineNumbers;
  final bool darkTheme;
  final double? maxHeight;

  const CodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showCopyButton = true,
    this.showLineNumbers = false,
    this.darkTheme = true,
    this.maxHeight,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.darkTheme ? atomOneDarkTheme : atomOneLightTheme;
    final bgColor = widget.darkTheme
        ? const Color(0xFF282C34)
        : const Color(0xFFFAFAFA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.darkTheme
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with language and copy button
          if (widget.language != null || widget.showCopyButton)
            _buildHeader(bgColor),
          // Code content
          _buildCodeContent(theme, bgColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.darkTheme
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      child: Row(
        children: [
          if (widget.language != null) ...[
            Icon(
              Icons.code,
              size: 14,
              color: widget.darkTheme ? Colors.white60 : HeyoColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              widget.language!,
              style: TextStyle(
                fontSize: 12,
                color: widget.darkTheme ? Colors.white60 : HeyoColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          if (widget.showCopyButton)
            GestureDetector(
              onTap: _copyToClipboard,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _copied
                      ? HeyoColors.success.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _copied ? Icons.check : Icons.copy,
                      size: 14,
                      color: _copied
                          ? HeyoColors.success
                          : (widget.darkTheme ? Colors.white60 : HeyoColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                        fontSize: 11,
                        color: _copied
                            ? HeyoColors.success
                            : (widget.darkTheme ? Colors.white60 : HeyoColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeContent(Map<String, TextStyle> theme, Color bgColor) {
    Widget codeWidget = HighlightView(
      widget.code,
      language: widget.language ?? 'python',
      theme: theme,
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.5,
      ),
    );

    if (widget.maxHeight != null) {
      codeWidget = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: SingleChildScrollView(
          child: codeWidget,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: const Radius.circular(7),
        bottomRight: const Radius.circular(7),
        topLeft: Radius.circular(
          (widget.language != null || widget.showCopyButton) ? 0 : 7,
        ),
        topRight: Radius.circular(
          (widget.language != null || widget.showCopyButton) ? 0 : 7,
        ),
      ),
      child: codeWidget,
    );
  }
}

/// A simpler output block for tool results (no syntax highlighting)
class OutputBlock extends StatelessWidget {
  final String output;
  final bool isError;
  final bool showCopyButton;

  const OutputBlock({
    super.key,
    required this.output,
    this.isError = false,
    this.showCopyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? HeyoColors.error.withValues(alpha: 0.1)
            : HeyoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? HeyoColors.error.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: SelectableText(
        output,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: isError ? HeyoColors.error : HeyoColors.textPrimary,
        ),
      ),
    );
  }
}
