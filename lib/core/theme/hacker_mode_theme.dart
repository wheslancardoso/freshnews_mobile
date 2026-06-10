import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_typography.dart';

class HackerModeTheme {
  HackerModeTheme._();

  static ThemeData get crtTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FNColors.hackerBackground,
      primaryColor: FNColors.hackerGreen,
      colorScheme: const ColorScheme.dark(
        primary: FNColors.hackerGreen,
        secondary: FNColors.hackerGreenDim,
        surface: FNColors.hackerBackground,
        error: FNColors.error,
        onPrimary: FNColors.hackerBackground,
        onSecondary: FNColors.hackerBackground,
        onSurface: FNColors.hackerGreen,
        onError: FNColors.hackerGreen,
      ),
      fontFamily: FNTypography.monospace.fontFamily,
      textTheme: TextTheme(
        displayLarge: FNTypography.monospace.copyWith(fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: FNTypography.monospace.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
        headlineLarge: FNTypography.monospace.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: FNTypography.monospace.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: FNTypography.monospace.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        bodyLarge: FNTypography.monospace.copyWith(fontSize: 16),
        bodyMedium: FNTypography.monospace.copyWith(fontSize: 14),
        bodySmall: FNTypography.monospace.copyWith(fontSize: 12),
        labelLarge: FNTypography.monospace.copyWith(fontSize: 12, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FNColors.hackerBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: FNTypography.monospace.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: FNColors.hackerGreen),
      ),
      cardTheme: CardThemeData(
        color: FNColors.hackerBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: FNColors.hackerGreen, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FNColors.hackerGreenDim,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FNColors.hackerBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: FNColors.hackerGreenDim),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: FNColors.hackerGreenDim),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: FNColors.hackerGreen, width: 1.5),
        ),
        hintStyle: FNTypography.monospace.copyWith(color: FNColors.hackerGreenDim),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FNColors.hackerBackground,
          foregroundColor: FNColors.hackerGreen,
          textStyle: FNTypography.monospace.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: FNColors.hackerGreen),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FNColors.hackerBackground,
        selectedItemColor: FNColors.hackerGreen,
        unselectedItemColor: FNColors.hackerGreenDim,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
