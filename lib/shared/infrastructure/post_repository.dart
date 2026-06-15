import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';

abstract class PostRepository {
  Future<List<Post>> getPublished({required World world, String? category, int page = 0, int pageSize = 20});
  Future<List<Post>> getApproved({required World world, int limit = 10});
  Future<List<Post>> getPending({required World world});
  Future<Post> getById(String id);
  Future<void> updateStatus(String id, String status);
  Future<void> updatePost(String id, {String? title, String? summary, String? content, String? category});
  Future<void> delete(String id);
}

class SupabasePostRepository implements PostRepository {
  final SupabaseClient _client;

  SupabasePostRepository(this._client);

  @override
  Future<List<Post>> getPublished({required World world, String? category, int page = 0, int pageSize = 20}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = _client
        .from('posts')
        .select()
        .eq('world', world.config.slug)
        .eq('status', 'published');

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('created_at', ascending: false).range(from, to);

    return (response as List<dynamic>)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Post>> getApproved({required World world, int limit = 10}) async {
    final response = await _client
        .from('posts')
        .select()
        .eq('world', world.config.slug)
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Post> getById(String id) async {
    final response = await _client.from('posts').select().eq('id', id).single();
    return Post.fromJson(response);
  }

  @override
  Future<List<Post>> getPending({required World world}) async {
    final response = await _client
        .from('posts')
        .select()
        .eq('world', world.config.slug)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    final updates = <String, dynamic>{
      'status': status,
    };
    if (status == 'approved') {
      updates['published_at'] = DateTime.now().toIso8601String();
    }
    await _client.from('posts').update(updates).eq('id', id);
  }

  @override
  Future<void> updatePost(String id, {
    String? title,
    String? summary,
    String? content,
    String? category,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (summary != null) updates['summary'] = summary;
    if (content != null) updates['content'] = content;
    if (category != null) updates['category'] = category;

    if (updates.isNotEmpty) {
      await _client.from('posts').update(updates).eq('id', id);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('posts').delete().eq('id', id);
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabasePostRepository(client);
});
