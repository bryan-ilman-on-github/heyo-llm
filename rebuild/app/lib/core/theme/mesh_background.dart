import 'package:flutter/material.dart';

import 'heyo_theme.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = context.isDarkMode;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.meshGradient),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _BlurCircle(
              size: 220,
              color: (isDarkMode ? HeyoColors.gradientPinkDark : HeyoColors.gradientPink)
                  .withValues(alpha: isDarkMode ? 0.28 : 0.46),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _BlurCircle(
              size: 180,
              color: (isDarkMode ? HeyoColors.gradientMintDark : HeyoColors.gradientMint)
                  .withValues(alpha: isDarkMode ? 0.24 : 0.38),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: _BlurCircle(
              size: 170,
              color:
                  (isDarkMode ? HeyoColors.gradientLavenderDark : HeyoColors.gradientLavender)
                      .withValues(alpha: isDarkMode ? 0.20 : 0.32),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 36,
            child: _BlurCircle(
              size: 140,
              color: (isDarkMode ? HeyoColors.gradientSkyDark : HeyoColors.gradientSky)
                  .withValues(alpha: isDarkMode ? 0.24 : 0.36),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
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
      ),
    );
  }
}
