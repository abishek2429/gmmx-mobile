import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme {
  // Dark theme colors
  static const Color ink = Color(0xFF020D2A);
  static const Color surface = Color(0xFF0E1A36);
  static const Color surfaceSoft = Color(0xFF132448);
  static const Color accent = Color(0xFFFF3E67);
  static const Color accentSoft = Color(0xFFFF6C89);
  static const Color textPrimary = Color(0xFFF7F8FC);
  static const Color textMuted = Color(0xFF93A2C6);

  // Light theme colors
  static const Color lightBg = Color(0xFFFAFAFB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1C);
  static const Color lightMuted = Color(0xFF8E8E93);

  static LinearGradient darkBackground = const LinearGradient(
    colors: [Color(0xFF010C2B), Color(0xFF03081F), Color(0xFF00081E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient lightBackground = const LinearGradient(
    colors: [Color(0xFFFAFAFB), Color(0xFFF5F5F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glassmorphic decorations (dark)
  static BoxDecoration glassCard({double radius = 16, bool isDark = true}) {
    return BoxDecoration(
      color: isDark
          ? surface.withValues(alpha: 0.25)
          : lightCard.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.4),
        width: 1.5,
      ),
    );
  }

  // Glassmorphic button with blur
  static BoxDecoration glassButton(
      {double radius = 12, bool isDark = true, bool isActive = false}) {
    return BoxDecoration(
      color: isDark
          ? (isActive
              ? accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.08))
          : (isActive
              ? accent.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: isActive ? 0.2 : 0.1)
            : Colors.white.withValues(alpha: isActive ? 0.5 : 0.3),
        width: 1,
      ),
    );
  }

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
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: lightCard,
        contentTextStyle: TextStyle(color: lightText),
      ),
    );
  }
}
