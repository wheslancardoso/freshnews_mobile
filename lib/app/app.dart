import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/app/router.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/core/services/notification_service.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_provider.dart';
import 'package:fresh_news_mobile/shared/widgets/chameleon_effects_overlay.dart';

class FreshNewsApp extends ConsumerStatefulWidget {
  const FreshNewsApp({super.key});

  @override
  ConsumerState<FreshNewsApp> createState() => _FreshNewsAppState();
}

class _FreshNewsAppState extends ConsumerState<FreshNewsApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final chameleonTheme = ref.watch(chameleonThemeProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: FNTheme.darkTheme(primaryColor: chameleonTheme.accent),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ChameleonEffectsOverlay(
          effects: chameleonTheme.effects,
          accentColor: chameleonTheme.accent,
          child: AnimatedTheme(
            data: FNTheme.darkTheme(primaryColor: chameleonTheme.accent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

