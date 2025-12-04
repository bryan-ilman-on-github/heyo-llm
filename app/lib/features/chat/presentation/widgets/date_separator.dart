import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

/// Floating date separator that appears between message groups (like WhatsApp)
class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.glassColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.glassBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return _weekdayName(date.weekday);
    } else {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

/// Helper to determine if we should show a date separator between two messages
bool shouldShowDateSeparator(DateTime? previous, DateTime current) {
  if (previous == null) return true;

  final prevDate = DateTime(previous.year, previous.month, previous.day);
  final currDate = DateTime(current.year, current.month, current.day);

  return prevDate != currDate;
}
