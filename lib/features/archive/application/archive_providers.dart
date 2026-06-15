import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriberIdNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  final SubscriberRepository _repository;

  SubscriberIdNotifier(this._prefs, this._repository) : super(null) {
    state = _prefs.getString('subscriber_id');
    _initSupabaseListener();
  }

  void _initSupabaseListener() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        final event = data.event;
        if (session != null && (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed)) {
          final email = session.user.email;
          if (email != null) {
            final subscriber = await _repository.getByEmail(email);
            if (subscriber != null) {
              await setSubscriberId(subscriber.id);
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          await setSubscriberId(null);
        }
      });
    } catch (_) {
      // Supabase is not initialized (e.g. during widget tests)
    }
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
  final repository = ref.watch(subscriberRepositoryProvider);
  return SubscriberIdNotifier(prefs, repository);
});

/// Subscriber data (se logado)
final subscriberProvider = FutureProvider.autoDispose<Subscriber?>((ref) async {
  final id = ref.watch(subscriberIdProvider);
  if (id == null) return null;
  return ref.read(subscriberRepositoryProvider).getById(id);
});

/// Newsletters publicadas do mundo ativo
final archivedNewslettersProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  final world = ref.watch(activeWorldProvider);
  return ref.read(newsletterRepositoryProvider).getPublished(
    world: world,
    pageSize: 100,
  );
});
