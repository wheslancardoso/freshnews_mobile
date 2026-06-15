import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';
import 'package:fresh_news_mobile/shared/widgets/news_card.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorld = ref.watch(activeWorldProvider);
    final archivedNewslettersAsync = ref.watch(archivedNewslettersProvider);

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : 2;

    return Scaffold(
      backgroundColor: FNColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, activeWorld),
          _buildHeroCardSection(archivedNewslettersAsync),
          _buildArchivedEditionsSection(archivedNewslettersAsync, crossAxisCount),
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
      title: Text(
        'ARQUIVO HISTÓRICO',
        style: FNTypography.headingMedium.copyWith(
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
        ),
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

  Widget _buildHeroCardSection(AsyncValue<List<dynamic>> newslettersAsync) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(FNSpacing.lg),
        child: Container(
          // Double border effect
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
              color: FNColors.surface,
            ),
            child: Stack(
              children: [
                // Scanlines Overlay (5%)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: const _ScanlinePainter(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(FNSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .fadeIn(duration: 600.ms)
                                 .then()
                                 .fadeOut(duration: 600.ms),
                                const SizedBox(width: FNSpacing.sm),
                                Text(
                                  'INTELLIGENCE_LOG',
                                  style: FNTypography.techLabelSmall.copyWith(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: FNSpacing.md),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'ARQUIVO ',
                                    style: FNTypography.h1.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'HISTÓRICO',
                                    style: FNTypography.h1.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      color: FNColors.primaryViolet,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: FNSpacing.sm),
                            Text(
                              'Explorando o log de transmissões técnicas',
                              style: FNTypography.bodySmall.copyWith(
                                color: FNColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: FNSpacing.md),
                      newslettersAsync.when(
                        data: (list) => _buildLogsCounter(list.length),
                        loading: () => _buildLogsCounter(0),
                        error: (_, __) => _buildLogsCounter(0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogsCounter(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FNSpacing.md, vertical: FNSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL_LOGS',
            style: FNTypography.techLabelSmall.copyWith(fontSize: 8, color: FNColors.mutedForeground),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString().padLeft(2, '0'),
            style: FNTypography.h1.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }



  Widget _buildArchivedEditionsSection(AsyncValue<List<Newsletter>> newslettersAsync, int crossAxisCount) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Divider(),
          const SizedBox(height: FNSpacing.lg),
          Row(
            children: [
              const Icon(LucideIcons.archive, size: 16, color: FNColors.primaryViolet),
              const SizedBox(width: FNSpacing.sm),
              Text(
                'EDIÇÕES ARQUIVADAS',
                style: FNTypography.techLabel.copyWith(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.md),
          newslettersAsync.when(
            data: (newsletters) {
              if (newsletters.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: FNSpacing.lg),
                  child: Center(
                    child: Text('Nenhuma edição arquivada.', style: FNTypography.bodyMedium),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: FNSpacing.lg,
                  mainAxisSpacing: FNSpacing.lg,
                  mainAxisExtent: 390,
                ),
                itemCount: newsletters.length,
                itemBuilder: (context, index) {
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
                  ).animate().fadeIn(delay: (index * 100).ms, duration: 300.ms).slideY(begin: 0.05, end: 0);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Erro ao carregar edições: $error', style: FNTypography.bodyMedium.copyWith(color: Colors.red)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
