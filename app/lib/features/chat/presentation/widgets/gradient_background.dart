import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: context.meshGradient,
      ),
      child: Stack(
        children: [
          // Decorative blurred circles for mesh effect
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(
              200,
              (isDark ? HeyoColors.gradientPinkDark : HeyoColors.gradientPink)
                  .withValues(alpha: isDark ? 0.3 : 0.5),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _buildBlurCircle(
              180,
              (isDark ? HeyoColors.gradientMintDark : HeyoColors.gradientMint)
                  .withValues(alpha: isDark ? 0.25 : 0.4),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: _buildBlurCircle(
              160,
              (isDark ? HeyoColors.gradientLavenderDark : HeyoColors.gradientLavender)
                  .withValues(alpha: isDark ? 0.2 : 0.3),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 50,
            child: _buildBlurCircle(
              140,
              (isDark ? HeyoColors.gradientSkyDark : HeyoColors.gradientSky)
                  .withValues(alpha: isDark ? 0.25 : 0.4),
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
