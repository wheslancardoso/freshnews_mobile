import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';

abstract class NewsletterRepository {
  Future<List<Newsletter>> getPublished({required World world, int page = 0, int pageSize = 20});
  Future<Newsletter> getById(String id);
}

class SupabaseNewsletterRepository implements NewsletterRepository {
  final SupabaseClient _client;

  SupabaseNewsletterRepository(this._client);

  @override
  Future<List<Newsletter>> getPublished({required World world, int page = 0, int pageSize = 20}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await _client
        .from('newsletters')
        .select()
        .eq('world', world.config.slug)
        .eq('status', 'published')
        .order('published_at', ascending: false)
        .range(from, to);

    return (response as List<dynamic>)
        .map((json) => Newsletter.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Newsletter> getById(String id) async {
    final response = await _client.from('newsletters').select().eq('id', id).single();
    return Newsletter.fromJson(response);
  }
}

final newsletterRepositoryProvider = Provider<NewsletterRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseNewsletterRepository(client);
});
