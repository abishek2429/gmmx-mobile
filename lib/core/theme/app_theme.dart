import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static String get _fontFamily => GoogleFonts.outfit().fontFamily ?? 'Outfit';

  /// ForUI light theme
  static FThemeData foruiLight() {
    final colors = FThemes.rose.light.colors.copyWith(
      primary: AppColors.primary,
      primaryForeground: Colors.white,
      secondary: AppColors.surfaceElevatedLight,
      secondaryForeground: AppColors.textPrimary,
      background: AppColors.backgroundLight,
      foreground: AppColors.textPrimary,
      muted: AppColors.surfaceElevatedLight,
      mutedForeground: AppColors.textSecondary,
      border: AppColors.borderLight,
      card: AppColors.surfaceLight,
      destructive: AppColors.error,
      destructiveForeground: Colors.white,
      error: AppColors.error,
      errorForeground: Colors.white,
    );

    return FThemeData(
      colors: colors,
      typography: FTypography.inherit(
        colors: colors,
        defaultFontFamily: _fontFamily,
      ),
    );
  }

  /// ForUI dark theme (OLED-optimized, deep blacks)
  static FThemeData foruiDark() {
    final colors = FThemes.rose.dark.colors.copyWith(
      primary: AppColors.primary,
      primaryForeground: Colors.white,
      secondary: AppColors.surfaceElevatedDark,
      secondaryForeground: AppColors.textPrimaryDark,
      background: AppColors.backgroundDark,
      foreground: AppColors.textPrimaryDark,
      muted: AppColors.secondaryBgDark,
      mutedForeground: AppColors.textSecondaryDark,
      border: AppColors.borderDark,
      card: AppColors.surfaceDark,
      destructive: AppColors.errorDark,
      destructiveForeground: Colors.white,
      error: AppColors.errorDark,
      errorForeground: Colors.white,
    );

    return FThemeData(
      colors: colors,
      typography: FTypography.inherit(
        colors: colors,
        defaultFontFamily: _fontFamily,
      ),
    );
  }

  /// Material light theme
  static ThemeData light() {
    return foruiLight().toApproximateMaterialTheme().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        surfaceContainerHighest: AppColors.surfaceElevatedLight,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Material dark theme (OLED)
  static ThemeData dark() {
    return foruiDark().toApproximateMaterialTheme().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        surfaceContainerHighest: AppColors.surfaceElevatedDark,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevatedDark,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Reusable decoration helpers ───

  static BoxDecoration cardDecoration({required bool isDark, double radius = 20}) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration elevatedCardDecoration({required bool isDark, double radius = 20}) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      ),
    );
  }

  static BoxDecoration glassCard({double radius = 16, bool isDark = true}) {
    return BoxDecoration(
      color: isDark
          ? AppColors.surfaceDark.withOpacity(0.85)
          : AppColors.surfaceLight.withOpacity(0.9),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration glassButton({bool isDark = true, bool isActive = false}) {
    return BoxDecoration(
      color: isActive
          ? AppColors.primary.withOpacity(0.15)
          : (isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isActive
            ? AppColors.primary.withOpacity(0.3)
            : (isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.borderLight),
        width: 1,
      ),
    );
  }

  static BoxDecoration primaryGradient({double radius = 24}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryHover],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration pageBackground({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
    );
  }

  static BoxDecoration glassBackground({required bool isDark}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF0F172A), const Color(0xFF1A0F1F)]
            : [AppColors.backgroundLight, AppColors.surfaceElevatedLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration foregroundGlow({required bool isDark}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: isDark ? 0.06 : 0.03),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }
}
