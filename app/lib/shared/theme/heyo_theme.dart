import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeyoColors {
  // Primary brand colors - softer, more modern
  static const Color primary = Color(0xFF6B9DFC);       // Soft blue
  static const Color primaryLight = Color(0xFF98BDFF);
  static const Color primaryDark = Color(0xFF4A7DD9);

  static const Color accent = Color(0xFFFFD166);        // Warm yellow
  static const Color accentLight = Color(0xFFFFE08A);

  // Light mode neutrals
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Dark mode neutrals
  static const Color backgroundDark = Color(0xFF0F1118);
  static const Color surfaceDark = Color(0xFF1A1D26);
  static const Color surfaceVariantDark = Color(0xFF252A36);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFA1A7B4);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // Semantic colors
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);

  // Gradient colors for mesh (light)
  static const Color gradientPink = Color(0xFFFFE4E6);
  static const Color gradientPeach = Color(0xFFFFEDD5);
  static const Color gradientMint = Color(0xFFD1FAE5);
  static const Color gradientLavender = Color(0xFFE9D5FF);
  static const Color gradientSky = Color(0xFFE0F2FE);

  // Gradient colors for mesh (dark)
  static const Color gradientPinkDark = Color(0xFF3D1F2B);
  static const Color gradientPeachDark = Color(0xFF3D2F1F);
  static const Color gradientMintDark = Color(0xFF1F3D2B);
  static const Color gradientLavenderDark = Color(0xFF2B1F3D);
  static const Color gradientSkyDark = Color(0xFF1F2B3D);

  // Glass effect colors (light)
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Glass effect colors (dark)
  static const Color glassDark = Color(0xCC1A1D26);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassShadowDark = Color(0x40000000);

  // Message colors (light)
  static const Color userBubble = Color(0xFF1A1D26);
  static const Color assistantBubble = Color(0xFFFFFFFF);

  // Message colors (dark)
  static const Color userBubbleDark = Color(0xFF6B9DFC);
  static const Color assistantBubbleDark = Color(0xFF252A36);

  // Tool colors
  static const Color toolMath = Color(0xFFFEF3C7);
  static const Color toolCode = Color(0xFF1E293B);
  static const Color toolCodeText = Color(0xFF22D3EE);

  // Branch colors for visualization (rotating palette)
  static const List<Color> branchColors = [
    Color(0xFF6B9DFC),  // Blue (primary)
    Color(0xFFEF4444),  // Red
    Color(0xFF34D399),  // Green
    Color(0xFFFBBF24),  // Yellow
    Color(0xFFA78BFA),  // Purple
    Color(0xFFF472B6),  // Pink
    Color(0xFF22D3EE),  // Cyan
    Color(0xFFFB923C),  // Orange
  ];
}

class HeyoGradients {
  // Light mode gradients
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

  // Dark mode gradient
  static const LinearGradient meshBackgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1520),  // Dark purple-ish
      Color(0xFF151A20),  // Dark blue-ish
      Color(0xFF101A18),  // Dark teal-ish
      Color(0xFF151820),  // Dark navy
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

  // Dark mode shadows (more subtle)
  static List<BoxShadow> softDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glassDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
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

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.dark(
        primary: HeyoColors.primary,
        onPrimary: Colors.white,
        secondary: HeyoColors.accent,
        onSecondary: HeyoColors.textPrimaryDark,
        surface: HeyoColors.surfaceDark,
        onSurface: HeyoColors.textPrimaryDark,
        error: HeyoColors.error,
      ),
      scaffoldBackgroundColor: HeyoColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: HeyoColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: HeyoColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: HeyoColors.textPrimaryDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: HeyoColors.textPrimaryDark,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HeyoColors.textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: HeyoColors.textPrimaryDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: HeyoColors.textSecondaryDark,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: HeyoColors.textTertiaryDark,
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

// Extension methods for theme-aware colors
extension HeyoThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary => isDarkMode ? HeyoColors.textPrimaryDark : HeyoColors.textPrimary;
  Color get textSecondary => isDarkMode ? HeyoColors.textSecondaryDark : HeyoColors.textSecondary;
  Color get textTertiary => isDarkMode ? HeyoColors.textTertiaryDark : HeyoColors.textTertiary;

  Color get surface => isDarkMode ? HeyoColors.surfaceDark : HeyoColors.surface;
  Color get surfaceVariant => isDarkMode ? HeyoColors.surfaceVariantDark : HeyoColors.surfaceVariant;
  Color get background => isDarkMode ? HeyoColors.backgroundDark : HeyoColors.background;

  Color get glassColor => isDarkMode ? HeyoColors.glassDark : HeyoColors.glassWhite;
  Color get glassBorder => isDarkMode ? HeyoColors.glassBorderDark : HeyoColors.glassBorder;

  Color get userBubble => isDarkMode ? HeyoColors.userBubbleDark : HeyoColors.userBubble;
  Color get assistantBubble => isDarkMode ? HeyoColors.assistantBubbleDark : HeyoColors.assistantBubble;

  LinearGradient get meshGradient => isDarkMode ? HeyoGradients.meshBackgroundDark : HeyoGradients.meshBackground;

  List<BoxShadow> get softShadow => isDarkMode ? HeyoShadows.softDark : HeyoShadows.soft;
  List<BoxShadow> get glassShadow => isDarkMode ? HeyoShadows.glassDark : HeyoShadows.glass;
}
