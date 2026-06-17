import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

enum World {
  tech,
  music,
  gear,
  game,
}

class WorldMeta {
  final World world;
  final String label;
  final String emoji;
  final Color primaryColor;
  final String tagline;
  final String quickTakesTitle;
  final List<String> categories;

  const WorldMeta({
    required this.world,
    required this.label,
    required this.emoji,
    required this.primaryColor,
    required this.tagline,
    required this.quickTakesTitle,
    required this.categories,
  });
}

class WorldRegistry {
  static const Map<World, WorldMeta> all = {
    World.tech: WorldMeta(
      world: World.tech,
      label: 'TECH',
      emoji: '💻',
      primaryColor: Color(0xFF22C55E),
      tagline: 'CÓDIGO & IA',
      quickTakesTitle: '⚡ GIRO TECH',
      categories: ['DEV', 'IA', 'SEGURANÇA', 'STARTUPS', 'CLOUD'],
    ),
    World.music: WorldMeta(
      world: World.music,
      label: 'MUSIC',
      emoji: '🎵',
      primaryColor: Color(0xFFEAB308),
      tagline: 'BEATS & NOISE',
      quickTakesTitle: '🎵 SETLIST RÁPIDO',
      categories: ['ARTISTAS', 'PRODUÇÃO', 'INDIE', 'CHARTS', 'LANÇAMENTOS'],
    ),
    World.gear: WorldMeta(
      world: World.gear,
      label: 'GEAR',
      emoji: '⚙️',
      primaryColor: const Color(0xFFEF4444),
      tagline: 'RPM & GADGETS',
      quickTakesTitle: '⚙️ DIAGNÓSTICO',
      categories: ['AUTOMOTIVO', 'GADGETS', 'WEARABLES', 'DIY', 'INOVAÇÃO'],
    ),
    World.game: WorldMeta(
      world: World.game,
      label: 'GAME',
      emoji: '🎮',
      primaryColor: Color(0xFFA855F7),
      tagline: 'ARCADE & PIXEL',
      quickTakesTitle: '🕹️ PRESS START',
      categories: ['PC', 'CONSOLE', 'MOBILE', 'ESPORTS', 'INDIE'],
    ),
  };

  static WorldMeta get(World world) => all[world]!;

  static World fromString(String value) {
    final lowerValue = value.toLowerCase();
    return World.values.firstWhere(
      (w) => w.name == lowerValue,
      orElse: () => World.tech,
    );
  }
}

// ─── Backwards Compatibility Extensions ─────────────────────────────────────

class WorldConfigCompat {
  final World world;
  final String label;
  final String slug;
  final Color primaryColor;
  final IconData icon;

  const WorldConfigCompat({
    required this.world,
    required this.label,
    required this.slug,
    required this.primaryColor,
    required this.icon,
  });
}

extension WorldExtension on World {
  IconData get icon {
    switch (this) {
      case World.tech:
        return LucideIcons.laptop;
      case World.music:
        return LucideIcons.music;
      case World.gear:
        return LucideIcons.settings;
      case World.game:
        return LucideIcons.gamepad;
    }
  }

  WorldConfigCompat get config => WorldConfigCompat(
        world: this,
        label: WorldRegistry.get(this).label,
        slug: name.toUpperCase(),
        primaryColor: WorldRegistry.get(this).primaryColor,
        icon: icon,
      );

  static World fromSlug(String slug) {
    return WorldRegistry.fromString(slug);
  }
}
