import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/network/dio_client.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';

/// Drafts (newsletters em rascunho)
final adminDraftsProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  return ref.read(newsletterRepositoryProvider).getDrafts();
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
