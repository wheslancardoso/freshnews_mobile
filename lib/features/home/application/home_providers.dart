import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final publishedNewslettersProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  final world = ref.watch(activeWorldProvider);
  return ref.read(newsletterRepositoryProvider).getPublished(world: world);
});

final filteredNewslettersProvider = Provider.autoDispose<AsyncValue<List<Newsletter>>>((ref) {
  final newsletters = ref.watch(publishedNewslettersProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return newsletters.whenData((list) {
    if (selectedCategory == null) return list;
    return list.where((n) => n.category == selectedCategory).toList();
  });
});

final latestNewsletterProvider = Provider.autoDispose<AsyncValue<Newsletter?>>((ref) {
  final newsletters = ref.watch(publishedNewslettersProvider);
  
  return newsletters.whenData((list) {
    if (list.isEmpty) return null;
    // Assume que a lista já vem ordenada por data descrescente (mais recente primeiro)
    return list.first;
  });
});
