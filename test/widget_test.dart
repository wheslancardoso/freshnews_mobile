import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/app/app.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';

class FakeNewsletterRepository implements NewsletterRepository {
  @override
  Future<List<Newsletter>> getPublished({required World world, int page = 0, int pageSize = 20}) async => [];
  @override
  Future<List<Newsletter>> getDrafts() async => [];
  @override
  Future<Newsletter> getById(String id) async => throw UnimplementedError();
  @override
  Future<void> updateStatus(String id, String status) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> updateDraft(String id, {String? title, String? imageUrl, String? imagePrompt, Map<String, dynamic>? contentJson, String? summaryIntro}) async {}
  @override
  Future<String> createDraft({required String world, required int editionNumber, required String title, required String summaryIntro, required Map<String, dynamic> contentJson, required String imagePrompt}) async => 'fake-id';
  @override
  Future<int> getMaxEditionNumber() async => 0;
}

class FakePostRepository implements PostRepository {
  @override
  Future<List<Post>> getPublished({required World world, String? category, int page = 0, int pageSize = 20}) async => [];
  @override
  Future<List<Post>> getApproved({required World world, int limit = 10}) async => [];
  @override
  Future<List<Post>> getPending({required World world}) async => [];
  @override
  Future<Post> getById(String id) async => throw UnimplementedError();
  @override
  Future<void> updateStatus(String id, String status) async {}
  @override
  Future<void> updateStatuses(List<String> ids, String status) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> updatePost(String id,
      {String? title, String? content, String? category, String? summary}) async {}
}

class FakeSubscriberRepository implements SubscriberRepository {
  @override
  Future<Subscriber> create({required String email, required List<World> worlds}) async => throw UnimplementedError();
  @override
  Future<Subscriber?> getByEmail(String email) async => null;
  @override
  Future<Subscriber?> getById(String id) async => null;
  @override
  Future<void> updatePreferences(String id,
      {List<World>? worlds,
      bool? active,
      List<String>? preferences,
      String? phone,
      bool? notifyEmail,
      bool? notifyWhatsapp,
      Map<String, double>? affinityVector}) async {}
  @override
  Future<UnsubscribeResult> unsubscribe(String token) async => const UnsubscribeResult(success: true, message: 'Sucesso');
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          newsletterRepositoryProvider.overrideWithValue(FakeNewsletterRepository()),
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
          subscriberRepositoryProvider.overrideWithValue(FakeSubscriberRepository()),
        ],
        child: const FreshNewsApp(),
      ),
    );

    expect(find.byType(FreshNewsApp), findsOneWidget);

    // Desmonta a árvore de widgets para cancelar timers e animações infinitas
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
