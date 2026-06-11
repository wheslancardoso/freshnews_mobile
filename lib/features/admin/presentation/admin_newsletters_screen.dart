import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/admin/application/admin_providers.dart';
import 'package:fresh_news_mobile/features/admin/presentation/widgets/newsletter_card_admin.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class AdminNewslettersScreen extends ConsumerStatefulWidget {
  const AdminNewslettersScreen({super.key});

  @override
  ConsumerState<AdminNewslettersScreen> createState() => _AdminNewslettersScreenState();
}

class _AdminNewslettersScreenState extends ConsumerState<AdminNewslettersScreen> {
  World _selectedWorld = World.tech;
  bool _isGenerating = false;

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);
    try {
      await ref
          .read(adminNewsletterControllerProvider)
          .generateDraft(_selectedWorld.name.toUpperCase());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nova edição gerada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar edição: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'EDIÇÕES PENDENTES',
              style: FNTypography.headingLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: FNSpacing.base),
            Text(
              'Gere novos rascunhos de multiverso e edite suas propriedades.',
              style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
            ),
            const SizedBox(height: FNSpacing.lg),

            // Controle de Geração
            GlassCard(
              padding: const EdgeInsets.all(FNSpacing.base),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<World>(
                      value: _selectedWorld,
                      dropdownColor: FNColors.surface,
                      decoration: const InputDecoration(
                        labelText: 'MUNDO',
                        border: InputBorder.none,
                      ),
                      style: FNTypography.bodyMedium.copyWith(color: FNColors.textPrimary),
                      items: World.values.map((world) {
                        return DropdownMenuItem(
                          value: world,
                          child: Text(world.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedWorld = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: FNSpacing.base),
                  FNButton(
                    label: _isGenerating ? 'GERANDO...' : 'GERAR NOVA',
                    leading: const Icon(LucideIcons.zap, size: 16, color: Colors.white),
                    onPressed: _isGenerating ? null : _handleGenerate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FNSpacing.lg),

            // Alerta Resend
            GlassCard(
              borderColor: FNColors.primaryViolet.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(FNSpacing.base),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: FNColors.primaryViolet),
                  const SizedBox(width: FNSpacing.base),
                  Expanded(
                    child: Text(
                      'Fase 5 (Resend) em integração automática no backend.',
                      style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FNSpacing.xl),

            Text(
              'RASCUNHOS DISPONÍVEIS',
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
                        'Nenhum rascunho de newsletter disponível.',
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
}
