import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/preferences/application/preferences_provider.dart';
import 'package:fresh_news_mobile/features/preferences/presentation/widgets/danger_zone.dart';
import 'package:fresh_news_mobile/features/preferences/presentation/widgets/profile_card.dart';
import 'package:fresh_news_mobile/features/preferences/presentation/widgets/reading_stats.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';

class PreferencesScreen extends ConsumerWidget {
  final String subscriberId;

  const PreferencesScreen({super.key, required this.subscriberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preferencesProvider(subscriberId));
    final notifier = ref.read(preferencesProvider(subscriberId).notifier);

    return Scaffold(
      backgroundColor: FNColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PREFERÊNCIAS',
          style: FNTypography.headingMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: FNColors.background.withOpacity(0.85),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: FNColors.primaryViolet))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(FNSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.subscriber != null) ...[
                    ProfileCard(subscriber: state.subscriber!),
                    const SizedBox(height: FNSpacing.xl),
                  ],

                  // Estatísticas de leitura
                  const ReadingStats(),
                  const SizedBox(height: FNSpacing.xl),

                  // Section: Mundos Ativos
                  Text(
                    'MUNDOS ATIVOS',
                    style: FNTypography.label.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  Wrap(
                    spacing: FNSpacing.sm,
                    runSpacing: FNSpacing.sm,
                    children: World.values.map((world) {
                      final meta = WorldRegistry.get(world);
                      final isSelected = state.selectedWorlds.contains(world);

                      return GestureDetector(
                        onTap: () => notifier.toggleWorld(world),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? meta.primaryColor.withValues(alpha: 0.15)
                                : FNColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? meta.primaryColor : FNColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(meta.emoji),
                              const SizedBox(width: 6),
                              Text(
                                meta.label,
                                style: FNTypography.bodySmall.copyWith(
                                  color: isSelected ? meta.primaryColor : FNColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: FNSpacing.xl),

                  // Section: Categorias de Interesse (Interesses)
                  Text(
                    'CATEGORIAS DE INTERESSE',
                    style: FNTypography.label.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: FNSpacing.sm),
                  Text(
                    'Personalize o sinal escolhendo quais tópicos priorizar no seu feed.',
                    style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  
                  // Pegar categorias dos mundos ativos
                  _buildCategoriesSelector(state, notifier),
                  const SizedBox(height: FNSpacing.xl),

                  // Mensagem de feedback
                  if (state.message != null) ...[
                    Text(
                      state.message!,
                      style: FNTypography.bodyMedium.copyWith(
                        color: state.message!.contains('sucesso') ? FNColors.success : FNColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FNSpacing.lg),
                  ],

                  // CTA Button: Salvar Preferências
                  FNButton(
                    label: 'SALVAR_PREFERÊNCIAS',
                    leading: const Icon(LucideIcons.save, size: 16, color: Colors.white),
                    onPressed: state.isSaving ? null : () => notifier.save(),
                    isLoading: state.isSaving,
                    fullWidth: true,
                  ),
                  const SizedBox(height: FNSpacing.xxl),

                  // Danger Zone
                  DangerZone(subscriberId: subscriberId),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoriesSelector(PreferencesState state, PreferencesNotifier notifier) {
    // Coleta todas as categorias exclusivas dos mundos selecionados pelo usuário
    final availableCategories = <String>{};
    for (final world in state.selectedWorlds) {
      availableCategories.addAll(WorldRegistry.get(world).categories);
    }

    if (availableCategories.isEmpty) {
      return Text(
        'Selecione pelo menos um mundo ativo para ver as categorias.',
        style: FNTypography.bodySmall.copyWith(color: FNColors.textMuted),
      );
    }

    return Wrap(
      spacing: FNSpacing.sm,
      runSpacing: FNSpacing.sm,
      children: availableCategories.map((category) {
        final isSelected = state.selectedPreferences.contains(category);

        return GestureDetector(
          onTap: () => notifier.togglePreference(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? FNColors.primaryViolet.withValues(alpha: 0.15)
                  : FNColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? FNColors.primaryViolet : FNColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              category,
              style: FNTypography.bodySmall.copyWith(
                color: isSelected ? FNColors.primaryViolet : FNColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
