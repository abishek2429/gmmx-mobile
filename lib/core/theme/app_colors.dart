import 'package:flutter/material.dart';

/// GMMX SaaS-grade color palette
class AppColors {
  // ─── Brand Colors ───
  static const Color primary = Color(0xFFFF5C73);       // Coral Pink
  static const Color primaryHover = Color(0xFFE14B60);
  static const Color primaryLight = Color(0xFFFFE4E8);
  static const Color primarySoft = Color(0xFFFF8A9A);    // Primary Glow (dark)

  // ─── Light Theme ───
  static const Color backgroundLight = Color(0xFFFFF6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color secondaryBgLight = Color(0xFFFDECEF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFF1F1F1);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ─── Dark Theme ───
  static const Color backgroundDark = Color(0xFF0F0F10);
  static const Color surfaceDark = Color(0xFF1A1A1C);
  static const Color secondaryBgDark = Color(0xFF222225);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  static const Color textHintDark = Color(0xFF71717A);
  static const Color borderDark = Color(0xFF2A2A2E);
  static const Color dividerDark = Color(0xFF27272A);

  // ─── Status Colors (Light) ───
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Status Colors (Dark — softer) ───
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color errorDark = Color(0xFFF87171);
  static const Color infoDark = Color(0xFF60A5FA);

  // ─── Backward-compatible aliases ───
  static const Color textMain = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color surfaceDarkSoft = secondaryBgDark;
  static const Color primaryContainer = primaryLight;
  static const Color backgroundLight_old = backgroundLight;
  static const Color surfaceLight_old = surfaceLight;
}
