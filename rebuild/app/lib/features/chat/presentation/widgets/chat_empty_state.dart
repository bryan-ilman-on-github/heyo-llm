import 'package:flutter/material.dart';

import '../../../../core/theme/heyo_theme.dart';
import '../../../../core/widgets/heyo_logo_badge.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const ChatEmptyState({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = <String>[
      "Rita's instagram handle is @rita",
      'What is going on in Rita\'s life lately?',
      'March 12, 3pm dentist.',
      'Why do I keep feeling stuck?',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        const SizedBox(height: 12),
        const Center(
          child: HeyoLogoBadge(size: 84, borderRadius: 28),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return HeyoGradients.primaryButton.createShader(bounds);
          },
          child: const Text(
            'Heyo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'One continuous chat for memory, recall, and reflection.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        ...suggestions.map(
          (String suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onSuggestionSelected(suggestion),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.surfaceColor.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: context.textTertiary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
