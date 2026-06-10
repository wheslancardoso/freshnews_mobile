import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_typography.dart';

class FNTheme {
  FNTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FNColors.background,
      primaryColor: FNColors.worldTech,
      colorScheme: const ColorScheme.dark(
        primary: FNColors.worldTech,
        secondary: FNColors.worldMusic,
        surface: FNColors.surface,
        error: FNColors.error,
        onPrimary: FNColors.background,
        onSecondary: FNColors.background,
        onSurface: FNColors.textPrimary,
        onError: FNColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: FNTypography.displayLarge,
        displayMedium: FNTypography.displayMedium,
        headlineLarge: FNTypography.headingLarge,
        headlineMedium: FNTypography.headingMedium,
        headlineSmall: FNTypography.headingSmall,
        bodyLarge: FNTypography.bodyLarge,
        bodyMedium: FNTypography.bodyMedium,
        bodySmall: FNTypography.bodySmall,
        labelLarge: FNTypography.label,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FNColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: FNTypography.headingMedium,
        iconTheme: const IconThemeData(color: FNColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: FNColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: FNColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FNColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FNColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FNColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FNColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FNColors.worldTech, width: 1.5),
        ),
        hintStyle: FNTypography.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FNColors.worldTech,
          foregroundColor: FNColors.background,
          textStyle: FNTypography.headingSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FNColors.surface,
        selectedItemColor: FNColors.worldTech,
        unselectedItemColor: FNColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
