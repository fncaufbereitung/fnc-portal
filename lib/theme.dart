import 'package:flutter/material.dart';

abstract final class FncColors {
  static const ink = Color(0xFF171816);
  static const ivory = Color(0xFFF6F3EC);
  static const surface = Color(0xFFFFFDF8);
  static const line = Color(0xFFE3DED3);
  static const gold = Color(0xFFB38A4A);
  static const muted = Color(0xFF6E706A);
}

abstract final class FncTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: FncColors.gold).copyWith(
      primary: FncColors.ink,
      secondary: FncColors.gold,
      surface: FncColors.surface,
    ),
    scaffoldBackgroundColor: FncColors.ivory,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: FncColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: FncColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: FncColors.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FncColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FncColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FncColors.gold, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        backgroundColor: FncColors.ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: FncColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: FncColors.line),
      ),
    ),
  );
}
