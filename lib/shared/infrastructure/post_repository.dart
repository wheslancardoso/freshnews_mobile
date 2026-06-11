import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';

abstract class PostRepository {
  Future<List<Post>> getPublished({required World world, String? category, int page = 0, int pageSize = 20});
  Future<List<Post>> getApproved({required World world, int limit = 10});
  Future<Post> getById(String id);
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

    final response = await query.order('published_at', ascending: false).range(from, to);

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
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabasePostRepository(client);
});
