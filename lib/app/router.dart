import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/features/auth/domain/auth_state.dart';
import 'package:fresh_news_mobile/features/auth/presentation/login_screen.dart';
import 'package:fresh_news_mobile/features/home/presentation/home_screen.dart';
import 'package:fresh_news_mobile/features/archive/presentation/archive_screen.dart';
import 'package:fresh_news_mobile/features/newsletter_detail/presentation/newsletter_detail_screen.dart';
import 'package:fresh_news_mobile/features/post_detail/presentation/post_detail_screen.dart';

import 'package:fresh_news_mobile/features/unsubscribe/presentation/unsubscribe_screen.dart';
import 'package:fresh_news_mobile/features/preferences/presentation/preferences_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshNotifier(authNotifier.stream),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/archive',
        name: 'archive',
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/archive/:id',
        name: 'newsletter_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NewsletterDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/post/:id',
        name: 'post_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const _PlaceholderScreen(title: 'About'),
      ),
      GoRoute(
        path: '/subscribe',
        name: 'subscribe',
        builder: (context, state) => const _PlaceholderScreen(title: 'Subscribe'),
      ),
      GoRoute(
        path: '/unsubscribe',
        name: 'unsubscribe',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return UnsubscribeScreen(token: token);
        },
      ),
      GoRoute(
        path: '/preferences/:id',
        name: 'preferences',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PreferencesScreen(subscriberId: id);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        redirect: (context, state) {
          if (authState.isAdmin) return '/admin/posts';
          return null;
        },
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        redirect: (context, state) {
          if (!authState.isAdmin) return '/login';
          return null;
        },
        routes: [
          GoRoute(
            path: '/admin',
            name: 'admin',
            redirect: (context, state) => '/admin/posts',
          ),
          GoRoute(
            path: '/admin/posts',
            name: 'admin_posts',
            builder: (context, state) => const _PlaceholderScreen(title: 'Admin Posts'),
          ),
          GoRoute(
            path: '/admin/newsletters',
            name: 'admin_newsletters',
            builder: (context, state) => const _PlaceholderScreen(title: 'Admin Newsletters'),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _AdminShell extends StatelessWidget {
  final Widget child;

  const _AdminShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

