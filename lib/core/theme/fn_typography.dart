import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';

class FNTypography {
  FNTypography._();

  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: FNColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: FNColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headingLarge => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: FNColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get headingMedium => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: FNColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: FNColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: FNColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: FNColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: FNColors.textMuted,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: FNColors.textSecondary,
        letterSpacing: 0.8,
      );

  static TextStyle get monospace => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: FNColors.hackerGreen,
        height: 1.5,
      );
}
