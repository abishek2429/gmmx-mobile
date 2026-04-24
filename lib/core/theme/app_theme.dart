import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static String get _fontFamily => GoogleFonts.outfit().fontFamily ?? 'Outfit';

  /// ForUI light theme with coral pink palette
  static FThemeData foruiLight() {
    final colors = FThemes.rose.light.colors.copyWith(
      primary: AppColors.primary,
      primaryForeground: Colors.white,
      secondary: AppColors.secondaryBgLight,
      secondaryForeground: AppColors.textPrimary,
      background: AppColors.backgroundLight,
      foreground: AppColors.textPrimary,
      mutedForeground: AppColors.textSecondary,
      border: AppColors.borderLight,
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

  /// ForUI dark theme with coral pink palette
  static FThemeData foruiDark() {
    final colors = FThemes.rose.dark.colors.copyWith(
      primary: AppColors.primary,
      primaryForeground: Colors.white,
      secondary: AppColors.secondaryBgDark,
      secondaryForeground: AppColors.textPrimaryDark,
      background: AppColors.backgroundDark,
      foreground: AppColors.textPrimaryDark,
      mutedForeground: AppColors.textSecondaryDark,
      border: AppColors.borderDark,
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

  /// Material light theme (for non-ForUI widgets)
  static ThemeData light() {
    return foruiLight().toApproximateMaterialTheme().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
        ),
      ),
    );
  }

  /// Material dark theme (for non-ForUI widgets)
  static ThemeData dark() {
    return foruiDark().toApproximateMaterialTheme().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }

  /// Glassmorphism card decoration
  static BoxDecoration glassCard({double radius = 16, bool isDark = true}) {
    return BoxDecoration(
      color: isDark
          ? AppColors.surfaceDark.withValues(alpha: 0.7)
          : AppColors.surfaceLight.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glass button decoration (backward compat for gmmx_components)
  static BoxDecoration glassButton({bool isDark = true, bool isActive = false}) {
    return BoxDecoration(
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.15)
          : (isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.3)
            : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight),
        width: 1,
      ),
    );
  }
}
