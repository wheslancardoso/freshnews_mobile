import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_provider.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';

import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/features/newsletter_detail/application/newsletter_detail_provider.dart';
import 'package:fresh_news_mobile/features/newsletter_detail/presentation/widgets/terminal_debate.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/infrastructure/tracking_repository.dart';

class NewsletterDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const NewsletterDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<NewsletterDetailScreen> createState() => _NewsletterDetailScreenState();
}

class _NewsletterDetailScreenState extends ConsumerState<NewsletterDetailScreen> {
  bool _tracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerTracking();
  }

  void _triggerTracking() {
    if (_tracked) return;

    final newsletterAsyncValue = ref.watch(newsletterDetailProvider(widget.id));
    newsletterAsyncValue.whenData((newsletter) {
      final subscriberId = ref.read(subscriberIdProvider);
      if (subscriberId != null) {
        ref.read(trackingRepositoryProvider).trackClick(
              subscriberId: subscriberId,
              category: newsletter.category ?? 'MASTER',
              newsletterId: newsletter.id,
            );
        _tracked = true;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
              newsletter.category ?? 'MASTER',
              world: newsletter.world.config.slug,
            );
      });
    });
  }


  Color _getCategoryColor(String name) {
    final upper = name.toUpperCase();
    if (upper.contains('IA') || upper.contains('INTELIGÊNCIA')) return const Color(0xFFA78BFA); // Lavender
    if (upper.contains('DEV') || upper.contains('ENGENHARIA')) return const Color(0xFF10B981); // Emerald
    if (upper.contains('SEC') || upper.contains('CIBER') || upper.contains('HACKER')) return const Color(0xFFF43F5E); // Rose
    if (upper.contains('STARTUP') || upper.contains('BUSINESS') || upper.contains('MERCADO')) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFF8B5CF6); // Violet default
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _launchUrl(String url, String category) async {
    final subscriberId = ref.read(subscriberIdProvider);
    if (subscriberId != null) {
      ref.read(trackingRepositoryProvider).trackClick(
            subscriberId: subscriberId,
            category: category,
            newsletterId: widget.id,
          );
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsletterAsync = ref.watch(newsletterDetailProvider(widget.id));
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          newsletterAsync.when(
            data: (n) => 'EDIÇÃO #${n.editionNumber}',
            loading: () => 'CARREGANDO...',
            error: (_, __) => 'ERRO',
          ),
          style: FNTypography.headingMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: FNColors.background.withOpacity(0.85),
      ),
      body: newsletterAsync.when(
        data: (newsletter) {
          final content = newsletter.contentJson;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Cover Image
                _buildCoverImage(newsletter.imageUrl),
                
                Padding(
                  padding: const EdgeInsets.all(FNSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Edition Metadata
                      Row(
                        children: [
                          FNBadge(label: 'EDIÇÃO #${newsletter.editionNumber}'),
                          const SizedBox(width: 8),
                          FNBadge(label: newsletter.category ?? 'MASTER'),
                          const Spacer(),
                          Text(
                            _formatDate(newsletter.createdAt),
                            style: FNTypography.techLabel.copyWith(color: FNColors.mutedForeground),
                          ),
                        ],
                      ),
                      const SizedBox(height: FNSpacing.lg),
                      
                      // 3. Title
                      Text(
                        newsletter.title,
                        style: FNTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: FNSpacing.md),
                      
                      // 4. Intro editorial
                      if (newsletter.summaryIntro != null && newsletter.summaryIntro!.isNotEmpty) ...[
                        Text(
                          newsletter.summaryIntro!,
                          style: FNTypography.bodyLarge.copyWith(
                            color: FNColors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: FNSpacing.lg),
                      ],
                      
                      const Divider(),
                      const SizedBox(height: FNSpacing.lg),
                      
                      // 5. Quick Takes (⚡ GIRO TECH)
                      if (content != null && content.quickTakes.isNotEmpty) ...[
                        _buildQuickTakes(content.quickTakes),
                        const SizedBox(height: FNSpacing.xl),
                        const Divider(),
                        const SizedBox(height: FNSpacing.lg),
                      ],

                      // 6. Categorias e Notícias
                      if (content != null && content.categories.isNotEmpty) ...[
                        ...content.categories.map((cat) => _buildCategorySection(cat)),
                        const SizedBox(height: FNSpacing.md),
                      ],
                      
                      // 7. Terminal Debate
                      if (newsletter.debateLog.isNotEmpty) ...[
                        VisibilityDetector(
                          key: Key('detail-debate-${newsletter.id}'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0.4) {
                              ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
                                    newsletter.category ?? 'MASTER',
                                    world: newsletter.world.config.slug,
                                  );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '── TERMINAL DEBATE ──',
                                style: FNTypography.techLabel.copyWith(
                                  color: FNColors.mutedForeground.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: FNSpacing.lg),
                              TerminalDebate(messages: newsletter.debateLog),
                              const SizedBox(height: FNSpacing.xl),
                            ],
                          ),
                        ),
                      ],

                      // 8. Admin Actions (Publish / Reject)
                      if (authState.isAdmin && newsletter.isDraft) ...[
                        const Divider(),
                        const SizedBox(height: FNSpacing.lg),
                        _buildAdminActions(context, ref, newsletter.id),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const _LoadingDetailView(),
        error: (error, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FNSpacing.xxl),
            child: Text(
              'Erro ao carregar detalhes da newsletter:\n$error',
              style: FNTypography.bodyMedium.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FNColors.primaryViolet.withOpacity(0.4),
              FNColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: const _ScanlinePainter(),
                ),
              ),
            ),
            const Center(
              child: Icon(LucideIcons.newspaper, color: Colors.white30, size: 48),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: const Color(0xFF1C1C1E),
              highlightColor: const Color(0xFF2C2C2E),
              child: Container(color: Colors.black),
            ),
            errorWidget: (context, url, error) => Icon(LucideIcons.image_off, color: Colors.white24),
          ),
          // Dark gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTakes(List<String> takes) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        border: Border.all(color: const Color(0xFF27272A), width: 2),
      ),
      padding: const EdgeInsets.all(FNSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ GIRO TECH',
            style: FNTypography.techLabel.copyWith(
              color: FNColors.primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: FNSpacing.base),
          ...takes.map((take) => Padding(
                padding: const EdgeInsets.only(bottom: FNSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: FNTypography.code.copyWith(color: FNColors.primaryYellow, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        take,
                        style: FNTypography.code.copyWith(
                          fontSize: 13,
                          color: const Color(0xFFE4E4E7),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategorySection(NewsCategory category) {
    final catColor = _getCategoryColor(category.name);

    return VisibilityDetector(
      key: Key('detail-category-${category.name}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.4) {
          ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(category.name);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: catColor, width: 2),
              ),
            ),
            child: Text(
              category.name.toUpperCase(),
              style: FNTypography.headingSmall.copyWith(
                color: catColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: FNSpacing.base),
          // News Items List
          ...category.items.map((item) => _buildNewsItemCard(item, catColor, category.name)),
          const SizedBox(height: FNSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildNewsItemCard(NewsItem item, Color catColor, String categoryName) {
    return Container(
      margin: const EdgeInsets.only(bottom: FNSpacing.lg),
      padding: const EdgeInsets.only(left: FNSpacing.base),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: catColor, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.zero, // brutalist
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.white10),
                  errorWidget: (context, url, error) => Icon(LucideIcons.image_off, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          InkWell(
            onTap: () => _launchUrl(item.link, categoryName),
            child: Text(
              item.headline,
              style: FNTypography.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: catColor.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: FNSpacing.sm),
          Text(
            item.story,
            style: FNTypography.bodyMedium.copyWith(
              color: FNColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchUrl(item.link, categoryName),
            child: Text(
              'Ler fonte original →',
              style: FNTypography.techLabelSmall.copyWith(
                color: catColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, WidgetRef ref, String id) {
    final controller = ref.read(newsletterDetailControllerProvider);

    return Row(
      children: [
        Expanded(
          child: FNButton(
            label: 'APROVAR E PUBLICAR',
            leading: Icon(LucideIcons.check, size: 16, color: Colors.white),
            onPressed: () async {
              try {
                await controller.publish(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Newsletter publicada com sucesso!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao publicar: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(width: FNSpacing.base),
        Expanded(
          child: FNButton(
            label: 'REJEITAR EDIÇÃO',
            leading: Icon(LucideIcons.x, size: 16, color: Colors.white),
            onPressed: () async {
              try {
                await controller.reject(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Newsletter rejeitada (mantida em rascunho).')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao rejeitar: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}

class _LoadingDetailView extends StatelessWidget {
  const _LoadingDetailView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(FNSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoadingSkeleton(height: 200),
            SizedBox(height: FNSpacing.lg),
            LoadingSkeleton(height: 20, width: 150),
            SizedBox(height: FNSpacing.base),
            LoadingSkeleton(height: 32),
            SizedBox(height: FNSpacing.base),
            LoadingSkeleton(height: 16),
            SizedBox(height: 8),
            LoadingSkeleton(height: 16, width: 250),
          ],
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
