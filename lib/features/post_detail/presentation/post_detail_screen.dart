import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/tracking_repository.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';

final postDetailProvider = FutureProvider.autoDispose.family<Post, String>((ref, id) {
  return ref.read(postRepositoryProvider).getById(id);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PostDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _tracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerTracking();
  }

  void _triggerTracking() {
    if (_tracked) return;

    final postAsyncValue = ref.watch(postDetailProvider(widget.id));
    postAsyncValue.whenData((post) {
      final subscriberId = ref.read(subscriberIdProvider);
      if (subscriberId != null) {
        ref.read(trackingRepositoryProvider).trackClick(
          subscriberId: subscriberId,
          category: post.category,
        );
        _tracked = true;
      }
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TECH_HACKER':
      case 'SEGURANÇA':
        return const Color(0xFFF87171); // red-400
      case 'SYNTH_AESTHETICS':
        return const Color(0xFFA78BFA); // purple-400
      case 'GEARHEAD':
        return const Color(0xFFFBBF24); // yellow-400
      case 'IA':
        return const Color(0xFF34D399); // emerald-400
      default:
        return const Color(0xFF22D3EE); // cyan-400
    }
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
          );
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: FNColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          postAsync.when(
            data: (post) => IconButton(
              icon: Icon(LucideIcons.share_2, color: Colors.white),
              onPressed: () {
                final text = post.whatsappSummary ?? post.summary;
                SharePlus.instance.share(ShareParams(text: '${post.title}\n\n$text\n\nLeia mais: ${post.url}'));
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) {
          final contentText = post.content.isNotEmpty ? post.content : post.summary;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(FNSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Metadata Badges Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FNBadge(
                          label: post.category,
                          color: _getCategoryColor(post.category),
                          backgroundColor: _getCategoryColor(post.category).withOpacity(0.12),
                        ),
                        const SizedBox(width: 8),
                        FNBadge(label: 'SCORE: ${post.score}'),
                        const SizedBox(width: 8),
                        FNBadge(label: post.subCategory),
                        const SizedBox(width: 8),
                        FNBadge(label: post.world.name.toUpperCase()),
                      ],
                    ),
                  ),
                  const SizedBox(height: FNSpacing.lg),

                  // 2. Title
                  Text(
                    post.title.toUpperCase(),
                    style: FNTypography.h2.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.sm),

                  // 3. Source + Date
                  Text(
                    'FONTE: ${post.source ?? 'WEB'} · ${_formatDate(post.createdAt)}'.toUpperCase(),
                    style: FNTypography.techLabel.copyWith(
                      color: FNColors.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  const Divider(),
                  const SizedBox(height: FNSpacing.lg),

                  // 4. Content
                  Text(
                    contentText,
                    style: FNTypography.bodyLarge.copyWith(
                      color: const Color(0xFFE4E4E7),
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.xl),
                  const Divider(),
                  const SizedBox(height: FNSpacing.lg),

                  // 5. WhatsApp Summary Card
                  if (post.whatsappSummary != null && post.whatsappSummary!.isNotEmpty) ...[
                    _buildWhatsappSummaryCard(post.whatsappSummary!),
                    const SizedBox(height: FNSpacing.lg),
                  ],

                  // 6. CTA Button
                  if (post.url.isNotEmpty)
                    FNButton(
                      label: 'LER FONTE ORIGINAL',
                      leading: Icon(LucideIcons.external_link, size: 16, color: Colors.white),
                      onPressed: () => _launchUrl(post.url, post.category),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const _LoadingPostDetailView(),
        error: (error, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FNSpacing.xxl),
            child: Text(
              'Erro ao carregar detalhes do post:\n$error',
              style: FNTypography.bodyMedium.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsappSummaryCard(String summary) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: FNColors.primaryViolet.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(FNSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.smartphone, size: 16, color: FNColors.primaryViolet),
              const SizedBox(width: 8),
              Text(
                'RESUMO_WHATSAPP',
                style: FNTypography.techLabel.copyWith(
                  color: FNColors.primaryViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.md),
          Text(
            summary,
            style: FNTypography.code.copyWith(
              fontSize: 13,
              color: FNColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: FNSpacing.md),
          Row(
            children: [
              Expanded(
                child: FNButton(
                  label: 'COPIAR',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: summary)).then((_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Resumo copiado!')),
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: FNSpacing.base),
              Expanded(
                child: FNButton(
                  label: 'COMPARTILHAR',
                  onPressed: () {
                    SharePlus.instance.share(ShareParams(text: summary));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingPostDetailView extends StatelessWidget {
  const _LoadingPostDetailView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(FNSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LoadingSkeleton(height: 16, width: 80),
                SizedBox(width: 8),
                LoadingSkeleton(height: 16, width: 80),
              ],
            ),
            SizedBox(height: FNSpacing.lg),
            LoadingSkeleton(height: 40),
            SizedBox(height: FNSpacing.sm),
            LoadingSkeleton(height: 14, width: 180),
            SizedBox(height: FNSpacing.lg),
            Divider(),
            SizedBox(height: FNSpacing.lg),
            LoadingSkeleton(height: 16),
            SizedBox(height: 8),
            LoadingSkeleton(height: 16),
            SizedBox(height: 8),
            LoadingSkeleton(height: 16, width: 280),
          ],
        ),
      ),
    );
  }
}
