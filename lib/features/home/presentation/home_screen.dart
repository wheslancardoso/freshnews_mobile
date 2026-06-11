import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
import 'package:fresh_news_mobile/shared/widgets/news_card.dart';

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
          SliverToBoxAdapter(child: _buildHeroSection(context)),
          SliverToBoxAdapter(child: _buildWorldChips(ref, activeWorld)),
          SliverToBoxAdapter(child: _buildCategoryTabs(ref, activeWorld)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
            sliver: _buildNewsletterGrid(filteredNewsletters, crossAxisCount),
          ),
          const SliverToBoxAdapter(child: SubscribeSection()),
          const SliverToBoxAdapter(child: SizedBox(height: FNSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, World activeWorld) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: FNColors.background.withValues(alpha: 0.85),
      elevation: 0,
      titleSpacing: FNSpacing.lg,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activeWorld.config.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: activeWorld.config.primaryColor.withValues(alpha: 0.4)),
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
        Padding(
          padding: const EdgeInsets.only(right: FNSpacing.lg),
          child: PopupMenuButton<World>(
            icon: Icon(activeWorld.config.icon, color: activeWorld.config.primaryColor),
            color: FNColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: FNColors.border),
            ),
            onSelected: (world) => ref.read(worldControllerProvider.notifier).setWorld(world),
            itemBuilder: (context) => World.values.map((world) {
              return PopupMenuItem(
                value: world,
                child: Row(
                  children: [
                    Icon(world.config.icon, color: world.config.primaryColor, size: 18),
                    const SizedBox(width: FNSpacing.sm),
                    Text(world.config.label, style: FNTypography.bodyMedium.copyWith(color: FNColors.textPrimary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FNSpacing.lg, FNSpacing.xl, FNSpacing.lg, FNSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FNColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FNColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  'STATUS // ONLINE // TRANSMITINDO',
                  style: FNTypography.label.copyWith(color: FNColors.success),
                ),
              ],
            ),
          ),
          const SizedBox(height: FNSpacing.lg),
          Text(
            'INFORMAÇÃO DESTILADA.\nSEM RUÍDO.',
            style: FNTypography.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.1,
            ),
          ),
          const SizedBox(height: FNSpacing.md),
          Text(
            'Curadoria editorial direta, sem distrações. As notícias mais relevantes do mundo selecionado, condensadas para você.',
            style: FNTypography.bodyLarge.copyWith(color: FNColors.textSecondary),
          ),
          const SizedBox(height: FNSpacing.xl),
          FNButton(
            label: 'VER_EDICOES_ANTERIORES',
            leading: const Icon(LucideIcons.archive, size: 16, color: Colors.white),
            onPressed: () => context.push('/archive'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldChips(WidgetRef ref, World activeWorld) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
        itemCount: World.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: FNSpacing.sm),
        itemBuilder: (context, index) {
          final world = World.values[index];
          final isSelected = world == activeWorld;

          return GestureDetector(
            onTap: () => ref.read(worldControllerProvider.notifier).setWorld(world),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? world.config.primaryColor.withValues(alpha: 0.15) : FNColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? world.config.primaryColor : FNColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    world.config.icon,
                    size: 18,
                    color: isSelected ? world.config.primaryColor : FNColors.textMuted,
                  ),
                  const SizedBox(width: FNSpacing.sm),
                  Text(
                    world.config.label.toUpperCase(),
                    style: FNTypography.label.copyWith(
                      color: isSelected ? world.config.primaryColor : FNColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(target: isSelected ? 1 : 0).scaleXY(begin: 1.0, end: 1.03, duration: 200.ms);
        },
      ),
    );
  }

  Widget _buildCategoryTabs(WidgetRef ref, World activeWorld) {
    final categories = worldCategories[activeWorld] ?? [];
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Padding(
      padding: const EdgeInsets.only(top: FNSpacing.lg),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
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
                onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
              );
            }

            final category = categories[index - 1];
            final isSelected = selectedCategory == category;
            return _categoryChip(
              ref,
              label: category.toUpperCase(),
              isSelected: isSelected,
              color: activeWorld.config.primaryColor,
              onTap: () => ref.read(selectedCategoryProvider.notifier).state = category,
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : FNColors.border),
        ),
        child: Text(
          label,
          style: FNTypography.bodySmall.copyWith(
            color: isSelected ? color : FNColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNewsletterGrid(AsyncValue<List<Newsletter>> filteredNewsletters, int crossAxisCount) {
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
            mainAxisExtent: 320,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final newsletter = newsletters[index];
              final dateString = '${newsletter.createdAt.day.toString().padLeft(2, '0')}/${newsletter.createdAt.month.toString().padLeft(2, '0')}/${newsletter.createdAt.year}';
              
              return NewsCard(
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
          mainAxisExtent: 320,
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
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: FNSpacing.xxxl),
          child: Center(
            child: Text(
              'Erro ao carregar edições. Tente novamente.',
              style: FNTypography.bodyMedium.copyWith(color: FNColors.error),
            ),
          ),
        ),
      ),
    );
  }
}
