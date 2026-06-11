import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';

final newsletterDetailProvider = FutureProvider.autoDispose.family<Newsletter, String>((ref, id) {
  return ref.read(newsletterRepositoryProvider).getById(id);
});

class NewsletterDetailController {
  final NewsletterRepository _repository;
  final Ref _ref;

  NewsletterDetailController(this._repository, this._ref);

  Future<void> publish(String id) async {
    await _repository.updateStatus(id, 'published');
    _ref.invalidate(newsletterDetailProvider(id));
  }

  Future<void> reject(String id) async {
    // Para rejeição de rascunhos, manter em 'draft' ou realizar a ação de exclusão
    // Aqui atualizamos para 'draft' (ou mantemos assim) de forma segura
    await _repository.updateStatus(id, 'draft');
    _ref.invalidate(newsletterDetailProvider(id));
  }
}

final newsletterDetailControllerProvider = Provider.autoDispose((ref) {
  final repository = ref.read(newsletterRepositoryProvider);
  return NewsletterDetailController(repository, ref);
});
