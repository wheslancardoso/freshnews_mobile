import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/network/dio_client.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';

/// Mundo selecionado ativamente no painel admin
final adminSelectedWorldProvider = StateProvider<World>((ref) => World.tech);

/// Drafts (newsletters em rascunho)
final adminDraftsProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  return ref.read(newsletterRepositoryProvider).getDrafts();
});

/// Posts pendentes de aprovação para o mundo selecionado
final adminPendingPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) {
  final world = ref.watch(adminSelectedWorldProvider);
  return ref.read(postRepositoryProvider).getPending(world: world);
});

/// Controller de ações administrativas da newsletter
class AdminNewsletterController {
  final NewsletterRepository _repository;
  final Ref _ref;

  AdminNewsletterController(this._repository, this._ref);

  Future<void> generateDraft(String world) async {
    final dio = _ref.read(dioClientProvider);
    // Dispara geração da edição pela API no backend
    await dio.post('/api/generate', queryParameters: {'world': world});
    _ref.invalidate(adminDraftsProvider);
  }

  Future<void> saveDraft(
    String id, {
    String? title,
    String? imageUrl,
    String? imagePrompt,
    Map<String, dynamic>? contentJson,
    String? summaryIntro,
  }) async {
    await _repository.updateDraft(
      id,
      title: title,
      imageUrl: imageUrl,
      imagePrompt: imagePrompt,
      contentJson: contentJson,
      summaryIntro: summaryIntro,
    );
    _ref.invalidate(adminDraftsProvider);
  }

  Future<void> publishDraft(String id) async {
    await _repository.updateStatus(id, 'published');
    _ref.invalidate(adminDraftsProvider);
  }

  Future<void> deleteDraft(String id) async {
    await _repository.delete(id);
    _ref.invalidate(adminDraftsProvider);
  }
}

final adminNewsletterControllerProvider = Provider.autoDispose((ref) {
  final repository = ref.read(newsletterRepositoryProvider);
  return AdminNewsletterController(repository, ref);
});

/// Controller para curadoria de posts individuais
class AdminPostController {
  final PostRepository _repository;
  final Ref _ref;

  AdminPostController(this._repository, this._ref);

  Future<void> approvePost(String id) async {
    await _repository.updateStatus(id, 'approved');
    _ref.invalidate(adminPendingPostsProvider);
  }

  Future<void> updatePost(String id, {
    String? title,
    String? summary,
    String? content,
    String? category,
  }) async {
    await _repository.updatePost(
      id,
      title: title,
      summary: summary,
      content: content,
      category: category,
    );
    _ref.invalidate(adminPendingPostsProvider);
  }

  Future<void> rejectPost(String id) async {
    await _repository.delete(id);
    _ref.invalidate(adminPendingPostsProvider);
  }
}

final adminPostControllerProvider = Provider.autoDispose((ref) {
  final repository = ref.read(postRepositoryProvider);
  return AdminPostController(repository, ref);
});
