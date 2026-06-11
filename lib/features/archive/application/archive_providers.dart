import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';

class SubscriberIdNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;

  SubscriberIdNotifier(this._prefs) : super(null) {
    state = _prefs.getString('subscriber_id');
  }

  Future<void> setSubscriberId(String? id) async {
    if (id == null) {
      await _prefs.remove('subscriber_id');
    } else {
      await _prefs.setString('subscriber_id', id);
    }
    state = id;
  }
}

/// ID do assinante (pode vir de SharedPrefs ou deep link)
final subscriberIdProvider = StateNotifierProvider<SubscriberIdNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SubscriberIdNotifier(prefs);
});

/// Subscriber data (se logado)
final subscriberProvider = FutureProvider.autoDispose<Subscriber?>((ref) async {
  final id = ref.watch(subscriberIdProvider);
  if (id == null) return null;
  return ref.read(subscriberRepositoryProvider).getById(id);
});

/// Posts aprovados do mundo ativo (com reordenação por afinidade)
final affinityPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final world = ref.watch(activeWorldProvider);
  final subscriber = await ref.watch(subscriberProvider.future);
  
  final posts = await ref.read(postRepositoryProvider).getApproved(
    world: world,
    limit: 10,
  );

  if (subscriber == null || subscriber.preferences.isEmpty) return posts;

  // Criamos uma cópia mutável para ordenação
  final sortedPosts = List<Post>.from(posts);

  // Reordenar por afinidade
  return sortedPosts..sort((a, b) {
    final aPref = subscriber.preferences.contains(a.category) ? 1 : 0;
    final bPref = subscriber.preferences.contains(b.category) ? 1 : 0;
    if (aPref != bPref) return bPref - aPref;
    return b.score.compareTo(a.score);
  });
});

/// Newsletters publicadas do mundo ativo
final archivedNewslettersProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  final world = ref.watch(activeWorldProvider);
  return ref.read(newsletterRepositoryProvider).getPublished(
    world: world,
    pageSize: 100,
  );
});
