import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeyoColors {
  static const Color primary = Color(0xFF6B9DFC);
  static const Color accent = Color(0xFFFFD166);
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color backgroundDark = Color(0xFF0F1118);
  static const Color surfaceDark = Color(0xFF1A1D26);
  static const Color surfaceVariantDark = Color(0xFF252A36);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFA1A7B4);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color gradientPink = Color(0xFFFFE4E6);
  static const Color gradientMint = Color(0xFFD1FAE5);
  static const Color gradientLavender = Color(0xFFE9D5FF);
  static const Color gradientSky = Color(0xFFE0F2FE);
  static const Color gradientPinkDark = Color(0xFF3D1F2B);
  static const Color gradientMintDark = Color(0xFF1F3D2B);
  static const Color gradientLavenderDark = Color(0xFF2B1F3D);
  static const Color gradientSkyDark = Color(0xFF1F2B3D);
  static const Color userBubble = Color(0xFF1A1D26);
  static const Color assistantBubble = Color(0xFFFFFFFF);
  static const Color userBubbleDark = Color(0xFF6B9DFC);
  static const Color assistantBubbleDark = Color(0xFF252A36);
}

class HeyoGradients {
  static const LinearGradient meshBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF7ED),
      Color(0xFFFDF2F8),
      Color(0xFFECFDF5),
      Color(0xFFF0F9FF),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient meshBackgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1520),
      Color(0xFF151A20),
      Color(0xFF101A18),
      Color(0xFF151820),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B9DFC),
      Color(0xFF8B5CF6),
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

  static List<BoxShadow> softDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.28),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

class HeyoTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
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
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: HeyoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
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
      colorScheme: const ColorScheme.dark(
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
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: HeyoColors.textPrimaryDark,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
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

extension HeyoThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  LinearGradient get meshGradient {
    if (isDarkMode) {
      return HeyoGradients.meshBackgroundDark;
    }
    return HeyoGradients.meshBackground;
  }

  Color get textPrimary {
    if (isDarkMode) {
      return HeyoColors.textPrimaryDark;
    }
    return HeyoColors.textPrimary;
  }

  Color get textSecondary {
    if (isDarkMode) {
      return HeyoColors.textSecondaryDark;
    }
    return HeyoColors.textSecondary;
  }

  Color get textTertiary {
    if (isDarkMode) {
      return HeyoColors.textTertiaryDark;
    }
    return HeyoColors.textTertiary;
  }

  Color get surfaceColor {
    if (isDarkMode) {
      return HeyoColors.surfaceDark;
    }
    return HeyoColors.surface;
  }

  Color get surfaceVariantColor {
    if (isDarkMode) {
      return HeyoColors.surfaceVariantDark;
    }
    return HeyoColors.surfaceVariant;
  }

  Color get userBubbleColor {
    if (isDarkMode) {
      return HeyoColors.userBubbleDark;
    }
    return HeyoColors.userBubble;
  }

  Color get assistantBubbleColor {
    if (isDarkMode) {
      return HeyoColors.assistantBubbleDark;
    }
    return HeyoColors.assistantBubble;
  }

  List<BoxShadow> get softShadow {
    if (isDarkMode) {
      return HeyoShadows.softDark;
    }
    return HeyoShadows.soft;
  }
}
