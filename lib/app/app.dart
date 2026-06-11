import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/app/router.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/core/services/notification_service.dart';

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
    return MaterialApp.router(
      routerConfig: router,
      theme: FNTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
