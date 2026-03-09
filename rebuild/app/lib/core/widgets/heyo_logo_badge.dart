import 'package:flutter/material.dart';

import '../theme/heyo_theme.dart';

class HeyoLogoBadge extends StatelessWidget {
  final double size;
  final double borderRadius;

  const HeyoLogoBadge({
    super.key,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: context.isDarkMode ? 0.94 : 0.98),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: HeyoShadows.glow(HeyoColors.primary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/logo_square.jpg',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
