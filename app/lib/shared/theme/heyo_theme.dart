import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeyoColors {
  // Primary brand colors - softer, more modern
  static const Color primary = Color(0xFF6B9DFC);       // Soft blue
  static const Color primaryLight = Color(0xFF98BDFF);
  static const Color primaryDark = Color(0xFF4A7DD9);

  static const Color accent = Color(0xFFFFD166);        // Warm yellow
  static const Color accentLight = Color(0xFFFFE08A);

  // Neutrals
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Semantic colors
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);

  // Gradient colors for mesh
  static const Color gradientPink = Color(0xFFFFE4E6);
  static const Color gradientPeach = Color(0xFFFFEDD5);
  static const Color gradientMint = Color(0xFFD1FAE5);
  static const Color gradientLavender = Color(0xFFE9D5FF);
  static const Color gradientSky = Color(0xFFE0F2FE);

  // Glass effect colors
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Message colors
  static const Color userBubble = Color(0xFF1A1D26);
  static const Color assistantBubble = Color(0xFFFFFFFF);

  // Tool colors
  static const Color toolMath = Color(0xFFFEF3C7);
  static const Color toolCode = Color(0xFF1E293B);
  static const Color toolCodeText = Color(0xFF22D3EE);
}

class HeyoGradients {
  static const LinearGradient meshBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF7ED),  // Warm cream
      Color(0xFFFDF2F8),  // Soft pink
      Color(0xFFECFDF5),  // Mint
      Color(0xFFF0F9FF),  // Sky
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE4E6),
      Color(0xFFFFEDD5),
      Color(0xFFD1FAE5),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B9DFC),
      Color(0xFF8B5CF6),
    ],
  );

  static const LinearGradient accentButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD166),
      Color(0xFFFBBF24),
    ],
  );

  static RadialGradient glowEffect(Color color) => RadialGradient(
    colors: [
      color.withValues(alpha: 0.3),
      color.withValues(alpha: 0.0),
    ],
  );
}

class HeyoShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glass = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.8),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

class HeyoTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.light(
        primary: HeyoColors.primary,
        onPrimary: Colors.white,
        secondary: HeyoColors.accent,
        onSecondary: HeyoColors.textPrimary,
        surface: HeyoColors.surface,
        onSurface: HeyoColors.textPrimary,
        error: HeyoColors.error,
      ),
      scaffoldBackgroundColor: HeyoColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: HeyoColors.textPrimary),
        titleTextStyle: TextStyle(
          color: HeyoColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: HeyoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: HeyoColors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HeyoColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: HeyoColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: HeyoColors.textSecondary,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: HeyoColors.textTertiary,
        ),
      ),
    );
  }
}

// Glass morphism decoration
class GlassDecoration extends BoxDecoration {
  GlassDecoration({
    double borderRadius = 20,
    Color? color,
    Border? border,
  }) : super(
    color: color ?? HeyoColors.glassWhite,
    borderRadius: BorderRadius.circular(borderRadius),
    border: border ?? Border.all(
      color: HeyoColors.glassBorder,
      width: 1,
    ),
    boxShadow: HeyoShadows.glass,
  );
}
