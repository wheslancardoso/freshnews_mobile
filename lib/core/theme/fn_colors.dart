import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';

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
  static const primaryRed    = Color(0xFFEF4444);

  // === Glass ===
  static Color glassBg     = Colors.white.withOpacity(0.03);
  static Color glassBorder = Colors.white.withOpacity(0.08);
  static const glassBlur   = 24.0;

  // === Semantic ===
  static const success = Color(0xFF10B981);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info    = Color(0xFF3B82F6);

  // === Legacy Categories (For fallback/compatibility) ===
  static const catIA      = Color(0xFFA78BFA);
  static const catDev     = Color(0xFF10B981);
  static const catSec     = Color(0xFFF43F5E);
  static const catStartup = Color(0xFFF59E0B);
  static const catDefault = Color(0xFF8B5CF6);

  // === Tech World Category Colors === (Verdes/Cyber)
  static const techDev = Color(0xFF10B981);       // Verde Menta / Emerald
  static const techIA = Color(0xFF059669);        // Verde Escuro / IA
  static const techSec = Color(0xFFFF003C);       // Vermelho Neon (Cyberpunk Security)
  static const techStartup = Color(0xFF84CC16);   // Verde Limão
  static const techCloud = Color(0xFF0D9488);     // Teal / Nuvem Verde

  // === Music World Category Colors === (Vibrantes / Palco / Neons Quentes)
  static const musicArtistas = Color(0xFFFF00AA);    // Magenta Pop / Neon Pink
  static const musicProducao = Color(0xFFFF6600);    // Laranja Vibrante / Synth
  static const musicIndie = Color(0xFF00E5FF);       // Ciano Elétrico / Indie Vibe
  static const musicCharts = Color(0xFFFFD700);      // Ouro Puro / Troféu
  static const musicLancamentos = Color(0xFFBFFF00); // Limão Ácido / Novidade

  // === Gear World Category Colors === (Industriais / LEDs / Motores)
  static const gearAutomotivo = Color(0xFFE60000);  // Vermelho Ferrari
  static const gearGadgets = Color(0xFF00BFFF);     // Azul Led / Sky Blue
  static const gearWearables = Color(0xFFFF5500);   // Laranja Segurança / Calor
  static const gearDiy = Color(0xFFA67B5B);         // Cobre / Madeira
  static const gearInovacao = Color(0xFFFF00FF);    // Laser Magenta

  // === Game World Category Colors === (RGB / Arcade / Neons Frios)
  static const gameIndie = Color(0xFFFF3366);       // Rosa Arcade
  static const gameConsole = Color(0xFF3300FF);     // Azul Indigo / Console
  static const gamePc = Color(0xFF00FF66);          // Verde RGB / Razer
  static const gameMobile = Color(0xFFFFB300);      // Dourado Moeda / Token
  static const gameEsports = Color(0xFF9900FF);     // Roxo Competitivo

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
  static Color forCategory(String category, {World? world}) {
    final catUpper = category.toUpperCase();
    final activeWorld = world ?? World.tech;

    switch (activeWorld) {
      case World.tech:
        if (catUpper.contains('DEV') || catUpper.contains('ENGENHARIA')) return techDev;
        if (catUpper.contains('IA') || catUpper.contains('INTELIGÊNCIA')) return techIA;
        if (catUpper.contains('SEC') || catUpper.contains('CIBER') || catUpper.contains('SEGURANÇA')) return techSec;
        if (catUpper.contains('STARTUP') || catUpper.contains('BUSINESS') || catUpper.contains('STARTUPS')) return techStartup;
        if (catUpper.contains('CLOUD') || catUpper.contains('HACKER')) return techCloud;
        final techPool = [techDev, techIA, techSec, techStartup, techCloud];
        return techPool[catUpper.hashCode.abs() % techPool.length];

      case World.music:
        if (catUpper.contains('ARTISTAS') || catUpper.contains('SCENE') || catUpper.contains('MUSIC_ARTISTS')) return musicArtistas;
        if (catUpper.contains('PRODUÇÃO') || catUpper.contains('PRODUCAO') || catUpper.contains('BEAT') || catUpper.contains('AUDIO') || catUpper.contains('MUSIC_PRODUCTION')) return musicProducao;
        if (catUpper.contains('INDIE') || catUpper.contains('DIY') || catUpper.contains('UNDERGROUND') || catUpper.contains('MUSIC_INDIE')) return musicIndie;
        if (catUpper.contains('CHARTS') || catUpper.contains('ROYAL') || catUpper.contains('STATS') || catUpper.contains('MUSIC_CHARTS')) return musicCharts;
        if (catUpper.contains('LANÇAMENTOS') || catUpper.contains('LANCAMENTOS') || catUpper.contains('REVIEW') || catUpper.contains('MUSIC_RELEASES')) return musicLancamentos;
        final musicPool = [musicArtistas, musicProducao, musicIndie, musicCharts, musicLancamentos];
        return musicPool[catUpper.hashCode.abs() % musicPool.length];

      case World.gear:
        if (catUpper.contains('AUTOMOTIVO') || catUpper.contains('AUTO') || catUpper.contains('RPM') || catUpper.contains('GEAR_AUTO')) return gearAutomotivo;
        if (catUpper.contains('GADGET') || catUpper.contains('HARDWARE') || catUpper.contains('CHIP') || catUpper.contains('GEAR_GADGETS')) return gearGadgets;
        if (catUpper.contains('WEARABLE') || catUpper.contains('BIO') || catUpper.contains('BIOMÉTRICA') || catUpper.contains('GEAR_WEARABLES')) return gearWearables;
        if (catUpper.contains('DIY') || catUpper.contains('MAKER') || catUpper.contains('ELETRÔNICA') || catUpper.contains('GEAR_DIY')) return gearDiy;
        if (catUpper.contains('INOVAÇÃO') || catUpper.contains('INOVACAO') || catUpper.contains('ROBÓTICA') || catUpper.contains('SEMICOND') || catUpper.contains('GEAR_INNOVATION')) return gearInovacao;
        final gearPool = [gearAutomotivo, gearGadgets, gearWearables, gearDiy, gearInovacao];
        return gearPool[catUpper.hashCode.abs() % gearPool.length];

      case World.game:
        if (catUpper.contains('INDIE') || catUpper.contains('RETRO') || catUpper.contains('GAME_INDIE')) return gameIndie;
        if (catUpper.contains('CONSOLE') || catUpper.contains('EMULA') || catUpper.contains('HACK') || catUpper.contains('GAME_CONSOLE')) return gameConsole;
        if (catUpper.contains('PC') || catUpper.contains('GRAPHIC') || catUpper.contains('GAME_PC')) return gamePc;
        if (catUpper.contains('MOBILE') || catUpper.contains('ARM') || catUpper.contains('PORTABLE') || catUpper.contains('GAME_MOBILE')) return gameMobile;
        if (catUpper.contains('ESPORTS') || catUpper.contains('COMPET') || catUpper.contains('GAME_ESPORTS')) return gameEsports;
        final gamePool = [gameIndie, gameConsole, gamePc, gameMobile, gameEsports];
        return gamePool[catUpper.hashCode.abs() % gamePool.length];
    }
  }
}
