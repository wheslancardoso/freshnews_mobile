import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/features/auth/presentation/subscriber_auth_screen.dart';
import 'package:fresh_news_mobile/features/preferences/presentation/preferences_screen.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Se já estiver logado como Administrador, exibe o painel de perfil do editor
    if (authState.isAdmin) {
      return Scaffold(
        backgroundColor: FNColors.background,
        appBar: AppBar(
          title: Text(
            'PERFIL ADMINISTRATIVO',
            style: FNTypography.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FNSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassCard(
                borderRadius: BorderRadius.circular(4),
                borderColor: FNColors.primaryViolet,
                borderWidth: 2.5,
                padding: const EdgeInsets.all(FNSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: FNColors.primaryViolet.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: FNColors.primaryViolet, width: 2),
                      ),
                      child: const Icon(
                        LucideIcons.shield_check,
                        color: FNColors.primaryViolet,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: FNSpacing.xl),
                    Text(
                      'SESSÃO DO EDITOR ATIVA',
                      textAlign: TextAlign.center,
                      style: FNTypography.headingMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: FNSpacing.sm),
                    Text(
                      'Você possui privilégios de administrador neste dispositivo.',
                      textAlign: TextAlign.center,
                      style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
                    ),
                    const SizedBox(height: FNSpacing.xxl),
                    FNButton(
                      label: 'ABRIR_CONSOLE_ADMIN',
                      leading: const Icon(LucideIcons.terminal, size: 16, color: Colors.white),
                      onPressed: () => context.push('/admin'),
                      fullWidth: true,
                    ),
                    const SizedBox(height: FNSpacing.md),
                    FNButton(
                      label: 'LOGOUT_ADMINISTRADOR',
                      variant: FNButtonVariant.outline,
                      primaryColor: FNColors.error,
                      leading: const Icon(LucideIcons.log_out, size: 16, color: FNColors.error),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                      },
                      fullWidth: true,
                    ),
                    const SizedBox(height: FNSpacing.xxl),
                    Text(
                      'Binary BroadSheet // Security Session',
                      textAlign: TextAlign.center,
                      style: FNTypography.bodySmall.copyWith(color: FNColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final subscriberId = ref.watch(subscriberIdProvider);

    if (subscriberId == null) {
      // Se não estiver logado como assinante, exibe a tela de login com link mágico
      return const SubscriberAuthScreen();
    }

    // Se estiver logado, exibe as preferências de forma integrada
    return PreferencesScreen(subscriberId: subscriberId);
  }
}
