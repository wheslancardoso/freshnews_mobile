import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/app/router.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';

class FreshNewsApp extends ConsumerWidget {
  const FreshNewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      theme: FNTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
