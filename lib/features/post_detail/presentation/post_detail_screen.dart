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
import 'package:fresh_news_mobile/shared/widgets/chameleon_effects_overlay.dart';

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

  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

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
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          postAsync.when(
            data: (post) => IconButton(
              icon: const Icon(LucideIcons.share_2, color: Colors.white),
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
          
          // Extrai cores e efeitos do Chameleon Engine
          final categoryColor = FNColors.forCategory(post.category, world: post.world);
          final accentColor = _parseHexColor(post.themeConfig?['accent_color'] as String?, categoryColor);
          final effectsRaw = post.themeConfig?['ui_effects'] as List<dynamic>? ?? const ['scanlines'];
          final effects = effectsRaw.map((e) => e.toString()).toList();

          return ChameleonEffectsOverlay(
            accentColor: accentColor,
            effects: effects,
            child: SingleChildScrollView(
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
                            color: accentColor,
                            backgroundColor: accentColor.withOpacity(0.12),
                          ),
                          const SizedBox(width: 8),
                          FNBadge(label: 'SCORE: ${post.score}'),
                          const SizedBox(width: 8),
                          FNBadge.category(
                            (post.subCategory.isNotEmpty && post.subCategory != 'GERAL') ? post.subCategory : post.category,
                            world: post.world,
                          ),
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
                    Divider(color: accentColor.withOpacity(0.2)),
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
                    Divider(color: accentColor.withOpacity(0.2)),
                    const SizedBox(height: FNSpacing.lg),
  
                    // 5. WhatsApp Summary Card
                    if (post.whatsappSummary != null && post.whatsappSummary!.isNotEmpty) ...[
                      _buildWhatsappSummaryCard(post.whatsappSummary!, accentColor),
                      const SizedBox(height: FNSpacing.lg),
                    ],
  
                    // 6. CTA Button
                    if (post.url.isNotEmpty)
                      FNButton(
                        label: 'LER FONTE ORIGINAL',
                        primaryColor: accentColor,
                        leading: const Icon(LucideIcons.external_link, size: 16, color: Colors.white),
                        onPressed: () => _launchUrl(post.url, post.category),
                      ),
                  ],
                ),
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

  Widget _buildWhatsappSummaryCard(String summary, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(FNSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.smartphone, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'RESUMO_WHATSAPP',
                style: FNTypography.techLabel.copyWith(
                  color: accentColor,
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
                  primaryColor: accentColor,
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
                  primaryColor: accentColor,
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
