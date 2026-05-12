// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary dark background
  static const Color background = Color(0xFF020617);
  // Accent colors for UI elements
  static const Color accentBlue = Color(0xFF00CFFF);
  static const Color accentGreen = Color(0xFF00FFAA);
  static const Color accentRed = Color(0xFFFF4E4E);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentGreen,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white30),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
