import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: HeyoGradients.meshBackground,
      ),
      child: Stack(
        children: [
          // Decorative blurred circles for mesh effect
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(
              200,
              HeyoColors.gradientPink.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _buildBlurCircle(
              180,
              HeyoColors.gradientMint.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: _buildBlurCircle(
              160,
              HeyoColors.gradientLavender.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 50,
            child: _buildBlurCircle(
              140,
              HeyoColors.gradientSky.withValues(alpha: 0.4),
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
