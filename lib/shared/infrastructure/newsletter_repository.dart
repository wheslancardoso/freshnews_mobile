import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';

abstract class NewsletterRepository {
  Future<List<Newsletter>> getPublished({required World world, int page = 0, int pageSize = 20});
  Future<List<Newsletter>> getDrafts();
  Future<Newsletter> getById(String id);
  Future<void> updateStatus(String id, String status);
  Future<void> delete(String id);
  Future<void> updateDraft(String id, {String? title, String? imageUrl, String? imagePrompt, Map<String, dynamic>? contentJson, String? summaryIntro});
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
  Future<List<Newsletter>> getDrafts() async {
    final response = await _client
        .from('newsletters')
        .select()
        .eq('status', 'draft')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Newsletter.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Newsletter> getById(String id) async {
    final response = await _client.from('newsletters').select().eq('id', id).single();
    return Newsletter.fromJson(response);
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    final updates = <String, dynamic>{
      'status': status,
    };
    if (status == 'published') {
      updates['published_at'] = DateTime.now().toIso8601String();
    }
    await _client.from('newsletters').update(updates).eq('id', id);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('newsletters').delete().eq('id', id);
  }

  @override
  Future<void> updateDraft(String id, {String? title, String? imageUrl, String? imagePrompt, Map<String, dynamic>? contentJson, String? summaryIntro}) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (imagePrompt != null) updates['image_prompt'] = imagePrompt;
    if (contentJson != null) updates['content_json'] = contentJson;
    if (summaryIntro != null) updates['summary_intro'] = summaryIntro;

    if (updates.isEmpty) return;

    await _client.from('newsletters').update(updates).eq('id', id);
  }
}

final newsletterRepositoryProvider = Provider<NewsletterRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseNewsletterRepository(client);
});
