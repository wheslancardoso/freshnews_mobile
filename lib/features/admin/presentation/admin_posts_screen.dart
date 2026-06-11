import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/admin/application/admin_providers.dart';
import 'package:fresh_news_mobile/features/admin/presentation/widgets/newsletter_card_admin.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class AdminPostsScreen extends ConsumerWidget {
  const AdminPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(adminDraftsProvider);
    final controller = ref.read(adminNewsletterControllerProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FNSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'INBOX DE CURADORIA',
              style: FNTypography.headingLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: FNSpacing.base),
            Text(
              'Monitore o engajamento e aprove os rascunhos das próximas edições.',
              style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
            ),
            const SizedBox(height: FNSpacing.lg),

            // Métricas
            Row(
              children: [
                Expanded(child: _buildMetricCard('42.8K', 'TRÁFEGO')),
                const SizedBox(width: FNSpacing.sm),
                Expanded(child: _buildMetricCard('8.2%', 'CONVERSÃO')),
                const SizedBox(width: FNSpacing.sm),
                Expanded(child: _buildMetricCard('04:12', 'SESSÃO')),
              ],
            ),
            const SizedBox(height: FNSpacing.xl),

            Text(
              'EDICÕES EM RASCUNHO',
              style: FNTypography.label.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: FNSpacing.md),

            draftsAsync.when(
              data: (drafts) {
                if (drafts.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(FNSpacing.xl),
                    child: Center(
                      child: Text(
                        'Nenhum rascunho pendente de curadoria.',
                        style: FNTypography.bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: drafts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: FNSpacing.lg),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return GlassCard(
      padding: const EdgeInsets.all(FNSpacing.base),
      child: Column(
        children: [
          Text(
            value,
            style: FNTypography.headingMedium.copyWith(
              color: FNColors.primaryViolet,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: FNTypography.techLabelSmall.copyWith(color: FNColors.textMuted),
          ),
        ],
      ),
    );
  }
}
