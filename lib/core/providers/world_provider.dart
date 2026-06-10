import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/core/constants/app_constants.dart';
import 'package:fresh_news_mobile/core/constants/worlds.dart';

class WorldNotifier extends StateNotifier<World> {
  WorldNotifier() : super(World.tech) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final slug = prefs.getString(AppConstants.prefsActiveWorldKey);
    if (slug != null) {
      state = WorldExtension.fromSlug(slug);
    }
  }

  Future<void> setWorld(World world) async {
    state = world;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsActiveWorldKey, world.config.slug);
  }
}

final activeWorldProvider = StateNotifierProvider<WorldNotifier, World>((ref) {
  return WorldNotifier();
});
