import 'package:flutter/material.dart';

class HeyoColors {
  // Primary brand colors from logo
  static const Color blue = Color(0xFF4A90B8);      // Face outline
  static const Color yellow = Color(0xFFD4A84B);    // Eyebrows, smile
  static const Color black = Color(0xFF2D2D2D);     // Eyes
  static const Color red = Color(0xFFE85A5A);       // Nose
  static const Color white = Color(0xFFFAFAFA);     // Background

  // Derived colors
  static const Color blueDark = Color(0xFF3A7A9E);
  static const Color blueLight = Color(0xFF6BB0D8);
  static const Color yellowLight = Color(0xFFE8C878);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF666666);

  // Tool colors
  static const Color codeBackground = Color(0xFF1E1E1E);
  static const Color mathBackground = Color(0xFFFFF8E1);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
}

class HeyoTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: HeyoColors.blue,
        onPrimary: Colors.white,
        secondary: HeyoColors.yellow,
        onSecondary: HeyoColors.black,
        surface: HeyoColors.white,
        onSurface: HeyoColors.black,
        error: HeyoColors.red,
      ),
      scaffoldBackgroundColor: HeyoColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: HeyoColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HeyoColors.yellow,
        foregroundColor: HeyoColors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HeyoColors.greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: HeyoColors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: HeyoColors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: HeyoColors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: HeyoColors.black,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
