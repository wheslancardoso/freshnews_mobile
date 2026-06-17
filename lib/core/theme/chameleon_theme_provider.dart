import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_config.dart';

class ChameleonThemeNotifier extends Notifier<ChameleonThemeConfig> {
  @override
  ChameleonThemeConfig build() {
    return ChameleonThemeConfig.defaultTech();
  }

  void updateThemeByCategory(String category, {String? world}) {
    state = ChameleonThemeConfig.fromCategory(category, world: world);
  }

  void updateThemeByWorld(String world) {
    switch (world.toUpperCase()) {
      case 'MUSIC':
        state = ChameleonThemeConfig.defaultMusic();
      case 'SPORTS':
        state = ChameleonThemeConfig.defaultSports();
      case 'GAME':
        state = ChameleonThemeConfig.defaultGame();
      default:
        state = ChameleonThemeConfig.defaultTech();
    }
  }

  void resetTheme() {
    state = ChameleonThemeConfig.defaultTech();
  }
}

final chameleonThemeProvider = NotifierProvider<ChameleonThemeNotifier, ChameleonThemeConfig>(
  ChameleonThemeNotifier.new,
);
