import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/shared/widgets/scanline_overlay.dart';
import 'package:fresh_news_mobile/core/constants/categories.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/home/application/home_providers.dart';
import 'package:fresh_news_mobile/features/subscribe/presentation/subscribe_section.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_card.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/widgets/news_card.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_provider.dart';


import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorld = ref.watch(activeWorldProvider);
    final filteredNewsletters = ref.watch(filteredNewslettersProvider);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : width < 900 ? 2 : 3;

    return Scaffold(
      backgroundColor: FNColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, activeWorld),
          SliverToBoxAdapter(child: _buildHeroSection(context, activeWorld)),
          SliverToBoxAdapter(child: _buildWorldChips(ref, activeWorld)),
          SliverToBoxAdapter(child: _buildCategoryTabs(ref, activeWorld)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
            sliver: _buildNewsletterGrid(ref, filteredNewsletters, crossAxisCount),
          ),
          const SliverToBoxAdapter(child: SubscribeSection()),
          const SliverToBoxAdapter(child: SizedBox(height: FNSpacing.xxl)),
        ],
      ),
    );
  }


  Widget _buildAppBar(BuildContext context, WidgetRef ref, World activeWorld) {
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
          GestureDetector(
            onLongPress: () {
              HapticFeedback.heavyImpact();
              context.push('/login');
            },
            child: Container(
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
          ),
          const SizedBox(width: FNSpacing.sm),
          Text(
            'FRESH NEWS',
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
        if (ref.watch(subscriberIdProvider) != null)
          Padding(
            padding: const EdgeInsets.only(right: FNSpacing.lg),
            child: IconButton(
              icon: const Icon(LucideIcons.settings, color: Colors.white),
              onPressed: () => context.push('/preferences/${ref.read(subscriberIdProvider)}'),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, World activeWorld) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FNSpacing.lg, FNSpacing.base, FNSpacing.lg, FNSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: FNColors.success,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
              const SizedBox(width: FNSpacing.sm),
              Text(
                'TRANSMITINDO AGORA',
                style: FNTypography.techLabelSmall.copyWith(color: FNColors.success, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/archive'),
            child: Row(
              children: [
                Text(
                  'ACESSAR ARQUIVO',
                  style: FNTypography.techLabelSmall.copyWith(
                    color: activeWorld.config.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.archive, size: 14, color: activeWorld.config.primaryColor),
              ],
            ),
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
    final selectedCategory = ref.watch(selectedCategoryProvider);

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
                  ref.read(selectedCategoryProvider.notifier).state = null;
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
                ref.read(selectedCategoryProvider.notifier).state = category;
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

  Widget _buildNewsletterGrid(WidgetRef ref, AsyncValue<List<Newsletter>> filteredNewsletters, int crossAxisCount) {
    return filteredNewsletters.when(
      data: (newsletters) {
        if (newsletters.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FNSpacing.xxxl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(LucideIcons.inbox, color: FNColors.textMuted, size: 40),
                    const SizedBox(height: FNSpacing.md),
                    Text(
                      'Nenhuma edição encontrada para este filtro.',
                      style: FNTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: FNSpacing.lg,
            mainAxisSpacing: FNSpacing.lg,
            mainAxisExtent: 390,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final newsletter = newsletters[index];
              final dateString = '${newsletter.createdAt.day.toString().padLeft(2, '0')}/${newsletter.createdAt.month.toString().padLeft(2, '0')}/${newsletter.createdAt.year}';
              
              return VisibilityDetector(
                key: Key('home-newsletter-${newsletter.id}'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction > 0.5) {
                    ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
                          newsletter.category ?? 'MASTER',
                          world: newsletter.world.config.slug,
                        );
                  }
                },
                child: NewsCard(
                  data: NewsCardData(
                    id: newsletter.id,
                    title: newsletter.title,
                    intro: newsletter.summaryIntro ?? '',
                    imageUrl: newsletter.imageUrl,
                    edition: 'EDIÇÃO #${newsletter.editionNumber}',
                    date: dateString,
                    categories: newsletter.category != null ? [newsletter.category!] : [],
                  ),
                  onTap: () => context.push('/archive/${newsletter.id}'),
                ),
              );
            },
            childCount: newsletters.length,
          ),
        );
      },
      loading: () => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: FNSpacing.lg,
          mainAxisSpacing: FNSpacing.lg,
          mainAxisExtent: 390,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const FNCard(
            child: SizedBox(
              height: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(height: 140),
                  SizedBox(height: FNSpacing.md),
                  LoadingSkeleton(height: 16, width: 100),
                  SizedBox(height: FNSpacing.sm),
                  LoadingSkeleton(height: 20),
                  SizedBox(height: FNSpacing.sm),
                  LoadingSkeleton(height: 14),
                ],
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
      error: (error, stack) {
        debugPrint('Erro na HomeScreen: $error\n$stack');
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FNSpacing.xxxl),
            child: Center(
              child: Text(
                'Erro ao carregar edições. Tente novamente.',
                style: FNTypography.bodyMedium.copyWith(color: FNColors.error),
              ),
            ),
          ),
        );
      },
    );
  }
}
