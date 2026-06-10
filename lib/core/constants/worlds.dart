import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum World {
  tech,
  music,
  gear,
  game,
}

class WorldConfig {
  final World world;
  final String label;
  final String slug;
  final IconData icon;
  final Color primaryColor;

  const WorldConfig({
    required this.world,
    required this.label,
    required this.slug,
    required this.icon,
    required this.primaryColor,
  });
}

const Map<World, WorldConfig> worldConfigs = {
  World.tech: WorldConfig(
    world: World.tech,
    label: 'Tech',
    slug: 'tech',
    icon: LucideIcons.cpu,
    primaryColor: Color(0xFF00FF9C),
  ),
  World.music: WorldConfig(
    world: World.music,
    label: 'Music',
    slug: 'music',
    icon: LucideIcons.music,
    primaryColor: Color(0xFFFF3CAC),
  ),
  World.gear: WorldConfig(
    world: World.gear,
    label: 'Gear',
    slug: 'gear',
    icon: LucideIcons.watch,
    primaryColor: Color(0xFFFFC400),
  ),
  World.game: WorldConfig(
    world: World.game,
    label: 'Game',
    slug: 'game',
    icon: LucideIcons.gamepad2,
    primaryColor: Color(0xFF00B8FF),
  ),
};

extension WorldExtension on World {
  WorldConfig get config => worldConfigs[this]!;

  static World fromSlug(String slug) {
    return World.values.firstWhere(
      (w) => w.config.slug == slug,
      orElse: () => World.tech,
    );
  }
}
