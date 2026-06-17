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
import 'package:fresh_news_mobile/core/theme/chameleon_theme_config.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';

import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/features/newsletter_detail/application/newsletter_detail_provider.dart';
import 'package:fresh_news_mobile/features/newsletter_detail/presentation/widgets/terminal_debate.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/chameleon_effects_overlay.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/loading_skeleton.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/infrastructure/telemetry_repository.dart';

class NewsletterDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const NewsletterDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<NewsletterDetailScreen> createState() =>
      _NewsletterDetailScreenState();
}

class _NewsletterDetailScreenState
    extends ConsumerState<NewsletterDetailScreen> {
  bool _tracked = false;

  // Rastreamento de Dwell Time: momento em que a categoria ficou visível
  final Map<String, DateTime> _categoryStartTimes = {};

  // Referência segura do repository (capturada antes do dispose)
  TelemetryRepository? _telemetryRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _telemetryRepo = ref.read(telemetryRepositoryProvider);
    _triggerTracking();
  }

  @override
  void dispose() {
    _flushAllDwellTimes();

    // Restaurar o tema global para o mundo ativo ao sair da tela
    try {
      final activeWorld = ref.read(activeWorldProvider);
      ref
          .read(chameleonThemeProvider.notifier)
          .updateThemeByWorld(activeWorld.config.slug);
    } catch (_) {}

    super.dispose();
  }

  /// Envia IMEDIATAMENTE o dwell time de UMA categoria quando ela sai do viewport
  void _sendCategoryDwellTime(String category, Duration duration) {
    if (_telemetryRepo == null) return;
    print(
        '[TELEMETRY] 🚀 Enviando dwell time INLINE para "$category": ${duration.inSeconds}s');
    _telemetryRepo!
        .recordDwellTime(category: category, visibleDuration: duration);
  }

  /// Flush final: envia o tempo de todas as categorias que AINDA estavam visíveis quando o user saiu da tela
  void _flushAllDwellTimes() {
    if (_telemetryRepo == null) return;
    final now = DateTime.now();

    for (final entry in Map.of(_categoryStartTimes).entries) {
      final duration = now.difference(entry.value);
      print(
          '[TELEMETRY] 🔚 Flush no dispose para "${entry.key}": ${duration.inSeconds}s');
      _telemetryRepo!
          .recordDwellTime(category: entry.key, visibleDuration: duration);
    }
    _categoryStartTimes.clear();
  }

  /// Chamado pelo VisibilityDetector quando uma categoria entra/sai do viewport
  void _onCategoryVisibilityChanged(
      String categoryName, double visibleFraction) {
    if (visibleFraction > 0.1) {
      // Categoria está visível — começar a contar se ainda não começou
      if (!_categoryStartTimes.containsKey(categoryName)) {
        _categoryStartTimes[categoryName] = DateTime.now();
        print('[TELEMETRY] 👁️ Começou a ler: "$categoryName"');
      }
    } else {
      // Categoria saiu do viewport — calcular e ENVIAR imediatamente
      if (_categoryStartTimes.containsKey(categoryName)) {
        final start = _categoryStartTimes.remove(categoryName)!;
        final duration = DateTime.now().difference(start);
        print(
            '[TELEMETRY] 📤 Saiu de "$categoryName" após ${duration.inSeconds}s');
        _sendCategoryDwellTime(categoryName, duration);
      }
    }
  }

  void _triggerTracking() {
    if (_tracked) return;

    final newsletterAsyncValue = ref.watch(newsletterDetailProvider(widget.id));
    newsletterAsyncValue.whenData((newsletter) {
      _tracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chameleonThemeProvider.notifier).updateThemeByCategory(
              newsletter.category ?? 'MASTER',
              world: newsletter.world.config.slug,
            );
      });
    });
  }

  Color _getCategoryColor(String name, String? worldSlug) {
    return ChameleonThemeConfig.fromCategory(name, world: worldSlug).primary;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _launchUrl(String url, String category) async {
    final subscriberId = ref.read(subscriberIdProvider);
    if (subscriberId != null) {
      ref.read(telemetryRepositoryProvider).recordLinkClick(
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
    final newsletterAsync = ref.watch(newsletterDetailProvider(widget.id));
    final authState = ref.watch(authProvider);
    final chameleonTheme = ref.watch(chameleonThemeProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: chameleonTheme.bg,
      child: ChameleonEffectsOverlay(
        effects: chameleonTheme.effects,
        accentColor: chameleonTheme.primary,
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            try {
              final activeWorld = ref.read(activeWorldProvider);
              ref
                  .read(chameleonThemeProvider.notifier)
                  .updateThemeByWorld(activeWorld.config.slug);
            } catch (e) {
              print('[TELEMETRY] Erro no PopScope ao resetar tema: $e');
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
                onPressed: () {
                  try {
                    final activeWorld = ref.read(activeWorldProvider);
                    ref
                        .read(chameleonThemeProvider.notifier)
                        .updateThemeByWorld(activeWorld.config.slug);
                  } catch (_) {}
                  context.pop();
                },
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
                  color: chameleonTheme.primary,
                ),
              ),
              backgroundColor: chameleonTheme.bg.withOpacity(0.85),
              elevation: 0,
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
                                FNBadge(
                                    label:
                                        'EDIÇÃO #${newsletter.editionNumber}'),
                                const SizedBox(width: 8),
                                FNBadge(label: newsletter.category ?? 'MASTER'),
                                const Spacer(),
                                Text(
                                  _formatDate(newsletter.createdAt),
                                  style: FNTypography.techLabel.copyWith(
                                      color: FNColors.mutedForeground),
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
                            if (newsletter.summaryIntro != null &&
                                newsletter.summaryIntro!.isNotEmpty) ...[
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

                            // 5. Quick Takes (dinâmico por mundo)
                            if (content != null &&
                                content.quickTakes.isNotEmpty) ...[
                              _buildQuickTakes(
                                  content.quickTakes, newsletter.world),
                              const SizedBox(height: FNSpacing.xl),
                              const Divider(),
                              const SizedBox(height: FNSpacing.lg),
                            ],

                            // 6. Categorias e Notícias
                            if (content != null &&
                                content.categories.isNotEmpty) ...[
                              Builder(
                                builder: (context) {
                                  final subscriber =
                                      ref.watch(subscriberProvider).valueOrNull;
                                  final affinity =
                                      subscriber?.affinityVector ?? {};

                                  // Remove emojis e espaços para comparar com as chaves do banco
                                  String normalizeCat(String raw) {
                                    return raw
                                        .replaceAll(
                                            RegExp(r'[^\w\sÀ-ÿ]',
                                                unicode: true),
                                            '')
                                        .trim()
                                        .toUpperCase();
                                  }

                                  final sortedCategories =
                                      List<NewsCategory>.from(
                                          content.categories);
                                  final originalOrder = {
                                    for (var i = 0;
                                        i < content.categories.length;
                                        i++)
                                      content.categories[i].name: i
                                  };

                                  if (affinity.isNotEmpty) {
                                    sortedCategories.sort((a, b) {
                                      final scoreA =
                                          affinity[normalizeCat(a.name)] ?? 0.0;
                                      final scoreB =
                                          affinity[normalizeCat(b.name)] ?? 0.0;

                                      if (scoreB != scoreA) {
                                        return scoreB.compareTo(scoreA);
                                      }
                                      // Fallback para a ordem original
                                      return originalOrder[a.name]!
                                          .compareTo(originalOrder[b.name]!);
                                    });
                                  }

                                  final showSoftGate =
                                      ref.watch(subscriberIdProvider) == null;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: sortedCategories
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final idx = entry.key;
                                      final cat = entry.value;
                                      final score =
                                          affinity[normalizeCat(cat.name)] ??
                                              0.0;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildCategorySection(
                                              cat, newsletter.world.config.slug,
                                              isAiRecommended: score >= 0.3),
                                          if (showSoftGate && idx == 0) ...[
                                            const SizedBox(
                                                height: FNSpacing.base),
                                            _buildSoftGateCard(context,
                                                chameleonTheme.primary),
                                            const SizedBox(
                                                height: FNSpacing.xl),
                                          ],
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: FNSpacing.md),
                            ],

                            // 7. Terminal Debate
                            if (newsletter.debateLog.isNotEmpty) ...[
                              VisibilityDetector(
                                key: Key('detail-debate-${newsletter.id}'),
                                onVisibilityChanged: (info) {
                                  if (info.visibleFraction > 0.4) {
                                    ref
                                        .read(chameleonThemeProvider.notifier)
                                        .updateThemeByCategory(
                                          newsletter.category ?? 'MASTER',
                                          world: newsletter.world.config.slug,
                                        );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '── TERMINAL DEBATE ──',
                                      style: FNTypography.techLabel.copyWith(
                                        color: FNColors.mutedForeground
                                            .withOpacity(0.5),
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: FNSpacing.lg),
                                    TerminalDebate(
                                        messages: newsletter.debateLog),
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
          ),
        ),
      ),
    );
  }

  Widget _buildSoftGateCard(BuildContext context, Color accentColor) {
    return GlassCard(
      borderColor: accentColor,
      borderWidth: 2.0,
      backgroundColor: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(FNSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.terminal, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ALERTA DE TRANSMISSÃO // CONEXÃO RESTRITA',
                  style: FNTypography.techLabel.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.base),
          Text(
            'Seu dispositivo está recebendo este feed no modo passivo de demonstração. Conecte-se para ativar o algoritmo de afinidade de inteligência artificial e passar a receber os boletins personalizados diretamente no seu E-mail ou WhatsApp.',
            style: FNTypography.bodyMedium.copyWith(
              color: FNColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: FNSpacing.lg),
          FNButton(
            label: 'ESTABELECER CONEXÃO',
            primaryColor: accentColor,
            onPressed: () {
              context.push('/subscriber-login');
            },
            fullWidth: true,
          ),
        ],
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
            const Center(
              child:
                  Icon(LucideIcons.newspaper, color: Colors.white30, size: 48),
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
            errorWidget: (context, url, error) =>
                Icon(LucideIcons.image_off, color: Colors.white24),
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

  Widget _buildQuickTakes(List<String> takes, World world) {
    final worldMeta = WorldRegistry.get(world);
    final accentColor = worldMeta.primaryColor;

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
            worldMeta.quickTakesTitle,
            style: FNTypography.techLabel.copyWith(
              color: accentColor,
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
                      style: FNTypography.code.copyWith(
                          color: accentColor, fontWeight: FontWeight.bold),
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

  Widget _buildCategorySection(NewsCategory category, String worldSlug,
      {bool isAiRecommended = false}) {
    final catColor = _getCategoryColor(category.name, worldSlug);

    return VisibilityDetector(
      key: Key('detail-category-${category.name}'),
      onVisibilityChanged: (info) {
        // Chameleon theme: Se a categoria ocupar pelo menos 10% da tela (ou do seu próprio tamanho), ativa a cor
        if (info.visibleFraction > 0.1) {
          ref
              .read(chameleonThemeProvider.notifier)
              .updateThemeByCategory(category.name, world: worldSlug);
        }
        // Telemetria de Dwell Time: Exige 10% para evitar contabilizar bordas vizinhas
        _onCategoryVisibilityChanged(category.name, info.visibleFraction);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: FNTypography.headingSmall.copyWith(
                    color: catColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                if (isAiRecommended)
                  Row(
                    children: [
                      Icon(LucideIcons.sparkles, size: 14, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        'Baseado no seu perfil',
                        style: FNTypography.bodySmall.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: FNSpacing.base),
          // News Items List
          ...category.items
              .map((item) => _buildNewsItemCard(item, catColor, category.name)),
          const SizedBox(height: FNSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildNewsItemCard(
      NewsItem item, Color catColor, String categoryName) {
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
                  placeholder: (context, url) =>
                      Container(color: Colors.white10),
                  errorWidget: (context, url, error) =>
                      Icon(LucideIcons.image_off, color: Colors.white24),
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
                    const SnackBar(
                        content: Text('Newsletter publicada com sucesso!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erro ao publicar: $e'),
                        backgroundColor: Colors.red),
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
                    const SnackBar(
                        content: Text(
                            'Newsletter rejeitada (mantida em rascunho).')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erro ao rejeitar: $e'),
                        backgroundColor: Colors.red),
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
