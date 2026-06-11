import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_news_mobile/core/constants/categories.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/core/utils/validators.dart';
import 'package:fresh_news_mobile/features/subscribe/application/subscribe_controller.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_input.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class SubscribeSection extends ConsumerStatefulWidget {
  const SubscribeSection({super.key});

  @override
  ConsumerState<SubscribeSection> createState() => _SubscribeSectionState();
}

class _SubscribeSectionState extends ConsumerState<SubscribeSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final activeWorld = ref.read(activeWorldProvider);
    final success = await ref.read(subscribeControllerProvider.notifier).subscribe(
          email: _emailController.text,
          world: activeWorld,
        );

    if (success) {
      _emailController.clear();
      _phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWorld = ref.watch(activeWorldProvider);
    final subscribeState = ref.watch(subscribeControllerProvider);
    final categories = worldCategories[activeWorld] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg, vertical: FNSpacing.xxl),
      child: GlassCard(
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.all(FNSpacing.xl),
        child: subscribeState.isSuccess
            ? _buildSuccessState()
            : _buildForm(activeWorld, categories, subscribeState),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: FNColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: FNColors.success.withValues(alpha: 0.4)),
          ),
          child: const Icon(LucideIcons.check, color: FNColors.success, size: 32),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: FNSpacing.lg),
        Text(
          'INSCRIÇÃO CONFIRMADA',
          style: FNTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: FNSpacing.sm),
        Text(
          'Você receberá as próximas edições diretamente no seu email.',
          style: FNTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: FNSpacing.xl),
        FNButton(
          label: 'NOVA_INSCRICAO',
          onPressed: () => ref.read(subscribeControllerProvider.notifier).reset(),
        ),
      ],
    );
  }

  Widget _buildForm(World activeWorld, List<String> categories, SubscribeState subscribeState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JUNTE-SE AO SINAL',
            style: FNTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: FNSpacing.sm),
          Text(
            'Receba a curadoria de ${activeWorld.config.label} direto no seu email, sem ruído.',
            style: FNTypography.bodyMedium,
          ),
          const SizedBox(height: FNSpacing.xl),
          FNInput(
            controller: _emailController,
            label: 'EMAIL',
            hint: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: FNSpacing.lg),
          FNInput(
            controller: _phoneController,
            label: 'TELEFONE (OPCIONAL)',
            hint: '(00) 00000-0000',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              if (!Validators.isValidPhone(value)) return 'Telefone inválido';
              return null;
            },
          ),
          const SizedBox(height: FNSpacing.xl),
          Text('PREFERÊNCIAS DE CATEGORIA', style: FNTypography.label),
          const SizedBox(height: FNSpacing.md),
          Wrap(
            spacing: FNSpacing.sm,
            runSpacing: FNSpacing.sm,
            children: categories.map((category) {
              final isSelected = subscribeState.selectedCategories.contains(category);
              return GestureDetector(
                onTap: () => ref.read(subscribeControllerProvider.notifier).toggleCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeWorld.config.primaryColor
                        : FNColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.black : FNColors.border,
                      width: 2.0,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    category,
                    style: FNTypography.bodySmall.copyWith(
                      color: isSelected ? Colors.black : FNColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (subscribeState.errorMessage != null) ...[
            const SizedBox(height: FNSpacing.md),
            Text(
              subscribeState.errorMessage!,
              style: FNTypography.bodySmall.copyWith(color: FNColors.error),
            ),
          ],
          const SizedBox(height: FNSpacing.xl),
          FNButton(
            label: 'INSCREVER_AGORA',
            leading: const Icon(LucideIcons.send, size: 16, color: Colors.white),
            onPressed: subscribeState.isLoading ? null : _handleSubmit,
            isLoading: subscribeState.isLoading,
            fullWidth: true,
          ),
          const SizedBox(height: FNSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => context.push('/subscriber-login'),
              child: Text(
                'Já está inscrito? Acesse seu perfil de leitor →',
                style: FNTypography.bodySmall.copyWith(
                  color: activeWorld.config.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: activeWorld.config.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
