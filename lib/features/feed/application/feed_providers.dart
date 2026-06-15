import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';

final selectedFeedCategoryProvider = StateProvider<String?>((ref) => null);

final feedPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final world = ref.watch(activeWorldProvider);
  // Buscamos os posts aprovados com limite de 50 para o feed inicial
  return ref.read(postRepositoryProvider).getApproved(
        world: world,
        limit: 50,
      );
});

final filteredFeedPostsProvider = Provider.autoDispose<AsyncValue<List<Post>>>((ref) {
  final postsAsync = ref.watch(feedPostsProvider);
  final selectedCategory = ref.watch(selectedFeedCategoryProvider);

  return postsAsync.whenData((posts) {
    if (selectedCategory == null) return posts;
    // O post armazena a categoria no campo 'category' ou 'sub_category'
    return posts.where((post) {
      final matchesCategory = post.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesSubCategory = post.subCategory.toLowerCase() == selectedCategory.toLowerCase();
      return matchesCategory || matchesSubCategory;
    }).toList();
  });
});
