import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/constants/categories.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/feed/application/feed_providers.dart';
import 'package:fresh_news_mobile/features/archive/presentation/widgets/post_card.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorld = ref.watch(activeWorldProvider);
    final filteredPosts = ref.watch(filteredFeedPostsProvider);
    final subscriberId = ref.watch(subscriberIdProvider);
    final subscriberAsync = ref.watch(subscriberProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, activeWorld, subscriberId),
          SliverToBoxAdapter(child: _buildHeroSection(activeWorld)),
          SliverToBoxAdapter(child: _buildWorldChips(ref, activeWorld)),
          SliverToBoxAdapter(child: _buildCategoryTabs(ref, activeWorld)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
            sliver: _buildPostsList(ref, filteredPosts, subscriberAsync),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: FNSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, World activeWorld, String? subscriberId) {
    final authState = ref.watch(authProvider);

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: FNColors.background.withValues(alpha: 0.85),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activeWorld.config.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: activeWorld.config.primaryColor, width: 2.0),
            ),
            child: Text(
              'FN',
              style: FNTypography.headingSmall.copyWith(
                color: activeWorld.config.primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: FNSpacing.sm),
          Text(
            'SINAL DIRETO',
            style: FNTypography.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
      actions: [
        if (authState.isAdmin)
          IconButton(
            icon: const Icon(LucideIcons.terminal, color: Colors.white),
            tooltip: 'Console Admin',
            onPressed: () => context.push('/admin'),
          ),
        if (subscriberId != null)
          Padding(
            padding: const EdgeInsets.only(right: FNSpacing.lg),
            child: IconButton(
              icon: const Icon(LucideIcons.settings, color: Colors.white),
              onPressed: () => context.push('/preferences/$subscriberId'),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection(World activeWorld) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FNSpacing.lg, FNSpacing.lg, FNSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ARTIGOS E FONTES CURADAS',
            style: FNTypography.headingLarge.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: FNSpacing.sm),
          Text(
            'Artigos recomendados do pipeline de inteligência artificial de ${activeWorld.config.label}. Reordenados em tempo real.',
            style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldChips(WidgetRef ref, World activeWorld) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FNSpacing.md),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
          itemCount: World.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: FNSpacing.sm),
          itemBuilder: (context, index) {
            final world = World.values[index];
            final isSelected = world == activeWorld;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(worldControllerProvider.notifier).setWorld(world);
                ref.read(chameleonThemeProvider.notifier).updateThemeByWorld(world.config.slug);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? world.config.primaryColor : FNColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? Colors.black : FNColors.border,
                    width: 2.0,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      world.config.icon,
                      size: 16,
                      color: isSelected ? Colors.black : FNColors.textMuted,
                    ),
                    const SizedBox(width: FNSpacing.sm),
                    Text(
                      world.config.label.toUpperCase(),
                      style: FNTypography.label.copyWith(
                        color: isSelected ? Colors.black : FNColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(WidgetRef ref, World activeWorld) {
    final categories = worldCategories[activeWorld] ?? [];
    final selectedCategory = ref.watch(selectedFeedCategoryProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: FNSpacing.lg),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: FNSpacing.sm),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = selectedCategory == null;
              return _categoryChip(
                ref,
                label: 'TODAS',
                isSelected: isSelected,
                color: activeWorld.config.primaryColor,
                onTap: () {
                  ref.read(selectedFeedCategoryProvider.notifier).state = null;
                  ref.read(chameleonThemeProvider.notifier).updateThemeByWorld(activeWorld.config.slug);
                },
              );
            }

            final category = categories[index - 1];
            final isSelected = selectedCategory == category;
            return _categoryChip(
              ref,
              label: category.toUpperCase(),
              isSelected: isSelected,
              color: activeWorld.config.primaryColor,
              onTap: () {
                ref.read(selectedFeedCategoryProvider.notifier).state = category;
                ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
                      category,
                      world: activeWorld.config.slug,
                    );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _categoryChip(
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.black : FNColors.border,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: FNTypography.bodySmall.copyWith(
            color: isSelected ? Colors.black : FNColors.textMuted,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList(WidgetRef ref, AsyncValue<List<Post>> filteredPosts, AsyncValue<dynamic> subscriberAsync) {
    return filteredPosts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FNSpacing.xxxl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(LucideIcons.inbox, color: FNColors.textMuted, size: 40),
                    const SizedBox(height: FNSpacing.md),
                    Text(
                      'Nenhum artigo encontrado para este filtro.',
                      style: FNTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final subscriber = subscriberAsync.valueOrNull;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              final isPreferred = subscriber != null && subscriber.preferences.contains(post.category);

              return VisibilityDetector(
                key: Key('feed-post-${post.id}'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction > 0.5) {
                    ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
                          post.category,
                          world: post.world.config.slug,
                        );
                  }
                },
                child: PostCard(
                  post: post,
                  isPreferred: isPreferred,
                ),
              );
            },
            childCount: posts.length,
          ),
        );
      },
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: FNSpacing.base),
            child: LoadingSkeleton(height: 140),
          ),
          childCount: 4,
        ),
      ),
      error: (error, stack) {
        debugPrint('Erro na FeedScreen: $error\n$stack');
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FNSpacing.xxxl),
            child: Center(
              child: Text(
                'Erro ao carregar artigos. Tente novamente.',
                style: FNTypography.bodyMedium.copyWith(color: FNColors.error),
              ),
            ),
          ),
        );
      },
    );
  }
}
