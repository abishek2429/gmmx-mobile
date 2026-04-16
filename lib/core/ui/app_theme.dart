import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF020D2A);
  static const Color surface = Color(0xFF0E1A36);
  static const Color surfaceSoft = Color(0xFF132448);
  static const Color accent = Color(0xFFFF3E67);
  static const Color accentSoft = Color(0xFFFF6C89);
  static const Color textPrimary = Color(0xFFF7F8FC);
  static const Color textMuted = Color(0xFF93A2C6);

  static const Color lightBg = Color(0xFFF3F3F5);
  static const Color lightCard = Color(0xFFE8E8EB);
  static const Color lightText = Color(0xFF31343C);
  static const Color lightMuted = Color(0xFF7E7E88);

  static LinearGradient darkBackground = const LinearGradient(
    colors: [Color(0xFF010C2B), Color(0xFF03081F), Color(0xFF00081E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration darkCard([double radius = 24]) => BoxDecoration(
        color: surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      );

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        onSurface: textPrimary,
      ),
      fontFamily: 'Segoe UI',
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: textPrimary),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        surface: lightCard,
        onSurface: lightText,
      ),
      fontFamily: 'Segoe UI',
    );
  }
}
