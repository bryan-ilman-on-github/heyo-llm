import 'package:flutter/material.dart';

import '../../../../core/theme/heyo_theme.dart';
import '../../domain/chat_models.dart';

class MemoryConfirmationPanel extends StatelessWidget {
  final List<MemoryConfirmation> confirmations;
  final ValueChanged<String>? onEntitySelected;

  const MemoryConfirmationPanel({
    super.key,
    required this.confirmations,
    this.onEntitySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (confirmations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: confirmations.map((MemoryConfirmation confirmation) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: HeyoColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: HeyoColors.success.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: HeyoColors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory stored',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        confirmation.content,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      if (confirmation.tags.isNotEmpty ||
                          confirmation.entities.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...confirmation.tags
                                  .take(4)
                                  .map(
                                    (String tag) => _InfoChip(
                                      label: tag,
                                      color: HeyoColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      foregroundColor: context.textSecondary,
                                    ),
                                  ),
                              ...confirmation.entities
                                  .take(4)
                                  .map(
                                    (String entity) => ActionChip(
                                      onPressed: onEntitySelected == null
                                          ? null
                                          : () => onEntitySelected!(entity),
                                      avatar: const Icon(
                                        Icons.person_outline_rounded,
                                        size: 16,
                                      ),
                                      label: Text(entity),
                                      labelStyle: TextStyle(
                                        color: context.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      backgroundColor: HeyoColors.primary
                                          .withValues(alpha: 0.12),
                                      side: BorderSide(
                                        color: HeyoColors.primary.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(
                                        horizontal: -2,
                                        vertical: -2,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundColor;

  const _InfoChip({
    required this.label,
    required this.color,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
