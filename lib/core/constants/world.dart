import 'package:flutter/material.dart';

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
  final List<String> categories;

  const WorldMeta({
    required this.world,
    required this.label,
    required this.emoji,
    required this.primaryColor,
    required this.tagline,
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
      categories: ['DEV', 'IA', 'SEGURANÇA', 'STARTUPS', 'CLOUD'],
    ),
    World.music: WorldMeta(
      world: World.music,
      label: 'MUSIC',
      emoji: '🎵',
      primaryColor: Color(0xFFEAB308),
      tagline: 'BEATS & NOISE',
      categories: ['ARTISTAS', 'PRODUÇÃO', 'INDIE', 'CHARTS', 'LANÇAMENTOS'],
    ),
    World.gear: WorldMeta(
      world: World.gear,
      label: 'GEAR',
      emoji: '⚙️',
      primaryColor: Color(0xFFF59E0B),
      tagline: 'RPM & GADGETS',
      categories: ['AUTOMOTIVO', 'GADGETS', 'WEARABLES', 'DIY', 'INOVAÇÃO'],
    ),
    World.game: WorldMeta(
      world: World.game,
      label: 'GAME',
      emoji: '🎮',
      primaryColor: Color(0xFFA855F7),
      tagline: 'ARCADE & PIXEL',
      categories: ['PC', 'CONSOLE', 'MOBILE', 'ESPORTS', 'INDIE'],
    ),
  };

  static WorldMeta get(World world) => all[world]!;

  static World fromString(String value) {
    return World.values.firstWhere(
      (w) => w.name == value,
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

  const WorldConfigCompat({
    required this.world,
    required this.label,
    required this.slug,
    required this.primaryColor,
  });
}

extension WorldExtension on World {
  WorldConfigCompat get config => WorldConfigCompat(
        world: this,
        label: WorldRegistry.get(this).label,
        slug: name,
        primaryColor: WorldRegistry.get(this).primaryColor,
      );

  static World fromSlug(String slug) {
    return WorldRegistry.fromString(slug);
  }
}
