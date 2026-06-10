import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fn_colors.dart';

// ─── Typography ─────────────────────────────────────────────────────────────

class FNTypography {
  FNTypography._();

  static TextStyle get body    => GoogleFonts.inter();
  static TextStyle get heading => GoogleFonts.outfit();
  static TextStyle get mono    => GoogleFonts.jetBrainsMono();

  // Compatibility getter for HackerModeTheme and other references
  static TextStyle get monospace => mono;

  // Headlines
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 48, fontWeight: FontWeight.w900,
    letterSpacing: -2, height: 0.85,
  );
  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 36, fontWeight: FontWeight.w900,
    letterSpacing: -1.5, height: 0.9,
  );
  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 28, fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500, height: 1.6,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
  );

  // Tech labels
  static TextStyle techLabel = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w900,
    letterSpacing: 3, height: 1,
  );
  static TextStyle techLabelSmall = GoogleFonts.inter(
    fontSize: 9, fontWeight: FontWeight.w900,
    letterSpacing: 4, height: 1,
  );

  // Mono
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.6,
  );
}

// ─── Spacing ────────────────────────────────────────────────────────────────

class FNSpacing {
  FNSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 48;
  static const double xxxl = 64;

  static const pagePadding    = EdgeInsets.symmetric(horizontal: 24);
  static const sectionPadding = EdgeInsets.symmetric(vertical: 48);
}

// ─── Theme ──────────────────────────────────────────────────────────────────

class FNTheme {
  FNTheme._();

  static ThemeData darkTheme({Color? primaryColor}) {
    final primary = primaryColor ?? FNColors.primaryViolet;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FNColors.background,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary.withOpacity(0.7),
        surface: FNColors.surface,
        onPrimary: Colors.white,
        onSurface: FNColors.foreground,
        error: FNColors.error,
      ),
      textTheme: TextTheme(
        displayLarge:  FNTypography.h1.copyWith(color: FNColors.foreground),
        displayMedium: FNTypography.h2.copyWith(color: FNColors.foreground),
        displaySmall:  FNTypography.h3.copyWith(color: FNColors.foreground),
        bodyLarge:     FNTypography.bodyLarge.copyWith(color: FNColors.foreground),
        bodyMedium:    FNTypography.bodyMedium.copyWith(color: FNColors.foreground),
        bodySmall:     FNTypography.bodySmall.copyWith(color: FNColors.mutedForeground),
        labelSmall:    FNTypography.techLabel.copyWith(color: FNColors.mutedForeground),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: FNTypography.h3.copyWith(
          color: FNColors.foreground,
          fontStyle: FontStyle.italic,
        ),
      ),
      cardTheme: CardThemeData(
        color: FNColors.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0x14FFFFFF)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: FNColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withOpacity(0.5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        hintStyle: FNTypography.bodyMedium.copyWith(
          color: FNColors.mutedForeground.withOpacity(0.3),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: FNColors.glassBorder,
        thickness: 1,
      ),
    );
  }
}
