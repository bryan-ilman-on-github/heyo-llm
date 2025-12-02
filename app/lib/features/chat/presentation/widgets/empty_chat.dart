import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: HeyoColors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/logo_square.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: HeyoColors.yellow,
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 60,
                    color: HeyoColors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Heyo!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: HeyoColors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 16,
              color: HeyoColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildCapabilityChips(),
        ],
      ),
    );
  }

  Widget _buildCapabilityChips() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(Icons.calculate_rounded, 'Math', HeyoColors.yellow),
        _buildChip(Icons.code_rounded, 'Code', HeyoColors.blue),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
