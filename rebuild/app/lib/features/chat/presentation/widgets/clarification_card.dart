import 'package:flutter/material.dart';

import '../../../../core/theme/heyo_theme.dart';
import '../../domain/chat_models.dart';

class ClarificationCard extends StatelessWidget {
  final ClarificationPrompt clarificationPrompt;
  final VoidCallback onStoreMemory;
  final VoidCallback onAskQuestion;

  const ClarificationCard({
    super.key,
    required this.clarificationPrompt,
    required this.onStoreMemory,
    required this.onAskQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.surfaceColor.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: context.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clarificationPrompt.title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                clarificationPrompt.message,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: onStoreMemory,
                      child: const Text('Store memory'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAskQuestion,
                      child: const Text('Ask question'),
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
