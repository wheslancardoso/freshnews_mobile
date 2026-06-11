import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';

abstract class TrackingRepository {
  Future<void> trackClick({
    required String subscriberId,
    required String category,
    String? newsletterId,
  });

  Future<Map<String, int>> getCategoryStats(String subscriberId);
}

class SupabaseTrackingRepository implements TrackingRepository {
  final SupabaseClient _client;

  SupabaseTrackingRepository(this._client);

  @override
  Future<void> trackClick({
    required String subscriberId,
    required String category,
    String? newsletterId,
  }) async {
    final cleanCategory = category.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (cleanCategory.isEmpty) return;

    // 1. Inserir clique no banco
    await _client.from('user_clicks').insert({
      'subscriber_id': subscriberId,
      'category': cleanCategory,
      if (newsletterId != null) 'newsletter_id': newsletterId,
    });

    // 2. Recalcular preferências (ML reativo)
    await _recalculatePreferences(subscriberId);
  }

  /// ML Reativo — Recalcula top 3 categorias preferidas
  Future<void> _recalculatePreferences(String subscriberId) async {
    try {
      // Buscar últimos 30 cliques
      final List<dynamic> response = await _client
          .from('user_clicks')
          .select('category')
          .eq('subscriber_id', subscriberId)
          .order('clicked_at', ascending: false)
          .limit(30);

      if (response.isEmpty) return;

      // Contar frequência
      final Map<String, int> counts = {};
      for (final click in response) {
        final cat = click['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }

      if (counts.isEmpty) return;

      // Ordenar por frequência e pegar as top 3
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topPrefs = sorted.take(3).map((e) => e.key).toList();

      // Atualizar subscriber no Supabase
      await _client
          .from('subscribers')
          .update({'preferences': topPrefs})
          .eq('id', subscriberId);
    } catch (e) {
      // Falha silenciosa para evitar travar fluxo do app
    }
  }

  @override
  Future<Map<String, int>> getCategoryStats(String subscriberId) async {
    try {
      final List<dynamic> response = await _client
          .from('user_clicks')
          .select('category')
          .eq('subscriber_id', subscriberId);

      final Map<String, int> stats = {};
      for (final click in response) {
        final cat = click['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
          stats[cat] = (stats[cat] ?? 0) + 1;
        }
      }
      return stats;
    } catch (e) {
      return {};
    }
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseTrackingRepository(client);
});
