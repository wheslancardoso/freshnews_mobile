import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/admin/application/admin_providers.dart';
import 'package:fresh_news_mobile/features/admin/presentation/widgets/newsletter_card_admin.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class AdminPostsScreen extends ConsumerWidget {
  const AdminPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWorld = ref.watch(adminSelectedWorldProvider);
    final pendingPostsAsync = ref.watch(adminPendingPostsProvider);
    final draftsAsync = ref.watch(adminDraftsProvider);
    final postController = ref.read(adminPostControllerProvider);
    final newsletterController = ref.read(adminNewsletterControllerProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FNSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CURADORIA',
                    style: FNTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // Seletor de Mundo Global do Admin
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: FNColors.surface,
                      border: Border.all(color: FNColors.border, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<World>(
                      value: selectedWorld,
                      dropdownColor: FNColors.surface,
                      underline: const SizedBox(),
                      style: FNTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      items: World.values.map((world) {
                        return DropdownMenuItem(
                          value: world,
                          child: Text(world.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(adminSelectedWorldProvider.notifier).state = val;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FNSpacing.base),
              Text(
                'Aprove artigos recomendados por IA ou publique rascunhos de newsletters.',
                style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
              ),
              const SizedBox(height: FNSpacing.lg),

              // Tabs de curadoria
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: FNColors.primaryViolet,
                        labelColor: Colors.white,
                        unselectedLabelColor: FNColors.textMuted,
                        labelStyle: FNTypography.techLabel.copyWith(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'ARTIGOS PENDENTES (N8N)'),
                          Tab(text: 'NEWSLETTERS (RASCUNHOS)'),
                        ],
                      ),
                      const SizedBox(height: FNSpacing.md),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ABA 1: Artigos do n8n
                            _buildPendingPostsTab(context, ref, pendingPostsAsync, postController),

                            // ABA 2: Rascunhos de Newsletters
                            _buildNewslettersTab(context, ref, draftsAsync, newsletterController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPostsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Post>> pendingPostsAsync,
    AdminPostController controller,
  ) {
    return pendingPostsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'Nenhum artigo pendente no inbox do n8n.',
              style: FNTypography.bodyMedium,
            ),
          );
        }

        return ListView.separated(
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: FNSpacing.md),
          itemBuilder: (context, index) {
            final post = posts[index];

            return GlassCard(
              padding: const EdgeInsets.all(FNSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FNBadge(
                        label: post.category,
                        color: FNColors.primaryViolet,
                        backgroundColor: FNColors.primaryViolet.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 8),
                      FNBadge(label: 'SCORE: ${post.score}'),
                      const Spacer(),
                      Text(
                        post.source?.toUpperCase() ?? 'WEB',
                        style: FNTypography.techLabelSmall.copyWith(color: FNColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: FNSpacing.sm),
                  Text(
                    post.title,
                    style: FNTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.summary.isNotEmpty ? post.summary : post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FNButton(
                          label: 'REJEITAR',
                          variant: FNButtonVariant.outline,
                          primaryColor: FNColors.error,
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await controller.rejectPost(post.id);
                          },
                        ),
                      ),
                      const SizedBox(width: FNSpacing.base),
                      Expanded(
                        child: FNButton(
                          label: 'APROVAR',
                          primaryColor: FNColors.success,
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await controller.approvePost(post.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: FNColors.primaryViolet),
      ),
      error: (error, __) => Center(
        child: Text(
          'Erro ao carregar artigos: $error',
          style: FNTypography.bodyMedium.copyWith(color: FNColors.error),
        ),
      ),
    );
  }

  Widget _buildNewslettersTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Newsletter>> draftsAsync,
    AdminNewsletterController controller,
  ) {
    return draftsAsync.when(
      data: (drafts) {
        if (drafts.isEmpty) {
          return Center(
            child: Text(
              'Nenhum rascunho de newsletter pendente.',
              style: FNTypography.bodyMedium,
            ),
          );
        }

        return ListView.separated(
          itemCount: drafts.length,
          separatorBuilder: (_, __) => const SizedBox(height: FNSpacing.md),
          itemBuilder: (context, index) {
            final draft = drafts[index];
            return NewsletterCardAdmin(
              draft: draft,
              onPublished: () async {
                try {
                  await controller.publishDraft(draft.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edição publicada com sucesso!')),
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
              onRejected: () async {
                try {
                  await controller.deleteDraft(draft.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edição excluída.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: FNColors.primaryViolet),
      ),
      error: (error, __) => Center(
        child: Text(
          'Erro ao carregar rascunhos: $error',
          style: FNTypography.bodyMedium.copyWith(color: FNColors.error),
        ),
      ),
    );
  }
}
