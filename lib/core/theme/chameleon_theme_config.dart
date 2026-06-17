import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
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

  // Default SPORTS (Laranja Vibrante)
  factory ChameleonThemeConfig.defaultSports() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0F0806),
      accent: const Color(0xFFF97316),
      primary: const Color(0xFFF97316),
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'terminal_glow'],
    );
  }

  // Default GAME (Roxo Arcade)
  factory ChameleonThemeConfig.defaultGame() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF0B080D),
      accent: FNColors.primaryPurple,
      primary: FNColors.primaryPurple,
      fontStyle: 'SpaceGrotesk',
      effects: ['scanlines', 'cloud_compute_grid'],
    );
  }

  // Mapeador dinâmico de categoria geral integrado com FNColors por Mundo
  factory ChameleonThemeConfig.fromCategory(String category, {String? world}) {
    final activeWorld = world != null ? WorldRegistry.fromString(world) : World.tech;
    final primaryColor = FNColors.forCategory(category, world: activeWorld);

    final catUpper = category.toUpperCase();

    // Imersão global: todos os assuntos ganham o brilho e scanlines
    List<String> effects = ['scanlines', 'terminal_glow'];

    Color bg;
    switch (activeWorld) {
      case World.tech:
        bg = const Color(0xFF090A0C);
        if (catUpper.contains('CLOUD')) effects.add('cloud_compute_grid');
        break;
      case World.music:
        bg = const Color(0xFF0C0A09);
        break;
      case World.sports:
        bg = const Color(0xFF0F0806);
        break;
      case World.game:
        bg = const Color(0xFF0B080D);
        if (catUpper.contains('CONSOLE') || catUpper.contains('ESPORTS')) {
          effects.add('cloud_compute_grid');
        }
        break;
    }

    return ChameleonThemeConfig(
      bg: bg,
      accent: primaryColor,
      primary: primaryColor,
      fontStyle: 'SpaceGrotesk',
      effects: effects,
    );
  }
}
