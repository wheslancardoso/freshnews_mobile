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
import 'package:fresh_news_mobile/features/auth/presentation/subscriber_auth_screen.dart';
import 'package:fresh_news_mobile/features/admin/presentation/admin_shell.dart';
import 'package:fresh_news_mobile/features/admin/presentation/admin_posts_screen.dart';
import 'package:fresh_news_mobile/features/admin/presentation/admin_newsletters_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:fresh_news_mobile/app/main_shell.dart';
import 'package:fresh_news_mobile/features/profile/presentation/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshNotifier(authNotifier.stream),
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
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
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
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
        path: '/subscriber-login',
        name: 'subscriber_login',
        builder: (context, state) => const SubscriberAuthScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        name: 'login_callback',
        redirect: (context, state) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            return '/profile';
          }
          return '/';
        },
        builder: (context, state) => const SizedBox.shrink(),
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
        builder: (context, state, child) => AdminShell(child: child),
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
            builder: (context, state) => const AdminPostsScreen(),
          ),
          GoRoute(
            path: '/admin/newsletters',
            name: 'admin_newsletters',
            builder: (context, state) => const AdminNewslettersScreen(),
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



