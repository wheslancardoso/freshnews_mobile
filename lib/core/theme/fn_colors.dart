import 'package:flutter/material.dart';

class FNColors {
  FNColors._();

  // === Base (Dark Theme) ===
  static const background      = Color(0xFF0A0A0B);
  static const surface         = Color(0xFF111113);
  static const card            = Color(0xFF141416);
  static const foreground      = Color(0xFFFAFAFA);
  static const mutedForeground = Color(0xFFA1A1AA);

  // === World Primaries ===
  static const primaryViolet = Color(0xFF8B5CF6);
  static const primaryGreen  = Color(0xFF22C55E);
  static const primaryYellow = Color(0xFFEAB308);
  static const primaryAmber  = Color(0xFFF59E0B);
  static const primaryPurple = Color(0xFFA855F7);

  // === Glass ===
  static Color glassBg     = Colors.white.withOpacity(0.03);
  static Color glassBorder = Colors.white.withOpacity(0.08);
  static const glassBlur   = 24.0;

  // === Semantic ===
  static const success = Color(0xFF10B981);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info    = Color(0xFF3B82F6);

  // === Categories ===
  static const catIA      = Color(0xFFA78BFA);
  static const catDev     = Color(0xFF10B981);
  static const catSec     = Color(0xFFF43F5E);
  static const catStartup = Color(0xFFF59E0B);
  static const catDefault = Color(0xFF8B5CF6);

  // === Hacker / CRT ===
  static const hackerGreen = Color(0xFF3DF13D);
  static const hackerBg    = Color(0xFF0A0A0A);

  // === Compatibility Fields ===
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF71717A);
  static const border = Color(0xFF27272A);
  static const surfaceVariant = Color(0xFF1F1F1F);
  static const hackerBackground = hackerBg;
  static const hackerGreenDim = Color(0xFF008F11);

  // === Category color helper ===
  static Color forCategory(String category) {
    switch (category.toUpperCase()) {
      case 'IA':
        return catIA;
      case 'DEV':
        return catDev;
      case 'SEGURANÇA':
        return catSec;
      case 'STARTUPS':
        return catStartup;
      default:
        return catDefault;
    }
  }
}
