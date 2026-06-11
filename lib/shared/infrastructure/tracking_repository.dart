import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';

abstract class TrackingRepository {
  Future<void> trackClick({
    required String subscriberId,
    required String category,
    String? newsletterId,
  });
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
    await _client.from('user_clicks').insert({
      'subscriber_id': subscriberId,
      'category': category,
      if (newsletterId != null) 'newsletter_id': newsletterId,
    });
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseTrackingRepository(client);
});
