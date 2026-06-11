import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';

abstract class SubscriberRepository {
  Future<Subscriber> create({required String email, required List<World> worlds});
  Future<Subscriber?> getByEmail(String email);
  Future<Subscriber?> getById(String id);
  Future<void> updatePreferences(String id, {List<World>? worlds, bool? active});
}

class SupabaseSubscriberRepository implements SubscriberRepository {
  final SupabaseClient _client;

  SupabaseSubscriberRepository(this._client);

  @override
  Future<Subscriber> create({required String email, required List<World> worlds}) async {
    final response = await _client
        .from('subscribers')
        .insert({
          'email': email,
          'worlds': worlds.map((w) => w.config.slug).toList(),
          'active': true,
        })
        .select()
        .single();

    return Subscriber.fromJson(response);
  }

  @override
  Future<Subscriber?> getByEmail(String email) async {
    final response = await _client.from('subscribers').select().eq('email', email).maybeSingle();
    if (response == null) return null;
    return Subscriber.fromJson(response);
  }

  @override
  Future<Subscriber?> getById(String id) async {
    final response = await _client.from('subscribers').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Subscriber.fromJson(response);
  }

  @override
  Future<void> updatePreferences(String id, {List<World>? worlds, bool? active}) async {
    final updates = <String, dynamic>{};
    if (worlds != null) updates['worlds'] = worlds.map((w) => w.config.slug).toList();
    if (active != null) updates['active'] = active;

    if (updates.isEmpty) return;

    await _client.from('subscribers').update(updates).eq('id', id);
  }
}

final subscriberRepositoryProvider = Provider<SubscriberRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSubscriberRepository(client);
});
