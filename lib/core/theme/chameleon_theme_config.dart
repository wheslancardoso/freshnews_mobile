import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';

class ChameleonThemeConfig {
  final Color bg;
  final Color accent;
  final Color primary;
  final String fontStyle;
  final List<String> effects;

  ChameleonThemeConfig({
    required this.bg,
    required this.accent,
    required this.primary,
    required this.fontStyle,
    required this.effects,
  });

  // Default TECH (Verde Neon)
  factory ChameleonThemeConfig.defaultTech() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF090A0C),
      accent: FNColors.primaryGreen,
      primary: FNColors.primaryGreen,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'terminal_glow'],
    );
  }

  // Default MUSIC (Dourado Hip-Hop)
  factory ChameleonThemeConfig.defaultMusic() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0C0A09),
      accent: FNColors.primaryYellow,
      primary: FNColors.primaryYellow,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines'],
    );
  }

  // IA (Lavender / Purple)
  factory ChameleonThemeConfig.ia() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0C0912),
      accent: FNColors.catIA,
      primary: FNColors.catIA,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'terminal_glow'],
    );
  }

  // DEV (Emerald / Green)
  factory ChameleonThemeConfig.dev() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF090C0A),
      accent: FNColors.catDev,
      primary: FNColors.catDev,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'cloud_compute_grid'],
    );
  }

  // SEGURANÇA (Rose / Red)
  factory ChameleonThemeConfig.security() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0D080A),
      accent: FNColors.catSec,
      primary: FNColors.catSec,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'terminal_glow'],
    );
  }

  // STARTUPS (Amber / Orange)
  factory ChameleonThemeConfig.startups() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0D0B08),
      accent: FNColors.catStartup,
      primary: FNColors.catStartup,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines'],
    );
  }

  // MUSIC Categories (Hip-Hop, Rock/Indie, Electronica)
  factory ChameleonThemeConfig.musicCategory(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains('hip') || catLower.contains('rap') || catLower.contains('hop')) {
      return ChameleonThemeConfig(
        bg: const Color(0xFF0C0B08),
        accent: FNColors.primaryYellow,
        primary: FNColors.primaryYellow,
        fontStyle: 'SpaceGrotesk',
        effects: ['scanlines'],
      );
    }
    if (catLower.contains('rock') || catLower.contains('indie') || catLower.contains('grunge')) {
      return ChameleonThemeConfig(
        bg: const Color(0xFF0D0808),
        accent: FNColors.primaryRed,
        primary: FNColors.primaryRed,
        fontStyle: 'SpaceGrotesk',
        effects: ['scanlines', 'terminal_glow'],
      );
    }
    if (catLower.contains('eletr') || catLower.contains('electro') || catLower.contains('synth') || catLower.contains('dance')) {
      return ChameleonThemeConfig(
        bg: const Color(0xFF0B080D),
        accent: FNColors.primaryPurple,
        primary: FNColors.primaryPurple,
        fontStyle: 'SpaceGrotesk',
        effects: ['scanlines', 'cloud_compute_grid'],
      );
    }

    return ChameleonThemeConfig.defaultMusic();
  }

  // Mapeador dinâmico de categoria geral
  factory ChameleonThemeConfig.fromCategory(String category, {String? world}) {
    final catUpper = category.toUpperCase();
    
    // Se for do mundo MUSIC ou a subcategoria se referir a música
    if (world?.toUpperCase() == 'MUSIC' || 
        catUpper.contains('HIP') || 
        catUpper.contains('ROCK') || 
        catUpper.contains('ELECTRO') ||
        catUpper.contains('INDIE') ||
        catUpper.contains('ELECTRONICA')) {
      return ChameleonThemeConfig.musicCategory(category);
    }

    // Se for do mundo TECH
    if (catUpper.contains('IA') || catUpper.contains('INTELIGÊNCIA')) {
      return ChameleonThemeConfig.ia();
    }
    if (catUpper.contains('DEV') || catUpper.contains('ENGENHARIA')) {
      return ChameleonThemeConfig.dev();
    }
    if (catUpper.contains('SEC') || catUpper.contains('CIBER') || catUpper.contains('HACKER') || catUpper.contains('SEGURANÇA')) {
      return ChameleonThemeConfig.security();
    }
    if (catUpper.contains('STARTUP') || catUpper.contains('BUSINESS') || catUpper.contains('MERCADO') || catUpper.contains('STARTUPS')) {
      return ChameleonThemeConfig.startups();
    }

    // Caso padrão baseado no mundo ativo
    if (world?.toUpperCase() == 'MUSIC') {
      return ChameleonThemeConfig.defaultMusic();
    }
    return ChameleonThemeConfig.defaultTech();
  }
}
