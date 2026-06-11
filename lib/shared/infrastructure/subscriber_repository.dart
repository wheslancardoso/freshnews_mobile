import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';

class UnsubscribeResult {
  final bool success;
  final String message;
  const UnsubscribeResult({required this.success, required this.message});
}

abstract class SubscriberRepository {
  Future<Subscriber> create({required String email, required List<World> worlds});
  Future<Subscriber?> getByEmail(String email);
  Future<Subscriber?> getById(String id);
  Future<void> updatePreferences(String id, {List<World>? worlds, bool? active, List<String>? preferences});
  Future<UnsubscribeResult> unsubscribe(String token);
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
  Future<void> updatePreferences(String id, {List<World>? worlds, bool? active, List<String>? preferences}) async {
    final updates = <String, dynamic>{};
    if (worlds != null) updates['worlds'] = worlds.map((w) => w.config.slug).toList();
    if (active != null) updates['active'] = active;
    if (preferences != null) updates['preferences'] = preferences;

    if (updates.isEmpty) return;

    await _client.from('subscribers').update(updates).eq('id', id);
  }

  @override
  Future<UnsubscribeResult> unsubscribe(String token) async {
    try {
      final response = await _client
          .from('subscribers')
          .select('id, email')
          .eq('unsubscribe_token', token)
          .maybeSingle();

      if (response == null) {
        return const UnsubscribeResult(success: false, message: 'Link inválido ou expirado.');
      }

      final id = response['id'] as String;

      await _client
          .from('subscribers')
          .update({'status': 'unsubscribed', 'active': false})
          .eq('id', id);

      return const UnsubscribeResult(success: true, message: 'Inscrição cancelada com sucesso.');
    } catch (e) {
      return UnsubscribeResult(success: false, message: 'Erro ao processar cancelamento: $e');
    }
  }
}

final subscriberRepositoryProvider = Provider<SubscriberRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSubscriberRepository(client);
});
