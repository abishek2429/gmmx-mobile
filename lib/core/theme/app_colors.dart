import 'package:flutter/material.dart';

/// GMMX SaaS-grade color palette
class AppColors {
  // ─── Brand Colors ───
  static const Color primary = Color(0xFFFF5C73);       // Coral Pink
  static const Color primaryHover = Color(0xFFE14B60);
  static const Color primaryLight = Color(0xFFFFE4E8);
  static const Color primarySoft = Color(0xFFFF8A9A);    // Primary Glow (dark)

  // ─── Light Theme ───
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F3F7);
  static const Color secondaryBgLight = Color(0xFFFDECEF);
  static const Color textPrimary = Color(0xFF0D0D12);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B8C4);
  static const Color borderLight = Color(0xFFEBEDF2);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ─── Dark Theme (OLED-optimized) ───
  static const Color backgroundDark = Color(0xFF080810);
  static const Color surfaceDark = Color(0xFF111118);
  static const Color surfaceElevatedDark = Color(0xFF1A1A26);
  static const Color secondaryBgDark = Color(0xFF1E1E2E);
  static const Color textPrimaryDark = Color(0xFFF0F0FF);
  static const Color textSecondaryDark = Color(0xFF8E8EA8);
  static const Color textHintDark = Color(0xFF52526A);
  static const Color borderDark = Color(0xFF1E1E30);
  static const Color dividerDark = Color(0xFF1A1A28);

  // ─── Status Colors ───
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF60A5FA);

  // ─── Plan Tier Colors ───
  static const Color planFree = Color(0xFF64748B);         // Slate
  static const Color planFreeLight = Color(0xFFF1F5F9);
  static const Color planStarter = Color(0xFF2563EB);      // Blue
  static const Color planStarterLight = Color(0xFFEFF6FF);
  static const Color planGrowth = Color(0xFF7C3AED);       // Violet
  static const Color planGrowthLight = Color(0xFFF5F3FF);
  static const Color planPro = Color(0xFFD97706);          // Amber/Gold
  static const Color planProLight = Color(0xFFFFFBEB);

  // ─── Plan Gradients ───
  static const List<Color> planFreeGradient = [Color(0xFF475569), Color(0xFF64748B)];
  static const List<Color> planStarterGradient = [Color(0xFF1D4ED8), Color(0xFF3B82F6)];
  static const List<Color> planGrowthGradient = [Color(0xFF6D28D9), Color(0xFF8B5CF6)];
  static const List<Color> planProGradient = [Color(0xFFB45309), Color(0xFFD97706)];

  // ─── Backward-compatible aliases ───
  static const Color textMain = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color surfaceDarkSoft = secondaryBgDark;
  static const Color primaryContainer = primaryLight;
  static const Color backgroundLight_old = backgroundLight;
  static const Color surfaceLight_old = surfaceLight;
}
